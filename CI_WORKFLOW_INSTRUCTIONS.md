# CI Workflow Push Instructions

## Problem

The GitHub Personal Access Token (PAT) currently configured for this repository
does **not** have the `workflow` scope. GitHub requires this scope to create or
modify files under `.github/workflows/` via `git push`. Pushes that include
workflow file changes will be **rejected** with:

```
refusing to allow a Personal Access Token to create or update workflow
`.github/workflows/asan.yml` without `workflow` scope
```

## Workflow Files to Push

The following workflow files have been created in the working tree but are
**not committed**:

| File | Purpose |
|------|---------|
| `.github/workflows/asan.yml` | ASAN + LSAN (Address & Leak Sanitizer) CI job |
| `.github/workflows/tsan.yml` | TSAN (Thread Sanitizer) CI job *(already tracked)* |

### What They Do

- **asan.yml** — Builds on `ubuntu-22.04` with Clang-14 and
  `-fsanitize=address,leak`. Runs `ctest` with `ASAN_OPTIONS=detect_leaks=1`.
  Uploads build/test logs as artifacts on failure.

- **tsan.yml** — Builds on `ubuntu-22.04` with Clang-14 and
  `-fsanitize=thread`. Runs `ctest` with `TSAN_OPTIONS=halt_on_error=1`.
  Uploads build/test logs as artifacts on failure.

## How to Push

You need a GitHub PAT (classic) or fine-grained token that includes the
**`workflow`** scope (sometimes shown as _"Update GitHub Action workflows"_).

### Option A: One-time push with a workflow-scoped token

```bash
# 1. Generate a new PAT at https://github.com/settings/tokens
#    with at least: repo + workflow scopes

# 2. Stage and commit the workflow files
cd "/Users/stillbulldog35/Documents/hass agent/jusPrin"
git add .github/workflows/asan.yml .github/workflows/tsan.yml
git commit -m "ci: add ASAN/LSAN and TSAN sanitizer workflows"

# 3. Push using the workflow-scoped token
#    Replace <TOKEN> with your PAT that has workflow scope
#    Replace <OWNER>/<REPO> with your GitHub org/repo
git push https://<TOKEN>@github.com/<OWNER>/<REPO>.git HEAD
```

### Option B: Temporarily update your remote URL

```bash
# 1. Save current remote
ORIG=$(git remote get-url origin)

# 2. Set remote to use workflow-scoped token
git remote set-url origin "https://<WORKFLOW_TOKEN>@github.com/<OWNER>/<REPO>.git"

# 3. Stage, commit, and push
git add .github/workflows/asan.yml .github/workflows/tsan.yml
git commit -m "ci: add ASAN/LSAN and TSAN sanitizer workflows"
git push origin HEAD

# 4. Restore original remote
git remote set-url origin "$ORIG"
```

### Option C: Use GitHub web UI

1. Navigate to the repository on github.com.
2. Go to **Add file → Create new file**.
3. Set the path to `.github/workflows/asan.yml`.
4. Paste the contents of the local `.github/workflows/asan.yml` file.
5. Commit directly to the target branch.
6. Repeat for `tsan.yml` if it needs updating.

## Verification

After pushing, confirm the workflows appear under the repository's
**Actions** tab. Trigger them manually via `workflow_dispatch` or push a
commit to `main` / `updates` to verify they run.

```bash
# Quick check that GitHub sees the workflows
gh workflow list
```
