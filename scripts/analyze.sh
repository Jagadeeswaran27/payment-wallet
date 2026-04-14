#!/bin/bash

# =============================================================================
# Analyze Script - Runs static analysis and formatting checks
# Usage: ./scripts/analyze.sh [--fix]
# Options:
#   --fix    Auto-fix issues where possible
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

AUTO_FIX=false

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --fix) AUTO_FIX=true ;;
        *) echo -e "${RED}Unknown parameter: $1${NC}"; exit 1 ;;
    esac
    shift
done

echo -e "${BLUE}🔍 Analyzing Paytm Wallet Project...${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Run dart fix if auto-fix is enabled
if [ "$AUTO_FIX" = true ]; then
    echo -e "${YELLOW}► Running dart fix --apply...${NC}"
    dart fix --apply
    echo ""
fi

# Format check
echo -e "${YELLOW}► Checking code formatting...${NC}"
if [ "$AUTO_FIX" = true ]; then
    dart format .
    echo -e "${GREEN}  Code formatted${NC}"
else
    if dart format --set-exit-if-changed --output=none . 2>/dev/null; then
        echo -e "${GREEN}  ✓ Code is properly formatted${NC}"
    else
        echo -e "${RED}  ✗ Code formatting issues found${NC}"
        echo -e "${CYAN}  Run './scripts/analyze.sh --fix' to auto-format${NC}"
    fi
fi
echo ""

# Static analysis
echo -e "${YELLOW}► Running flutter analyze...${NC}"
if flutter analyze; then
    echo -e "${GREEN}  ✓ No analysis issues found${NC}"
else
    echo -e "${RED}  ✗ Analysis issues found (see above)${NC}"
    if [ "$AUTO_FIX" = false ]; then
        echo -e "${CYAN}  Run './scripts/analyze.sh --fix' to auto-fix some issues${NC}"
    fi
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Analysis complete!${NC}"

