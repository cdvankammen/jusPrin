# Building JusPrin with Docker

## Overview

This guide provides Docker-based build solutions for JusPrin to work around local build issues like CrowdStrike interference on macOS.

## Linux Build (Fully Supported)

### Quick Start

```bash
# Build the Docker image
docker build -f Dockerfile.linux -t jusprin-linux-builder .

# Run the build
docker run --rm -v $(pwd)/build:/build/build jusprin-linux-builder
```

### Using Docker Compose (Recommended)

```bash
# Build Linux version
docker-compose up linux-build

# Build with AppImage
docker-compose up linux-build-appimage

# Interactive debugging shell
docker-compose run --rm linux-shell
```

### Build Artifacts

After the build completes, artifacts will be in `./build/` directory:
- `build/src/JusPrin` - Main executable
- `build/src/JusPrin_profile_validator` - Profile validator tool
- AppImage (if built with `-i` flag)

### Caching for Faster Rebuilds

Dependencies are cached in `./deps/build/` and `./deps/DL_CACHE/`. The Docker Compose configuration automatically mounts these as volumes to speed up subsequent builds.

---

## macOS Build (Docker Limitation)

### ⚠️ Important: macOS .app Cannot Be Built in Docker

**Docker on macOS runs Linux containers only.** You cannot build native macOS .app bundles inside Docker because:

1. macOS apps require Apple frameworks (Foundation, Cocoa, AppKit)
2. Code signing requires macOS codesign tool
3. DMG creation requires macOS-specific tools
4. Cross-compilation to macOS requires macOS SDK and Xcode

### CrowdStrike Workaround Options

Since CrowdStrike is blocking local macOS builds, here are your options:

#### Option 1: GitHub Actions (Recommended)

Use the existing GitHub Actions workflow which runs on clean macOS runners without CrowdStrike:

```bash
# Push to your branch - builds automatically run
git push origin <branch-name>

# Monitor build status
gh run watch

# Download artifacts when done
gh run download <run-id>
```

**Advantages:**
- No local CrowdStrike interference
- Clean build environment
- Automatic artifact storage
- Free for public repositories

#### Option 2: Disable CrowdStrike Temporarily

If you have admin rights:

```bash
# Check CrowdStrike status
sudo /Applications/Falcon.app/Contents/Resources/falconctl stats

# Disable temporarily (requires admin password)
sudo /Applications/Falcon.app/Contents/Resources/falconctl unload

# Build locally
./build_release_macos.sh

# Re-enable CrowdStrike
sudo /Applications/Falcon.app/Contents/Resources/falconctl load
```

**⚠️ Security Warning:** Only disable CrowdStrike if you understand the security implications and have permission from your organization.

#### Option 3: Allowlist JusPrin Build Directory

Add the build directory to CrowdStrike's allowlist:

```bash
# Contact your IT/Security team to allowlist:
/Users/<your-username>/Documents/GitHub/JusPrin/build/
/Users/<your-username>/Documents/hass agent/jusPrin/build/
```

This allows builds to complete without blocking the .app creation.

#### Option 4: Build on a Personal Mac

If you have access to a personal Mac without CrowdStrike:
- Clone the repo on the personal machine
- Build normally with `./build_release_macos.sh`
- Transfer the .app/.dmg back to your work machine

#### Option 5: Remote macOS Build Service

Use a cloud macOS build service:
- **GitHub Actions** (recommended, already configured)
- **CircleCI** with macOS executors
- **AWS EC2 Mac instances** (expensive)
- **MacStadium** (dedicated Mac hosting)

---

## Windows Build

### Docker Limitation

Windows GUI applications (.exe) built with Visual Studio are challenging in Docker because:
- Windows containers require Windows Server base images
- wxWidgets GUI doesn't work well in containers
- Large image sizes (several GB)
- Complex licensing

### Recommended Approach: GitHub Actions

The existing workflow already builds Windows versions:

```bash
# Workflow automatically builds for Windows on every push
git push origin <branch-name>

# Check build status
gh run list --branch <branch-name>

# Download Windows artifacts
gh run download <run-id> --name "JusPrin-Windows-*"
```

### Local Windows Build (If Needed)

If you must build locally on Windows:

```bash
# Run from Windows PowerShell or CMD
.\build_release_vs2022.bat slicer
```

**Requirements:**
- Visual Studio 2022 (Community/Professional/Enterprise)
- CMake 3.13+ (max 3.31.x)
- Windows 10 SDK

---

## Comparison Table

| Platform | Docker Support | Recommended Method | Notes |
|----------|----------------|-------------------|-------|
| **Linux** | ✅ Full support | Docker or native | Fast, clean builds |
| **macOS** | ❌ Not possible | GitHub Actions | Docker runs Linux only |
| **Windows** | ⚠️ Limited | GitHub Actions | Complex, large images |

---

## Troubleshooting

### Linux Docker Build Issues

**Problem:** Permission denied errors in build/ directory

```bash
# Fix permissions
sudo chown -R $USER:$USER build/ deps/
```

**Problem:** Out of disk space

```bash
# Clean Docker cache
docker system prune -a --volumes
```

**Problem:** Build fails with "ninja: build stopped"

```bash
# Check logs in docker-compose
docker-compose logs linux-build

# Run interactive shell to debug
docker-compose run --rm linux-shell
# Then manually run: ./build_linux.sh -d
```

### macOS CrowdStrike Issues

**Problem:** CrowdStrike deletes .app immediately after creation

**Solution:** Use GitHub Actions or allowlist the build directory

**Problem:** Cannot disable CrowdStrike (no admin rights)

**Solution:** Must use GitHub Actions or request IT to allowlist

---

## Performance Tips

### Linux Docker Builds

1. **Cache dependencies:** Deps build takes ~30 minutes first time, but cached afterward
2. **Use `-j` flag:** Control CPU cores: `./build_linux.sh -j 4`
3. **Mount volumes:** Docker Compose config already optimizes volume mounts
4. **Skip unnecessary builds:** Build only what you need (deps vs slicer)

### GitHub Actions Builds

1. **Use caching:** Workflow already caches deps (save ~20 minutes)
2. **Cancel outdated runs:** `gh run cancel <run-id>` to save time
3. **Download only needed artifacts:** Specify platform when downloading

---

## Next Steps

1. **For Linux development:** Use Docker (fast, reproducible)
2. **For macOS .app releases:** Use GitHub Actions
3. **For Windows builds:** Use GitHub Actions
4. **For testing:** Download artifacts from GitHub Actions

## Questions?

- Check [COORDINATION_STATUS.md](COORDINATION_STATUS.md) for current build status
- Review GitHub Actions logs: `gh run view <run-id> --log`
- See [CLAUDE.md](CLAUDE.md) for detailed build commands
