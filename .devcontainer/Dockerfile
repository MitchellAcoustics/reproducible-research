# Specify R version as a build argument
ARG R_VERSION=4.4.1
FROM rocker/r-ver:${R_VERSION}

# Specify Python version as a build argument
ARG PYTHON_VERSION=3.12

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # python3-pip \
    # python3-venv \
    git \ 
    curl \
    libcurl4-openssl-dev \
    wget \
    jq \
    xz-utils \
    # texlive-base \
    # texlive-latex-extra \
    # texlive-fonts-recommended \
    # texlive-publishers \
    # texlive-science \
    pandoc \ 
    libicu-dev \
    libxml2-dev \
    sudo \
    zsh \
    fonts-powerline \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# tlmgr setup
# RUN curl -L -o install-tl-unx.tar.gz https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz
# RUN zcat < install-tl-unx.tar.gz | tar xf -
# RUN cd install-tl-*
# RUN perl ./install-tl --no-interaction
# RUN export PATH=/usr/local/texlive/2024/bin/x86_64-linux:$PATH
# RUN tlmgr init-usertree
RUN wget -qO- "https://yihui.org/tinytex/install-bin-unix.sh" | sh

# ENV PATH="/usr/local/texlive/2024/bin/x86_64-linux:${PATH}"
ENV PATH="/root/bin:${PATH}"
RUN tlmgr init-usertree

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
RUN curl -LsSf https://astral.sh/uv/0.4.6/install.sh | sh && \
    mv /root/.cargo/bin/uv /usr/local/bin/uv

# Configure Git
RUN git config --system core.autocrlf input

# Create directories for environments
RUN mkdir -p /opt/python_env /opt/r_env

# Set up environment variables
ENV PATH="/usr/local/bin:/root/.rye/shims:${PATH}" \
    UV_HOME="/opt/python_env" \
    R_LIBS_USER="/opt/r_env" \
    RENV_PATHS_ROOT="/opt/r_env" \
    RENV_PATHS_LIBRARY="/opt/r_env/library" 

RUN uv python install ${PYTHON_VERSION}

# Install renv
RUN R --quiet -e "install.packages('renv', repos = 'https://cloud.r-project.org/')"

# Configure renv
# approach one https://rstudio.github.io/renv/articles/docker.html
ENV RENV_SETTINGS_USE_CACHE FALSE
ENV RENV_CONFIG_PAK_ENABLED TRUE

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

# Set the working directory
WORKDIR /workspace

# Note: Python packages will be installed in the project's 
# virtual environment during the post-create command