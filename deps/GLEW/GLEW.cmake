# We have to check for OpenGL to compile GLEW
set(OpenGL_GL_PREFERENCE "LEGACY") # to prevent a nasty warning by cmake
find_package(OpenGL QUIET REQUIRED)

orcaslicer_add_cmake_project(
  GLEW
  SOURCE_DIR  ${CMAKE_CURRENT_LIST_DIR}/glew
  PATCH_COMMAND find . -name "CMakeLists.txt" -exec sed -i.bak "s/cmake_minimum_required[ ]*(VERSION[ ]*[0-9]\\.[0-9]\\.[0-9]*)/cmake_minimum_required (VERSION 3.13)/g" {} +
)

if (MSVC)
    add_debug_dep(dep_GLEW)
endif ()
