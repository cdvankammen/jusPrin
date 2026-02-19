# Description

<!--
> Please provide a summary of the changes made in this PR. Include details such as:
  > * What issue does this PR address or fix?
  > * What new features or enhancements does this PR introduce?
  > * Are there any breaking changes or dependencies that need to be considered?

# Screenshots/Recordings/Graphs

<!--
> Please attach relevant screenshots to showcase the UI changes.
> Please attach images that can help explain the changes.

## Tests

<!--
> Please describe the tests that you have conducted to verify the changes made in this PR.
```markdown
# Phase 1 — Quick fixes (agent-prepared)

This PR contains a small, focused set of Phase-1 fixes intended to make the repository bootstrappable and safer for follow-up work.

Summary of included changes:

- Restore DEP_BUILD_DIR / CMAKE_PREFIX_PATH auto-generation (CMake) so configure finds vendored deps.
- Export `BBL_RELEASE_TO_PUBLIC` compile definition.
- Enable SSL verification by default in `src/slic3r/Utils/Http.cpp` with env override `JUSPRIN_DISABLE_SSL_VERIFY`.
- Add `.gitignore` entries for build/analysis artifacts.
- Fix dangling `.string().c_str()` usage in `src/libslic3r/Format/OBJ.cpp`.

Testing done locally:

- CMake configure completed and auto-detected `CMAKE_PREFIX_PATH` for `deps` tree.

Notes:

- Branch prepared locally: `phase1-fixes/misc-fixes` (commits created locally; not pushed).
- Keep this PR minimal to simplify review and backporting.

``` 
