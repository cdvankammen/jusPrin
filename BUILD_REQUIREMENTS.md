# Build Requirements

This document lists all external dependencies required to build JusPrin from source.

## Required System Dependencies

### All Platforms

**Build Tools:**
- CMake >= 3.13 (Windows: <= 3.31.x)
- Git
- C++17 compliant compiler:
  - GCC >= 7.0
  - Clang >= 6.0
  - MSVC >= 2019

**Required Libraries** (must be installed or auto-built by deps):
- Boost >= 1.83.0 (components: system, filesystem, thread, log, log_setup, locale, regex, chrono, atomic, date_time, iostreams, program_options, nowide)
- Intel TBB (Threading Building Blocks)
- OpenSSL >= 1.1.1 (⚠️ SECURITY: Upgrade to 3.x LTS recommended)
- libcurl >= 7.75.0 (⚠️ SECURITY: Upgrade to 8.x recommended)
- wxWidgets >= 3.1.5
- CGAL (Computational Geometry Algorithms Library)
- Eigen >= 3.3
- OpenGL / GLEW >= 2.0
- JPEG library (provided by OpenCV's bundled libjpeg-turbo)
- PNG library
- FreeType >= 2.12
- Expat (XML parser)
- zlib

**CAD & Geometry Libraries:**
- OpenCASCADE (OCCT) - For STEP file support
- OpenCV >= 4.6.0 - Computer vision (includes bundled libjpeg-turbo)
- libnoise - Perlin noise generation
- OpenVDB >= 5.0 - Volumetric data structures
- NLopt - Numerical optimization
- qhull - Convex hull computations

**Optional Dependencies:**
- Draco - Compressed mesh format support (currently disabled)

### Linux-Specific

**Package Manager Install (Ubuntu/Debian):**
```bash
sudo apt-get install \
    build-essential cmake git \
    libboost-all-dev \
    libtbb-dev \
    libssl-dev \
    libcurl4-openssl-dev \
    libwxgtk3.0-gtk3-dev \
    libcgal-dev \
    libeigen3-dev \
    libglew-dev \
    libpng-dev \
    libfreetype6-dev \
    libexpat1-dev \
    zlib1g-dev \
    libgtk-3-dev \
    libdbus-1-dev \
    libwayland-dev \
    libsecret-1-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev
```

**Wayland Support:**
- wayland-protocols
- libwayland-client
- libwayland-egl
- libwayland-server

### macOS-Specific

**Xcode Command Line Tools:**
```bash
xcode-select --install
```

**Homebrew Packages:**
```bash
brew install cmake boost tbb openssl wxwidgets cgal eigen glew
```

**Frameworks** (system-provided):
- IOKit.framework
- CoreFoundation.framework
- AVFoundation.framework
- AVKit.framework
- CoreMedia.framework
- VideoToolbox.framework

### Windows-Specific

**Visual Studio 2019 or later** with:
- C++ Desktop Development workload
- Windows 10/11 SDK

**Additional Tools:**
- NSIS (for installer creation)
- gettext utilities (in tools/ directory)

## Build Dependency Scripts

The project includes automated dependency building:

**macOS:**
```bash
./build_release_macos.sh -d  # Build dependencies only
./build_release_macos.sh     # Build deps + slicer
```

**Linux:**
```bash
./build_linux.sh -u   # Install system dependencies
./build_linux.sh -d   # Build custom dependencies
./build_linux.sh -dsi # Build everything + AppImage
```

**Windows:**
```cmd
build_release_vs2022.bat deps    # Build dependencies
build_release_vs2022.bat slicer  # Build slicer
```

## Dependency Locations

**Pre-built dependencies** are installed to:
- `deps/build/destdir/usr/local/` (Linux)
- `deps/build/${ARCH}/OrcaSlicer_dep/usr/local/` (macOS/Windows)

CMake will auto-detect these locations. If not found, set manually:
```bash
cmake -DCMAKE_PREFIX_PATH=/path/to/deps/install ...
```

## Security Notices

⚠️ **CRITICAL DEPENDENCY UPDATES RECOMMENDED:**

1. **OpenSSL 1.1.1w** - End of Life (EOL)
   - Multiple known CVEs
   - **Recommendation:** Upgrade to OpenSSL 3.x LTS
   - Impact: All HTTPS connections

2. **libcurl 7.75.0** - Outdated
   - Known security vulnerabilities
   - **Recommendation:** Upgrade to libcurl 8.x
   - Impact: Network communications, updates, cloud sync

## Architecture Support

- **Linux:** x86_64, aarch64
- **macOS:** arm64 (Apple Silicon), x86_64 (Intel), universal binaries
- **Windows:** x64

## Minimum System Requirements

**RAM:** 4GB minimum, 8GB recommended (16GB for large models)
**Disk Space:** 2GB for build artifacts, 500MB for installed application
**Display:** OpenGL 2.0+ compatible graphics

## Troubleshooting

**CMake can't find dependencies:**
```bash
# Check auto-detected path
cmake -S . -B build
# If failed, specify manually
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/deps/install
```

**OpenCASCADE not found:**
```bash
# Ensure OCCT is installed in deps
ls $CMAKE_PREFIX_PATH/lib/cmake/occt
```

**Boost version mismatch:**
```bash
# Build uses Boost 1.83.0+, check system version
boost --version  # Linux
brew info boost  # macOS
```

## Additional Resources

- **Build Instructions:** See `README.md`
- **Developer Guide:** See `CLAUDE.md`
- **Dependency Patches:** See `deps/` directory

---

*Last Updated: 2026-02-19*
*Based on: OrcaSlicer v2.3.2-dev + JusPrin v1.5.0*
