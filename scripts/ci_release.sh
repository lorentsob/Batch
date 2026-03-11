#!/usr/bin/env bash
# ci_release.sh — Manual-triggered release candidate creation for local and CI.
#
# Purpose:
#   Prepares the production build (Archive) and performs non-secret dry-runs.
#   In CD, this handles signing and exporting the IPA for TestFlight.
#
# Usage:
#   bash scripts/ci_release.sh --dry-run
#
# Exit codes:
#   0 = dry-run successful OR release candidate created successfully
#   1 = failure (build error, missing signing, etc.)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="/tmp/LevainRelease"
SCHEME="Levain"
CONFIGURATION="Release"
DRY_RUN=false

# ── Parse arguments ──────────────────────────────────────────────────────────
for arg in "$@"; do
  case $arg in
    --dry-run)
      DRY_RUN=true
      shift
      ;;
  esac
done

echo "=== Levain CD Release Candidate ==="
echo "Repo root:   $REPO_ROOT"
echo "Derived data: $DERIVED_DATA"
echo "Scheme:       $SCHEME"
echo "Configuration: $CONFIGURATION"
echo "Dry run:      $DRY_RUN"
echo ""

# 1. Regenerate project (ensure it's clean)
bash scripts/ci_bootstrap.sh

# 2. Build Release Archive (no signing allowed for dry-run)
echo "📦 Creating Xcode Archive..."
if [[ "$DRY_RUN" == "true" ]]; then
  xcodebuild \
    -project "$REPO_ROOT/Levain.xcodeproj" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -derivedDataPath "$DERIVED_DATA" \
    -destination "generic/platform=iOS" \
    CODE_SIGNING_ALLOWED=NO \
    clean archive -archivePath "$DERIVED_DATA/$SCHEME.xcarchive"
  echo ""
  echo "✅ DRY-RUN COMPLETE: Build succeeded. If secrets were present, we would sign and upload now."
else
  # Here we would normally perform signing and export
  echo "⚠️ ERROR: Actual release requires signing secrets. Use --dry-run to verify build logic only."
  exit 1
fi

echo ""
echo "=== CD Release complete ==="
