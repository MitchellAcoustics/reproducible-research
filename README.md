# Research Environment Setup

This repository contains a devcontainer configuration for a reproducible research environment. It's designed to support projects that use Python, R, Quarto, LaTeX, and Typst, with a focus on reproducibility and ease of use.

## Key Features

1. **Reproducibility**: We use specific versions of R and Python to ensure consistency across different machines.
2. **Multi-language Support**: The environment supports both Python and R, along with tools for document preparation (Quarto, LaTeX, Typst).
3. **Version Control**: Git is pre-configured, and we mount the user's `.gitconfig` for personalized settings.
4. **Package Management**: 
   - For Python: We use UV for fast package installation and Rye for project management.
   - For R: We use renv for reproducible package management.
5. **Development Tools**: VSCode is configured with extensions for Python, R, Quarto, LaTeX, and Typst.
6. **Security**: The container runs as a non-root user for improved security.

## Key Choices and Rationale

1. **Base Image**: We use `rocker/r-ver` as our base image. This provides a minimal R installation, which we then build upon.

2. **Python and R Versions**: 
   - We pin specific versions (Python 3.11 and R 4.3.1 by default) for reproducibility.
   - These are set as build arguments, allowing easy updates.

3. **Package Managers**:
   - UV: Chosen for its speed and efficiency in Python package installation.
   - Rye: Used for Python project management, providing a consistent way to manage Python versions and dependencies.
   - renv: Used for R to create reproducible environments.

4. **Document Preparation**:
   - Quarto: A powerful tool for creating dynamic documents that can include both R and Python code.
   - LaTeX: Essential for many academic documents.
   - Typst: A modern alternative to LaTeX, offering easier syntax and faster compilation.

5. **VSCode Extensions**: We include extensions for all our key languages and tools, enhancing the development experience.

6. **Volume Mounts**:
   - We use Docker volumes for Python and R package caches to improve performance across container rebuilds.
   - The user's `.gitconfig` is mounted to personalize Git settings.

7. **Environment Variables**: We set `PYTHONPATH` and `R_LIBS_USER` to ensure correct library paths.

## Usage

1. Ensure you have Docker and VSCode with the Remote - Containers extension installed.
2. Clone this repository.
3. Open the repository in VSCode.
4. Set your preferred Python and R versions in the `devcontainer.json`. Also choose whether the devcontainer should automatically setup renv and uv environments.
5. When prompted, click "Reopen in Container".
6. Wait for the container to build and start. This may take several minutes the first time.

## Customization

- You can modify the Python and R versions by changing the build arguments in the Dockerfile.
- VSCode settings and extensions can be modified in the `devcontainer.json` file.

## Contributing

Contributions to improve this setup are welcome! Please submit a pull request or open an issue to discuss proposed changes.

## License

This project is licensed under the MIT License - see the LICENSE file for details.