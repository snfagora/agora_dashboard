#!/bin/bash

# Set up variables
SITE_DIR="_site"
DOCS_DIR="docs"
REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
REMOTE_URL=$(git config --get remote.origin.url || true)
GITHUB_USER=""

if [[ -n "$REMOTE_URL" ]]; then
  if [[ "$REMOTE_URL" =~ github.com[:/](.+)/.+(\.git)?$ ]]; then
    GITHUB_USER="${BASH_REMATCH[1]}"
  fi
fi

# Render the Quarto project
echo "Rendering Quarto project..."
quarto render

# Check if rendering was successful
if [ $? -ne 0 ]; then
    echo "Error: Quarto render failed."
    exit 1
fi

# Create the docs folder if it doesn't exist
echo "Creating 'docs' folder..."
mkdir -p $DOCS_DIR

# Move the rendered files from _site to docs/
echo "Copying rendered files to 'docs' folder..."
cp -r $SITE_DIR/* $DOCS_DIR/

# Add the changes to git
echo "Adding changes to Git..."
git add $DOCS_DIR

# Commit the changes
echo "Committing changes..."
git commit -m "Deploy Quarto dashboard to GitHub Pages"

# Push the changes to GitHub
echo "Pushing changes to GitHub..."
git push

# Output the GitHub Pages URL
echo "GitHub Pages site is now live at:"
if [[ -n "$GITHUB_USER" ]]; then
  echo "https://${GITHUB_USER}.github.io/${REPO_NAME}/"
else
  echo "https://<your-username>.github.io/${REPO_NAME}/"
fi

# End of script
