# Specify R version as a build argument
ARG R_VERSION=4.4.1
FROM rocker/r-ver:${R_VERSION}

# Specify Python version as a build argument
ARG PYTHON_VERSION=3.12

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3-pip \
    python3-venv \
    git \ 
    curl \
    libcurl4-openssl-dev \
    wget \
    jq \
    xz-utils \
    texlive-base \
    texlive-latex-extra \
    texlive-fonts-recommended \
    texlive-publishers \
    texlive-science \
    sudo \
    zsh \
    fonts-powerline \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Quarto
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then QUARTO_ARCH="linux-amd64"; \
    elif [ "$ARCH" = "arm64" ]; then QUARTO_ARCH="linux-arm64"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    QUARTO_VERSION=$(curl -s https://api.github.com/repos/quarto-dev/quarto-cli/releases/latest | jq -r '.tag_name') && \
    curl -L "https://github.com/quarto-dev/quarto-cli/releases/download/${QUARTO_VERSION}/quarto-${QUARTO_VERSION#v}-${QUARTO_ARCH}.deb" -o quarto.deb && \
    dpkg -i quarto.deb && \
    rm quarto.deb

# Install Typst
RUN ARCH=$(dpkg --print-architecture) && \
    if [ "$ARCH" = "amd64" ]; then TYPST_ARCH="x86_64"; \
    elif [ "$ARCH" = "arm64" ]; then TYPST_ARCH="aarch64"; \
    else echo "Unsupported architecture: $ARCH" && exit 1; fi && \
    curl -LO "https://github.com/typst/typst/releases/latest/download/typst-${TYPST_ARCH}-unknown-linux-musl.tar.xz" && \
    tar -xvf typst-${TYPST_ARCH}-unknown-linux-musl.tar.xz && \
    mv typst-${TYPST_ARCH}-unknown-linux-musl/typst /usr/local/bin/ && \
    rm -rf typst-${TYPST_ARCH}-unknown-linux-musl*

# Install UV
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.cargo/bin/uv /usr/local/bin/uv

# Install Rye and set up global shims
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash && \
    echo 'source "$HOME/.rye/env"' >> ~/.bashrc && \
    /root/.rye/shims/rye config --set-bool behavior.global-python=true && \
    /root/.rye/shims/rye config --set-bool behavior.use-uv=true

# Configure Git
RUN git config --system core.autocrlf input

# Create directories for environments
RUN mkdir -p /opt/python_env /opt/r_env

# Set up environment variables
ENV PATH="/usr/local/bin:/root/.rye/shims:${PATH}" \
    RYE_HOME="/opt/python_env"
# R_LIBS_USER="/opt/r_env" \
# RENV_PATHS_ROOT="/opt/r_env" \
# RENV_PATHS_LIBRARY="/opt/r_env/library" \

# Install renv
RUN R --quiet -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Set zsh as the default shell
SHELL ["/bin/zsh", "-c"]

# Set the working directory
WORKDIR /workspace

# Note: Python packages will be installed in the project's 
# virtual environment during the post-create command