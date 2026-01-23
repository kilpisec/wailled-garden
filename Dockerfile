FROM debian:12

# Metadata labels
LABEL maintainer="gabriel@kilpi.tech"
LABEL description="Base AI agent image with OpenAI, Anthropic Claude Code, and Google Gemini CLI tools"
LABEL version="1.0"

# Set locale environment
ENV LANG="C.UTF-8" \
    LC_ALL="C.UTF-8"

# do the heavy apt-get early so we can reuse it as much as possible
RUN apt-get update
RUN apt-get install -y vim command-not-found sudo ripgrep \
  iptables less \
  git \
  procps \
  sudo \
  fzf \
  zsh \
  man-db \
  unzip \
  gnupg2 \
  gh \
  iptables \
  ipset \
  iproute2 \
  dnsutils \
  aggregate \
  jq \
  nano \
  vim \
  command-not-found \
  dnsdist \
  python3 \
  python3-pip \
  python3-venv \
  curl \ 
  bat \
  tree \
  fd-find 

RUN apt-file update
RUN echo "agent ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Create non-root user for security
RUN useradd -m -s /bin/bash agent && \
    mkdir -p /home/agent/.config && \
    chown -R agent:agent /home/agent

RUN mkdir -p /opt/agent-base-image

# install go
ARG TARGETARCH
RUN echo $TARGETARCH
RUN curl -L -o go1.25.5.linux-$TARGETARCH.tar.gz https://go.dev/dl/go1.25.5.linux-$TARGETARCH.tar.gz && tar -C /usr/local -xzf go1.25.5.linux-$TARGETARCH.tar.gz

# Switch to non-root user
USER agent

# Set working directory
WORKDIR /workspace

# install node via nvm
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash && \
    bash -c 'source ~/.nvm/nvm.sh && nvm install 24 && nvm use 24'

# install bun
RUN curl -fsSL https://bun.sh/install | bash

# install uv
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# install claude
# this is from the official script except it does not run the install part because that creates .claude
RUN set -e && \
    ARCH=$([ "$TARGETARCH" = "amd64" ] && echo "x64" || echo "arm64") && \
    GCS="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases" && \
    VERSION=$(curl -fsSL "$GCS/latest") && \
    mkdir -p ~/.local/bin && \
    curl -fsSL -o ~/.local/bin/claude "$GCS/$VERSION/linux-$ARCH/claude" && \
    chmod +x ~/.local/bin/claude

# Copy and set up entrypoint script for auth handling
COPY --chown=agent:agent --chmod=744 docker-entrypoint.sh /opt/agent-base-image/docker-entrypoint.sh
COPY --chown=agent:agent --chmod=744 link-agents.sh /opt/agent-base-image/link-agents.sh
COPY --chown=agent:agent --chmod=755 codex-wrapper.sh /opt/agent-base-image/codex-wrapper.sh
COPY --chown=agent:agent --chmod=444 sandbox-base-image-instructions.txt /opt/agent-base-image/sandbox-base-image-instructions.txt
COPY --chown=agent:agent .bashrc /home/agent/.bashrc

# Volume for persistent configuration
VOLUME ["/home/agent/.config"]

# Default command - interactive zsh shell
CMD ["/bin/bash"]

# Set entrypoint to handle authentication
ENTRYPOINT ["/opt/agent-base-image/docker-entrypoint.sh"]

RUN echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

