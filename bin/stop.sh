#!/bin/bash
set -e

echo "⏹️ Stopping Docker environment..."
docker compose down
echo "✅ Environment stopped."