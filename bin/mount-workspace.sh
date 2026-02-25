#!/bin/bash
set -e

WORKSPACE_DIR="$(cd "$(dirname "$0")/.." && pwd)/workspace"

# Create workspace if it doesn't exist
if [ ! -d "$WORKSPACE_DIR" ]; then
    echo "📁 Creating workspace directory at $WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR"
fi

# Optionally create a sample project placeholder
SAMPLE_PROJECT="$WORKSPACE_DIR/sample-app"
if [ ! -d "$SAMPLE_PROJECT" ]; then
    echo "📦 Creating sample-app placeholder (you can replace with your own project)"
    mkdir -p "$SAMPLE_PROJECT"
    echo "# Sample Rails App" > "$SAMPLE_PROJECT/README.md"
fi

echo "✅ Workspace is ready at $WORKSPACE_DIR"
echo "   Your docker-compose.yml should mount this directory, e.g.:"
echo "   volumes:"
echo "     - ./workspace:${APP_ROOT}${RAILS_PROJECTS_FOLDER}"