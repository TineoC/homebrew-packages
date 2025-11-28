#!/bin/bash

# Set the brew path. Prioritize BREW_PATH if set, otherwise default to Homebrew.
BREW_COMMAND_PATH="${BREW_PATH:-/opt/homebrew/bin}"
export PATH="$BREW_COMMAND_PATH:$PATH"

# Define the path using the absolute, fixed path for user tineoc
REPO_PATH="${1:-/Users/tineoc/Documents/Code/homebrew-packages}"

echo "Navigating to repository..."
cd "$REPO_PATH" || exit

echo "Generating new Homebrew package list..."
brew list > Brewfile.txt

echo "Committing changes..."
git add Brewfile.txt
git commit -m "Automated update of package list on $(date)"

echo "Pushing to GitHub..."
git push

echo "Update complete."
