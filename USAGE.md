# AI Agent Docker Image - Usage Guide

## Overview
This is a small sandbox image designed to run agents. It will use a shared volume for storing your sessoions and histories. 

## Key Features
- **Smaller image size**: Uses `node:20-slim` (~700MB smaller than full image)
- **Persistent auth**: Support for Docker/Podman secrets and volume mounts
- **Security**: Runs as non-root user `agent`
- **Flexible**: Can be used as a base image or run directly

## Host Helper Script (Git Worktrees)

If your agent tooling keys off the project path, use `run-agent.sh` to mount a repo-specific git worktree instead of the same `/workspace` every time.

```bash
./run-agent.sh
```

Configuration (environment variables):
- `AGENT_WORKTREE_BASE` (default `~/.agent-worktrees`)
- `AGENT_NO_WORKTREE=1` to disable worktree creation
- `AGENT_ENGINE` (default `podman`)
- `AGENT_IMAGE` (default `agent-base-image`)
- `AGENT_CONFIG_VOLUME` (default `agents`)

Pass extra container options before `--`, and a command after it:

```bash
./run-agent.sh -- -lc "pwd && ls"
```

On exit, the helper warns about uncommitted changes and notes if the worktree branch is ahead of the branch you launched from (when available). It never deletes anything automatically.

## Authentication Methods

### Option 1: Docker/Podman Secrets (Recommended)

Create secret files:
```bash
# Docker
echo "your-openai-key" | docker secret create openai_api_key -
echo "your-anthropic-key" | docker secret create anthropic_api_key -
echo "your-google-key" | docker secret create google_api_key -

# Podman
echo "your-openai-key" > openai_api_key
echo "your-anthropic-key" > anthropic_api_key
echo "your-google-key" > google_api_key
```

Run with secrets:
```bash
# Docker
docker run -it \
  --secret openai_api_key \
  --secret anthropic_api_key \
  --secret google_api_key \
  ai-agent-base

# Podman
podman run -it \
  --secret openai_api_key \
  --secret anthropic_api_key \
  --secret google_api_key \
  ai-agent-base
```

### Option 2: Environment Variables

```bash
docker run -it \
  -e OPENAI_API_KEY="your-openai-key" \
  -e ANTHROPIC_API_KEY="your-anthropic-key" \
  -e GOOGLE_API_KEY="your-google-key" \
  ai-agent-base
```

### Option 3: Persistent Volume Mount

```bash
# First run to set up auth (use either secrets or env vars)
docker run -it \
  -v ai-agent-config:/home/agent/.config \
  --secret anthropic_api_key \
  ai-agent-base

# Subsequent runs will reuse the config
docker run -it \
  -v ai-agent-config:/home/agent/.config \
  ai-agent-base
```

## Docker Compose Example

```yaml
version: '3.8'
services:
  ai-agent:
    build: .
    secrets:
      - openai_api_key
      - anthropic_api_key
      - google_api_key
    volumes:
      - ai-config:/home/agent/.config
      - ./workspace:/workspace
    stdin_open: true
    tty: true

secrets:
  openai_api_key:
    file: ./secrets/openai_api_key
  anthropic_api_key:
    file: ./secrets/anthropic_api_key
  google_api_key:
    file: ./secrets/google_api_key

volumes:
  ai-config:
```

## Using as a Base Image

```dockerfile
FROM ai-agent-base

# Add your custom tools or configurations
RUN npm install -g your-custom-package

# Your custom setup
COPY your-scripts /workspace/scripts

# Override CMD if needed
CMD ["your-command"]
```

## Building the Image

```bash
# Docker
docker build -t ai-agent-base .

# Podman
podman build -t ai-agent-base .
```

## Notes

- All API keys are optional - only configure the tools you need
- The entrypoint script will automatically detect and configure available keys
- Config persists in `/home/agent/.config` (mount as volume for persistence)
- Working directory is `/workspace` for your projects
- Runs as user `agent` (UID typically 1000) for security
