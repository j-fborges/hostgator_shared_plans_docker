#!/bin/bash
set -e
echo "========================================="
echo "🚀 Starting HostGator Matching Environment"
echo "========================================="
echo "Ruby version: $(ruby -v)"
echo "Bundler version: $(bundle -v 2>/dev/null || echo 'not installed')"
echo "========================================="
exec "$@"