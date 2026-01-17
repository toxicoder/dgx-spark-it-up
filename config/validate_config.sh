#!/bin/bash

# Configuration Validation Script
# Validates that all ports are within the 10000-20000 range and checks for conflicts

set -e  # Exit on any error

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/port_config.txtpb"

# Function to validate port range (10000-20000)
validate_port_range() {
    echo "Validating port range (10000-20000)..."
    
    local invalid_ports=()
    
    # Read the config file and validate each port
    while IFS= read -r line; do
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        # Parse key:value pairs
        if [[ "$line" =~ ^([^:]+):[[:space:]]*(.*)$ ]]; then
            key="${BASH_REMATCH[1]# }"
            value="${BASH_REMATCH[2]# }"
            
            # Only validate numeric ports (not API keys)
            if [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -ge 10000 ]] && [[ "$value" -le 20000 ]]; then
                echo "✓ $key: $value (valid)"
            elif [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -lt 10000 || "$value" -gt 20000 ]]; then
                echo "✗ $key: $value (OUT OF RANGE - must be 10000-20000)"
                invalid_ports+=("$key:$value")
            fi
        fi
    done < "$CONFIG_FILE"
    
    if [ ${#invalid_ports[@]} -eq 0 ]; then
        echo "All ports are within the valid range!"
        return 0
    else
        echo "Found ${#invalid_ports[@]} invalid ports:"
        for port in "${invalid_ports[@]}"; do
            echo "  $port"
        done
        return 1
    fi
}

# Function to check for port conflicts
check_port_conflicts() {
    echo ""
    echo "Checking for port conflicts..."
    
    # Get all port values from config
    local ports=()
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        if [[ "$line" =~ ^([^:]+):[[:space:]]*(.*)$ ]]; then
            key="${BASH_REMATCH[1]# }"
            value="${BASH_REMATCH[2]# }"
            
            if [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -ge 10000 ]] && [[ "$value" -le 20000 ]]; then
                ports+=("$value")
            fi
        fi
    done < "$CONFIG_FILE"
    
    # Sort ports and check for duplicates
    local sorted_ports=($(printf '%s\n' "${ports[@]}" | sort -n))
    local duplicates=()
    
    for ((i=0; i<${#sorted_ports[@]}-1; i++)); do
        if [[ "${sorted_ports[i]}" == "${sorted_ports[i+1]}" ]]; then
            duplicates+=("${sorted_ports[i]}")
        fi
    done
    
    if [ ${#duplicates[@]} -eq 0 ]; then
        echo "No duplicate ports found!"
        return 0
    else
        echo "Duplicate ports found:"
        for dup in "${duplicates[@]}"; do
            echo "  $dup"
        done
        return 1
    fi
}

# Function to check if ports are in use
check_ports_in_use() {
    echo ""
    echo "Checking if ports are already in use..."
    
    local in_use=()
    
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ -z "$line" ]] && continue
        
        if [[ "$line" =~ ^([^:]+):[[:space:]]*(.*)$ ]]; then
            key="${BASH_REMATCH[1]# }"
            value="${BASH_REMATCH[2]# }"
            
            if [[ "$value" =~ ^[0-9]+$ ]] && [[ "$value" -ge 10000 ]] && [[ "$value" -le 20000 ]]; then
                if lsof -i :"$value" >/dev/null 2>&1; then
                    echo "⚠ $key: $value (PORT IN USE)"
                    in_use+=("$key:$value")
                else
                    echo "✓ $key: $value (available)"
                fi
            fi
        fi
    done < "$CONFIG_FILE"
    
    if [ ${#in_use[@]} -eq 0 ]; then
        echo "All ports are available!"
        return 0
    else
        echo "Warning: ${#in_use[@]} ports are already in use:"
        for port in "${in_use[@]}"; do
            echo "  $port"
        done
        return 1
    fi
}

# Main validation function
main() {
    echo "=== Port Configuration Validation ==="
    echo "Configuration file: $CONFIG_FILE"
    echo ""
    
    local all_valid=true
    
    # Validate port range
    if ! validate_port_range; then
        all_valid=false
    fi
    
    # Check for duplicates
    if ! check_port_conflicts; then
        all_valid=false
    fi
    
    # Check if ports are in use
    if ! check_ports_in_use; then
        all_valid=false
    fi
    
    echo ""
    if [ "$all_valid" = true ]; then
        echo "✓ All validations passed!"
        exit 0
    else
        echo "✗ Some validations failed!"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi