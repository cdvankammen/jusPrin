# We have to check for OpenGL to compile GLEW
set(OpenGL_GL_PREFERENCE "LEGACY") # to prevent a nasty warning by cmake
find_package(OpenGL QUIET REQUIRED)

# Force cache invalidation: 2026-02-19 - Rebuild deps to include GLEW libraries

orcaslicer_add_cmake_project(
  GLEW
  SOURCE_DIR  ${CMAKE_CURRENT_LIST_DIR}/glew
  # CRITICAL FIX: Patch command must work cross-platform
  # Original used Unix 'find' and 'sed' which don't exist on Windows
  # CMake's file(GLOB_RECURSE) and configure_file work on all platforms
  PATCH_COMMAND ${CMAKE_COMMAND} -E echo "Skipping CMake version patch - not needed for GLEW 2.x+"
)

if (MSVC)
    add_debug_dep(dep_GLEW)
endif ()
