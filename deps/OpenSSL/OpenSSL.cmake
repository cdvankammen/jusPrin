
include(ProcessorCount)
ProcessorCount(NPROC)

# ---------------------------------------------------------------------------
# Option: use OpenSSL 3.3.x LTS instead of the legacy 1.1.1w branch.
# Toggle with -DDEP_OPENSSL_USE_3=ON at deps configure time.
# ---------------------------------------------------------------------------
option(DEP_OPENSSL_USE_3 "Build OpenSSL 3.3.2 (LTS) instead of 1.1.1w" OFF)

if(DEFINED OPENSSL_ARCH)
    set(_cross_arch ${OPENSSL_ARCH})
else()
    if(WIN32)
        set(_cross_arch "VC-WIN64A")
    elseif(APPLE)
        set(_cross_arch "darwin64-arm64-cc")
    endif()
endif()

if(WIN32)
    set(_conf_cmd perl Configure )
    set(_cross_comp_prefix_line "")
    set(_make_cmd nmake)
    set(_install_cmd nmake install_sw )
else()
    if(APPLE)
        set(_conf_cmd export MACOSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET} && ./Configure -mmacosx-version-min=${CMAKE_OSX_DEPLOYMENT_TARGET})
    else()
        set(_conf_cmd "./config")
    endif()
    set(_cross_comp_prefix_line "")
    set(_make_cmd make -j${NPROC})
    set(_install_cmd make -j${NPROC} install_sw)
    if (CMAKE_CROSSCOMPILING)
        set(_cross_comp_prefix_line "--cross-compile-prefix=${TOOLCHAIN_PREFIX}-")

        if (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "aarch64" OR ${CMAKE_SYSTEM_PROCESSOR} STREQUAL "arm64")
            set(_cross_arch "linux-aarch64")
        elseif (${CMAKE_SYSTEM_PROCESSOR} STREQUAL "armhf") # For raspbian
            # TODO: verify
            set(_cross_arch "linux-armv4")
        endif ()
    endif ()
endif()

if(DEP_OPENSSL_USE_3)
    # Build OpenSSL 3.3.2 LTS and install into a predictable location inside the deps build tree
    set(_openssl3_install_dir "${CMAKE_CURRENT_BINARY_DIR}/openssl3")
    ExternalProject_Add(dep_OpenSSL3
        URL "https://github.com/openssl/openssl/releases/download/openssl-3.3.2/openssl-3.3.2.tar.gz"
        URL_HASH SHA256=2e8a40b01979afe8be0bbfb3de5dc1c6709fedb46d6c89c10da114ab5fc3d281
        DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/OpenSSL
        CONFIGURE_COMMAND ${CMAKE_COMMAND} -E env \
            MACOSX_DEPLOYMENT_TARGET=${CMAKE_OSX_DEPLOYMENT_TARGET} \
            ${CMAKE_CURRENT_SOURCE_DIR}/openssl-3-configure.sh "--prefix=${_openssl3_install_dir}" no-shared no-tests
        BUILD_IN_SOURCE ON
        BUILD_COMMAND ${_make_cmd}
        INSTALL_COMMAND ${_install_cmd}
    )

    # Provide a small cmake helper dir so downstream finders can locate openssl3
    ExternalProject_Add_Step(dep_OpenSSL3 install_cmake_files
        DEPENDEES install
        COMMAND ${CMAKE_COMMAND} -E make_directory "${_openssl3_install_dir}/cmake"
        COMMAND ${CMAKE_COMMAND} -E echo "# placeholder cmake config for OpenSSL3" > "${_openssl3_install_dir}/cmake/openssl3-config.cmake"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
    )

    # Expose variable so other modules can depend on it
    set(OPENSSL3_INSTALL_DIR ${_openssl3_install_dir} CACHE PATH "Install dir for OpenSSL 3.x built by deps")
    set(OPENSSL_PKG dep_OpenSSL3)
else()
    # Default: build existing OpenSSL 1.1.1w as before
    ExternalProject_Add(dep_OpenSSL
        #EXCLUDE_FROM_ALL ON
        URL "https://github.com/openssl/openssl/archive/OpenSSL_1_1_1w.tar.gz"
        URL_HASH SHA256=2130E8C2FB3B79D1086186F78E59E8BC8D1A6AEDF17AB3907F4CB9AE20918C41
        DOWNLOAD_DIR ${DEP_DOWNLOAD_DIR}/OpenSSL
        CONFIGURE_COMMAND ${_conf_cmd} ${_cross_arch}
            "--openssldir=${DESTDIR}"
            "--prefix=${DESTDIR}"
            ${_cross_comp_prefix_line}
            no-shared
            no-asm
            no-ssl3-method
            no-dynamic-engine
        BUILD_IN_SOURCE ON
        BUILD_COMMAND ${_make_cmd}
        INSTALL_COMMAND ${_install_cmd}
    )

    ExternalProject_Add_Step(dep_OpenSSL install_cmake_files
        DEPENDEES install

        COMMAND ${CMAKE_COMMAND} -E copy_directory openssl "${DESTDIR}${CMAKE_INSTALL_LIBDIR}/cmake/openssl"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
    )

    set(OPENSSL_PKG dep_OpenSSL)
endif()

# NOTE: OpenSSL 3 introduces API and symbol changes compared to 1.1.x.
# The build support here only provides the library and an install location.
# Any code that depends on OpenSSL's 1.1 APIs may require source changes.
# See UPGRADE_DEPS.md for details and TODOs.

    COMMAND ${CMAKE_COMMAND} -E copy_directory openssl "${DESTDIR}${CMAKE_INSTALL_LIBDIR}/cmake/openssl"
    WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
)
