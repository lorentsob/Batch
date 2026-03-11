# Levain CI/CD Documentation

**Last updated:** 2026-03-10 — Phase 09-02 / 09-03

---

## Overview

Levain uses GitHub Actions for build and test validation (CI) and a separate manual-triggered workflow for release-candidate creation (CD). Both workflows reuse the same XcodeGen and `xcodebuild` baseline used locally.

```
Local machine  ──────────────────────────────────────────────
                                                             │
  bash scripts/ci_bootstrap.sh   # generates project       │
  bash scripts/ci_test.sh        # builds + tests          │  same commands
  bash scripts/ci_release.sh --dry-run                     │
                                                            │
GitHub Actions ──────────────────────────────────────────────
  ios-ci.yml      → triggered on push / PR
  ios-release.yml → triggered by manual workflow_dispatch
```

---

## CI: ios-ci.yml

### When It Runs

| Event | Branches |
|-------|----------|
| `push` | `main`, `release/**` |
| `pull_request` | `main`, `release/**` |

### What It Does

1. **Checkout** the repository
2. **Select Xcode** — targets `Xcode_16.3.app`; falls back to default Xcode
3. **Install XcodeGen** via Homebrew
4. **Bootstrap** — runs `scripts/ci_bootstrap.sh` to regenerate `Levain.xcodeproj` from `project.yml`
5. **Build** — `xcodebuild … CODE_SIGNING_ALLOWED=NO clean build`
6. **Test** — `xcodebuild … test` (unit + UI tests on iPhone 17 Pro simulator)
7. **Upload artifacts** — xcresult bundle retained 14 days; build log retained 7 days on failure

### Branch Protection

To enforce the CI gate:

1. In **GitHub → Settings → Branches**, add a branch protection rule for `main`.
2. Enable **Require status checks to pass before merging**.
3. Add `Build & Test` as a required check.

### Local Reproduction

```bash
# 1. Generate project from project.yml
bash scripts/ci_bootstrap.sh

# 2. Build and test (default simulator: iPhone 17 Pro)
bash scripts/ci_test.sh

# Override simulator:
bash scripts/ci_test.sh "iPhone 16 Pro"
```

### Debugging a Failing CI Run

1. Open the failed run on GitHub Actions.
2. Download the `levain-xcresult-<run>` artifact.
3. Open in Xcode: `open Levain.xcresult` — navigate to Failures.
4. If the build step failed, download `levain-build-log-<run>` and search for the first error.

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

## Secrets Boundary

CI does **not** require any secrets. It builds with `CODE_SIGNING_ALLOWED=NO` so clean macOS runners work without provisioning profiles or certificates.

CD requires signing secrets; see `docs/release-secrets.md`.

---

*Documentation version: 1.0 — Phase 09-02/03 — 2026-03-10*
