orcaslicer_add_cmake_project(libnoise
    URL https://github.com/SoftFever/Orca-deps-libnoise/archive/refs/tags/1.0.zip
        URL_HASH SHA256=96ffd6cc47898dd8147aab53d7d1b1911b507d9dbaecd5613ca2649468afd8b6
        PATCH_COMMAND find . -name "CMakeLists.txt" -exec sed -i.bak "s/cmake_minimum_required[ ]*(VERSION[ ]*[0-9]\.[0-9]\.[0-9]*)/cmake_minimum_required (VERSION 3.13)/g" {} +
)