#!/bin/bash
set -e

echo "🚀 Setting up Docker environment..."

# Build images (if not already built)
docker compose build

# Start all services in detached mode
docker compose up -d

# Wait a moment for containers to fully start
sleep 5

# Run database setup inside the app container (if applicable)
echo "Running database setup..."
docker compose exec app bundle exec rails db:create db:migrate db:seed 2>/dev/null || echo "Database setup skipped (maybe not needed)."

echo "✅ Environment ready!"
echo "   Access your app at http://localhost:3000"
echo "   To open a shell in the app container: docker compose exec app bash"