#!/bin/bash
# Wrapper script for codex to handle authentication in container environments
# Automatically uses device auth flow when no authentication is present

# Only intervene if:
# 1. No auth.json file exists
# 2. No OPENAI_API_KEY is set
# 3. User ran plain 'codex' with no arguments

if [ ! -f "$HOME/.codex/auth.json" ] && [ -z "$OPENAI_API_KEY" ] && [ $# -eq 0 ]; then
    exec bunx @openai/codex@latest login --device-auth
else
    exec bunx @openai/codex@latest "$@"
fi
