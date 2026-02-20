# Dependency Upgrade Guide

## OpenSSL 3.x Migration

### Overview

JusPrin supports building against either **OpenSSL 1.1.1w** (default) or
**OpenSSL 3.3.2 LTS** via a CMake option:

```bash
cmake -S deps -B deps/build -DDEP_OPENSSL_USE_3=ON   # build OpenSSL 3.3.2
cmake -S deps -B deps/build                           # build OpenSSL 1.1.1w (default)
```

The toggle lives in `deps/OpenSSL/OpenSSL.cmake`.

### Why upgrade?

OpenSSL 1.1.1 reached end-of-life on 2023-09-11 and no longer receives
security fixes. OpenSSL 3.x is the actively maintained LTS branch.

### API changes (non-exhaustive)

| Legacy 1.1.x call | OpenSSL 3.x replacement |
|-|-|
| `SSL_library_init()` | `OPENSSL_init_ssl()` |
| `ERR_load_crypto_strings()` | `OPENSSL_init_crypto()` |
| `EVP_MD_CTX_create()` / `EVP_MD_CTX_destroy()` | `EVP_MD_CTX_new()` / `EVP_MD_CTX_free()` |
| `RSA_generate_key()` | `EVP_PKEY_keygen()` |
| ENGINE APIs | Provider APIs (`OSSL_PROVIDER`) |

Search the codebase for legacy symbols before switching:

```bash
grep -rn 'SSL_library_init\|ERR_load_crypto_strings\|EVP_MD_CTX_create\|RSA_generate_key' src/
```

### Build instructions

1. Configure deps with the flag:
   ```bash
   cmake -S deps -B deps/build -DDEP_OPENSSL_USE_3=ON
   cmake --build deps/build
   ```
2. Configure the main project, pointing at the deps prefix:
   ```bash
   cmake -S . -B build -DCMAKE_PREFIX_PATH="$(pwd)/deps/build/destdir/usr/local"
   cmake --build build
   ```
3. Run the test suite:
   ```bash
   cd build && ctest --output-on-failure
   ```

### Verification checklist

- [ ] `find_package(OpenSSL)` resolves to 3.3.x when `DEP_OPENSSL_USE_3=ON`.
- [ ] Full build succeeds on macOS arm64, macOS x86_64, Linux x86_64.
- [ ] Unit tests pass (`ctest`).
- [ ] TLS connections (HTTPS uploads/downloads) work correctly at runtime.
- [ ] No deprecated-API warnings emitted during compilation.

### Rollback

Set `DEP_OPENSSL_USE_3=OFF` (or omit it entirely) to revert to 1.1.1w.

---

## libcurl 8.x Migration

JusPrin supports building against either **libcurl 7.75.0** (default) or
**libcurl 8.11.1** via a CMake option:

```bash
cmake -S deps -B deps/build -DDEP_CURL_USE_8=ON    # build curl 8.11.1
cmake -S deps -B deps/build                         # build curl 7.75.0 (default)
```

The toggle lives in `deps/CURL/CURL.cmake`.

### Coordinating with OpenSSL 3.x

When `DEP_CURL_USE_8` is enabled you should also supply the OpenSSL 3.x install
prefix so curl links against the correct TLS backend:

```bash
cmake -S deps -B deps/build -DDEP_CURL_USE_8=ON -DDEP_OPENSSL3_ROOT=/path/to/openssl3
```

`DEP_OPENSSL3_ROOT` is a cache variable defined in `CURL.cmake`. If left empty,
curl will link against whatever OpenSSL CMake discovers on its own.

### SHA-256 checksums

| Version | Archive | SHA-256 |
|-|-|-|
| 7.75.0 | GitHub zip | `a63ae025bb0a14f119e73250f2c923f4bf89aa93b8d4fafa4a9f5353a96a765a` |
| 8.11.1 | curl.se tar.gz | `a889ac9dbba3644271bd9d1302b5c22a088893719b72be3487bc3d401e5c4e80` |

### Migration notes

- libcurl 8.x may disable older protocols by default and change TLS backend
  detection. Rebuild any code that directly links libcurl and verify deprecated
  `CURLOPT_*` options have been updated.
- See the [curl changelog](https://curl.se/changes.html) for the full delta
  between 7.75.0 and 8.11.1.

### Rollback

Set `DEP_CURL_USE_8=OFF` (or omit it entirely) to revert to 7.75.0.

---

## Troubleshooting

| Symptom | Fix |
|-|-|
| CMake finds system OpenSSL instead of deps build | Set `-DOPENSSL_ROOT_DIR=<deps prefix>` explicitly |
| Undefined symbols at link time | Ensure static/shared lib selection matches (`no-shared` vs `shared`) |
| macOS: curl uses Secure Transport | Pass `-DCURL_USE_OPENSSL=ON` to curl's CMake |
| Runtime: library not found | Set `LD_LIBRARY_PATH` (Linux) or `DYLD_LIBRARY_PATH` (macOS), or fix RPATH |
