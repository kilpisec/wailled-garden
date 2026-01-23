# AI Agent Base Image

Base Docker image with OpenAI, Anthropic Claude Code, and Google Gemini CLI tools.

## Quick Start

```bash
# With persistent agent configuration
docker run -it --rm -v agents:/aconf -v ./workspace:/workspace agent-base-image

# Without persistence (configurations lost on exit)
docker run -it --rm -v ./workspace:/workspace agent-base-image
```

**Note:** Use `-v agents:/aconf` to persist agent logins, history, and configurations across container sessions.

## Using Secrets

Configure API keys using Docker/Podman secrets or environment variables.

### Docker Secrets

Create secret files:
```bash
echo "your-openai-key" > openai_api_key.txt
echo "your-anthropic-key" > anthropic_api_key.txt
echo "your-google-key" > google_api_key.txt
```

Run with secrets:
```bash
docker run -it \
  --secret openai_api_key,src=openai_api_key.txt \
  --secret anthropic_api_key,src=anthropic_api_key.txt \
  --secret google_api_key,src=google_api_key.txt \
  agent-base-image
```

### Podman Secrets

Create secrets:
```bash
podman secret create openai_api_key openai_api_key.txt
podman secret create anthropic_api_key anthropic_api_key.txt
podman secret create google_api_key google_api_key.txt
```

Run with secrets:
```bash
podman run -it \
  --secret openai_api_key \
  --secret anthropic_api_key \
  --secret google_api_key \
  agent-base-image
```

### Environment Variables

```bash
docker run -it \
  -e OPENAI_API_KEY="your-key" \
  -e ANTHROPIC_API_KEY="your-key" \
  -e GOOGLE_API_KEY="your-key" \
  agent-base-image
```

## Agent Configurations

The container stores agent configurations in `/aconf` which is symlinked to `/home/agent/`:
- `/aconf/.claude` → `/home/agent/.claude`
- `/aconf/.codex` → `/home/agent/.codex`
- `/aconf/.gemini` → `/home/agent/.gemini`
- `/aconf/.claude.json` → `/home/agent/.claude.json`

Use a named volume to persist across sessions:
```bash
docker run -it --rm -v agents:/aconf agent-base-image
```

## CLI Aliases

- `claude` - runs `bunx @anthropic-ai/claude-code`
- `codex` - runs `bunx @anthropic-ai/codex`
