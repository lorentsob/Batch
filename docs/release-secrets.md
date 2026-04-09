# Batch Release Secrets

**Prepared:** 2026-03-10 — Phase 09-03
**Impact:** `ios-release.yml` failures until these are provisioned (RISK-01).

---

## Required Secrets (GitHub Settings → Secrets → Actions)

To enable signed distribution and TestFlight uploads, add the following secrets to the repository:

### 1. iOS Signing (p12)

| Secret Name | Value Description |
|-------------|-------------------|
| `CERTIFICATES_P12` | Base64-encoded `dist_cert.p12` file |
| `CERTIFICATES_P12_PASSWORD` | Password for the p12 file |
| `PROVISIONING_PROFILE_BASE64` | Base64-encoded `.mobileprovision` file |

**How to generate p12 Base64:**
```bash
cat dist_cert.p12 | base64 | pbcopy
```

---

### 2. App Store Connect API

Required for uploading the IPA (`xcrun altool` or `xcrun notarytool`).

| Secret Name | Value Description |
|-------------|-------------------|
| `APP_STORE_CONNECT_API_KEY_ID` | Key ID from App Store Connect (e.g. `2X9K3...`) |
| `APP_STORE_CONNECT_API_ISSUER_ID` | Issuer ID from App Store Connect (UUID) |
| `APP_STORE_CONNECT_API_KEY_BASE64` | Base64-encoded `.p8` private key file |

---

## Workflow Integration

Once these secrets are present, the `.github/workflows/ios-release.yml` file should be updated to use the `Apple-Actions/import-codesign-certs` and `Apple-Actions/upload-testflight-build` actions (or custom `xcrun` commands).

The current implementation (Phase 09-03) stops at the **dry-run** build stage to maintain a clean controlled release flow without exposing signing risks until these secrets are provisioned by the owner.

---

*Last updated: 2026-03-10*
