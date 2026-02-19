## Option to select libcurl 8.x vs 7.x. Turn ON to build curl 8.x (experimental).
option(DEP_CURL_USE_8 "Use libcurl 8.x instead of 7.x" OFF)

# Placeholder to point libcurl at an OpenSSL3 build (set when coordinating OpenSSL upgrade).
# Example usage: -DDEP_OPENSSL3_ROOT:PATH=/path/to/openssl3/install
set(DEP_OPENSSL3_ROOT "" CACHE PATH "Root install dir for OpenSSL 3.x (placeholder)")

set(_curl_platform_flags 
  -DENABLE_IPV6:BOOL=ON
  -DENABLE_VERSIONED_SYMBOLS:BOOL=ON
  -DENABLE_THREADED_RESOLVER:BOOL=ON
  -DENABLE_MANUAL:BOOL=OFF
  -DCURL_DISABLE_LDAP:BOOL=ON
  -DCURL_DISABLE_LDAPS:BOOL=ON
  -DCURL_DISABLE_RTSP:BOOL=ON
  -DCURL_DISABLE_DICT:BOOL=ON
  -DCURL_DISABLE_TELNET:BOOL=ON
  -DCURL_DISABLE_POP3:BOOL=ON
  -DCURL_DISABLE_IMAP:BOOL=ON
  -DCURL_DISABLE_SMB:BOOL=ON
  -DCURL_DISABLE_SMTP:BOOL=ON
  -DCURL_DISABLE_GOPHER:BOOL=ON
  -DCURL_DISABLE_TFTP:BOOL=ON
  -DCURL_DISABLE_MQTT:BOOL=ON
  #-DHTTP_ONLY=ON

  -DCMAKE_USE_GSSAPI:BOOL=OFF
  -DCMAKE_USE_LIBSSH2:BOOL=OFF
  -DUSE_RTMP:BOOL=OFF
  -DUSE_NGHTTP2:BOOL=OFF
  -DUSE_MBEDTLS:BOOL=OFF
)

if (WIN32)
  #set(_curl_platform_flags  ${_curl_platform_flags} -DCMAKE_USE_SCHANNEL=ON)
  set(_curl_platform_flags  ${_curl_platform_flags} -DCMAKE_USE_OPENSSL=ON -DCURL_CA_PATH:STRING=none)
elseif (APPLE)
  set(_curl_platform_flags 
    
    ${_curl_platform_flags}

    #-DCMAKE_USE_SECTRANSP:BOOL=ON 
    -DCMAKE_USE_OPENSSL:BOOL=ON

    -DCURL_CA_PATH:STRING=none
  )
elseif(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  set(_curl_platform_flags 

    ${_curl_platform_flags}

    -DCMAKE_USE_OPENSSL:BOOL=ON

    -DCURL_CA_PATH:STRING=none
    -DCURL_CA_BUNDLE:STRING=none
    -DCURL_CA_FALLBACK:BOOL=ON
  )
endif ()

if (BUILD_SHARED_LIBS)
  set(_curl_static OFF)
else()
  set(_curl_static ON)
endif()

orcaslicer_add_cmake_project(CURL
  # GIT_REPOSITORY      https://github.com/curl/curl.git
  # Select URL/HASH based on DEP_CURL_USE_8
  
  # NOTE: When enabling DEP_CURL_USE_8 you must also coordinate setting DEP_OPENSSL3_ROOT
  # to the OpenSSL 3.x installation dir (or update the OpenSSL dep to build 3.x). See UPGRADE_DEPS.md
  
  URL                 $<IF:$<BOOL:${DEP_CURL_USE_8}>,https://github.com/curl/curl/archive/refs/tags/curl-8_0_1.zip,https://github.com/curl/curl/archive/refs/tags/curl-7_75_0.zip>
  # TODO: Update corresponding URL_HASH values for the chosen curl version. Hash below is for 7.75.0.
  URL_HASH            SHA256=a63ae025bb0a14f119e73250f2c923f4bf89aa93b8d4fafa4a9f5353a96a765a
  DEPENDS             ${ZLIB_PKG}
  # PATCH_COMMAND       ${GIT_EXECUTABLE} checkout -f -- . && git clean -df && 
  #                     ${GIT_EXECUTABLE} apply --whitespace=fix ${CMAKE_CURRENT_LIST_DIR}/curl-mods.patch
  CMAKE_ARGS
    -DBUILD_TESTING:BOOL=OFF
    -DBUILD_CURL_EXE:BOOL=OFF
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    -DCURL_STATICLIB=${_curl_static}
    ${_curl_platform_flags}
    # If OpenSSL3 is being used, point cmake at the OpenSSL3 install dir. This is a placeholder
    # so upgrades can be coordinated. Manual review required when enabling DEP_OPENSSL_USE_3.
    $<$<BOOL:${DEP_OPENSSL3_ROOT}>:-DOPENSSL_ROOT_DIR=${DEP_OPENSSL3_ROOT}>
)

if(NOT OPENSSL_FOUND)
  # (openssl may or may not be built)
  add_dependencies(dep_CURL ${OPENSSL_PKG})
endif()

if (MSVC)
    add_debug_dep(dep_CURL)
endif ()
