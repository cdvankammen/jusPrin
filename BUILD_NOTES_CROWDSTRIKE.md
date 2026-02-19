# Build Notes - CrowdStrike Workaround

## Issue
CrowdStrike security software deletes built .app executables during the build process, causing encoding-check to fail.

## Solution
Disable the source file encoding check during CMake configuration by adding:
```
-DSLIC3R_ENC_CHECK=OFF
```

## Build Command
From the `build/arm64` directory:
```bash
cmake /Users/stillbulldog35/Documents/GitHub/JusPrin \
  -G Xcode \
  -DBBL_RELEASE_TO_PUBLIC=1 \
  -DORCA_TOOLS=ON \
  -DCMAKE_PREFIX_PATH=/Users/stillbulldog35/Documents/GitHub/JusPrin/deps/build/arm64/OrcaSlicer_dep/usr/local \
  -DCMAKE_INSTALL_PREFIX=/Users/stillbulldog35/Documents/GitHub/JusPrin/build/arm64/JusPrin \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_MACOSX_RPATH=ON \
  -DCMAKE_INSTALL_RPATH=/Users/stillbulldog35/Documents/GitHub/JusPrin/deps/build/arm64/OrcaSlicer_dep/usr/local \
  -DCMAKE_MACOSX_BUNDLE=ON \
  -DCMAKE_OSX_ARCHITECTURES=arm64 \
  -DCMAKE_OSX_DEPLOYMENT_TARGET=11.3 \
  -DSLIC3R_ENC_CHECK=OFF

xcodebuild -project OrcaSlicer.xcodeproj -target JusPrin -configuration Release build
```

## What This Disables
The encoding-check is a build-time validation tool that verifies source file encodings are UTF-8. Disabling it does not affect the functionality of the built application.

## Build Result
- Build Status: **SUCCESS**
- Binary Location: `build/arm64/src/Release/JusPrin.app`
- Note: CrowdStrike may delete the .app file after it's built, but the build itself completes successfully
