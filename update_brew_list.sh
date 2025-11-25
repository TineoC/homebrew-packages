#!/bin/bash

# Define the path to your repository
REPO_PATH="$HOME/Documents/Code/homebrew-packages"

echo "Navigating to repository..."
cd "$REPO_PATH" || exit

echo "Generating new Homebrew package list..."
brew list > Brewfile.txt

echo "Committing changes..."
git add Brewfile.txt
# Use 'date' for a dynamic commit message
git commit -m "Automated update of package list on $(date)"

echo "Pushing to GitHub..."
git push

echo "Update complete."

