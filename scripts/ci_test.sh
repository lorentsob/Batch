#!/usr/bin/env bash
# ci_test.sh — Build and automated test execution for CI and local reproduction.
#
# Purpose:
#   Runs the full Levain build and test suite against a chosen simulator.
#   Keeps the build step and test step explicit so failures are easy to isolate.
#
# Usage:
#   bash scripts/ci_test.sh [SIMULATOR_NAME]
#
#   SIMULATOR_NAME defaults to "iPhone 17 Pro" (matches the CI runner default).
#   Override on machines without that model: bash scripts/ci_test.sh "iPhone 16 Pro"
#
# Requirements:
#   - Levain.xcodeproj must exist (run ci_bootstrap.sh first)
#   - Target simulator must be available in the local/hosted runtime
#
# Exit codes:
#   0 = build and tests passed
#   1 = build or test failure

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DERIVED_DATA="/tmp/LevainDerivedCI"
SCHEME="Levain"
CONFIGURATION="Debug"
SIMULATOR_NAME="${1:-iPhone 17 Pro}"
DESTINATION="platform=iOS Simulator,name=${SIMULATOR_NAME}"

echo "=== Levain CI Test ==="
echo "Repo root:   $REPO_ROOT"
echo "Derived data: $DERIVED_DATA"
echo "Scheme:       $SCHEME"
echo "Destination:  $DESTINATION"
echo ""

# ── Verify project exists ─────────────────────────────────────────────────────
if [[ ! -d "$REPO_ROOT/Levain.xcodeproj" ]]; then
  echo "❌ ERROR: Levain.xcodeproj not found. Run ci_bootstrap.sh first."
  exit 1
fi

cd "$REPO_ROOT"

# ── Step 1: Clean build (no signing) ─────────────────────────────────────────
echo "=== Step 1: Clean build ==="
xcodebuild \
  -project Levain.xcodeproj \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "$DESTINATION" \
  CODE_SIGNING_ALLOWED=NO \
  clean build \
  | xcpretty --color 2>/dev/null || true

# Verify the binary exists (xcpretty may suppress the status line)
if ! xcodebuild \
  -project Levain.xcodeproj \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "$DESTINATION" \
  CODE_SIGNING_ALLOWED=NO \
  build 2>&1 | grep -q "BUILD SUCCEEDED"; then
  echo "❌ BUILD FAILED"
  exit 1
fi

echo "✅ Build succeeded."
echo ""

# ── Step 2: Run unit + UI tests ───────────────────────────────────────────────
echo "=== Step 2: Run tests ==="
RESULT_BUNDLE="$DERIVED_DATA/Levain.xcresult"

set +e
xcodebuild \
  -project Levain.xcodeproj \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -derivedDataPath "$DERIVED_DATA" \
  -destination "$DESTINATION" \
  -resultBundlePath "$RESULT_BUNDLE" \
  CODE_SIGNING_ALLOWED=NO \
  test 2>&1
TEST_EXIT=$?
set -e

if [[ $TEST_EXIT -ne 0 ]]; then
  echo ""
  echo "❌ TESTS FAILED (exit code $TEST_EXIT)"
  echo "   xcresult bundle: $RESULT_BUNDLE"
  echo "   Open in Xcode:   open $RESULT_BUNDLE"
  exit 1
fi

echo ""
echo "✅ All tests passed."
echo "   xcresult bundle: $RESULT_BUNDLE"
echo ""
echo "=== CI Test complete ==="
