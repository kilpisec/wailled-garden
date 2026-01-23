#!/bin/bash
set -e

# Script to symlink .claude, .codex directories and .claude.json from /aconf to /home/agent/
# This allows mounting agent configurations into the Docker container

# Create /aconf if it doesn't exist
mkdir -p /aconf

# Create .claude directory in /aconf if it doesn't exist
mkdir -p /aconf/.claude

# Create .codex directory in /aconf if it doesn't exist
mkdir -p /aconf/.codex

# Create .gemini directory in /aconf if it doesn't exist
mkdir -p /aconf/.gemini

# Create .claude.json if it doesn't exist
touch /aconf/.claude.json

# Create symlinks (will fail if files already exist, which is fine for a fresh container)
ln -s /aconf/.claude /home/agent/.claude 2>/dev/null || true
ln -s /aconf/.codex /home/agent/.codex 2>/dev/null || true
ln -s /aconf/.gemini /home/agent/.gemini 2>/dev/null || true
ln -s /aconf/.claude.json /home/agent/.claude.json 2>/dev/null || true
