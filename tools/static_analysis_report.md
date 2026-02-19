## Static analysis report (best-effort)

Repository: jusPrin (cdvankammen/jusPrin)
Path scanned: src/ and deps_src/

Summary
-------
- Tooling: clang-tidy was not available / CMake configure failed to produce compile_commands.json on this environment, so I ran best-effort pattern-based scans (grep) for common risky constructs: raw new/delete, malloc/free, strcpy/sprintf, casts, and notable audit JSON findings already present in the tree.
- This report lists the top 20 findings prioritized by severity with recommended fixes.

Methodology
-----------
- Attempted to run CMake with -DCMAKE_EXPORT_COMPILE_COMMANDS=ON; configuration failed due to missing Threads detection in this environment, so a compile database was not produced.
- Performed workspace grep searches for risky patterns and inspected existing SECURITY_AUDIT/ROBUSTNESS JSON files embedded in the repo to identify high-confidence issues.

Top 20 findings (by priority)
--------------------------------
1) Critical — Unchecked uncompressed sizes when extracting ZIP/3MF entries
   - Files: `src/libslic3r/Format/SECURITY_AUDIT_FORMAT.json` (evidence lines describe data.resize(stat.m_uncomp_size) and XML_GetBuffer cast)
   - Risk: crafted archive can specify extremely large uncompressed size -> std::bad_alloc/OOM or crash; integer truncation when casting to int.
   - Fix: Validate stat.m_uncomp_size before using (guard against > INT_MAX and a reasonable maximum), fail safely and report error; use size_t and strong bounds checks.

2) Critical — Triangle indices appended from parser without bounds validation
   - Files: `src/libslic3r/Format/SECURITY_AUDIT_FORMAT.json` (description of appending raw v1,v2,v3 indices)
   - Risk: Out-of-bounds indices may lead to crashes or memory corruption when later indexing vertex arrays.
   - Fix: Validate parsed indices are within [0, geometry.vertices.size()) before appending; refuse/skip malformed faces.

3) High — Manual new/delete of thread objects (boost::thread) — leak on exception
   - Files: `src/libslic3r/Format/STEP_OBJ_ROBUSTNESS_AUDIT.json` and code locations (Step::load/mesh evidence)
   - Risk: If exception thrown between new and delete, thread object leaks and possibly detached threads; join/delete pattern fragile.
   - Fix: Use RAII: prefer std::thread with std::jthread (C++20) or wrap in std::unique_ptr, or use std::async/std::future; ensure join in destructor or use scoped thread helper.

4) High — Raw owning pointer pattern for ViewerImpl (new/delete)
   - Files: `src/libvgcode/src/Viewer.cpp`, `ViewerImpl.hpp` (m_impl = new ViewerImpl(); delete m_impl;)
   - Risk: Manual memory management error-prone; leaks on exceptions or early returns.
   - Fix: Replace raw pointer with std::unique_ptr<ViewerImpl> m_impl; remove manual delete; initialize with std::make_unique.

5) High — Use of unsafe C string functions (sprintf/strcpy/strcat)
   - Files: various (deps_src/qhull, src/libvgcode, SECURITY_AUDIT_FORMAT.json evidence)
   - Risk: Buffer-overflow, memory corruption, security vulnerabilities.
   - Fix: Replace with snprintf/strlcpy/strlcat or prefer std::string and safe APIs; ensure buffer sizes are respected.

6) High — malloc/free uses with potential unchecked sizes (glad/gl code, deps)
   - Files: `src/libvgcode/glad/src/*`, deps_src/*
   - Risk: allocation failures, integer-overflow when computing sizes, or missing frees in some paths.
   - Fix: When possible, prefer std::vector/std::string; else check allocation sizes, handle null returns, and pair malloc/free in same scope.

7) Medium — uint16_t length arithmetic can overflow (len = 5 + u8path.length())
   - Files: `src/libslic3r/Format/SECURITY_AUDIT_FORMAT.json` (evidence)
   - Risk: wrap-around producing too-small lengths -> read/write out-of-bounds by other tools.
   - Fix: Use size_t for length calculations and validate bounds before casting to smaller integer types.

8) Medium — Exception handling around large allocations
   - Files: multiple (SECURITY_AUDIT_FORMAT.json points out code that may not catch bad_alloc in some callers)
   - Risk: unhandled std::bad_alloc may terminate the process in some call paths.
   - Fix: Avoid allocating huge buffers from untrusted metadata; add size sanity checks and handle exceptions or return errors.

9) Medium — Manual delete usage without nulling and non-RAII lifetime
   - Files: `src/libvgcode/src/Viewer.cpp` and other C++ files with manual delete
   - Fix: Use smart pointers, or at minimum document ownership and ensure deletes are exception-safe.

10) Medium — C-style casts and reinterpret_cast usage
    - Files: scattered (grep hits for casts)
    - Risk: unsafe conversions hiding bugs and UB.
    - Fix: Use static_cast/dynamic_cast/reinterpret_cast explicitly; audit each cast and justify or remove.

11) Medium — Potential missing range checks when indexing arrays
    - Files: multiple parsing/formatting modules (see SECURITY_AUDIT_FORMAT.json)
    - Fix: Add explicit range checks and unit tests for malformed inputs.

12) Low — Legacy C APIs in deps that use global buffers/strcat patterns
    - Files: deps_src/qhull and other vendored C libs
    - Fix: These are third-party; if maintained upstream, prefer upstream fixes. Locally: audit entry points used by the app and wrap unsafe calls.

13) Low — boost::thread usage instead of std::thread (portability and lifetime)
    - Files: many (evidence in audits)
    - Fix: Where feasible, migrate to std::thread/std::jthread for simpler RAII and portability.

14) Low — File-path concatenation using plain '/' may be unsafe on some platforms
    - Files: zip extraction and path handling code (evidence in audit json)
    - Fix: Use boost::filesystem / std::filesystem APIs to join and normalize paths; validate against path traversal.

15) Low — Use of raw pointers in C APIs returned into C++ code (ownership unclear)
    - Fix: Clearly document ownership or wrap in RAII types.

16) Low — Some generated or vendored C code uses older APIs; prioritized lower unless reachable from untrusted inputs.

17) Low — Potential for use-after-free where manual deletes exist (requires targeted dynamic analysis).
    - Fix: Replace manual deletes with unique_ptr and run ASan/UBSan.

18) Informational — Numerous occurrences of logging/printf usage; confirm format string safety.

19) Informational — Some files include comment evidence of known issues already captured in the repo (audit JSONs). These should be triaged by maintainers.

20) Informational — Incomplete exception-safety around threads and IO; add unit tests and fuzz targets for parsers.

Recommendations and next steps
------------------------------
1. Install clang/clang-tidy and re-run with a compile_commands.json: re-run `cmake -S . -B build/clang-tidy -DCMAKE_EXPORT_COMPILE_COMMANDS=ON` after ensuring Threads package is discoverable, then run `run-clang-tidy -p build/clang-tidy` with checks: clang-analyzer-*,bugprone-*,cppcoreguidelines-* and export fixes.
2. Prioritize fixes 1–6 as security/robustness issues. Implement bounds checks and convert manual memory management to RAII.
3. Add unit tests and fuzz tests for archive and mesh parsers to validate malformed inputs.
4. Run AddressSanitizer and UndefinedBehaviorSanitizer after making changes to find runtime issues.

Appendix: commands attempted
---------------------------
- cmake -S . -B build/clang-tidy -DCMAKE_BUILD_TYPE=Release -DCMAKE_EXPORT_COMPILE_COMMANDS=ON  (failed to complete in this environment due to Threads detection missing)
- grep-based searches for patterns: new, delete, malloc/free, strcpy/sprintf, reinterpret_cast, smart-pointer usage

Prepared by: GitHub Copilot (best-effort, clang-tidy not installed in this environment)
