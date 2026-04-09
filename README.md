# Batch

Batch is a native iPhone app for operational fermentation planning. It keeps the next action obvious across bread, sourdough starter, and milk kefir workflows without turning into a generic recipe manager or requiring any backend infrastructure.

This repository is maintained as a portfolio-ready product repo. The app name shown to users is `Batch`; some internal technical identifiers still use `Levain` while the public rename is being completed.

## What It Does

- Keeps `Oggi` focused on the next actionable step instead of a generic dashboard
- Supports bread workflows with formulas, generated timelines, timeline shifts, and execution tracking
- Supports starter logging, reminder planning, and operational health checks
- Supports milk kefir batch tracking, lineage, archive history, and storage-aware reminders
- Keeps reference knowledge bundled locally for fast offline access

## Product Scope

- Platform: iPhone only
- Stack: SwiftUI, SwiftData, UserNotifications, bundled JSON content
- Architecture: local-first, single-user, offline-first
- Status: active personal product / presentation repo

## Local Development

### Prerequisites

- macOS with Xcode 16.3+
- iOS 26 SDK
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

### Setup

```bash
bash scripts/ci_bootstrap.sh
open Levain.xcodeproj
```

Use the `Levain` scheme when running locally. The on-device display name is `Batch`.

## CI Reality

The repository documentation is intentionally honest about the current workflow:

- The public default branch is `main`
- GitHub Actions CI currently runs on a `self-hosted` runner
- CI currently performs build validation only
- External forks should not expect self-hosted CI validation automatically

See [docs/ci-cd.md](docs/ci-cd.md) for the exact current workflow.

## Repository Intent

This repo is optimized first for product presentation and code review, not for broad outside contribution. Internal planning and agent-only working files stay outside the shared repo surface so the public project remains focused and readable.

## License

This repository is source-visible for review and portfolio purposes. Reuse is not permitted without written permission. See [LICENSE](LICENSE).
