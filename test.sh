#!/bin/bash

# This script tests the update_brew_list.sh script in a sandboxed environment.

set -e # Exit immediately if a command exits with a non-zero status.

echo "🧪 Starting test..."

# --- Setup ---
# Create a temporary directory for the test environment.
TEST_DIR=$(mktemp -d)
echo "📂 Test environment created at: $TEST_DIR"

# Create a directory for the "remote" bare repository.
REMOTE_REPO_DIR="$TEST_DIR/remote.git"
git init --bare "$REMOTE_REPO_DIR"

# Clone the bare repository to create a "local" repository.
LOCAL_REPO_DIR="$TEST_DIR/local"
git clone "$REMOTE_REPO_DIR" "$LOCAL_REPO_DIR"

# Configure the local repository.
cd "$LOCAL_REPO_DIR"
git config user.name "Test Bot"
git config user.email "test@example.com"

# Create an initial Brewfile and commit it.
echo "initial-package" > Brewfile.txt
git add Brewfile.txt
git commit -m "Initial commit"
# Find the default branch name and push the initial commit.
DEFAULT_BRANCH=$(git symbolic-ref --short HEAD)
git push origin "$DEFAULT_BRANCH"

# Mock the 'brew' command by creating a fake script.
# This makes the test faster and independent of the actual Homebrew installation.
FAKE_BIN_DIR="$TEST_DIR/bin"
mkdir -p "$FAKE_BIN_DIR"
echo '#!/bin/bash' > "$FAKE_BIN_DIR/brew"
echo 'echo "updated-package-1"' >> "$FAKE_BIN_DIR/brew"
echo 'echo "updated-package-2"' >> "$FAKE_BIN_DIR/brew"
chmod +x "$FAKE_BIN_DIR/brew"

echo "✅ Setup complete."

# --- Execution ---
echo "🚀 Running update_brew_list.sh against the test environment..."
# Path to the script we are testing.
SCRIPT_PATH="/Users/tineoc/Documents/Code/homebrew-packages/update_brew_list.sh"
# Execute the script, passing the local test repo path as an argument.
BREW_PATH="$FAKE_BIN_DIR" bash "$SCRIPT_PATH" "$LOCAL_REPO_DIR"

# --- Verification ---
echo "🔍 Verifying results..."

# 1. Verify a new commit was created with the correct message.
LATEST_COMMIT_MSG=$(git log -1 --pretty=%B)
EXPECTED_SUBSTRING="Automated update of package list"

if [[ "$LATEST_COMMIT_MSG" != *"$EXPECTED_SUBSTRING"* ]]; then
    echo "❌ Test Failed: Commit message mismatch."
    echo "   Expected substring: '$EXPECTED_SUBSTRING'"
    echo "   Actual message: '$LATEST_COMMIT_MSG'"
    exit 1
fi
echo "✔️  New commit found with the correct message."

# 2. Verify the Brewfile.txt content was updated.
EXPECTED_CONTENT=$'updated-package-1\nupdated-package-2'
ACTUAL_CONTENT=$(cat Brewfile.txt)

# Compare content, ignoring potential trailing newlines.
if [[ "$(echo -n "$ACTUAL_CONTENT")" != "$(echo -n "$EXPECTED_CONTENT")" ]]; then
    echo "❌ Test Failed: Brewfile.txt content mismatch."
    echo "   Expected:"
    printf "%s\n" "$EXPECTED_CONTENT"
    echo "   Actual:"
    printf "%s\n" "$ACTUAL_CONTENT"
    exit 1
fi
echo "✔️  Brewfile.txt was updated correctly."

# 3. Verify the commit was pushed to the remote repository.
REMOTE_LATEST_COMMIT_SHA=$(git -C "$REMOTE_REPO_DIR" rev-parse "$DEFAULT_BRANCH")
LOCAL_LATEST_COMMIT_SHA=$(git rev-parse HEAD)

if [[ "$REMOTE_LATEST_COMMIT_SHA" != "$LOCAL_LATEST_COMMIT_SHA" ]]; then
    echo "❌ Test Failed: Commit was not pushed to the remote."
    exit 1
fi
echo "✔️  Commit was successfully pushed to the remote."

# --- Cleanup ---
echo "🧹 Cleaning up..."
rm -rf "$TEST_DIR"
echo "Test environment removed."

echo "✅✅✅ All tests passed! The automation script works as expected."
