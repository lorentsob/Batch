#!/usr/bin/env bash
# ci_bootstrap.sh — Project generation bootstrap for CI and local reproduction.
#
# Purpose:
#   Installs XcodeGen (if not present) and regenerates Levain.xcodeproj from
#   project.yml so the CI environment does not depend on a committed .xcodeproj
#   that might diverge from the source of truth.
#
# Usage:
#   bash scripts/ci_bootstrap.sh
#
# Requirements:
#   - macOS with Xcode 16+ installed (xcode-select --print-path must resolve)
#   - Homebrew (optional: used to install xcodegen if not already available via Mint or direct path)
#
# Exit codes:
#   0 = success
#   1 = fatal error (missing tool, generation failure)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_YML="$REPO_ROOT/project.yml"

echo "=== Levain CI Bootstrap ==="
echo "Repo root: $REPO_ROOT"
echo "project.yml: $PROJECT_YML"
echo ""

# ── Verify project.yml exists ────────────────────────────────────────────────
if [[ ! -f "$PROJECT_YML" ]]; then
  echo "❌ ERROR: project.yml not found at $PROJECT_YML"
  exit 1
fi

# ── Verify Xcode toolchain ───────────────────────────────────────────────────
if ! command -v xcodebuild &>/dev/null; then
  echo "❌ ERROR: xcodebuild not found. Install Xcode and accept the license."
  exit 1
fi

XCODE_VERSION=$(xcodebuild -version)
XCODE_VERSION=${XCODE_VERSION%%$'\n'*}
echo "✅ Xcode: $XCODE_VERSION"

# ── Install or locate XcodeGen ───────────────────────────────────────────────
XCODEGEN_BIN=""

if command -v xcodegen &>/dev/null; then
  XCODEGEN_BIN=$(command -v xcodegen)
  echo "✅ XcodeGen already in PATH: $XCODEGEN_BIN"
elif command -v mint &>/dev/null; then
  echo "⬇️  Installing XcodeGen via Mint..."
  mint install yonaskolb/XcodeGen
  XCODEGEN_BIN="$(mint which xcodegen)"
  echo "✅ XcodeGen installed via Mint: $XCODEGEN_BIN"
elif command -v brew &>/dev/null; then
  echo "⬇️  Installing XcodeGen via Homebrew..."
  brew install xcodegen
  XCODEGEN_BIN=$(command -v xcodegen)
  echo "✅ XcodeGen installed via Homebrew: $XCODEGEN_BIN"
else
  echo "❌ ERROR: XcodeGen not found and no package manager available."
  echo "   Install XcodeGen via Homebrew (brew install xcodegen) or Mint."
  exit 1
fi

XCODEGEN_VERSION=$({ "$XCODEGEN_BIN" --version 2>&1 || echo "unknown"; })
XCODEGEN_VERSION=${XCODEGEN_VERSION%%$'\n'*}
echo "   Version: $XCODEGEN_VERSION"
echo ""

# ── Generate Xcode project ───────────────────────────────────────────────────
echo "⚙️  Generating Levain.xcodeproj from project.yml..."
"$XCODEGEN_BIN" generate --spec "$PROJECT_YML" --project "$REPO_ROOT"

if [[ ! -d "$REPO_ROOT/Levain.xcodeproj" ]]; then
  echo "❌ ERROR: Levain.xcodeproj was not generated."
  exit 1
fi

echo ""
echo "✅ Bootstrap complete. Levain.xcodeproj is ready."
echo ""
echo "Next step: bash scripts/ci_test.sh"
