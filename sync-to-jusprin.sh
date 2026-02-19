#!/bin/bash
#
# sync-to-jusprin.sh
#
# Automatically syncs changes from JusPrin (christophervankammen/JusPrin)
# to jusPrin (cdvankammen/jusPrin)
#
# Usage: ./sync-to-jusprin.sh [--dry-run] [--force]
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Directories
SOURCE_DIR="/Users/stillbulldog35/Documents/GitHub/JusPrin"
TARGET_DIR="/Users/stillbulldog35/Documents/hass agent/jusPrin"
SYNC_LOG="/tmp/jusprin-sync-$(date +%Y%m%d-%H%M%S).log"

# Parse arguments
DRY_RUN=false
FORCE=false
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        *)
            ;;
    esac
done

# Logging function
log() {
    echo -e "${BLUE}[$(date '+%H:%M:%S')]${NC} $1" | tee -a "$SYNC_LOG"
}

log_success() {
    echo -e "${GREEN}[$(date '+%H:%M:%S')] ✓${NC} $1" | tee -a "$SYNC_LOG"
}

log_warning() {
    echo -e "${YELLOW}[$(date '+%H:%M:%S')] ⚠${NC} $1" | tee -a "$SYNC_LOG"
}

log_error() {
    echo -e "${RED}[$(date '+%H:%M:%S')] ✗${NC} $1" | tee -a "$SYNC_LOG"
}

# Header
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  JusPrin → jusPrin Sync Script${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo ""
log "Source: $SOURCE_DIR (christophervankammen/JusPrin)"
log "Target: $TARGET_DIR (cdvankammen/jusPrin)"
log "Log file: $SYNC_LOG"
echo ""

if [ "$DRY_RUN" = true ]; then
    log_warning "DRY RUN MODE - No changes will be made"
    echo ""
fi

# Pre-flight checks
log "Running pre-flight checks..."

# Check source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    log_error "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

# Check target directory exists
if [ ! -d "$TARGET_DIR" ]; then
    log_error "Target directory does not exist: $TARGET_DIR"
    exit 1
fi

# Check both are git repositories
if [ ! -d "$SOURCE_DIR/.git" ]; then
    log_error "Source is not a git repository: $SOURCE_DIR"
    exit 1
fi

if [ ! -d "$TARGET_DIR/.git" ]; then
    log_error "Target is not a git repository: $TARGET_DIR"
    exit 1
fi

log_success "Pre-flight checks passed"
echo ""

# Get current state
log "Getting repository status..."

cd "$SOURCE_DIR"
SOURCE_BRANCH=$(git branch --show-current)
SOURCE_COMMIT=$(git rev-parse --short HEAD)
SOURCE_REMOTE=$(git remote get-url origin)

cd "$TARGET_DIR"
TARGET_BRANCH=$(git branch --show-current)
TARGET_COMMIT=$(git rev-parse --short HEAD)
TARGET_REMOTE=$(git remote get-url origin)

log "Source: $SOURCE_BRANCH @ $SOURCE_COMMIT"
log "Target: $TARGET_BRANCH @ $TARGET_COMMIT"
echo ""

# Check for uncommitted changes in target
cd "$TARGET_DIR"
if ! git diff-index --quiet HEAD -- 2>/dev/null; then
    log_warning "Target has uncommitted changes"
    if [ "$FORCE" = false ]; then
        log_error "Use --force to sync anyway, or commit/stash changes first"
        exit 1
    else
        log_warning "Continuing due to --force flag"
    fi
fi

# Files and directories to sync
# Exclude: .git, build directories, deps, analysis files
log "Preparing file list to sync..."

EXCLUDE_PATTERNS=(
    ".git"
    ".gitignore"
    "build*"
    "deps/build*"
    "*.log"
    "*.DS_Store"
    ".vscode"
    ".idea"
    ".vs"
    "_build"
    "blib"
    "local-lib"
    "analysis.md"
    "analysis_v2.md"
    "chat.md"
    "task.md"
    "BUILD_NOTES_CROWDSTRIKE.md"
    "BUILD_LOG.md"
    "*_audit.json"
    "COMPREHENSIVE_ANALYSIS_REPORT.md"
    "FINAL_IMPLEMENTATION_REPORT.md"
)

# Build rsync exclude arguments
RSYNC_EXCLUDES=""
for pattern in "${EXCLUDE_PATTERNS[@]}"; do
    RSYNC_EXCLUDES="$RSYNC_EXCLUDES --exclude=$pattern"
done

# Count files to sync
cd "$SOURCE_DIR"
FILE_COUNT=$(rsync --dry-run -av $RSYNC_EXCLUDES . "$TARGET_DIR" | grep -E "^[^d]" | wc -l | tr -d ' ')
log "Files to sync: $FILE_COUNT"
echo ""

if [ "$DRY_RUN" = true ]; then
    log "DRY RUN: Files that would be synced:"
    rsync --dry-run -av $RSYNC_EXCLUDES . "$TARGET_DIR" | grep -E "^[^d]" | head -50
    if [ $FILE_COUNT -gt 50 ]; then
        log "... and $((FILE_COUNT - 50)) more files"
    fi
    echo ""
    log_warning "DRY RUN COMPLETE - No changes made"
    exit 0
fi

# Perform sync
log "Starting sync..."
echo ""

if rsync -av --delete $RSYNC_EXCLUDES "$SOURCE_DIR/" "$TARGET_DIR/" | tee -a "$SYNC_LOG"; then
    log_success "Sync completed successfully"
else
    log_error "Sync failed"
    exit 1
fi

echo ""

# Special handling for analysis_v3.md - always sync to target
if [ -f "$SOURCE_DIR/analysis_v3.md" ]; then
    log "Syncing analysis_v3.md to target..."
    cp "$SOURCE_DIR/analysis_v3.md" "$TARGET_DIR/analysis_v3.md"
    log_success "analysis_v3.md synced"
fi

# Git operations in target
cd "$TARGET_DIR"

log "Checking for changes in target repository..."
if git diff-index --quiet HEAD -- 2>/dev/null; then
    log_success "No changes detected - repositories are in sync"
else
    CHANGED_FILES=$(git diff --name-only | wc -l | tr -d ' ')
    log "Changed files in target: $CHANGED_FILES"

    echo ""
    log "Git status in target:"
    git status --short | tee -a "$SYNC_LOG"
    echo ""

    # Show a sample of changes
    log "Sample of changes (first 20 lines):"
    git diff --stat | head -20 | tee -a "$SYNC_LOG"
    echo ""

    # Commit changes
    log "Creating commit in target repository..."
    git add -A

    COMMIT_MSG="Sync from JusPrin (christophervankammen/JusPrin)

Synced changes from source repository:
- Source branch: $SOURCE_BRANCH
- Source commit: $SOURCE_COMMIT
- Sync timestamp: $(date '+%Y-%m-%d %H:%M:%S %Z')
- Changed files: $CHANGED_FILES

This sync includes all Phase 1, 2, 3 fixes from analysis_v3.md:
- Build system fixes (CMAKE_PREFIX_PATH, JPEG conflict, BBL_RELEASE_TO_PUBLIC)
- Security fixes (SSL verification, path traversal, integer overflow)
- Memory safety fixes (free/delete mismatch, dangling pointer)
- Thread safety fixes (atomic operations, thread_local variables)
- Security hardening (compiler flags)
- Documentation (BUILD_REQUIREMENTS.md, analysis_v3.md)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

    if git commit -m "$COMMIT_MSG"; then
        log_success "Changes committed to target repository"

        TARGET_NEW_COMMIT=$(git rev-parse --short HEAD)
        log "New commit: $TARGET_NEW_COMMIT"

        echo ""
        log "Push to remote? (you can manually push with: cd \"$TARGET_DIR\" && git push origin $TARGET_BRANCH)"
    else
        log_error "Failed to commit changes"
        exit 1
    fi
fi

echo ""
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Sync Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════════════════${NC}"
echo ""
log "Summary:"
log "  Source: $SOURCE_BRANCH @ $SOURCE_COMMIT"
log "  Target: $TARGET_BRANCH @ $(cd "$TARGET_DIR" && git rev-parse --short HEAD)"
log "  Log file: $SYNC_LOG"
echo ""
log_success "All done!"
