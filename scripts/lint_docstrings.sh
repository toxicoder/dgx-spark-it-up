#!/bin/bash

# Lint Bash script docstrings for compliance with project standards.
# This script checks that all functions, sub-shells, and global variables
# have properly formatted docstrings with required sections.

set -euo pipefail

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m' # No Color

# error - Print an error message to stderr.
#
# Displays a formatted error message with red color prefix to stderr.
#
# Parameters:
#   message (String) - The error message to display.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   None - This function does not produce errors.
error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# warning - Print a warning message to stderr.
#
# Displays a formatted warning message with yellow color prefix to stderr.
#
# Parameters:
#   message (String) - The warning message to display.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   None - This function does not produce errors.
warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1" >&2
}

# success - Print a success message to stdout.
#
# Displays a formatted success message with green color prefix to stdout.
#
# Parameters:
#   message (String) - The success message to display.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   None - This function does not produce errors.
success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# check_file - Verify file exists and is readable.
#
# Checks if a file exists, is readable, and appears to be a Bash script.
#
# Parameters:
#   file (String) - The path to the file to check.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   1 - File does not exist.
#   2 - File is not readable.
check_file() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        error "File does not exist: $file"
        return 1
    fi
    
    if [[ ! -r "$file" ]]; then
        error "File is not readable: $file"
        return 1
    fi
    
    # Check if it's a Bash script
    if [[ "$(head -n1 "$file")" != "#!/bin/bash" ]] && [[ "$(head -n1 "$file")" != "#!/usr/bin/env bash" ]]; then
        warning "File does not appear to be a Bash script: $file"
    fi
    
    return 0
}

# validate_function_docstring - Validate the structure of a function's docstring.
#
# Checks if a function's docstring contains all required components: summary, description, parameters, returns, and errors.
#
# Parameters:
#   file (String) - The path to the Bash script file.
#   function_name (String) - The name of the function being validated.
#   start_line (Integer) - The starting line number of the docstring.
#   end_line (Integer) - The ending line number of the docstring.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   None - This function does not produce errors, but may issue warnings for incomplete docstrings.
validate_function_docstring() {
    local file="$1"
    local function_name="$2"
    local start_line="$3"
    local end_line="$4"
    
    # Extract the docstring lines
    local docstring_lines=()
    local i
    for ((i=start_line; i<=end_line; i++)); do
        local line
        line=$(sed -n "${i}p" "$file")
        docstring_lines+=("$line")
    done
    
    # Check for required components
    local has_summary=false
    local has_blank_line=false
    local has_description=false
    local has_params=false
    local has_returns=false
    local has_errors=false
    
    local in_params=false
    local in_returns=false
    local in_errors=false
    
    local line_num=0
    for line in "${docstring_lines[@]}"; do
        ((line_num++))
        
        # Skip empty lines at the beginning
        if [[ -z "$line" ]] && [[ $line_num -eq 1 ]]; then
            continue
        fi
        
        # Check for one-line summary (first non-empty line)
        if [[ $line_num -eq 1 ]] && [[ "$line" =~ ^#.*[^.]$ ]]; then
            # Check if it's a proper one-line summary (starts with uppercase verb/noun, ends with period)
            if [[ "$line" =~ ^#[[:space:]]*[A-Z][a-zA-Z].*\.$ ]]; then
                has_summary=true
            else
                warning "Function $function_name has incomplete one-line summary: $line"
            fi
        fi
        
        # Check for blank line separator (line with just #)
        if [[ "$line" == "#"* ]] && [[ -z "${line#'#'}" ]]; then
            has_blank_line=true
        fi
        
        # Check for parameters section
        if [[ "$line" =~ ^#[[:space:]]*@?Parameters? ]]; then
            in_params=true
            has_params=true
        fi
        
        # Check for returns section
        if [[ "$line" =~ ^#[[:space:]]*@?Returns? ]]; then
            in_returns=true
            has_returns=true
        fi
        
        # Check for errors section
        if [[ "$line" =~ ^#[[:space:]]*@?Errors? ]]; then
            in_errors=true
            has_errors=true
        fi
        
        # Check that parameters/returns/errors lines end with periods
        if [[ $in_params == true ]] && [[ "$line" =~ ^#[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[^#].*[[:space:]]*[^.]$ ]]; then
            warning "Parameter line missing period: $line"
        fi
        
        if [[ $in_returns == true ]] && [[ "$line" =~ ^#[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[^#].*[[:space:]]*[^.]$ ]]; then
            warning "Return line missing period: $line"
        fi
        
        if [[ $in_errors == true ]] && [[ "$line" =~ ^#[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[[:space:]]*[^#].*[[:space:]]*[^.]$ ]]; then
            warning "Error line missing period: $line"
        fi
        
        # Reset section flags
        if [[ "$line" =~ ^#[[:space:]]*[^[:space:]] ]] && [[ $line_num -gt 1 ]]; then
            in_params=false
            in_returns=false
            in_errors=false
        fi
    done
    
    # If we have a docstring but it's incomplete, report it
    if [[ ${#docstring_lines[@]} -gt 0 ]] && [[ $has_summary == false ]]; then
        warning "Function $function_name has docstring without proper summary"
    fi
    
    return 0
}

# lint_bash_file - Check docstring compliance for a single Bash file.
#
# Validates that all functions in a Bash script have properly formatted docstrings according to project standards.
#
# Parameters:
#   file (String) - The path to the Bash script file to lint.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   1 - File does not exist or is not readable.
lint_bash_file() {
    local file="$1"
    
    echo "Checking docstring compliance for: $file"
    
    # Check file existence
    if ! check_file "$file"; then
        return 1
    fi
    
    # Use grep to find function definitions and their docstrings
    local function_lines=()
    local line_num=0
    
    # Get all function lines with line numbers
    while IFS= read -r line || [[ -n "$line" ]]; do
        ((line_num++))
        
        # Match function definitions
        if [[ "$line" =~ ^[[:space:]]*function[[:space:]]+([a-zA-Z_][a-zA-Z0-9_]*)[[:space:]]*\(\) ]]; then
            local func_name="${BASH_REMATCH[1]}"
            echo "Found function: $func_name at line $line_num"
            
            # Find the function docstring
            # Look backwards for docstring lines
            local docstring_start=0
            local i=$((line_num - 1))
            while [[ $i -ge 1 ]]; do
                local prev_line
                prev_line=$(sed -n "${i}p" "$file")
                if [[ "$prev_line" =~ ^#[[:space:]]* ]]; then
                    if [[ $docstring_start -eq 0 ]]; then
                        docstring_start=$i
                    fi
                elif [[ "$prev_line" =~ ^[[:space:]]*$ ]]; then
                    # Empty line - continue searching
                    :
                else
                    # Non-comment line - stop looking
                    break
                fi
                ((i--))
            done
            
            if [[ $docstring_start -gt 0 ]]; then
                echo "  Found docstring starting at line $docstring_start"
                # Find where docstring ends
                local docstring_end=$line_num
                local j=$((line_num + 1))
                while [[ $j -le $(wc -l < "$file") ]]; do
                    local next_line
                    next_line=$(sed -n "${j}p" "$file")
                    if [[ "$next_line" =~ ^[[:space:]]*[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(\) ]]; then
                        # Another function definition - docstring ends before this
                        break
                    elif [[ "$next_line" =~ ^[[:space:]]*# ]]; then
                        docstring_end=$j
                    else
                        # Non-comment line - stop
                        break
                    fi
                    ((j++))
                done
                
                echo "  Docstring covers lines $docstring_start-$docstring_end"
                validate_function_docstring "$file" "$func_name" "$docstring_start" "$docstring_end"
            fi
        fi
    done < "$file"
    
    echo "Finished checking $file"
    return 0
}

# main - Main entry point for the docstring linting script.
#
# Processes command line arguments and runs docstring validation on specified files or all .sh files in the repository.
#
# Parameters:
#   None - This function takes command line arguments for specific files to check.
#
# Returns:
#   0 on success, non-zero exit code on failure.
#
# Errors:
#   1 - Found files with docstring issues.
#   2 - General processing error.
main() {
    local files_to_check=()
    
    # If arguments provided, check those files
    if [[ $# -gt 0 ]]; then
        files_to_check=("$@")
    else
        # Find all .sh files in repository (excluding hidden directories)
        mapfile -t files_to_check < <(find . -type f -name "*.sh" -not -path "./.*" -not -path "./.git/*" 2>/dev/null)
    fi
    
    echo "Running docstring linting on ${#files_to_check[@]} files..."
    
    local total_errors=0
    
    for file in "${files_to_check[@]}"; do
        if [[ -f "$file" ]] && [[ -r "$file" ]]; then
            if ! lint_bash_file "$file"; then
                ((total_errors++))
            fi
        fi
    done
    
    if [[ $total_errors -eq 0 ]]; then
        success "All docstrings compliant"
        exit 0
    else
        error "Found $total_errors files with docstring issues"
        exit 1
    fi
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi