#!/bin/bash
# JusPrin Docker Build Helper Script
#
# Usage:
#   ./docker-build.sh                 # Build Linux version
#   ./docker-build.sh appimage        # Build Linux with AppImage
#   ./docker-build.sh clean           # Clean build artifacts
#   ./docker-build.sh shell           # Interactive debugging shell

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[Docker Build]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[Warning]${NC} $1"
}

error() {
    echo -e "${RED}[Error]${NC} $1"
    exit 1
}

check_docker() {
    if ! command -v docker &> /dev/null; then
        error "Docker is not installed. Please install Docker Desktop: https://www.docker.com/products/docker-desktop"
    fi

    if ! docker info &> /dev/null; then
        error "Docker daemon is not running. Please start Docker Desktop."
    fi
}

build_image() {
    log "Building Docker image (this may take a few minutes first time)..."
    docker build -f Dockerfile.linux -t jusprin-linux-builder . || error "Failed to build Docker image"
    log "Docker image built successfully!"
}

run_build() {
    local appimage_flag=${1:-0}

    log "Starting JusPrin Linux build..."
    log "Build output will be in: $SCRIPT_DIR/build/"

    # Create build directories if they don't exist
    mkdir -p "$SCRIPT_DIR/build"
    mkdir -p "$SCRIPT_DIR/deps/build"
    mkdir -p "$SCRIPT_DIR/deps/DL_CACHE"

    docker run --rm \
        -v "$SCRIPT_DIR/build:/build/build" \
        -v "$SCRIPT_DIR/deps/build:/build/deps/build" \
        -v "$SCRIPT_DIR/deps/DL_CACHE:/build/deps/DL_CACHE" \
        -e BUILD_APPIMAGE="$appimage_flag" \
        jusprin-linux-builder \
        || error "Build failed!"

    log "Build completed successfully!"
    log "Artifacts location: $SCRIPT_DIR/build/"
    ls -lh "$SCRIPT_DIR/build/"
}

run_shell() {
    log "Starting interactive shell in build container..."
    docker run --rm -it \
        -v "$SCRIPT_DIR/build:/build/build" \
        -v "$SCRIPT_DIR/deps/build:/build/deps/build" \
        -v "$SCRIPT_DIR/deps/DL_CACHE:/build/deps/DL_CACHE" \
        jusprin-linux-builder \
        /bin/bash
}

clean_build() {
    log "Cleaning build artifacts..."

    if [ -d "$SCRIPT_DIR/build" ]; then
        rm -rf "$SCRIPT_DIR/build"
        log "Removed build/"
    fi

    if [ -d "$SCRIPT_DIR/deps/build" ]; then
        read -p "Remove cached dependencies (will require full rebuild)? [y/N] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$SCRIPT_DIR/deps/build"
            rm -rf "$SCRIPT_DIR/deps/DL_CACHE"
            log "Removed deps/build/ and deps/DL_CACHE/"
        else
            log "Kept dependency cache"
        fi
    fi

    log "Clean completed!"
}

show_help() {
    cat << EOF
JusPrin Docker Build Helper

Usage: $0 [command]

Commands:
    (none)      Build Linux version (default)
    appimage    Build Linux version with AppImage
    shell       Open interactive shell in build container
    clean       Clean build artifacts
    help        Show this help message

Examples:
    $0                  # Build Linux version
    $0 appimage         # Build with AppImage
    $0 shell            # Debug build issues
    $0 clean            # Start fresh

For more information, see BUILD_WITH_DOCKER.md
EOF
}

# Main script
case "${1:-}" in
    "")
        check_docker
        build_image
        run_build 0
        ;;
    appimage)
        check_docker
        build_image
        run_build 1
        ;;
    shell)
        check_docker
        build_image
        run_shell
        ;;
    clean)
        clean_build
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        error "Unknown command: $1. Run '$0 help' for usage."
        ;;
esac
