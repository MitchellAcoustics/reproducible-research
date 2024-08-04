# Specify R version as a build argument
ARG R_VERSION=4.4.1
FROM rocker/r-ver:${R_VERSION}

# Specify Python version as a build argument
ARG PYTHON_VERSION=3.12

# Install system dependencies including texlive-base, xz-utils, and zsh
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

# Set up the 'vscode' user
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

# Create R library and renv directories for the vscode user
RUN mkdir -p /home/$USERNAME/R/library \
    && mkdir -p /home/$USERNAME/.renv \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/R \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.renv


# Install UV for Python environment management (alternative to pip)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh && \
    mv /root/.cargo/bin/uv /usr/local/bin/uv && \
    chown $USERNAME:$USERNAME /usr/local/bin/uv

# Install Rye for Python project management
RUN curl -sSf https://rye.astral.sh/get | RYE_INSTALL_OPTION="--yes" bash && \
    chown -R $USERNAME:$USERNAME /root/.rye && \
    mv /root/.rye /home/$USERNAME/.rye

# Set up Git to use the correct user
RUN git config --system core.autocrlf input

# Set R library path
ENV R_LIBS_USER="/home/$USERNAME/R/library"

# Install renv as root
RUN R --quiet -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Switch to vscode user for further configuration
USER $USERNAME

# Configure renv
RUN echo 'options(renv.settings.use.cache = FALSE)' >> /home/$USERNAME/.Rprofile
RUN echo 'Sys.setenv(RENV_PATHS_ROOT = "/home/vscode/.renv")' >> /home/$USERNAME/.Rprofile
RUN echo 'Sys.setenv(RENV_PATHS_LIBRARY = "/workspace/.renv/library")' >> /home/$USERNAME/.Rprofile

# Install oh-my-zsh and plugins
USER $USERNAME
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Configure zsh
RUN sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc \
    && echo 'export TERM=xterm-256color' >> ~/.zshrc

# Set zsh as the default shell for vscode user
USER root
RUN chsh -s /usr/bin/zsh $USERNAME

# Switch back to the vscode user
USER $USERNAME

# Add UV and Rye to PATH
ENV PATH="/usr/local/bin:${PATH}:/home/$USERNAME/.rye/shims"

# Set the working directory
WORKDIR /workspace

# Note: Python packages (including Jupyter) will be installed in the project's 
# virtual environment during the post-create command, not globally in the container