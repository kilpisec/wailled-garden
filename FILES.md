# Files Reference

Quick reference for each file. Touch only what you need.

## Container Build

| File | Purpose | When to Edit |
|------|---------|--------------|
| `Dockerfile` | Builds the agent image (Debian 12 + tools) | Adding/updating tools, changing base image, modifying installed packages |
| `.bashrc` | Shell config copied into container | Adding aliases, PATH changes, shell customization |

## Container Runtime

| File | Purpose | When to Edit |
|------|---------|--------------|
| `docker-entrypoint.sh` | Runs on container start; sets up symlinks, shows first-run guidance | Changing startup behavior, adding init logic |
| `link-agents.sh` | Creates symlinks from `/aconf` to `~agent/` for config persistence | Adding new agent config dirs to persist |
| `codex-wrapper.sh` | Wraps `codex` to auto-use device auth when needed | Fixing OpenAI auth issues |

## Host Scripts

| File | Purpose | When to Edit |
|------|---------|--------------|
| `run-agent.sh` | Launches container with worktree setup, handles git mounts | Changing worktree logic, container run options, exit notices |

## Documentation/Templates

| File | Purpose | When to Edit |
|------|---------|--------------|
| `README.md` | Human documentation | Updating usage docs |
| `sandbox-base-image-instructions.txt` | Template for agent AGENTS.md/CLAUDE.md files | Changing default agent instructions |
| `AGENTS.md` | This bootstrap for agents | Adding agent guidance |
| `FILES.md` | This file reference | Adding/removing files |
