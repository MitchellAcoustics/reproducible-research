#!/bin/bash

set -euo pipefail

echo "Starting environment setup..."

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Python setup
echo "Setting up Python environment..."

if [ -f "pyproject.toml" ] && [ -f "requirements.lock" ]; then
    echo "Rye project detected."
    if command_exists rye; then
        echo "Using Rye for environment management."
        rye sync
        rye add jupyter ipykernel
        rye run python -m ipykernel install --user --name=project_kernel
    else
        echo "Rye not found. Falling back to uv with venv."
        uv venv
        source .venv/bin/activate
        uv pip install -r requirements.lock
        [ -f "requirements-dev.lock" ] && uv pip install -r requirements-dev.lock
        uv pip install jupyter ipykernel
        python -m ipykernel install --user --name=project_kernel
    fi
elif [ -f ".venv/pyvenv.cfg" ]; then
    echo "Existing venv detected. Assuming uv was used."
    source .venv/bin/activate
    if [ -f "requirements.txt" ]; then
        uv pip install -r requirements.txt
    fi
    uv pip install jupyter ipykernel
    python -m ipykernel install --user --name=project_kernel
elif [ -f "requirements.txt" ]; then
    echo "requirements.txt found. Creating new environment with uv."
    uv venv
    source .venv/bin/activate
    uv pip install -r requirements.txt
    uv pip install jupyter ipykernel
    python -m ipykernel install --user --name=project_kernel
else
    echo "No Python environment configuration found. Creating a basic environment."
    uv venv
    source .venv/bin/activate
    uv pip install jupyter ipykernel
    python -m ipykernel install --user --name=project_kernel
fi

# R setup
if command_exists R; then
    echo "Setting up R environment..."
    
    # Initialize renv if renv.lock exists, otherwise create a new project
    if [ -f "renv.lock" ]; then
        echo "Existing renv.lock found. Restoring packages..."
        R --quiet -e "renv::restore()"
    else
        echo "No renv.lock found. Initializing new renv project..."
        R --quiet -e "renv::init()"
    fi
else
    echo "R not found. Please install R or check your PATH."
fi

echo "Environment setup complete!"