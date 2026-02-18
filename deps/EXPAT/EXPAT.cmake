orcaslicer_add_cmake_project(EXPAT
  # GIT_REPOSITORY https://github.com/nigels-com/glew.git
  # GIT_TAG 3a8eff7 # 2.1.0
  SOURCE_DIR          ${CMAKE_CURRENT_LIST_DIR}/expat
  PATCH_COMMAND find . -name "CMakeLists.txt" -exec sed -i.bak "s/cmake_minimum_required[ ]*(VERSION[ ]*[0-9]\.[0-9]\.[0-9]*)/cmake_minimum_required (VERSION 3.13)/g" {} +
)

if (MSVC)
    add_debug_dep(dep_EXPAT)
endif ()
