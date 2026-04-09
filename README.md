# Batch

Batch is a native iPhone app for operational fermentation planning.

It is built around one simple question: **what needs attention now?** Instead of behaving like a recipe archive, a food-content app, or a generic fermentation tracker, Batch is designed to help a person manage living ferments over time with clarity, continuity, and as little friction as possible.

This repository is maintained as a portfolio-ready product repo. The app name shown to users is **Batch**. Some internal technical identifiers still use **Levain** while the public rename is being completed.

The interface language is **Italian**.

## Product Overview

Batch started from sourdough and bread-making workflows, but its direction is broader: it is becoming a local-first operational system for **living ferments**. The current product scope covers:

- bread workflows and real bake execution
- sourdough starter management
- milk kefir batch tracking
- bundled reference knowledge for fermentation routines and troubleshooting

The long-term concept is not "bread app plus extras". It is a **single calm system for following cultures, batches, routines, pauses, restarts, and next actions across different fermented preparations**.

## What Batch Is

Batch is:

- a planner-first fermentation app
- an operational companion for real routines
- a local-first personal tool
- a native iPhone product built to stay simple and fast
- a focused system for tracking live cultures and active batches over time

## What Batch Is Not

Batch is not:

- a generic recipe manager
- a social or community platform
- an AI fermentation assistant
- a content-heavy food app
- a cloud-dependent SaaS product
- a backend-heavy multi-user system

That constraint is intentional. The product works best when it stays concrete, readable, and action-oriented.

## Core Concept

Fermentation is not static. A starter, a dough, or a kefir batch changes over time and often does not follow the plan perfectly. Batch exists to make that moving reality easier to manage.

The core concept is:

> **living processes, tracked operationally**

That means the app is designed around:

- routines
- timing windows
- next steps
- flexible adjustments
- status clarity
- continuity between one batch and the next

The goal is not to log everything. The goal is to help the user understand **what is happening, what matters, and what to do next**.

## Product Promise

Batch helps the user:

- understand what is active right now
- see the next relevant action quickly
- manage fermentation workflows without separate notes
- adjust schedules when reality changes
- keep historical continuity between batches, refreshes, and maintenance routines
- access useful reference knowledge offline when needed

## Experience Principles

The product is guided by a few stable principles:

### 1. Action-first

The app should surface the next relevant action before anything else.

### 2. Calm clarity

The interface should feel quiet, precise, and legible, not busy or overly technical.

### 3. Local-first

The app should remain useful without accounts, sync, or backend infrastructure.

### 4. Real-world flexibility

Fermentation does not behave like a rigid timer. Planned values matter, but actual execution matters more.

### 5. Progressive disclosure

Advanced data can exist, but it should not clutter the core flow.

## Main Product Areas

The app is structured around three tabs.

### Oggi

The operational home of the app.

Oggi is not a generic dashboard. It is the place where the user immediately sees:

- what is running
- what is overdue
- what is coming later today
- which starter or ferment needs attention
- what can wait until tomorrow

### Fermentazioni

The hub for active fermentation work.

This tab brings together all operational areas in one place. Users can navigate into bread workflows, sourdough starter management, and kefir batch tracking from a unified surface. Each area can be enabled or disabled independently based on what the user is actively managing.

**Bread and bakes** — Batch supports formula-based bake creation, schedule generation, step-by-step execution, timer guidance, and timeline shifts when the original plan changes.

**Starter** — Users can manage starter profiles, log refreshments quickly, track due states, and keep routine maintenance separate from active baking execution while still connected to it.

**Kefir** — Milk kefir batch tracking with lineage, archive history, event logging, and storage-aware reminders. Kefir shares the same operational logic as sourdough: recurring care, living cultures, storage states, pauses, restarts, and lightweight continuity between batches.

### Guide

Bundled local knowledge content for practical guidance.

This tab is intentionally lightweight. It exists to support the workflow with contextual help, troubleshooting, and quick reference — not to become a full editorial platform. Knowledge items link contextually from within operational flows so the user can access relevant theory without leaving the task.

## Key Behaviors

Some of the core product behaviors that define Batch:

- **Oggi-first prioritization** so urgent and active work appears before passive information
- **Formula-driven scheduling** for breads and structured workflows
- **Real vs planned timing** so actual execution can diverge from the original schedule
- **Timeline shifting** to push future steps forward without rewriting everything manually
- **Starter due-state logic** based on simple maintenance data
- **Batch continuity** for ferments that evolve over days and across derived batches
- **Local notifications** for reminders that still work without a server
- **Offline knowledge access** from bundled app content
- **Per-ferment toggles** so users can activate only the areas they currently need

## What a Future Version Could Include

The product direction is toward a broader operational hub for living ferments. The current architecture is designed to accommodate new ferment categories without turning the app into a generic food tracker.

Ferment categories that are conceptually natural extensions of the same system:

- **Kombucha** — SCOBY management, continuous vs batch cycles, bottling stages, carbonation tracking
- **Vinegar** — mother culture, acidification stages, dilution and monitoring
- **Tempeh** — spore-to-substrate, incubation timing, temperature windows
- **Miso and long ferments** — multi-month tracking, stage markers, environmental notes
- **Fermented vegetables** — lacto-fermentation batches, brine ratios, tasting windows, archiving
- **Water kefir** — grain management parallel to milk kefir, carbonation stages, flavor variants
- **Ginger beer and sodas** — GBP maintenance, secondary fermentation, pressure tracking

Each of these categories shares the operational core that Batch is already built for: a living culture or batch, a recurring care routine, a timeline that evolves, state transitions that matter, and the need to know what comes next. Adding a new ferment category means extending the data model and workflow surfaces — not rebuilding the system.

The long-term product idea is a **single calm system for ferments of any kind**, governed by the same operational logic: observe, act, continue.

## Why the Product Exists

Many existing tools around baking and fermentation lean too far in one of these directions:

- recipe storage
- content browsing
- community sharing
- over-detailed hobbyist logging

Batch takes a different stance.

It is built for the operational gap between "I know the theory" and "I need to manage this live process across time". The product is most useful when the user is in the middle of something real: a dough in bulk fermentation, a starter due for refresh, a kefir batch that needs attention, or a schedule that has slipped.

## Design Direction

The product direction is intentionally contemporary and restrained.

Batch should feel:

- precise
- calm
- alive
- refined
- reliable
- quietly intelligent

It should not feel rustic, nostalgic, decorative, overly scientific, or like a generic food brand. The visual and verbal identity are meant to support the product behavior rather than compete with it.

## Product Scope

### Platform

- iPhone only

### Technical direction

- SwiftUI
- SwiftData
- UserNotifications
- bundled JSON content
- local-first architecture
- no backend
- no auth
- no sync
- no third-party dependency baseline

### Usage model

- single user
- offline-first
- personal product
- interface language: Italian
- internal testing and portfolio presentation

## Repository Intent

This repository is meant to do two things at once:

1. show the product clearly as a coherent portfolio project
2. keep the implementation understandable for review and future iteration

Because of that, the repo is optimized for:

- product presentation
- code review readability
- honest documentation
- clear architecture and feature boundaries

## Current State

The product direction, core UX, architecture, and roadmap are already defined in detail. The repository documents a native iPhone app with a three-area structure around Oggi, Batch, and Guide, and a roadmap that covers app shell, execution flows, starter management, kefir tracking, knowledge, and hardening for internal release confidence.

## Local Development

### Prerequisites

- macOS with Xcode 16.3+
- iOS 26 SDK (requires a pre-release Xcode toolchain)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

### Setup

```bash
bash scripts/ci_bootstrap.sh
open Levain.xcodeproj
```

Use the `Levain` scheme when running locally. The on-device display name is `Batch`.

## CI Reality

The repository documentation is intentionally honest about the current workflow:

- the public default branch is `main`
- active development happens on `develop` and feature branches
- GitHub Actions CI currently runs on a `self-hosted` runner
- CI currently performs build validation only
- external forks should not assume green hosted CI out of the box

See [docs/ci-cd.md](docs/ci-cd.md) for the exact current workflow.

## License

This repository is source-visible for review and portfolio purposes. Reuse is not permitted without written permission. See [LICENSE](LICENSE).
