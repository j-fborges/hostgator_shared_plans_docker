#!/bin/bash
set -e

echo "⚠️  WARNING: This will delete all containers, volumes, and images."
read -p "Are you sure? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "💥 Destroying Docker environment..."
    docker compose down -v --rmi all
    echo "✅ Environment destroyed."
else
    echo "Cancelled."
fi