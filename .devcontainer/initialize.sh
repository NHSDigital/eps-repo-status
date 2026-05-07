#!/usr/bin/env bash
set -euo pipefail

echo 'running initialization command'

if ! command -v docker &> /dev/null; then
    echo "Error: Docker CLI is not installed or not available on PATH. Please install Docker and ensure the \`docker\` command is available before running initialize." >&2
    exit 1
fi

if ! command -v gh &> /dev/null; then
    echo "Error: gh CLI is not installed. Please install it in your WSL instance from https://cli.github.com/" >&2
    exit 1
fi
if gh auth status --json hosts --jq '.hosts["github.com"][0].scopes' 2>/dev/null | grep -q 'read:packages'; then 
    echo 'gh auth already has read:packages scope'
else 
    gh auth login --web --git-protocol ssh --skip-ssh-key --scopes read:packages
fi

echo "Authenticating to ghcr.io with gh CLI credentials..."
GITHUB_USERNAME=$(gh api user --jq '.login')

gh auth token | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin
