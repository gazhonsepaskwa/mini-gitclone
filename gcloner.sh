#!/bin/bash

# Use default username if not provided as an argument
USERNAME="${1:-gazhonsepaskwa}"

# Fetch the list of repositories using GitHub API and sort by creation date (descending)
REPO_LIST=$(curl -s "https://api.github.com/users/$USERNAME/repos?sort=created&direction=desc" | jq -r '.[] | .name')

# Check if jq is installed
if ! command -v jq &>/dev/null; then
  echo "Error: jq is not installed. Please install jq to use this script."
  exit 1
fi

# If no repositories found, exit
if [ -z "$REPO_LIST" ]; then
  echo "No repositories found for user $USERNAME."
  exit 1
fi

# List repositories with numbers
echo "Repositories for $USERNAME (most recent first):"
REPO_ARRAY=()
i=0
while read -r repo; do
  REPO_ARRAY+=("$repo")
  echo "$i) $repo"
  ((i++))
done <<<"$REPO_LIST"

# Prompt user to choose a repository
echo "Enter the number of the repository you want to clone:"
read -r CHOICE

# Validate input
if ! [[ $CHOICE =~ ^[0-9]+$ ]] || [ "$CHOICE" -lt 0 ] || [ "$CHOICE" -ge "${#REPO_ARRAY[@]}" ]; then
  echo "Invalid choice. Please enter a number between 0 and $((${#REPO_ARRAY[@]} - 1))."
  exit 1
fi

# Get the name of the selected repository
REPO_NAME=${REPO_ARRAY[$CHOICE]}

# Get the current working directory
CURRENT_DIR=$(pwd)

# Clone the selected repository into the current directory
echo "Cloning repository: $REPO_NAME into $CURRENT_DIR..."
git clone "https://github.com/$USERNAME/$REPO_NAME.git" "$CURRENT_DIR/$REPO_NAME"
