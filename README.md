# wAIlled garden - AI Agent Base Image


## What?

Base docker image with OpenAI, Anthropic Claude Code, and Google Gemini CLI tools.

Project also includes helper scripts to quickly create a worktree and jump into the container.

## Why?

If you ever played with the agents, you quickly notice that if you have to approve every command, you need to carefully monitor them and approve things. But hopefully you aren't crazy enough to enabling `yolo` mode on a real computer.

The solution is to put them into a sandbox. A container is not watertight, but for most purposes and it's more than enough. 

This project is my little attempt to create a container and some tooling to make this process easier.

## Quick Start

You can either use the container directly like this.

```bash
# With persistent agent configuration
docker run -it --rm -v agents:/aconf -v ./workspace:/workspace agent-base-image

# Without persistence (configurations lost on exit, you will need to authenticate unless you pass API keys as env variables)
docker run -it --rm -v ./workspace:/workspace agent-base-image
```

or you can use the helper script.

## run-agent.sh

Or you can use the helper script that will prompt you for a worktree and create that for ensuring the agent does not wreack too much havoc.

```bash
./run-agent.sh
```

Defaults:
- Worktree path: `~/.agent-worktrees/<repo>`
- Branch: `agent/<repo>` (created on first run)

Options:
- `AGENT_ENGINE` - the container engine (default `podman`)
- `AGENT_IMAGE` - the container image (default `agent-base-image`)
- `AGENT_CONFIG_VOLUME` - the config volume name (default `agents`)
- `AGENT_WORKTREE_BASE` - the base worktree path (default `~/.agent-worktrees`)
- `AGENT_NO_WORKTREE=1` - disable worktree creation

On exit, the helper checks the worktree for uncommitted changes and notes if the worktree branch has commits not on the branch you launched from (when available). It never deletes anything automatically.

## Inside the container

- `codex` and `gemini` will be installed and run on demand with `bunx` to ensure they are the latest versions. `claude` is a standalone nowadays and handles that itself.
- `codex`  is aliased to `codex-wrapper.sh`, a little wrapper to default to --device-auth if we don't have auth.json because codex normal oauth is really buggy. 

## Agent Configurations

The container persists agent configuration and history in `/aconf` which is symlinked to `/home/agent/` on startup:
- `/aconf/.claude` → `/home/agent/.claude`
- `/aconf/.codex` → `/home/agent/.codex`
- `/aconf/.gemini` → `/home/agent/.gemini`
- `/aconf/.claude.json` → `/home/agent/.claude.json`
