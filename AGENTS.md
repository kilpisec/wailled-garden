# Agent Instructions

This repo builds a Docker image for running AI coding agents (Claude, Codex, Gemini) in isolated worktrees.

## Quick Context

- **Purpose**: Container image + helper scripts for sandboxed AI agent sessions
- **Stack**: Debian 12, bash scripts, Dockerfile
- **See**: [FILES.md](FILES.md) for file-by-file reference

## For Agents Working Here

1. **Build changes** - Edit `Dockerfile` for new tools/dependencies
2. **Runtime behavior** - Edit `docker-entrypoint.sh` or `link-agents.sh`
3. **Host-side changes** - Edit `run-agent.sh` (worktree/container launch logic)
4. **Test changes** - Build with `podman build -t agent-base-image .` or `docker build -t agent-base-image .`

## Key Concepts

- `/aconf` volume persists agent configs across sessions
- Worktrees isolate agent work from main repo
- `codex-wrapper.sh` handles OpenAI auth edge cases
