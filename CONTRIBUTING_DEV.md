## Contributing (developer quickstart)

This short guide explains how to bootstrap dependencies, run CMake configure, and run the AddressSanitizer (ASAN) job locally for the jusPrin repository.

Prerequisites
- Git, CMake (>= 3.13), a C/C++ toolchain (clang/gcc), Ninja or make, Python 3 for some scripts.
- On macOS, Xcode command line tools are required.

1) Bootstrapping deps

Use the platform helper scripts included in the repository to build or fetch deps:

- macOS

  ./build_release_macos.sh -d

- Linux

  ./build_linux.sh -dsi

- Windows (Developer Prompt / PowerShell)

  build_release_vs2022.bat deps

These scripts will produce the dependency install root under `deps/build/...` and (when present) the auto-detected `CMAKE_PREFIX_PATH` used by the top-level configure.

2) Configure and build (example)

From the repository root:

```bash
# out-of-source configure
cmake -S . -B build -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_PREFIX_PATH="$(pwd)/deps/build/<arch>/OrcaSlicer_dep/usr/local"

# build
cmake --build build --parallel

# run tests
ctest --test-dir build --output-on-failure
```

Replace `<arch>` with the directory produced by the deps scripts (for example `arm64` on macOS M1/arm64 builds).

3) Running the ASAN job locally

Create a dedicated ASAN build directory and turn on sanitizer flags at configure time. Example (works on macOS and Linux):

```bash
cmake -S . -B build/asan -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DCMAKE_C_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" \
  -DCMAKE_CXX_FLAGS="-fsanitize=address -fno-omit-frame-pointer -g" \
  -DCMAKE_EXE_LINKER_FLAGS="-fsanitize=address" \
  -DCMAKE_SHARED_LINKER_FLAGS="-fsanitize=address"

cmake --build build/asan --parallel

# Run tests under ASAN (optionally log sanitizer output):
ASAN_OPTIONS=verbosity=1:detect_leaks=1:log_path=asan.log \
  ctest --test-dir build/asan --output-on-failure
```

Notes and tips
- If the top-level CMake already auto-detects `CMAKE_PREFIX_PATH`, you can omit the explicit `-DCMAKE_PREFIX_PATH`.
- On macOS, ASAN builds can require extra environment handling for dynamic libraries; prefer a RelWithDebInfo + sanitizer flags build.
- If you need to suppress known false positives use an LSAN/ASAN suppression file and pass it with `LSAN_OPTIONS` / `ASAN_OPTIONS`.

Mirroring to /JusPrin

When you're ready to mirror these developer changes into the sibling `JusPrin` tree (`/Users/stillbulldog35/Documents/GitHub/JusPrin`), a simple rsync is a convenient way to copy files while preserving permissions and excluding build artifacts:

```bash
rsync -a --exclude='build' --exclude='deps/build' \
  /Users/stillbulldog35/Documents/hass\ agent/jusPrin/ \
  /Users/stillbulldog35/Documents/GitHub/JusPrin/
```

Before mirroring, run `git status` in both trees and consider pushing changes or opening a PR from the main repo instead of manual mirroring when possible.

Acknowledgements
This document is a concise developer-focused quickstart; for full build and packaging instructions see the repository's top-level build scripts (`build_*`) and the longer analysis documents.
