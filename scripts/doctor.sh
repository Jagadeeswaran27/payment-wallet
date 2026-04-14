#!/bin/bash

# =============================================================================
# Doctor Script - Comprehensive environment and project health check
# Usage: ./scripts/doctor.sh
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

# Get the project root directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT"

echo -e "${BLUE}🏥 Paytm Wallet Health Check${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Flutter Doctor
echo -e "${MAGENTA}📋 Flutter Environment${NC}"
echo "─────────────────────────────────────────────────────"
flutter doctor -v
echo ""

# Project Info
echo -e "${MAGENTA}📦 Project Information${NC}"
echo "─────────────────────────────────────────────────────"
echo -e "${CYAN}Project:${NC} $(grep 'name:' pubspec.yaml | head -1 | awk '{print $2}')"
echo -e "${CYAN}Version:${NC} $(grep 'version:' pubspec.yaml | head -1 | awk '{print $2}')"
echo -e "${CYAN}SDK Constraint:${NC} $(grep 'sdk:' pubspec.yaml | head -1 | awk '{print $2}')"
echo ""

# Dependencies count
DEP_COUNT=$(grep -c "^  [a-z]" pubspec.yaml 2>/dev/null || echo "0")
echo -e "${CYAN}Dependencies:${NC} ~$DEP_COUNT packages"
echo ""

# Check for outdated packages
echo -e "${MAGENTA}📊 Dependency Status${NC}"
echo "─────────────────────────────────────────────────────"
flutter pub outdated
echo ""

# Analyze
echo -e "${MAGENTA}🔍 Static Analysis${NC}"
echo "─────────────────────────────────────────────────────"
if flutter analyze 2>/dev/null; then
    echo -e "${GREEN}✓ No issues found${NC}"
else
    echo -e "${YELLOW}⚠ Some issues found (see above)${NC}"
fi
echo ""

# Check for TODOs
echo -e "${MAGENTA}📝 TODOs in Code${NC}"
echo "─────────────────────────────────────────────────────"
TODO_COUNT=$(grep -r "TODO" lib/ --include="*.dart" 2>/dev/null | wc -l | tr -d ' ')
if [ "$TODO_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}Found $TODO_COUNT TODO comments:${NC}"
    grep -rn "TODO" lib/ --include="*.dart" 2>/dev/null | head -10
    if [ "$TODO_COUNT" -gt 10 ]; then
        echo -e "${CYAN}  ... and $((TODO_COUNT - 10)) more${NC}"
    fi
else
    echo -e "${GREEN}✓ No TODO comments found${NC}"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ Health check complete!${NC}"
