#!/bin/bash

set -e

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
    
    # Ensure R_LIBS_USER is set and the directory exists
    R_LIBS_USER=${R_LIBS_USER:-"/home/vscode/R/library"}
    mkdir -p "$R_LIBS_USER"
    
    # Ensure renv is installed
    R --quiet -e "if (!requireNamespace('renv', quietly = TRUE)) install.packages('renv', lib = Sys.getenv('R_LIBS_USER'), repos = 'https://cloud.r-project.org/')"
    
    # Initialize or restore renv
    if [ -f "renv.lock" ]; then
        echo "Existing renv.lock found. Restoring packages..."
        R --quiet -e "renv::restore()"
    else
        echo "No renv.lock found. Initializing renv..."
        R --quiet -e "renv::init()"
    fi
    
    # Install pak if not already installed
    R --quiet -e "if (!requireNamespace('pak', quietly = TRUE)) renv::install('pak')"
    
    # Create or update .Rprofile
    echo "Configuring .Rprofile..."
    if [ -f ".Rprofile" ]; then
        echo "Existing .Rprofile found. Ensuring renv and pak configurations are present..."
        if ! grep -q "renv.config.pak.enabled" .Rprofile; then
            echo "options(renv.config.pak.enabled = TRUE)" >> .Rprofile
        fi
        if ! grep -q "source(\"renv/activate.R\")" .Rprofile; then
            echo "source(\"renv/activate.R\")" >> .Rprofile
        fi
    else
        cat << EOF > .Rprofile
options(renv.config.pak.enabled = TRUE)
source("renv/activate.R")
EOF
    fi
else
    echo "R not found. Please install R or check your PATH."
fi

echo "Environment setup complete!"