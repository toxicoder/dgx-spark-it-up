#!/usr/bin/env bash

# Strictly fail on errors, unassigned variables, and pipe failures
set -euo pipefail

# ==============================================================================
# Throttled Ollama Pull Script
# ==============================================================================
# Description:
#   A wrapper script to download Ollama models while limiting network bandwidth.
#   Uses 'wondershaper' (kernel-level traffic control) to prevent Ollama from
#   consuming all available local network bandwidth. Automatically clears limits
#   when finished or if the script is interrupted (Ctrl+C). Includes a pre-check
#   to skip models that are already fully downloaded.
#
# Requirements:
#   - sudo privileges
#   - ollama installed and running
#   - wondershaper (script will attempt to auto-install if missing)
#
# Note on Speeds:
#   Network speeds are in Megabits (Mbps), not Megabytes (MB/s). 
#   To calculate your limit: 1 MB/s = 8 Mbps. (e.g., 5 MB/s = 40 Mbps).
#
# Flags:
#   -d <mbps>     : [Required] Set download speed limit in Mbps.
#   -u <mbps>     : [Optional] Set upload speed limit in Mbps (Defaults to uncapped).
#   -m <model>    : Specify a model to download. Can be used multiple times.
#   -f <file.txt> : Specify a text file with model names (one per line). 
#                   Supports multiple files. Ignores empty lines and '#' comments.
#   -c            : CLEAR MODE. Instantly removes all bandwidth limits and exits.
#   -h            : Show the help menu.
#
# Examples:
#   1. Download a single model at 40 Mbps (5 MB/s):
#      ./throttled_ollama.sh -d 40 -m llama3
#
#   2. Download multiple models with specific upload/download limits:
#      ./throttled_ollama.sh -d 80 -u 20 -m mistral -m phi3
#
#   3. Download a queue of models from a text file:
#      ./throttled_ollama.sh -d 50 -f my_models.txt
#
#   4. Emergency Kill-Switch (if your internet gets stuck throttled):
#      ./throttled_ollama.sh -c
# ==============================================================================

# ==========================================
# Configuration & Constants
# ==========================================

readonly SCRIPT_NAME="$(basename "$0")"
readonly DEFAULT_UPLOAD_MBPS=100000
readonly BANDWIDTH_UNIT_MULTIPLIER=1000
readonly USAGE_MSG="Throttled Ollama Pull Script

Description:
  A wrapper script to download Ollama models while limiting network bandwidth.

Requirements:
  - sudo privileges
  - ollama installed and running
  - wondershaper (script will attempt to auto-install if missing)

Flags:
  -d <mbps>     : [Required] Set download speed limit in Mbps.
  -u <mbps>     : [Optional] Set upload speed limit in Mbps (Defaults to uncapped).
  -m <model>    : Specify a model to download. Can be used multiple times.
  -f <file.txt> : Specify a text file with model names (one per line).
                  Supports multiple files. Ignores empty lines and '#' comments.
  -c            : CLEAR MODE. Instantly removes all bandwidth limits and exits.
  -h            : Show the help menu.

Examples:
  1. Download a single model at 40 Mbps (5 MB/s):
     ${SCRIPT_NAME} -d 40 -m llama3

  2. Download multiple models with specific upload/download limits:
     ${SCRIPT_NAME} -d 80 -u 20 -m mistral -m phi3

  3. Download a queue of models from a text file:
     ${SCRIPT_NAME} -d 50 -f my_models.txt

  4. Emergency Kill-Switch (if your internet gets stuck throttled):
     ${SCRIPT_NAME} -c
"

# ==========================================
# Validation Module
# ==========================================

_validate_download_limit() {
    local limit="$1"
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
        echo "[X] Error: Download limit must be a positive integer." >&2
        exit 1
    fi
}

_validate_upload_limit() {
    local limit="$1"
    if ! [[ "$limit" =~ ^[0-9]+$ ]]; then
        echo "[X] Error: Upload limit must be a positive integer." >&2
        exit 1
    fi
}

_validate_models_provided() {
    local -n models_ref=$1
    if [[ ${#models_ref[@]} -eq 0 ]]; then
        echo "[X] Error: No valid models found to download."
        echo "$USAGE_MSG"
        exit 1
    fi
}

_validate_interface_detected() {
    local interface="$1"
    if [[ -z "$interface" ]]; then
        echo "[X] Error: Could not detect active network interface." >&2
        exit 1
    fi
}

# ==========================================
# Interface Management Module
# ==========================================

_get_active_interface() {
    ip route get 1.1.1.1 2>/dev/null | awk '{print $5; exit}'
}

_validate_interface_usable() {
    local interface="$1"
    if ! ip link show "$interface" &>/dev/null; then
        echo "[X] Error: Interface '$interface' is not available." >&2
        exit 1
    fi
}

_format_bandwidth_display() {
    local down_mbps="$1"
    local up_mbps="$2"

    if [[ "$up_mbps" -eq "$DEFAULT_UPLOAD_MBPS" ]]; then
        echo "[i] Applying limits -> Download: ${down_mbps} Mbps | Upload: Uncapped"
    else
        echo "[i] Applying limits -> Download: ${down_mbps} Mbps | Upload: ${up_mbps} Mbps"
    fi
}

# ==========================================
# Model Management Module
# ==========================================

_normalize_model_name() {
    local model="$1"
    if [[ "$model" != *:* ]]; then
        echo "${model}:latest"
    else
        echo "$model"
    fi
}

_get_installed_models() {
    ollama list 2>/dev/null | awk 'NR>1 {print $1}'
}

_is_model_installed() {
    local model="$1"
    local installed_models="$2"
    
    if echo "$installed_models" | grep -qx "$model"; then
        return 0
    fi
    return 1
}

_pull_single_model() {
    local model="$1"
    local normalized_name
    normalized_name=$(_normalize_model_name "$model")
    
    if _is_model_installed "$normalized_name" "$(_get_installed_models)"; then
        echo "[i] Model '$model' is already installed. Skipping..."
        echo "-----------------------------------------"
        return 0
    fi

    echo "[->] Starting download for: $model"
    
    if ! ollama pull "$model"; then
        echo "[!] Warning: Failed to pull model '$model'. Moving to the next one..." >&2
        return 1
    else
        echo "[OK] Finished pulling: $model"
        echo "-----------------------------------------"
        return 0
    fi
}

_process_models_file() {
    local file="$1"
    local -n models_ref=$2
    
    if [[ ! -f "$file" ]]; then
        echo "[X] Error: File '$file' not found." >&2
        exit 1
    fi
    
    echo "[i] Reading models from file: $file"
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        # Remove carriage returns and trim whitespace
        line=$(echo "$line" | tr -d '\r' | xargs || true)
        
        # Skip empty lines and comments
        if [[ -n "$line" && ! "$line" =~ ^# ]]; then
            models_ref+=("$line")
        fi
    done < "$file"
}

# ==========================================
# Dependency Management Module
# ==========================================

_check_wondershaper_installed() {
    command -v wondershaper &>/dev/null
}

_detect_package_manager() {
    if command -v apt-get &>/dev/null; then
        echo "apt"
    elif command -v pacman &>/dev/null; then
        echo "pacman"
    elif command -v dnf &>/dev/null; then
        echo "dnf"
    else
        echo ""
    fi
}

_install_wondershaper_apt() {
    echo "[i] Installing wondershaper via apt-get..."
    sudo apt-get update && sudo apt-get install -y wondershaper
}

_install_wondershaper_pacman() {
    echo "[i] Installing wondershaper via pacman..."
    sudo pacman -S --noconfirm wondershaper
}

_install_wondershaper_dnf() {
    echo "[i] Installing wondershaper via dnf..."
    sudo dnf install -y wondershaper
}

_install_wondershaper() {
    if _check_wondershaper_installed; then
        return 0
    fi
    
    echo "[!] wondershaper not found. Attempting to install..."
    
    local pkg_manager
    pkg_manager=$(_detect_package_manager)
    
    case "$pkg_manager" in
        apt)  _install_wondershaper_apt ;;
        pacman)  _install_wondershaper_pacman ;;
        dnf)  _install_wondershaper_dnf ;;
        *)
            echo "[X] Unsupported package manager. Please install wondershaper manually." >&2
            exit 1
            ;;
    esac
}

# ==========================================
# Bandwidth Control Module
# ==========================================

_apply_bandwidth_limits() {
    local interface="$1"
    local down_mbps="$2"
    local up_mbps="$3"

    local down_kbps=$(( down_mbps * BANDWIDTH_UNIT_MULTIPLIER ))
    local up_kbps=$(( up_mbps * BANDWIDTH_UNIT_MULTIPLIER ))

    _format_bandwidth_display "$down_mbps" "$up_mbps"
    
    sudo wondershaper "$interface" "$down_kbps" "$up_kbps"
}

_clear_bandwidth_limits() {
    local interface="$1"
    
    echo -e "\n[Cleanup] Removing bandwidth limits from ${interface}..."
    
    if _check_wondershaper_installed; then
        sudo wondershaper clear "${interface}" &>/dev/null || true
        echo "[i] Limits cleared. Exiting safely."
    else
        echo "[i] Wondershaper not installed, no limits to clear."
    fi
}

_register_cleanup_handlers() {
    local interface="$1"
    trap '_clear_bandwidth_limits "$interface"' EXIT INT TERM HUP
}

# ==========================================
# Argument Parsing Module
# ==========================================

_show_usage() {
    echo "$USAGE_MSG"
}

# Parse command arguments. Returns 0 on success, 1 on error, and exits on -h/--help
# Sets: down_ref, up_ref, models_ref, clear_only_ref, help_requested_ref
_parse_command_args() {
    local -n down_ref=$1
    local -n up_ref=$2
    local -n models_ref=$3
    local -n clear_only_ref=$4
    local -n help_requested_ref=$5
    
    help_requested_ref=false
    
    # Shift past the 5 nameref parameter names to get to actual arguments
    shift 5
    
    # Now $1, $2, etc. refer to the actual command-line arguments
    local -a actual_args=("$@")
    
    # Handle long options and -h before getopts
    for arg in "${actual_args[@]}"; do
        case "$arg" in
            --help|--usage|-h)
                help_requested_ref=true
                _show_usage
                return 0
                ;;
        esac
    done
    
    # Filter out --help, --usage, -h for getopts processing
    local -a filtered_args=()
    for arg in "${actual_args[@]}"; do
        case "$arg" in
            --help|--usage|-h) continue ;;
            *) filtered_args+=("$arg") ;;
        esac
    done
    
    # Now parse remaining args with getopts
    if [[ ${#filtered_args[@]} -gt 0 ]]; then
        local OPTIND
        while getopts "cd:u:m:f:h" opt "${filtered_args[@]}"; do
            case "${opt}" in
                c) clear_only_ref=true ;;
                d) 
                    _validate_download_limit "${OPTARG}"
                    down_ref="${OPTARG}" 
                    ;;
                u) 
                    _validate_upload_limit "${OPTARG}"
                    up_ref="${OPTARG}" 
                    ;;
                m) models_ref+=("${OPTARG}") ;;
                f) _process_models_file "${OPTARG}" models_ref ;;
                h) 
                    help_requested_ref=true
                    return 0
                    ;;
                *) 
                    return 1
                    ;;
            esac
        done
    fi
    
    return 0
}

# ==========================================
# Main Entry Point
# ==========================================

_main() {
    local down_mbps=""
    local up_mbps="$DEFAULT_UPLOAD_MBPS"
    local models_queue=()
    local clear_only=false
    local help_requested=false

    # 1. Parse Arguments
    _parse_command_args down_mbps up_mbps models_queue clear_only help_requested "$@"

    # Exit immediately if help was requested
    if [[ "$help_requested" == true ]]; then
        exit 0
    fi

    # 2. Handle Emergency Clear Failsafe (-c)
    if [[ "$clear_only" == true ]]; then
        local active_interface
        active_interface=$(_get_active_interface)
        _validate_interface_detected "$active_interface"
        _clear_bandwidth_limits "$active_interface"
        exit 0
    fi

    # 3. Validate Required Inputs for Normal Operation
    if [[ -z "$down_mbps" ]]; then
        echo "[X] Error: Download limit (-d) is required unless using (-c) to clear limits."
        echo "$USAGE_MSG"
        exit 1
    fi

    _validate_models_provided models_queue

    # 4. Setup Dependencies & Interface
    _install_wondershaper
    
    local active_interface
    active_interface=$(_get_active_interface)
    _validate_interface_detected "$active_interface"
    _validate_interface_usable "$active_interface"
    
    echo "[i] Detected active internet interface: $active_interface"

    # 5. Register the Cleanup Trap
    _register_cleanup_handlers "$active_interface"

    # 6. Execute Core Logic
    _apply_bandwidth_limits "$active_interface" "$down_mbps" "$up_mbps"
    
    local success=true
    for model in "${models_queue[@]}"; do
        if ! _pull_single_model "$model"; then
            success=false
        fi
    done
    
    echo "[i] All model downloads in queue complete."
    
    if [[ "$success" == false ]]; then
        echo "[!] Some models failed to download. Check the output above." >&2
        exit 1
    fi
}

_main "$@"