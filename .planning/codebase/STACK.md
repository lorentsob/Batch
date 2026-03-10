# Technology Stack

**Analysis Date:** 2026-03-10

## Languages

**Primary:**
- Swift 6.2.4 - All application, test, and feature code
- Markdown - Product requirements, planning artifacts, and editorial source content

**Secondary:**
- YAML - XcodeGen project manifest in `project.yml`
- JSON - Bundled knowledge content and planning config

## Runtime

**Environment:**
- Xcode 26.3 - Local iOS build toolchain
- iOS 26 simulator/device runtime target - Native application runtime

**Package Manager:**
- None - no external package manager or dependency graph is required
- Lockfile: not applicable

## Frameworks

**Core:**
- SwiftUI - Native iPhone UI framework
- SwiftData - Local persistence and querying
- UserNotifications - Local reminder scheduling and handling

**Testing:**
- XCTest - Unit and UI testing

**Build/Dev:**
- XcodeGen 2.44.1 - Generates the Xcode project from `project.yml`
- xcodebuild - Command-line build and test entry point

## Key Dependencies

**Critical:**
- Apple frameworks only - no third-party libraries are part of the baseline stack

**Infrastructure:**
- Bundled JSON in `Levain/Resources/knowledge.json` - static knowledge content

## Configuration

**Environment:**
- No environment variables or external credentials
- Local-only data persistence and local notifications

**Build:**
- `project.yml` - XcodeGen source of truth for the project structure
- `.planning/config.json` - GSD workflow defaults for this repo

## Platform Requirements

**Development:**
- macOS with Xcode 26.3 installed
- No backend services or Docker dependencies

**Production:**
- Internal iPhone testing only
- Minimum target: iOS 26

---
*Stack analysis: 2026-03-10*
*Update after major dependency changes*
