# Start from the rocker/r-ver image which includes only R
FROM rocker/r-ver:latest

# Install system dependencies including texlive-base
RUN apt-get update && apt-get install -y \
    python3-pip \
    python3-venv \
    git \ 
    curl \
    libcurl4-openssl-dev \
    wget \
    jq \
    texlive-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-publishers \
    texlive-science \
    && rm -rf /var/lib/apt/lists/*

# Dynamically fetch and install the latest version of Quarto
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then QUARTO_ARCH="linux-amd64"; \
    elif [ "$ARCH" = "arm64" ]; then QUARTO_ARCH="linux-arm64"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    QUARTO_VERSION=$(curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest | jq -r '.tag_name') && \
    curl -L "https://github.com/quarto-dev/quarto-cli/releases/download/${QUARTO_VERSION}/quarto-${QUARTO_VERSION#v}-${QUARTO_ARCH}.deb" -o quarto.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# Install Typst for modern document preparation
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then TYPST_ARCH="x86_64"; \
    elif [ "$ARCH" = "arm64" ]; then TYPST_ARCH="aarch64"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    curl -LO "https://github.com/typst/typst/releases/latest/download/typst-${TYPST_ARCH}-unknown-linux-musl.tar.xz" && \
    tar -xvf typst-${TYPST_ARCH}-unknown-linux-musl.tar.xz && \
    mv typst-${TYPST_ARCH}-unknown-linux-musl/typst /usr/local/bin/ && \
    rm -rf typst-${TYPST_ARCH}-unknown-linux-musl*

# Set up a non-root user (recommended for security)
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && apt-get update \
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Create R library directory for the non-root user
RUN mkdir -p /home/${USERNAME}/R/library \
    && chown -R ${USERNAME}:${USERNAME} /home/${USERNAME}/R

# Install UV for Python environment management (alternative to pip)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.cargo/bin/uv /usr/local/bin/uv && \
    chown ${USERNAME}:${USERNAME} /usr/local/bin/uv

# Install Rye for Python project management
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash && \
    chown -R ${USERNAME}:${USERNAME} /root/.rye && \
    mv /root/.rye /home/${USERNAME}/.rye

# Set up Git to use the correct user
RUN git config --system core.autocrlf input

# Switch to the non-root user
USER $USERNAME

# Configure Git for the non-root user
RUN git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name"


# Add UV and Rye to PATH
ENV PATH="/usr/local/bin:${PATH}:/home/${USERNAME}/.rye/shims"

# Set R library path for the non-root user
ENV R_LIBS_USER="/home/${USERNAME}/R/library"

# Set the working directory
WORKDIR /workspace

# Note: Python packages (including Jupyter) will be installed in the project's 
# virtual environment during the post-create command, not globally in the container