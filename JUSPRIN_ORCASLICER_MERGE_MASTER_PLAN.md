# JusPrin ↔ OrcaSlicer Merge Master Plan
**Generated:** February 18, 2026
**Status:** Ready for Implementation
**Timeline:** 8-10 weeks (phased approach)

---

## Executive Summary

This document provides the comprehensive plan for merging **2,913 commits** (4 months of development) from OrcaSlicer into JusPrin while preserving JusPrin's unique GenAI features.

### Current State
- **JusPrin Version:** 1.4.0 (based on OrcaSlicer v2.3.1)
- **Last Sync:** October 15, 2025
- **OrcaSlicer Version:** 2.3.2-dev
- **Commits Behind:** 2,913 commits
- **Bug Fixes Missed:** ~592 fixes
- **New Features:** Major architectural improvements

### Critical Success Factors
1. **Preserve JusPrin AI System** - 16 custom files (~2,400 lines)
2. **Maintain Branding** - Custom logos, colors, naming throughout
3. **Test Thoroughly** - Each phase must pass validation before proceeding
4. **Isolate Changes** - Work in feature branches, not main

---

## Table of Contents

1. [Research Summary](#1-research-summary)
2. [JusPrin Custom Features to Preserve](#2-jusprin-custom-features-to-preserve)
3. [OrcaSlicer Changes to Integrate](#3-orcaslicer-changes-to-integrate)
4. [Phased Implementation Plan](#4-phased-implementation-plan)
5. [Conflict Resolution Strategy](#5-conflict-resolution-strategy)
6. [Testing & Validation](#6-testing--validation)
7. [Risk Mitigation](#7-risk-mitigation)
8. [File-by-File Merge Instructions](#8-file-by-file-merge-instructions)
9. [AI System Impact Analysis](#9-ai-system-impact-analysis)
10. [Implementation Checklist](#10-implementation-checklist)

---

## 1. Research Summary

### 1.1 JusPrin Architecture (from Agent 1 & 5)

**Core Innovation:** Cloud-connected GenAI chat interface embedded in 3D slicer

**Key Components:**
- **JusPrinChatPanel** - WebView-based AI chat (JSON-RPC style communication)
- **JusPrinPresetConfigUtils** - AI-driven configuration management
- **JusPrinPlateUtils** - 3D rendering & model feature extraction for AI
- **JusPrinView3D** - Custom 3D view with chat overlay
- **JusPrinLoginDialog** - OAuth2 authentication to Obico cloud
- **JusPrinNotificationManager** - Event forwarding to AI

**AI Architecture:**
```
Native C++ App (JusPrin)
    ↓ WebView (embedded browser)
    ↓ JSON messages
    ↓ HTTPS
Cloud AI Service (app.obico.io)
    ↓ LLM recommendations
```

**Critical Files (16 files, ~2,400 lines):**
```
src/slic3r/GUI/JusPrin/
├── JusPrinChatPanel.{cpp,hpp}
├── JusPrinView3D.{cpp,hpp}
├── JusPrinPlateUtils.{cpp,hpp}
├── JusPrinPresetConfigUtils.{cpp,hpp}
├── JusPrinLoginDialog.{cpp,hpp}
├── JusPrinNotificationManager.{cpp,hpp}
├── JusPrinPricingPlanDialog.{cpp,hpp}
└── JusPrinUtils.{cpp,hpp}
```

**Branding Files:**
```
resources/images/JusPrin.{ico,png,svg}
resources/images/JusPrin_128px.png
version.inc (SLIC3R_APP_NAME="JusPrin")
```

### 1.2 OrcaSlicer Architecture (from Agent 2)

**Current Version:** 2.3.2-dev (SoftFever_VERSION)

**Major New Modules:**

1. **libvgcode (46 files)**
   - Complete G-code visualization rewrite from PrusaSlicer 2.8.0
   - Major performance improvements
   - Better rendering quality

2. **DeviceCore (50 files)**
   - Modular printer agent architecture
   - Support for third-party AMS systems
   - MoonrakerPrinterAgent with Happy Hare AFC support
   - Better extensibility for future printer integrations

3. **New Dependencies:**
   - **Clipper2** - Modern polygon library (replaces older Clipper)
   - **Draco** - 3D geometry compression (.drc format)
   - **earcut** - Polygon triangulation
   - **md4c** - Markdown parser

4. **Filament Management Overhaul:**
   - FilamentGroup support
   - FilamentPickerDialog (column browser with search)
   - AMS filament sync options
   - Better multi-material workflow

5. **Enhanced Features:**
   - Mesh subdivision (from Bambu Studio)
   - Wipe tower improvements (preheat/cooldown)
   - Arc welder
   - Rectilinear interlaced support
   - Better overhang detection

### 1.3 Git History Analysis (from Agent 3)

**Divergence Point:** September 28, 2025 (commit 15037283e7)

**Last Sync:** October 15, 2025
- JusPrin merged from OrcaSlicer `release/v2.3.1` branch
- Commit: cb34c1ff32

**Unique Commits:**
- **JusPrin:** 351 commits (branding, AI features, customization)
- **OrcaSlicer:** 2,913 commits (features, bug fixes, improvements)

**Critical Bug Fixes in OrcaSlicer (Missing in JusPrin):**
1. Linux 3D Preview Crash (EGL/GLX mismatch) - **CRITICAL**
2. 3MF Import Crash - **CRITICAL**
3. Wayland Setup Wizard Hang - **BLOCKING**
4. Printer Configuration Hang on Linux - **BLOCKING**

### 1.4 Code Differences (from Agent 4)

**Statistics:**
- **Files Modified:** 431+ files (125 in libslic3r, 306 in GUI)
- **Files Added:** 120+ new files in OrcaSlicer
- **Files Unique to JusPrin:** 16 files (JusPrin/ directory)

**High-Conflict Areas:**
- Build system (CMakeLists.txt)
- UI branding (33 files with "JusPrin" references)
- Configuration (version.inc)
- Workflows (.github/workflows/)

**Safe to Merge:**
- New OrcaSlicer modules (DeviceCore, libvgcode)
- Bug fixes (mostly isolated)
- Profile updates
- Translation updates

---

## 2. JusPrin Custom Features to Preserve

### 2.1 Priority 1: AI System (MUST PRESERVE)

**Files:**
```
src/slic3r/GUI/JusPrin/JusPrinChatPanel.cpp
src/slic3r/GUI/JusPrin/JusPrinChatPanel.hpp
src/slic3r/GUI/JusPrin/JusPrinView3D.cpp
src/slic3r/GUI/JusPrin/JusPrinView3D.hpp
src/slic3r/GUI/JusPrin/JusPrinPlateUtils.cpp
src/slic3r/GUI/JusPrin/JusPrinPlateUtils.hpp
src/slic3r/GUI/JusPrin/JusPrinPresetConfigUtils.cpp
src/slic3r/GUI/JusPrin/JusPrinPresetConfigUtils.hpp
src/slic3r/GUI/JusPrin/JusPrinLoginDialog.cpp
src/slic3r/GUI/JusPrin/JusPrinLoginDialog.hpp
src/slic3r/GUI/JusPrin/JusPrinNotificationManager.cpp
src/slic3r/GUI/JusPrin/JusPrinNotificationManager.hpp
src/slic3r/GUI/JusPrin/JusPrinPricingPlanDialog.cpp
src/slic3r/GUI/JusPrin/JusPrinPricingPlanDialog.hpp
src/slic3r/GUI/JusPrin/JusPrinUtils.cpp
src/slic3r/GUI/JusPrin/JusPrinUtils.hpp
```

**Integration Points:** These files call into:
- `Plater.cpp` - Main workspace
- `GUI_App.cpp` - Application core
- `View3D.cpp` - 3D view base class
- `NotificationManager.cpp` - Notification system
- `PresetBundle.cpp` - Configuration management

**Update Strategy:**
- Keep JusPrin files as-is
- Update integration points if APIs changed
- Test all AI features after each phase

### 2.2 Priority 2: Branding (MUST PRESERVE)

**Visual Assets:**
```
resources/images/JusPrin.ico
resources/images/JusPrin.png
resources/images/JusPrin.svg
resources/images/JusPrin_128px.png
resources/web/jusprin/ (web chat interface)
```

**Code References (33 files with "JusPrin"):**
- Application name in titles, dialogs, about pages
- Binary names (jus-prin)
- Package names
- OAuth URLs to Obico
- Custom color schemes

**Update Strategy:**
- Use search & replace for branding conflicts
- Keep JusPrin branding, apply functional fixes from OrcaSlicer
- Review each conflict manually

### 2.3 Priority 3: Build Configuration (MODIFY CAREFULLY)

**Files:**
```
CMakeLists.txt (root)
src/CMakeLists.txt
version.inc
build_release_macos.sh
build_linux.sh
.github/workflows/
```

**Changes Needed:**
- Update for new dependencies (Draco, clipper2, md4c, earcut)
- Add libvgcode build target
- Update DeviceCore integration
- Maintain JusPrin binary naming
- Keep JusPrin version numbering

---

## 3. OrcaSlicer Changes to Integrate

### 3.1 Phase 1: Core Dependencies (Week 1-2)

**New Libraries to Add:**

1. **Clipper2** (deps_src/clipper2/)
   - Modern polygon clipping library
   - Replaces older Clipper in ~100+ files
   - Better performance and precision

2. **Draco** (deps/Draco/)
   - Google's 3D geometry compression
   - Enables .drc file format
   - Reduces calibration model sizes

3. **earcut** (deps_src/earcut/)
   - Fast polygon triangulation
   - Header-only library

4. **md4c** (deps_src/md4c/)
   - Markdown parser for documentation
   - Used in UI components

**New Source Files:**
```
src/libslic3r/Clipper2Utils.cpp/hpp
src/libslic3r/Clipper2ZUtils.hpp
src/libslic3r/Format/DRC.cpp/hpp
```

**Build System Updates:**
- Update root CMakeLists.txt for new deps
- Add Draco find_package
- Link new libraries to main targets

### 3.2 Phase 2: libvgcode Integration (Week 2-3)

**New Module:** `src/libvgcode/` (46 files)

**Purpose:**
- Complete rewrite of G-code visualization
- Ported from PrusaSlicer 2.8.0
- Major performance improvements

**Files to Add:**
```
src/libvgcode/
├── GCodeProcessor.cpp/hpp
├── GCodeReader.cpp/hpp
├── GCodeViewer.cpp/hpp
├── PathVertex.hpp
├── Processor.cpp/hpp
├── Viewer.cpp/hpp
└── ... (40 more files)
```

**Integration:**
- Add `add_subdirectory(libvgcode)` to src/CMakeLists.txt
- Link libvgcode to main OrcaSlicer target
- Update GUI to use new viewer API
- Preserve any JusPrin-specific preview features

### 3.3 Phase 3: DeviceCore Architecture (Week 3-4)

**New Module:** `src/slic3r/GUI/DeviceCore/` (50 files)

**Purpose:**
- Modular printer agent system
- Support for third-party AMS
- Better extensibility

**Key Files:**
```
src/slic3r/GUI/DeviceCore/
├── AMS.cpp/hpp
├── DeviceAgent.cpp/hpp
├── DeviceManager.cpp/hpp
├── FilamentSync.cpp/hpp
├── MoonrakerAgent.cpp/hpp
├── NetworkAgent.cpp/hpp
└── ... (44 more files)
```

**Integration:**
- Add DeviceCore to GUI CMakeLists.txt
- Update printer connectivity code
- Integrate with JusPrin AI system (AI can query printer status)
- Test network features thoroughly

### 3.4 Phase 4: Clipper2 Migration (Week 4-5)

**Impact:** ~100+ files use Clipper library

**Strategy:**
1. Add Clipper2Utils alongside old ClipperUtils
2. Migrate files one subsystem at a time:
   - Fill/ directory
   - Support/ directory
   - GCode/ directory
   - Geometry/ directory
3. Test each subsystem after migration
4. Remove old Clipper once all migrated

**Files Affected:**
- All fill pattern generators
- Support generation
- Perimeter generation
- Polygon offsetting operations

### 3.5 Phase 5: GUI Enhancements (Week 5-6)

**New GUI Components:**

1. **Filament Management:**
   ```
   FilamentGroup.cpp/hpp
   FilamentGroupUtils.cpp/hpp
   FilamentGroupPopup.cpp/hpp
   FilamentMapDialog/Panel.cpp/hpp
   FilamentPickerDialog.cpp/hpp
   ```

2. **UI Widgets:**
   ```
   CapsuleButton.cpp/hpp
   BaseTransparentDPIFrame.cpp/hpp
   ImageDPIFrame.cpp/hpp
   DragDropPanel.cpp/hpp
   ```

3. **Device Management:**
   ```
   DeviceErrorDialog.cpp/hpp
   NetworkPluginDialog.cpp/hpp
   ```

4. **Pre-Print Validation:**
   ```
   PrePrintChecker.cpp/hpp
   SafetyOptionsDialog.cpp/hpp
   ```

**Integration:**
- Add new files to GUI CMakeLists.txt
- Update existing UI code to use new components
- Preserve JusPrin chat panel integration
- Test UI on all platforms (Windows, macOS, Linux)

### 3.6 Phase 6: Core Algorithm Updates (Week 6-7)

**Slicing Improvements:**

1. **Support Generation:**
   - Rectilinear interlaced support
   - Better overhang detection
   - Raft and support interface improvements

2. **Multi-Material:**
   - Wipe tower preheat/cooldown
   - Flush volume optimization
   - Better tool ordering

3. **Geometry Processing:**
   - Mesh subdivision
   - Arc welder
   - Tool ordering utilities

**Files to Update:**
```
src/libslic3r/Support/
src/libslic3r/GCode/WipeTower.cpp
src/libslic3r/GCode/ToolOrderUtils.cpp/hpp
src/libslic3r/TriangleMeshDeal.cpp/hpp
src/libslic3r/Geometry/ArcWelder.cpp/hpp
```

### 3.7 Phase 7: Resource Updates (Week 7)

**Calibration Models (STL → DRC):**
```
resources/calib/input_shaping/
resources/calib/pressure_advance/
resources/calib/retraction/
resources/calib/temperature_tower/
resources/calib/vfa/ (NEW)
resources/calib/volumetric_speed/
```

**New Resources:**
```
resources/flush/ - Flush volume data
resources/hms/ - Hardware Management System data
```

**Strategy:**
- Copy new .drc files from OrcaSlicer
- Keep old .stl files for backward compatibility (optional)
- Update resource loading code to support .drc
- Test calibration workflows

### 3.8 Phase 8: Build System Finalization (Week 8)

**CMakeLists.txt Updates:**
- Add all new targets (libvgcode, DeviceCore)
- Link new dependencies (Draco, clipper2, etc.)
- Update JusPrin binary naming
- Maintain JusPrin version numbering

**Build Scripts:**
- Update macOS build script for new flags
- Update Linux build script for new dependencies
- Update Windows build scripts
- Test builds on all platforms

**CI/CD:**
- Update GitHub Actions workflows
- Add unit test execution
- Add test artifact upload/download
- Maintain JusPrin-specific workflows

---

## 4. Phased Implementation Plan

### Phase 1: Dependencies & Build System (Week 1-2)

**Goal:** Establish foundation for code integration

**Tasks:**
1. Add Draco dependency to `deps/`
2. Add clipper2 to `deps_src/`
3. Add earcut to `deps_src/`
4. Add md4c to `deps_src/`
5. Update root CMakeLists.txt for new deps
6. Test dependency builds on all platforms
7. Update build scripts for compatibility

**Validation:**
- [ ] All dependencies build successfully
- [ ] Existing JusPrin still builds
- [ ] No functionality broken

**Risk:** Low - additive changes only

---

### Phase 2: Core Libraries (Week 2-3)

**Goal:** Integrate libvgcode and update libslic3r

**Tasks:**
1. Copy `src/libvgcode/` from OrcaSlicer (46 files)
2. Add `add_subdirectory(libvgcode)` to src/CMakeLists.txt
3. Copy new libslic3r utility files:
   - Clipper2Utils.cpp/hpp
   - Clipper2ZUtils.hpp
   - CommonDefs.hpp
   - StreamUtils.hpp
   - MaterialType.cpp/hpp
   - PrintConfigConstants.hpp
4. Copy Format/DRC.cpp/hpp for Draco support
5. Link libvgcode to JusPrin target
6. Update CMakeLists.txt with new source files

**Validation:**
- [ ] libvgcode builds successfully
- [ ] New utility files compile
- [ ] JusPrin links and runs
- [ ] No new crashes

**Risk:** Medium - new major module

---

### Phase 3: DeviceCore Integration (Week 3-4)

**Goal:** Integrate modular device management

**Tasks:**
1. Copy `src/slic3r/GUI/DeviceCore/` (50 files)
2. Update src/slic3r/CMakeLists.txt with DeviceCore files
3. Update device management integration points
4. Merge printer agent changes
5. Test with JusPrin AI system integration

**Validation:**
- [ ] DeviceCore builds successfully
- [ ] Printer connectivity works
- [ ] Network features operational
- [ ] JusPrin AI can query printer status

**Risk:** High - major architectural change

---

### Phase 4: Clipper2 Migration (Week 4-5)

**Goal:** Migrate from Clipper to Clipper2

**Tasks:**
1. Add Clipper2Utils alongside existing ClipperUtils
2. Migrate Fill/ directory files (one by one)
3. Migrate Support/ directory files
4. Migrate GCode/ polygon operations
5. Migrate Geometry/ operations
6. Test each subsystem thoroughly
7. Remove old Clipper references (optional - can keep both)

**Validation:**
- [ ] All fill patterns work correctly
- [ ] Support generation unchanged
- [ ] No slicing differences (or acceptable)
- [ ] Performance equal or better

**Risk:** High - affects core algorithms

---

### Phase 5: GUI Enhancements (Week 5-6)

**Goal:** Integrate new UI components and dialogs

**Tasks:**
1. Copy new GUI files (~50 files):
   - FilamentGroup*.cpp/hpp
   - FilamentMap*.cpp/hpp
   - FilamentPicker*.cpp/hpp
   - CapsuleButton.cpp/hpp
   - DragDropPanel.cpp/hpp
   - PrePrintChecker.cpp/hpp
   - SafetyOptionsDialog.cpp/hpp
   - (and others)
2. Update existing GUI files (306 modified files):
   - Apply functional fixes
   - Preserve JusPrin branding
   - Merge UI improvements
3. Update Plater.cpp/hpp
4. Update GUI_App.cpp/hpp
5. Update Tab.cpp/hpp

**Conflict Resolution:**
- For branding conflicts: Keep JusPrin
- For functional improvements: Merge OrcaSlicer
- For UI layout: Test both, choose best

**Validation:**
- [ ] All new dialogs work
- [ ] Filament picker functional
- [ ] JusPrin chat panel still works
- [ ] No UI regressions

**Risk:** Medium-High - many files affected

---

### Phase 6: Algorithm Updates (Week 6-7)

**Goal:** Merge slicing algorithm improvements

**Tasks:**
1. Update Support/ directory files
2. Update GCode/WipeTower.cpp (multi-material improvements)
3. Add GCode/ToolOrderUtils.cpp/hpp
4. Add Geometry/ArcWelder.cpp/hpp
5. Update TriangleMeshDeal.cpp/hpp
6. Add FlushVolPredictor.cpp/hpp
7. Test slicing with various models

**Validation:**
- [ ] Support generation works
- [ ] Multi-material slicing functional
- [ ] Wipe tower generates correctly
- [ ] G-code output valid
- [ ] No crashes on complex models

**Risk:** Medium - core algorithms

---

### Phase 7: Resources & Assets (Week 7)

**Goal:** Update calibration models and resources

**Tasks:**
1. Copy new .drc calibration models
2. Copy resources/flush/ directory
3. Copy resources/hms/ directory
4. Update resource loading code for .drc
5. Test calibration workflows

**Validation:**
- [ ] Calibration models load
- [ ] Calibration wizards work
- [ ] .drc format supported
- [ ] Backward compatibility with .stl

**Risk:** Low - mostly additive

---

### Phase 8: JusPrin AI Integration (Week 8)

**Goal:** Ensure AI system works with all changes

**Tasks:**
1. Update JusPrinPresetConfigUtils for new config options
2. Update JusPrinPlateUtils for new rendering APIs
3. Test JusPrinChatPanel with new libvgcode
4. Test printer control with DeviceCore
5. Update JusPrinNotificationManager for new notifications
6. Test OAuth authentication
7. Test all AI agent actions:
   - get_presets
   - apply_config
   - render_plate
   - start_slicer_all
   - auto_orient_all_objects
   - (and 20+ others)

**Validation:**
- [ ] Chat panel loads and displays
- [ ] AI can query presets
- [ ] AI can apply configurations
- [ ] AI can render thumbnails
- [ ] AI receives slicing progress
- [ ] All agent actions functional

**Risk:** Medium - integration points may break

---

### Phase 9: Testing & Validation (Week 9)

**Goal:** Comprehensive testing before release

**Tasks:**
1. Run unit tests: `cd build && ctest`
2. Test on macOS (arm64 and x86_64)
3. Test on Linux (Ubuntu 20.04, 24.04)
4. Test on Windows (if applicable)
5. Test all major workflows:
   - Load model → Slice → Preview → Export
   - Multi-material printing
   - Printer connectivity
   - Calibration workflows
   - AI chat interactions
6. Performance testing (memory, speed)
7. Regression testing (known issues)

**Validation:**
- [ ] All tests pass
- [ ] No crashes on all platforms
- [ ] Performance equal or better
- [ ] JusPrin branding intact
- [ ] AI features fully functional

**Risk:** Low - testing phase

---

### Phase 10: Documentation & Release (Week 10)

**Goal:** Document changes and prepare release

**Tasks:**
1. Update README.md
2. Create CHANGELOG.md (OrcaSlicer v2.3.1 → v2.3.2-dev changes)
3. Document new features for users
4. Update build instructions
5. Create release notes
6. Tag release: `v1.5.0-beta` (or similar)
7. Beta release to limited users
8. Monitor for issues

**Validation:**
- [ ] Documentation complete
- [ ] Beta users can install and use
- [ ] No critical bugs reported
- [ ] Feedback incorporated

**Risk:** Low - final polish

---

## 5. Conflict Resolution Strategy

### 5.1 File Conflict Categories

**Category A: Keep JusPrin (Branding)**
- version.inc
- Resources with "JusPrin" branding
- About dialog
- Application name references

**Strategy:** Keep JusPrin version, manually apply functional fixes from OrcaSlicer

---

**Category B: Keep OrcaSlicer (Bug Fixes)**
- Bug fix commits
- Core algorithm improvements
- Memory leak fixes
- Crash fixes

**Strategy:** Accept OrcaSlicer version, re-apply JusPrin branding if needed

---

**Category C: Merge Both (Functional + Branding)**
- GUI_App.cpp
- Plater.cpp
- Tab.cpp
- NotificationManager.cpp

**Strategy:**
1. Accept OrcaSlicer functional changes
2. Re-add JusPrin-specific code (AI integration)
3. Update branding references
4. Test thoroughly

---

**Category D: New OrcaSlicer Files (No Conflict)**
- libvgcode/ (46 files)
- DeviceCore/ (50 files)
- New utility files

**Strategy:** Copy directly from OrcaSlicer

---

**Category E: JusPrin Custom Files (No Conflict)**
- JusPrin/ directory (16 files)

**Strategy:** Keep as-is, update only if APIs changed

---

### 5.2 Specific File Conflict Resolution

#### CMakeLists.txt (Root)

**Conflicts:**
- Project name (OrcaSlicer vs JusPrin)
- Version numbers
- Compile definitions (BBL_RELEASE_TO_PUBLIC)

**Resolution:**
```cmake
# From OrcaSlicer - take new structure
cmake_minimum_required(VERSION 3.13...3.31)
cmake_policy(VERSION 3.13...3.31)

# From JusPrin - keep project name in comments, but use OrcaSlicer for compatibility
project(OrcaSlicer)  # Keep as OrcaSlicer for build system compatibility

# From JusPrin - use JusPrin versioning
include(version.inc)  # Will set SLIC3R_APP_NAME="JusPrin"

# From OrcaSlicer - take new logic
if(APPLE OR WIN32)
    set(BBL_RELEASE_TO_PUBLIC "1")
else()
    set(BBL_RELEASE_TO_PUBLIC "0")
endif()

# From OrcaSlicer - take new dependencies
find_package(Draco REQUIRED)
add_subdirectory(deps_src/clipper2)
add_subdirectory(deps_src/earcut)
add_subdirectory(deps_src/md4c)

# From JusPrin - keep any custom flags
```

---

#### src/CMakeLists.txt

**Conflicts:**
- Target name (OrcaSlicer vs JusPrin)
- libvgcode subdirectory (new in Orca)
- Source file lists

**Resolution:**
```cmake
# From OrcaSlicer - add new subdirectory
add_subdirectory(libvgcode)

# From JusPrin - keep target naming
if(WIN32)
    add_library(JusPrin SHARED ${SOURCES})
else()
    add_executable(JusPrin ${SOURCES})
endif()

set_target_properties(JusPrin PROPERTIES OUTPUT_NAME "jus-prin")

# From OrcaSlicer - link new libraries
target_link_libraries(JusPrin
    libslic3r
    libvgcode  # NEW
    ${DEPS}
)
```

---

#### version.inc

**Conflicts:**
- SLIC3R_APP_NAME
- SoftFever_VERSION

**Resolution:**
```cmake
# Keep JusPrin branding
set(SLIC3R_APP_NAME "JusPrin")
set(SLIC3R_APP_KEY "JusPrin")

# Update to reflect merge
set(SoftFever_VERSION "1.5.0")  # JusPrin version (based on Orca 2.3.2-dev)

# Keep JusPrin configuration
set(BBL_INTERNAL_TESTING "0")
set(SLIC3R_VERSION "01.10.01.50")
```

---

#### src/slic3r/GUI/Plater.cpp

**Conflicts:**
- JusPrinView3D vs standard View3D
- JusPrin chat panel integration
- OrcaSlicer functional improvements

**Resolution:**
1. Take OrcaSlicer version as base
2. Search for JusPrin modifications in old file
3. Re-add JusPrin-specific code:
   ```cpp
   // JusPrin: Use custom View3D with chat panel
   #include "JusPrin/JusPrinView3D.hpp"

   // Replace View3D with JusPrinView3D
   m_view3D = new JusPrinView3D(this, ...);
   ```
4. Test chat panel integration

---

#### src/slic3r/GUI/GUI_App.cpp

**Conflicts:**
- Application initialization
- JusPrin OAuth setup
- OrcaSlicer improvements

**Resolution:**
1. Take OrcaSlicer version as base
2. Re-add JusPrin initialization:
   ```cpp
   #include "JusPrin/JusPrinUtils.hpp"

   // JusPrin: Initialize AI system
   JusPrinUtils::InitializeJusPrin();
   ```
3. Test application startup

---

#### src/slic3r/GUI/NotificationManager.cpp

**Conflicts:**
- JusPrinNotificationManager inheritance
- OrcaSlicer notification improvements

**Resolution:**
1. Keep NotificationManager from OrcaSlicer with improvements
2. Ensure JusPrinNotificationManager still inherits correctly
3. Update JusPrinNotificationManager.cpp if APIs changed
4. Test notification forwarding to AI

---

## 6. Testing & Validation

### 6.1 Unit Tests

**Run after each phase:**
```bash
cd build
ctest --output-on-failure
```

**Expected:**
- All existing tests pass
- No new test failures

---

### 6.2 Build Testing

**Platforms:**
- macOS 11.3+ (arm64)
- macOS 11.3+ (x86_64)
- macOS Universal Binary
- Ubuntu 20.04 LTS
- Ubuntu 24.04 LTS
- Windows 10/11 (MSVC 2022)

**Commands:**
```bash
# macOS
./build_release_macos.sh -a arm64
./build_release_macos.sh -a x86_64
./build_release_macos.sh -a universal

# Linux
./build_linux.sh -dsi

# Windows
build_release_vs2022.bat
```

**Validation:**
- [ ] Clean build completes
- [ ] No compiler errors
- [ ] No linker errors
- [ ] Binary runs without crashes

---

### 6.3 Functional Testing

**Critical Workflows:**

1. **Model Loading**
   - [ ] Load STL file
   - [ ] Load 3MF file
   - [ ] Load DRC file (new)
   - [ ] Load OBJ file
   - [ ] Load STEP file

2. **Slicing**
   - [ ] Single material slicing
   - [ ] Multi-material slicing
   - [ ] Tree supports
   - [ ] Rectilinear supports
   - [ ] Lightning infill
   - [ ] Adaptive infill

3. **Preview**
   - [ ] 3D preview loads (libvgcode)
   - [ ] Layer slider works
   - [ ] Feature color legend
   - [ ] Camera controls

4. **Export**
   - [ ] Export G-code
   - [ ] Export 3MF project
   - [ ] Export STL
   - [ ] Send to printer

5. **JusPrin AI Features**
   - [ ] Chat panel loads
   - [ ] OAuth login works
   - [ ] AI can query presets
   - [ ] AI can apply config
   - [ ] AI can render thumbnails
   - [ ] AI receives notifications
   - [ ] AI can start slicing
   - [ ] AI can auto-orient models
   - [ ] All 20+ agent actions work

6. **Printer Connectivity**
   - [ ] Detect printers (DeviceCore)
   - [ ] Connect to Bambu Lab printer
   - [ ] Connect to Moonraker printer
   - [ ] Connect to OctoPrint
   - [ ] File transfer works
   - [ ] Print job monitoring

7. **Calibration**
   - [ ] Temperature tower
   - [ ] Pressure advance
   - [ ] Retraction test
   - [ ] VFA tower (new)
   - [ ] Input shaping

---

### 6.4 Performance Testing

**Metrics:**
- Slicing time (should not regress)
- Memory usage (should improve with optimizations)
- Preview rendering FPS
- UI responsiveness

**Test Models:**
- Simple cube (baseline)
- Benchy (standard test)
- Complex multi-part assembly
- Large model (high polygon count)
- Multi-material model

---

### 6.5 Regression Testing

**Known Issues to Verify Fixed:**
- [ ] Linux 3D preview crash (EGL/GLX)
- [ ] 3MF import crash
- [ ] Wayland setup wizard hang
- [ ] Printer configuration hang

**JusPrin Specific:**
- [ ] Chat panel doesn't break
- [ ] OAuth authentication works
- [ ] AI features don't crash

---

## 7. Risk Mitigation

### 7.1 Backup Strategy

**Before starting:**
```bash
cd /Users/stillbulldog35/Documents/GitHub/JusPrin
git checkout main
git tag v1.4.0-pre-merge
git checkout -b backup/pre-merge-2026-02-18
git push origin backup/pre-merge-2026-02-18
```

**Rollback if needed:**
```bash
git checkout main
git reset --hard v1.4.0-pre-merge
```

---

### 7.2 Incremental Commits

**Commit strategy:**
- One commit per phase
- Clear commit messages
- Tag each milestone

**Example:**
```bash
git commit -m "Phase 1: Add dependencies (Draco, Clipper2, earcut, md4c)"
git tag phase-1-complete

git commit -m "Phase 2: Integrate libvgcode (46 files)"
git tag phase-2-complete
```

---

### 7.3 Feature Branches

**Use branches for risky changes:**
```bash
git checkout -b feature/clipper2-migration
# Make changes
# Test thoroughly
git checkout main
git merge feature/clipper2-migration
```

---

### 7.4 Testing Checkpoints

**After each phase:**
1. Run unit tests
2. Build on all platforms
3. Test critical workflows
4. Test JusPrin AI features
5. Document any issues

**Do not proceed to next phase if:**
- Tests fail
- Build breaks
- Critical features broken
- AI system not working

---

## 8. File-by-File Merge Instructions

### 8.1 New Files to Copy (No Conflicts)

**From OrcaSlicer → JusPrin:**

#### Dependencies
```bash
# Copy entire directories
cp -r /path/to/OrcaSlicer/deps_src/clipper2/ deps_src/
cp -r /path/to/OrcaSlicer/deps_src/earcut/ deps_src/
cp -r /path/to/OrcaSlicer/deps_src/md4c/ deps_src/
cp -r /path/to/OrcaSlicer/deps/Draco/ deps/
```

#### libvgcode (46 files)
```bash
cp -r /path/to/OrcaSlicer/src/libvgcode/ src/
```

#### DeviceCore (50 files)
```bash
cp -r /path/to/OrcaSlicer/src/slic3r/GUI/DeviceCore/ src/slic3r/GUI/
```

#### New libslic3r files
```bash
cp /path/to/OrcaSlicer/src/libslic3r/Clipper2Utils.* src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/Clipper2ZUtils.hpp src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/CommonDefs.hpp src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/StreamUtils.hpp src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/MaterialType.* src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/PrintConfigConstants.hpp src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/FilamentGroup.* src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/FilamentGroupUtils.* src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/FlushVolPredictor.* src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/TriangleMeshDeal.* src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/ObjColorUtils.cpp src/libslic3r/
cp /path/to/OrcaSlicer/src/libslic3r/Format/DRC.* src/libslic3r/Format/
cp /path/to/OrcaSlicer/src/libslic3r/GCode/TimelapsePosPicker.* src/libslic3r/GCode/
cp /path/to/OrcaSlicer/src/libslic3r/GCode/ToolOrderUtils.* src/libslic3r/GCode/
cp /path/to/OrcaSlicer/src/libslic3r/Geometry/ArcWelder.* src/libslic3r/Geometry/
```

#### New GUI files (~50 files)
```bash
# Create list of new GUI files from research
# Copy each one manually or via script
cp /path/to/OrcaSlicer/src/slic3r/GUI/FilamentGroup*.* src/slic3r/GUI/
cp /path/to/OrcaSlicer/src/slic3r/GUI/FilamentMap*.* src/slic3r/GUI/
cp /path/to/OrcaSlicer/src/slic3r/GUI/FilamentPicker*.* src/slic3r/GUI/
cp /path/to/OrcaSlicer/src/slic3r/GUI/CapsuleButton.* src/slic3r/GUI/
cp /path/to/OrcaSlicer/src/slic3r/GUI/DragDropPanel.* src/slic3r/GUI/
cp /path/to/OrcaSlicer/src/slic3r/GUI/PrePrintChecker.* src/slic3r/GUI/
cp /path/to/OrcaSlicer/src/slic3r/GUI/SafetyOptionsDialog.* src/slic3r/GUI/
# ... (continue for all new GUI files)
```

#### Resources
```bash
# Calibration models (.drc format)
cp -r /path/to/OrcaSlicer/resources/calib/ resources/

# New resource directories
cp -r /path/to/OrcaSlicer/resources/flush/ resources/
cp -r /path/to/OrcaSlicer/resources/hms/ resources/
```

---

### 8.2 Files to Merge (Conflicts Expected)

**For each file:**
1. Create backup: `cp file.cpp file.cpp.jusprin_backup`
2. Copy OrcaSlicer version: `cp /path/to/OrcaSlicer/file.cpp ./`
3. Compare: `diff -u file.cpp.jusprin_backup file.cpp`
4. Identify JusPrin-specific code
5. Re-add JusPrin code to OrcaSlicer version
6. Test compilation
7. Test functionality

**Priority files to merge:**

#### Build System (High Priority)
```
CMakeLists.txt (root)
src/CMakeLists.txt
src/slic3r/CMakeLists.txt
src/libslic3r/CMakeLists.txt
version.inc
build_release_macos.sh
build_linux.sh
build_release_vs2022.bat
```

#### Core Application (High Priority)
```
src/libslic3r/libslic3r.h
src/OrcaSlicer.cpp
src/slic3r/GUI/GUI_App.cpp/hpp
src/slic3r/GUI/Plater.cpp/hpp
src/slic3r/GUI/MainFrame.cpp/hpp
```

#### UI Components (Medium Priority)
```
src/slic3r/GUI/Tab.cpp/hpp
src/slic3r/GUI/Preferences.cpp/hpp
src/slic3r/GUI/AboutDialog.cpp/hpp
src/slic3r/GUI/NotificationManager.cpp/hpp
src/slic3r/GUI/WebView.cpp/hpp
```

#### Slicing Core (Medium Priority)
```
src/libslic3r/Print.cpp/hpp
src/libslic3r/PrintObject.cpp/hpp
src/libslic3r/PrintConfig.cpp/hpp
src/libslic3r/GCode.cpp/hpp
```

---

## 9. AI System Impact Analysis

### 9.1 Configuration System Changes

**AI Dependency:** JusPrinPresetConfigUtils queries and modifies presets via JSON

**Potential Impacts:**
- New config options in OrcaSlicer
- Renamed config keys
- Changed value formats
- New preset inheritance rules

**Mitigation:**
1. Test `get_presets` action after Phase 5
2. Test `apply_config` action with new options
3. Verify JSON serialization still works
4. Update AI cloud service if config schema changed

**Validation:**
```cpp
// Test preset retrieval
nlohmann::json presets = JusPrinPresetConfigUtils::GetAllPresets();
// Verify structure matches expected format

// Test config application
nlohmann::json config = {{"layer_height", 0.2}, {"infill_density", 20}};
bool success = JusPrinPresetConfigUtils::ApplyConfig(config);
// Verify settings applied correctly
```

---

### 9.2 Rendering System Changes (libvgcode)

**AI Dependency:** JusPrinPlateUtils generates thumbnails for AI analysis

**Potential Impacts:**
- Preview rendering API changes
- OpenGL context requirements
- Thumbnail generation methods

**Mitigation:**
1. Test `render_plate` action after Phase 2
2. Verify thumbnail quality
3. Update rendering code if APIs changed

**Validation:**
```cpp
// Test thumbnail generation
std::string base64_image = JusPrinPlateUtils::RenderPlate(camera_params);
// Verify image is valid base64 JPEG
```

---

### 9.3 Slicing Progress Reporting

**AI Dependency:** Chat panel receives real-time progress updates

**Potential Impacts:**
- Progress callback API changes
- New progress message formats

**Mitigation:**
1. Test slicing after Phase 6
2. Verify progress events sent to chat
3. Update event forwarding if needed

**Validation:**
```cpp
// During slicing, verify events sent:
// SendSlicingProgressEvent(percent, "Generating support...")
// SendSlicingProgressEvent(100, "Slicing complete")
```

---

### 9.4 Printer Control (DeviceCore)

**AI Dependency:** AI may query printer status or send files

**Potential Impacts:**
- Printer agent API changes
- New device management methods
- Connection status reporting

**Mitigation:**
1. Test printer connectivity after Phase 3
2. Update AI actions if APIs changed
3. Test file transfer workflows

**Validation:**
- [ ] AI can query connected printers
- [ ] AI can send G-code to printer
- [ ] AI receives printer status updates

---

### 9.5 Model Operations

**AI Dependency:** AI can auto-orient and arrange models

**Potential Impacts:**
- Orient.cpp algorithm changes
- Arrange API changes

**Mitigation:**
1. Test `auto_orient_all_objects` action
2. Test `arrange_all_objects` action
3. Verify algorithms still produce good results

**Validation:**
```cpp
// Test auto-orientation
JusPrinUtils::AutoOrientAllObjects();
// Verify models oriented correctly

// Test auto-arrangement
JusPrinUtils::ArrangeAllObjects();
// Verify models arranged on build plate
```

---

### 9.6 Agent Actions Compatibility

**All AI Agent Actions (20+):**

**Synchronous (return JSON):**
- [x] `get_presets` - Test after Phase 5
- [x] `get_edited_presets` - Test after Phase 5
- [x] `render_plate` - Test after Phase 2
- [x] `select_preset` - Test after Phase 5
- [x] `apply_config` - Test after Phase 5
- [x] `get_current_project` - Test after Phase 6

**Asynchronous (void):**
- [x] `start_slicer_all` - Test after Phase 6
- [x] `export_gcode` - Test after Phase 6
- [x] `auto_orient_all_objects` - Test after Phase 6
- [x] `arrange_all_objects` - Test after Phase 6
- [x] `switch_to_preview` - Test after Phase 2
- [x] `show_login` - Test after Phase 8
- [x] `show_pricing_plan` - Test after Phase 8
- [x] `add_printers` - Test after Phase 3
- [x] `add_filaments` - Test after Phase 5
- [x] `plater_undo` - Test after Phase 5

**Testing Script:**
```python
# Test each action
actions_to_test = [
    "get_presets",
    "render_plate",
    "apply_config",
    "start_slicer_all",
    # ... (all actions)
]

for action in actions_to_test:
    result = test_action(action)
    assert result.success, f"Action {action} failed"
```

---

## 10. Implementation Checklist

### Pre-Implementation
- [ ] Read and understand this entire document
- [ ] Back up JusPrin repository
- [ ] Create backup branch: `backup/pre-merge-2026-02-18`
- [ ] Tag current state: `v1.4.0-pre-merge`
- [ ] Set up test environment (macOS, Linux, Windows)
- [ ] Notify team of upcoming merge

---

### Phase 1: Dependencies (Week 1-2)
- [ ] Copy deps_src/clipper2/
- [ ] Copy deps_src/earcut/
- [ ] Copy deps_src/md4c/
- [ ] Copy deps/Draco/
- [ ] Update root CMakeLists.txt for new deps
- [ ] Test dependency builds on macOS
- [ ] Test dependency builds on Linux
- [ ] Test dependency builds on Windows
- [ ] Commit: "Phase 1: Add dependencies"
- [ ] Tag: `phase-1-complete`

---

### Phase 2: libvgcode (Week 2-3)
- [ ] Copy src/libvgcode/ (46 files)
- [ ] Add subdirectory to src/CMakeLists.txt
- [ ] Copy Clipper2Utils files
- [ ] Copy Format/DRC files
- [ ] Copy other new libslic3r utility files
- [ ] Update src/libslic3r/CMakeLists.txt
- [ ] Link libvgcode to JusPrin target
- [ ] Test build on all platforms
- [ ] Test preview rendering
- [ ] Test JusPrinPlateUtils::RenderPlate()
- [ ] Commit: "Phase 2: Integrate libvgcode"
- [ ] Tag: `phase-2-complete`

---

### Phase 3: DeviceCore (Week 3-4)
- [ ] Copy src/slic3r/GUI/DeviceCore/ (50 files)
- [ ] Update src/slic3r/CMakeLists.txt
- [ ] Update device management integration
- [ ] Test printer connectivity
- [ ] Test with Bambu Lab printer
- [ ] Test with Moonraker printer
- [ ] Test AI printer control actions
- [ ] Commit: "Phase 3: Integrate DeviceCore"
- [ ] Tag: `phase-3-complete`

---

### Phase 4: Clipper2 Migration (Week 4-5)
- [ ] Add Clipper2Utils to project
- [ ] Migrate Fill/ directory files
- [ ] Test fill patterns
- [ ] Migrate Support/ directory files
- [ ] Test support generation
- [ ] Migrate GCode/ polygon operations
- [ ] Test G-code generation
- [ ] Migrate Geometry/ operations
- [ ] Run full slicing tests
- [ ] Commit: "Phase 4: Migrate to Clipper2"
- [ ] Tag: `phase-4-complete`

---

### Phase 5: GUI Enhancements (Week 5-6)
- [ ] Copy new GUI files (~50 files)
- [ ] Update src/slic3r/CMakeLists.txt
- [ ] Merge Plater.cpp (preserve JusPrinView3D)
- [ ] Merge GUI_App.cpp (preserve JusPrin init)
- [ ] Merge Tab.cpp
- [ ] Merge Preferences.cpp
- [ ] Merge NotificationManager.cpp
- [ ] Test all dialogs
- [ ] Test filament picker
- [ ] Test JusPrin chat panel
- [ ] Test AI `get_presets` action
- [ ] Test AI `apply_config` action
- [ ] Commit: "Phase 5: GUI enhancements"
- [ ] Tag: `phase-5-complete`

---

### Phase 6: Algorithm Updates (Week 6-7)
- [ ] Update Support/ directory files
- [ ] Update GCode/WipeTower.cpp
- [ ] Add GCode/ToolOrderUtils files
- [ ] Add Geometry/ArcWelder files
- [ ] Update TriangleMeshDeal files
- [ ] Add FlushVolPredictor files
- [ ] Test single-material slicing
- [ ] Test multi-material slicing
- [ ] Test support generation
- [ ] Test wipe tower
- [ ] Test AI `start_slicer_all` action
- [ ] Test AI receives progress events
- [ ] Commit: "Phase 6: Algorithm updates"
- [ ] Tag: `phase-6-complete`

---

### Phase 7: Resources (Week 7)
- [ ] Copy resources/calib/ (.drc models)
- [ ] Copy resources/flush/
- [ ] Copy resources/hms/
- [ ] Update resource loading for .drc
- [ ] Test calibration wizards
- [ ] Test temperature tower
- [ ] Test pressure advance
- [ ] Test new VFA tower
- [ ] Commit: "Phase 7: Update resources"
- [ ] Tag: `phase-7-complete`

---

### Phase 8: JusPrin AI Integration (Week 8)
- [ ] Update JusPrinPresetConfigUtils for new config
- [ ] Update JusPrinPlateUtils for new APIs
- [ ] Test JusPrinChatPanel loads
- [ ] Test OAuth login
- [ ] Test all 20+ AI agent actions:
  - [ ] get_presets
  - [ ] get_edited_presets
  - [ ] select_preset
  - [ ] apply_config
  - [ ] render_plate
  - [ ] get_current_project
  - [ ] start_slicer_all
  - [ ] export_gcode
  - [ ] auto_orient_all_objects
  - [ ] arrange_all_objects
  - [ ] switch_to_preview
  - [ ] show_login
  - [ ] show_pricing_plan
  - [ ] add_printers
  - [ ] add_filaments
  - [ ] plater_undo
  - [ ] set_btn_notification_badges
  - [ ] (and others)
- [ ] Test AI receives events:
  - [ ] autoOrient
  - [ ] modelObjectsChanged
  - [ ] nativeErrorOccurred
  - [ ] notificationPushed
  - [ ] chatPanelFocus
  - [ ] slicingProgress
- [ ] Commit: "Phase 8: Integrate JusPrin AI"
- [ ] Tag: `phase-8-complete`

---

### Phase 9: Testing (Week 9)
- [ ] Run unit tests: `cd build && ctest`
- [ ] Build on macOS arm64
- [ ] Build on macOS x86_64
- [ ] Build on macOS universal
- [ ] Build on Linux Ubuntu 20.04
- [ ] Build on Linux Ubuntu 24.04
- [ ] Build on Windows
- [ ] Test all critical workflows
- [ ] Test JusPrin AI features end-to-end
- [ ] Performance testing
- [ ] Memory leak testing
- [ ] Regression testing
- [ ] Commit: "Phase 9: Testing complete"
- [ ] Tag: `phase-9-complete`

---

### Phase 10: Release (Week 10)
- [ ] Update README.md
- [ ] Create CHANGELOG.md
- [ ] Update build instructions
- [ ] Create release notes
- [ ] Tag release: `v1.5.0-beta`
- [ ] Build release binaries for all platforms
- [ ] Beta release to limited users
- [ ] Monitor for critical bugs
- [ ] Fix issues found in beta
- [ ] Tag stable release: `v1.5.0`
- [ ] Public release announcement

---

### Post-Release
- [ ] Monitor user feedback
- [ ] Fix any critical bugs
- [ ] Plan next sync (monthly recommended)
- [ ] Document lessons learned
- [ ] Update this plan based on experience

---

## Appendix A: Quick Reference

### Repository Paths
- **JusPrin:** `/Users/stillbulldog35/Documents/GitHub/JusPrin`
- **OrcaSlicer:** `/Users/stillbulldog35/Documents/personalGithub/OrcaSlicer`

### Key Statistics
- **Commits Behind:** 2,913
- **Time Behind:** 4 months
- **Bug Fixes Missed:** ~592
- **New Files to Add:** ~120
- **Files to Merge:** ~431
- **JusPrin Custom Files:** 16

### Critical Files
**Must Preserve (JusPrin):**
- src/slic3r/GUI/JusPrin/ (all 16 files)
- resources/images/JusPrin.*
- version.inc (SLIC3R_APP_NAME)

**Must Integrate (OrcaSlicer):**
- src/libvgcode/ (46 files)
- src/slic3r/GUI/DeviceCore/ (50 files)
- deps_src/clipper2/
- deps/Draco/

### Build Commands
```bash
# macOS
./build_release_macos.sh -a arm64

# Linux
./build_linux.sh -dsi

# Windows
build_release_vs2022.bat

# Test
cd build && ctest --output-on-failure
```

### Git Commands
```bash
# Backup
git tag v1.4.0-pre-merge
git checkout -b backup/pre-merge-2026-02-18

# Work
git checkout -b feature/orcaslicer-merge

# Compare
diff -u file1 file2

# Commit each phase
git commit -m "Phase N: Description"
git tag phase-N-complete
```

---

## Appendix B: Contact & Resources

### Documentation Generated
- [JUSPRIN_ORCASLICER_MERGE_MASTER_PLAN.md](JUSPRIN_ORCASLICER_MERGE_MASTER_PLAN.md) (this file)
- JUSPRIN_ORCASLICER_CHANGES_TRACKING.md (to be created)
- JUSPRIN_ORCASLICER_MERGE_README.md (to be created)

### Research Documents (from agents)
- /tmp/EXECUTIVE_SUMMARY.txt
- /tmp/SYNC_ACTION_PLAN.md
- /tmp/git_history_analysis_summary.md
- /tmp/detailed_feature_breakdown.md
- MERGE_ANALYSIS.md

### Key Resources
- OrcaSlicer GitHub: https://github.com/OrcaSlicer/OrcaSlicer
- JusPrin GitHub: https://github.com/TheSpaghettiDetective/JusPrin
- OrcaSlicer Wiki: https://orcaslicer.com/wiki
- Obico (JusPrin AI): https://app.obico.io

---

**END OF MASTER PLAN**

**Next Steps:**
1. Review this plan thoroughly
2. Create backup branch
3. Begin Phase 1: Dependencies
4. Follow checklist systematically
5. Test after each phase
6. Do not skip validation steps

**Estimated Total Time:** 8-10 weeks (conservative)
**Risk Level:** High (major architectural changes)
**Success Probability:** High (with careful execution)

Good luck! 🚀
