#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Treat unset variables as an error when substituting.
set -u

# Pipe failure will result in script exit
set -o pipefail

# Function to log messages
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to handle errors
handle_error() {
    log "Error occurred in script at line: ${1}. Exit code: ${2}"
    exit 1
}

# Set up error handling
trap 'handle_error ${LINENO} $?' ERR

log "Starting environment setup..."

# Python setup
log "Setting up Python environment..."

setup_python_env() {
    if [ -f "pyproject.toml" ]; then
        log "pyproject.toml found. Using Rye for environment setup."
        if ! rye sync; then
            log "Error: Failed to sync Python environment with Rye."
            return 1
        fi
    elif [ -f "requirements.lock" ]; then
        log "requirements.lock found. Setting up venv with locked dependencies."
        rye init . --virtual
        source .venv/bin/activate
        if ! rye sync; then
            log "Error: Failed to install dependencies from requirements.lock."
            return 1
        fi
    elif [ -f "requirements.txt" ]; then
        log "requirements.txt found. Setting up venv with listed dependencies."
        rye init . --virtual
        source .venv/bin/activate
        if ! uv pip install -r requirements.txt; then
            log "Error: Failed to install dependencies from requirements.txt."
            return 1
        fi
    else
        log "No Python project files found. Setting up a basic environment."
        rye init . --virtual
        if ! rye add jupyter ipykernel numpy pandas matplotlib; then
            log "Error: Failed to install basic packages."
            return 1
        fi
        rye sync
        source .venv/bin/activate
    fi

    # Install Jupyter and ipykernel if not already installed
    if ! python -m pip list | grep -q jupyter; then
        if ! rye add jupyter ipykernel; then
            log "Error: Failed to install Jupyter and ipykernel."
            return 1
        fi
    fi

    return 0
}

if ! setup_python_env; then
    log "Python environment setup failed."
    exit 1
fi

log "Python environment setup complete."

# R setup
log "Setting up R environment..."

setup_r_env() {
    if [ -f "renv.lock" ]; then
        log "renv.lock found. Restoring R environment."
        if ! R --quiet -e "renv::restore()"; then
            log "Error: Failed to restore R environment with renv."
            return 1
        fi
    else
        log "No renv.lock found. Initializing new renv project."
        if ! R --quiet -e "renv::init()"; then
            log "Error: Failed to initialize renv project."
            return 1
        fi
    fi

    return 0
}

if ! setup_r_env; then
    log "R environment setup failed."
    exit 1
fi

log "R environment setup complete."

log "Environment setup completed successfully!"