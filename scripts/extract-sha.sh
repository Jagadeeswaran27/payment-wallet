#!/bin/bash

# =============================================================================
# Firebase SHA Script - Extract SHA keys for Firebase configuration
# Usage: ./scripts/firebase-sha.sh [options]
# Options: --debug | --release <keystore_path> | --all
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


# Default debug keystore locations
if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux"* ]]; then
    DEBUG_KEYSTORE="$HOME/.android/debug.keystore"
else
    # Windows
    DEBUG_KEYSTORE="$USERPROFILE/.android/debug.keystore"
fi

# Show usage
show_usage() {
    echo -e "${BLUE}Usage: ./scripts/firebase-sha.sh [option]${NC}"
    echo ""
    echo "Options:"
    echo "  --debug                     Extract SHA from debug keystore (default)"
    echo "  --release <keystore_path>   Extract SHA from release keystore"
    echo "  --all <keystore_path>       Extract SHA from both debug and release"
    echo "  --gradle                    Extract SHA using Gradle signingReport"
    echo "  --help                      Show this help message"
    echo ""
    echo "Examples:"
    echo "  ./scripts/firebase-sha.sh"
    echo "  ./scripts/firebase-sha.sh --debug"
    echo "  ./scripts/firebase-sha.sh --release ~/keys/release.keystore"
    echo "  ./scripts/firebase-sha.sh --all ~/keys/release.keystore"
    echo "  ./scripts/firebase-sha.sh --gradle"
    echo ""
    echo -e "${CYAN}Note: Add these SHA keys to your Firebase project:${NC}"
    echo "  Firebase Console → Project Settings → Your Apps → Android → Add Fingerprint"
}

# Extract SHA from keystore using keytool
extract_sha_from_keystore() {
    local keystore_path=$1
    local keystore_type=$2
    local alias=${3:-"androiddebugkey"}
    local password=${4:-"android"}

    if [ ! -f "$keystore_path" ]; then
        echo -e "${RED}✗ Keystore not found: $keystore_path${NC}"
        return 1
    fi

    echo -e "${MAGENTA}🔑 $keystore_type Keystore${NC}"
    echo "─────────────────────────────────────────────────────"
    echo -e "${CYAN}Path:${NC} $keystore_path"
    echo ""

    # Extract certificate info
    local cert_info
    set +e
    cert_info=$(keytool -list -v -keystore "$keystore_path" -alias "$alias" -storepass "$password" 2>/dev/null)
    local exit_code=$?
    set -e

    if [ $exit_code -ne 0 ]; then
        echo -e "${YELLOW}⚠ Could not read keystore with default credentials.${NC}"
        echo -e "${CYAN}For release keystores, enter credentials:${NC}"
        echo ""
        read -p "Keystore alias (default: key0): " input_alias
        alias=${input_alias:-"key0"}
        read -sp "Keystore password: " input_password
        echo ""
        password=$input_password

        set +e
        cert_info=$(keytool -list -v -keystore "$keystore_path" -alias "$alias" -storepass "$password" 2>/dev/null)
        exit_code=$?
        set -e
        
        if [ $exit_code -ne 0 ]; then
            echo -e "${RED}✗ Failed to read keystore. Check alias and password.${NC}"
            return 1
        fi
    fi

    # Extract SHA-1
    local sha1
    sha1=$(echo "$cert_info" | grep "SHA1:" | awk '{print $2}')
    if [ -z "$sha1" ]; then
        sha1=$(echo "$cert_info" | grep -i "sha1" | head -1 | sed 's/.*: //')
    fi

    # Extract SHA-256
    local sha256
    sha256=$(echo "$cert_info" | grep "SHA256:" | awk '{print $2}')
    if [ -z "$sha256" ]; then
        sha256=$(echo "$cert_info" | grep -i "sha256" | head -1 | sed 's/.*: //')
    fi

    if [ -n "$sha1" ]; then
        echo -e "${GREEN}SHA-1:${NC}"
        echo -e "  ${YELLOW}$sha1${NC}"
        echo ""
    fi

    if [ -n "$sha256" ]; then
        echo -e "${GREEN}SHA-256:${NC}"
        echo -e "  ${YELLOW}$sha256${NC}"
        echo ""
    fi

    if [ -z "$sha1" ] && [ -z "$sha256" ]; then
        echo -e "${RED}✗ Could not extract SHA fingerprints${NC}"
        return 1
    fi

    return 0
}

# Extract SHA using Gradle signingReport
extract_sha_gradle() {
    echo -e "${MAGENTA}📋 Gradle Signing Report${NC}"
    echo "─────────────────────────────────────────────────────"

    # Ensure we are in the project root for Gradle
    cd "$PROJECT_ROOT"
    
    if [ ! -d "android" ]; then
        echo -e "${RED}✗ Android directory not found.${NC}"
        return 1
    fi

    cd android
    
    echo -e "${YELLOW}► Running Gradle signingReport...${NC}"
    echo ""
    
    if [ -f "gradlew" ]; then
        ./gradlew signingReport 2>/dev/null | grep -A 4 "Variant:" | grep -E "(Variant:|SHA1:|SHA-256:)" || {
            echo -e "${YELLOW}Detailed output:${NC}"
            ./gradlew signingReport
        }
    else
        echo -e "${RED}✗ gradlew not found in android directory${NC}"
        # No need to cd .. as we are in a subshell or localized function context if invoked appropriately, 
        # but since we cd'd in this function, we can just return.
        return 1
    fi
    
    # Return to previous directory not strictly necessary if script exits, but good practice if called multiple times
    cd "$PROJECT_ROOT" 
    return 0
}

echo -e "${BLUE}🔥 Firebase SHA Key Extractor${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if keytool is available
if ! command -v keytool &> /dev/null; then
    echo -e "${RED}✗ keytool not found. Please install Java JDK.${NC}"
    exit 1
fi

# Parse arguments
case "${1:-}" in
    --help|-h)
        show_usage
        exit 0
        ;;
    --debug|"")
        extract_sha_from_keystore "$DEBUG_KEYSTORE" "Debug" "androiddebugkey" "android"
        ;;
    --release)
        if [ -z "${2:-}" ]; then
            echo -e "${RED}✗ Please provide the path to the release keystore${NC}"
            echo ""
            show_usage
            exit 1
        fi
        extract_sha_from_keystore "$2" "Release"
        ;;
    --all)
        extract_sha_from_keystore "$DEBUG_KEYSTORE" "Debug" "androiddebugkey" "android"
        echo ""
        if [ -n "${2:-}" ]; then
            extract_sha_from_keystore "$2" "Release"
        else
            echo -e "${YELLOW}⚠ No release keystore provided. Showing debug only.${NC}"
        fi
        ;;
    --gradle)
        extract_sha_gradle
        ;;
    *)
        echo -e "${RED}Unknown option: $1${NC}"
        echo ""
        show_usage
        exit 1
        ;;
esac

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo -e "${GREEN}✅ SHA extraction complete!${NC}"
echo ""
echo -e "${CYAN}📌 Next steps:${NC}"
echo "  1. Go to Firebase Console → Project Settings"
echo "  2. Select your Android app"
echo "  3. Click 'Add fingerprint'"
echo "  4. Paste the SHA-1 and/or SHA-256 values above"
echo ""

