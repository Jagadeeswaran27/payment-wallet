#!/bin/bash

# =============================================================================
# Setup Script - Clean install of all dependencies
# Usage: ./scripts/setup.sh
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

echo -e "${BLUE}📦 Setting up Paytm Wallet Project...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Get Flutter dependencies
echo -e "${YELLOW}► Getting Flutter dependencies...${NC}"
flutter pub get

# Check if on macOS for iOS setup
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo -e "${YELLOW}► Installing iOS dependencies (CocoaPods)...${NC}"
    cd ios
    pod install --repo-update
    cd ..
fi

echo ""
echo -e "${GREEN}✅ Project setup complete!${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${BLUE}Run 'flutter run' to start the app${NC}"

