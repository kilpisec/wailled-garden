#!/bin/bash
# this is a simple helper script to provide some helpful guidance for the user
set -e

# Set up agent symlinks to the shared agent volume volume
/opt/agent-base-image/link-agents.sh

# Check if /aconf is mounted
if ! mountpoint -q /aconf 2>/dev/null; then
    echo "NOTE: /aconf is not mounted. You might loose history and you will have to log in again with each agent. To maintain history and logins across sessions:"
    echo " Use: -v agents:/aconf"
fi

# Check if this is the first run
FIRST_RUN_MARKER="/aconf/.initialized"
if [ ! -f "${FIRST_RUN_MARKER}" ]; then
    echo "Use 'claude' or 'codex' commands to get started. See README for configuration."
    INSTRUCTIONS_SRC="/opt/agent-base-image/sandbox-base-image-instructions.txt"
    if [ -t 0 ]; then
        echo "It's good to tell inform the agent it is in a sandbox and can do anything. Here is a sample AGENT.md"
        echo "--------------"
        cat "$INSTRUCTIONS_SRC"
        echo "--------------"
        read -r -p "Do you want to create a AGENTS.md with these instructions? [y/N] " reply
        case "$reply" in
            y|Y)
                if [ ! -f "/aconf/.claude/CLAUDE.md" ]; then
                    cp "$INSTRUCTIONS_SRC" /aconf/.claude/CLAUDE.md
                    echo "Created /aconf/.claude/CLAUDE.md"
                else
                    echo "/aconf/.claude/CLAUDE.md exists (not overwriting)"
                fi
                if [ ! -f "/aconf/.codex/AGENTS.md" ]; then
                    cp "$INSTRUCTIONS_SRC" /aconf/.codex/AGENTS.md
                    echo "Created /aconf/.codex/AGENTS.md"
                else
                    echo "/aconf/.codex/AGENTS.md exists (not overwriting)"
                fi
                if [ ! -f "/aconf/.gemini/GEMINI.md" ]; then
                    cp "$INSTRUCTIONS_SRC" /aconf/.gemini/GEMINI.md
                    echo "Created /aconf/.gemini/GEMINI.md"
                else
                    echo "/aconf/.gemini/GEMINI.md exists (not overwriting)"
                fi
                ;;
            *)
                echo "Skipped. It's usually useful to add instructions to AGENTS.md to inform the agent it is a sandbox and can work more freely but I trust you know what you're doing." >&2
                ;;
        esac
    fi
    touch "${FIRST_RUN_MARKER}" 2>/dev/null || true
fi

# Change to project directory if it exists
if [ -n "${PROJECT_NAME:-}" ] && [ -d "/workspace/$PROJECT_NAME" ]; then
    cd "/workspace/$PROJECT_NAME"
fi

# Execute the main command
exec "$@"
