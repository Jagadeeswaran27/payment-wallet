#!/bin/bash

# =============================================================================
# Clean Script - Removes all build artifacts and caches
# Usage: ./scripts/clean.sh
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${BLUE}🧹 Cleaning Paytem Wallet Project...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Flutter clean
echo -e "${YELLOW}► Running flutter clean...${NC}"
flutter clean

# Remove Dart tool cache
echo -e "${YELLOW}► Removing .dart_tool...${NC}"
rm -rf .dart_tool

# Remove build directory
echo -e "${YELLOW}► Removing build directory...${NC}"
rm -rf build

echo -e "${YELLOW}► Removing pubspec.lock...${NC}"
rm -f pubspec.lock

echo ""
echo -e "${GREEN}✅ Project cleaned successfully!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Next step: Run './scripts/setup.sh' to reinstall dependencies${NC}"

