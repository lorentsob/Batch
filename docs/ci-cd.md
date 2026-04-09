# Batch CI/CD Documentation

**Last updated:** 2026-03-10 — Phase 09-02 / 09-03

---

## Overview

Batch uses GitHub Actions for build validation and a separate manual-triggered workflow for release-candidate preparation. Public-facing docs intentionally reflect the current reality: the app display name is `Batch`, while the Xcode scheme and project still use `Levain`.

```
Local machine  ──────────────────────────────────────────────
                                                             │
  bash scripts/ci_bootstrap.sh   # generates project       │
  bash scripts/ci_test.sh        # builds + tests          │  same commands
  bash scripts/ci_release.sh --dry-run                     │
                                                            │
GitHub Actions ──────────────────────────────────────────────
  ios-ci.yml      → triggered on push to main/develop, PRs from same repo only
  ios-release.yml → triggered by manual workflow_dispatch
```

---

## CI: ios-ci.yml

### When It Runs

| Event | Branches |
|-------|----------|
| `push` | `main`, `develop` |
| `pull_request` | `main`, `develop` (same-repo branches only) |

### What It Does

1. **Checkout** the repository
2. **Select Xcode** — targets the standard `Xcode.app` (providing the current iOS SDK)
3. **Install XcodeGen** via Homebrew
4. **Bootstrap** — runs `scripts/ci_bootstrap.sh` to regenerate `Levain.xcodeproj` from `project.yml`
5. **Build** — `xcodebuild … CODE_SIGNING_ALLOWED=NO build`
6. **Diagnostics** — lists available iPhone simulators on the runner
7. **Upload artifacts** — build log retained 7 days on failure

### Branch Protection

To enforce the CI gate:

1. In **GitHub → Settings → Branches**, add a branch protection rule for `main`.
2. Enable **Require status checks to pass before merging**.
3. Add `Build & Test` as a required check.

### Local Reproduction

```bash
# 1. Generate project from project.yml
bash scripts/ci_bootstrap.sh

# 2. Build and test locally
bash scripts/ci_test.sh

# Override simulator if needed:
bash scripts/ci_test.sh "iPhone 16 Pro"
```

### Debugging a Failing CI Run

1. Open the failed run on GitHub Actions.
2. Download the `levain-xcresult-<run>` artifact.
3. Open in Xcode: `open Levain.xcresult` — navigate to Failures.
4. If the build step failed, download `levain-build-log-<run>` and search for the first error.
5. If the workflow did not start or stayed queued, verify that the self-hosted runner was online.

---

## CD: ios-release.yml

See `docs/release-runbook.md` for the full operator procedure.

### When It Runs

Manual only — triggered via **GitHub → Actions → iOS Release → Run workflow**.

### What It Does

1. Bootstraps the project (same as CI)
2. Builds the Release configuration for `generic/platform=iOS`
3. Archives the app and exports an IPA
4. Uploads to TestFlight (if signing secrets are present)

### Required Secrets

See `docs/release-secrets.md` for the full secrets specification.

| Secret | Purpose |
|--------|---------|
| `CERTIFICATES_P12` | Base64-encoded signing certificate |
| `CERTIFICATES_P12_PASSWORD` | Certificate password |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded provisioning profile |
| `APP_STORE_CONNECT_API_KEY_ID` | App Store Connect API key ID |
| `APP_STORE_CONNECT_API_ISSUER_ID` | App Store Connect issuer ID |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded `.p8` private key |

---

## Simulator Availability

The CI workflow defaults to `iPhone 17 Pro`. If the runner image does not include this model, override the `SIMULATOR_NAME` env var in the workflow or pass it to the local script:

```bash
bash scripts/ci_test.sh "iPhone 16 Pro"
```

List available simulators:

```bash
xcrun simctl list devices available | grep iPhone
```

---

## XcodeGen Requirement

`project.yml` is the **source of truth** for the Xcode project. `Levain.xcodeproj` is regenerated from it on every CI run. Do not commit manual changes to `Levain.xcodeproj`; change `project.yml` instead and regenerate locally with:

```bash
xcodegen generate --spec project.yml
```

---

## Hosted Runner Expectations

The current CI job runs on a self-hosted macOS runner. That is acceptable for a personal product repo, but outside forks should not assume they can run CI unchanged without equivalent infrastructure. The workflow should only execute PR validation for branches coming from the same repository, not from untrusted forks.

## Fork Policy

For a public repo using a self-hosted runner, the safest default is:

- accept outside issues and discussion
- treat outside pull requests as reviewable contributions, but not as automatically runnable CI jobs
- run CI automatically only for pushes and same-repo pull requests

This keeps the public repo readable and reviewable without exposing the self-hosted runner to untrusted fork code.

## Secrets Boundary

CI does **not** require repository secrets. It builds with `CODE_SIGNING_ALLOWED=NO`.

CD requires signing secrets; see `docs/release-secrets.md`.

---

*Documentation version: 1.0 — Phase 09-02/03 — 2026-03-10*
