#!/bin/bash
set -e

echo "▶️ Starting Docker environment..."
docker compose up -d
echo "✅ Environment started. Services:"
docker compose ps

sleep 2

echo "🔌 Opening bash shell in the app container..."
echo "Type 'exit' to leave the shell (containers will keep running)."
docker compose exec app bash