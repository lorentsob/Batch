# Batch Release Runbook

**Prepared:** 2026-03-10 — Phase 09-03
**Standard Operating Procedure:** Creating and verifying a v1 Release Candidate for TestFlight.

---

## 1. Preparation (Manual Pass)

Before triggering a release, the maintainer MUST run the manual smoke checklist.

- [ ] Execute `docs/v1-smoke-checklist.md` on a real device.
- [ ] Review `docs/v1-release-risks.md` for any open blockers (except RISK-01).
- [ ] Ensure local changes are committed and pushed to `main` or a `release/**` branch.

---

## 2. Triggering the Release Candidate (CD)

1. Open **GitHub → Actions → iOS Release**.
2. Click **Run workflow**.
3. Select the branch and the version bump (default: `patch`).
4. Click **Run workflow**.

---

## 3. Verification Post-Build

Once the GitHub Action completes:

1. **Verify Artifacts:** Check the action summary for export logs or built archive artifacts.
2. **TestFlight (if active):** Open App Store Connect and confirm the build appears in the TestFlight section.
3. **Internal Audit Check:** Update `docs/v1-audit.md` with the new build number and final test results.

---

## 4. Recovery & Failed Runs

If the release workflow fails:

1. **Check build logs:** Search for `error:` in the `Create Release Candidate` job.
2. **Local Reproduction:**
   ```bash
   # Run the exact same release logic locally (dry-run mode)
   bash scripts/ci_release.sh --dry-run
   ```
3. **Common failure points:**
   - **XCTest failures:** Fix code and push before re-triggering.
   - **Signing errors:** Verify credentials in `docs/release-secrets.md`.
   - **Connection errors:** Check App Store Connect status or API key permissions.

---

## 5. Release Candidate Checklist

For every build, fill out this minimal checklist to ensure quality before it reaches TestFlight.

- [ ] CI build passed on clean runner (ios-ci.yml check).
- [ ] Maintainer verification passed locally before release.
- [ ] UI smoke pass completed on device or simulator before release.
- [ ] Signing succeeded using repository-managed secrets.
- [ ] Exported IPA is readable (if local export was used for validation).

---

*Runbook version: 1.0 — 2026-03-10*
