FROM node:20

ARG TZ=UTC
ENV TZ="$TZ"

ARG CLAUDE_CODE_VERSION=latest
ARG ZSH_IN_DOCKER_VERSION=1.2.0
ARG PYTHON_VERSION=3.12.10

# System packages: dev tools + iptables/ipset for firewall + pyenv build deps
# default-jre-headless: required by allure CLI
RUN apt-get update && apt-get install -y --no-install-recommends \
  less git procps sudo fzf zsh man-db unzip gnupg2 \
  gh iptables ipset iproute2 dnsutils aggregate jq nano vim \
  make build-essential libssl-dev zlib1g-dev libbz2-dev \
  libreadline-dev libsqlite3-dev wget curl llvm \
  libncurses5-dev libncursesw5-dev xz-utils tk-dev \
  libffi-dev liblzma-dev python3-openssl \
  default-jre-headless \
  && apt-get clean && rm -rf /var/lib/apt/lists/*

# just — task runner (https://just.systems). Installed system-wide as root.
RUN curl -fsSL https://just.systems/install.sh | bash -s -- --to /usr/local/bin \
  && just --version

# npm global dir — writable by node user
RUN mkdir -p /usr/local/share/npm-global && \
  chown -R node:node /usr/local/share

ENV DEVCONTAINER=true

RUN mkdir -p /workspace /home/node/.claude && \
  chown -R node:node /workspace /home/node/.claude

WORKDIR /workspace

USER node

ENV NPM_CONFIG_PREFIX=/usr/local/share/npm-global
ENV PATH=$PATH:/usr/local/share/npm-global/bin
ENV SHELL=/bin/zsh
ENV EDITOR=nano

# pyenv — install as node user so it lives in /home/node/.pyenv
ENV PYENV_ROOT="/home/node/.pyenv"
ENV PATH="$PYENV_ROOT/bin:$PYENV_ROOT/shims:$PATH"
RUN curl -fsSL https://pyenv.run | bash

# Install Python via pyenv and set as global default
RUN pyenv install ${PYTHON_VERSION} && pyenv global ${PYTHON_VERSION}

# Poetry — installed into the pyenv Python; no --break-system-packages needed
RUN pip install --no-cache-dir poetry==2.3.2

# Oh-my-zsh with Powerlevel10k theme
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v${ZSH_IN_DOCKER_VERSION}/zsh-in-docker.sh)" -- \
  -p git \
  -p fzf \
  -a "source /usr/share/doc/fzf/examples/key-bindings.zsh" \
  -a "source /usr/share/doc/fzf/examples/completion.zsh" \
  -a "export PYENV_ROOT=\"/home/node/.pyenv\"" \
  -a "export PATH=\"\$PYENV_ROOT/bin:\$PYENV_ROOT/shims:\$PATH\"" \
  -a "eval \"\$(pyenv init -)\"" \
  -x

# Claude Code
RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_CODE_VERSION}

# Allure CLI — requires JRE (installed above via default-jre-headless)
RUN npm install -g allure-commandline

# Bake project-controlled Claude aliases into Oh-my-zsh custom dir.
# No host bind-mount dependency — reproduced identically on any machine.
# COPY uses build context (.devcontainer/), so the file must live there.
COPY --chown=node:node claude.zsh /home/node/.oh-my-zsh/custom/claude.zsh

# Firewall
COPY init-firewall.sh /usr/local/bin/
USER root
RUN chmod +x /usr/local/bin/init-firewall.sh && \
  echo "node ALL=(root) NOPASSWD: /usr/local/bin/init-firewall.sh" > /etc/sudoers.d/node-firewall && \
  chmod 0440 /etc/sudoers.d/node-firewall
USER node
