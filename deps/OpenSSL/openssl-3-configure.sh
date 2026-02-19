#!/usr/bin/env bash
# openssl-3-configure.sh
# Wrapper around OpenSSL 3.x ./Configure invoked by ExternalProject_Add.
# Detects the host platform and forwards all arguments.
set -euo pipefail

# Determine the OpenSSL Configure target based on the platform
case "$(uname -s)-$(uname -m)" in
    Darwin-arm64)  TARGET="darwin64-arm64-cc" ;;
    Darwin-x86_64) TARGET="darwin64-x86_64-cc" ;;
    Linux-x86_64)  TARGET="linux-x86_64" ;;
    Linux-aarch64) TARGET="linux-aarch64" ;;
    *)             TARGET="" ;;  # let Configure auto-detect
esac

if [ -n "$TARGET" ]; then
    exec ./Configure "$TARGET" "$@"
else
    exec ./config "$@"
fi
