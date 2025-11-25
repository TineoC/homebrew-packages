#!/bin/bash

export PATH="/opt/homebrew/bin:$PATH"

# Define the path using the absolute, fixed path for user tineoc
REPO_PATH="/Users/tineoc/Documents/Code/homebrew-packages"

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
