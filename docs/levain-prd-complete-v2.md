# Levain
## Product Definition, UX, PRD Direction, and Technical Stack

## 1. Project Overview

This app is a personal iPhone-only tool for managing sourdough starter and homemade baking workflows.

The product is **not** a generic recipe app.
It is a **planner and operational companion for baking and fermentation**, designed to answer one central question:

**What do I need to do now?**

The app should help the user:
- manage active bakes
- follow steps, timings and real execution
- keep track of starter maintenance
- save reusable baking formulas
- surface useful tips at the right moment

The project is currently:
- a **personal project**
- for **internal testing**
- intended as a **fast MVP**
- designed to be **minimal**
- designed to avoid unnecessary setup, infrastructure, and complexity
- built with **native iPhone development** in mind

---

## 2. Product Positioning

### What the app is
A planner-first baking app focused on:
1. **active bake execution**
2. **step timing and reminders**
3. **timeline adjustment when reality changes**
4. **starter management as a secondary function**
5. **formula reuse**
6. **contextual knowledge and troubleshooting tips**

### What it is not
It should not become:
- a bloated recipe manager
- a social/community app
- an AI baking assistant
- a multi-device platform
- a general food logging tool
- an infrastructure-heavy SaaS

The goal is to keep the product focused and operational.

---

## 3. Core Product Direction

### Primary focus
The core of the app is **baking workflow management**.

### Secondary focus
Starter management supports the baking workflow but is not the main center of the product.

### Main product promise
The product should let the user:
- see what must be done today
- manage a bake in progress
- track steps with timers and reminders
- adapt the timeline when delays happen
- store and reuse formulas
- maintain starter without keeping separate notes

---

## 4. Target Platform and Product Constraints

### Platform
- **iPhone only**
- no iPad requirement for MVP
- native iOS experience preferred
- acceptable to target **only iOS 26**, since this is for personal use and internal testing

### Product constraints
- internal testing only
- no public launch requirement for MVP
- no backend
- no authentication
- no sync
- no cloud dependency
- no external database
- no fancy functionality that adds complexity without validating value

### Product philosophy
This MVP should be:
- fast to build
- fast to test
- low setup
- low maintenance
- predictable for AI-assisted implementation
- minimal in both UX and technical structure

---

## 5. Validation of Existing Direction

The previous product direction is considered solid for these reasons:

### 5.1 Planner-centric approach
The choice to make the app planner-first is correct.
The product should not be centered around recipe storage but around daily action and workflow execution.

### 5.2 Separation of concerns
The distinction between:
- starter
- baking workflows
- knowledge/tips

is good and should remain clear.

### 5.3 Offline-first and single-user
This is appropriate for an MVP and removes large amounts of technical complexity.

### 5.4 Strong process orientation
The app focuses on:
- timing
- stages
- flexible execution
- real vs planned events

This is one of the strongest parts of the concept.

---

## 6. Product Priorities

## 6.1 Core priority areas
These are the true core of the MVP:

1. **Today**
2. **Bakes**
3. **Bake steps**
4. **Step timers**
5. **Timeline shift**
6. **Recipe formulas**
7. **Starter essentials**
8. **Local tips**

### 6.2 Supporting but secondary
These should exist but not dominate the UX:
- flour mix for starter
- container weight
- advanced fields
- lightweight knowledge section

### 6.3 Hidden or advanced
These should stay hidden or minimized:
- photo logging
- rich note systems
- over-detailed nerd metrics
- encyclopedic knowledge browsing

---

## 7. UX Direction

## 7.1 Home = Today
The home screen should be the operational center of the app.

It must be **action-first**, not dashboard-first.

### Priority order in Today
1. **Now / overdue**
2. **Upcoming steps today**
3. **Starter refreshes due**
4. **Later / tomorrow**

### Each item in Today must show
- clear title
- time or window
- state
- one obvious primary action

### Example items
- “Bulk fermentation · Pane base”
- “running · expected end 15:40”
- action: `Open step`

or

- “Starter grano duro”
- “refresh due today”
- action: `Refresh`

### UX rule
The Today screen should feel like a to-do board for fermentation, not a static overview.

---

## 7.2 Most important screen: Bake Detail
The bake detail screen is the real center of the product.

### Header content
Only useful information:
- bake name
- bake type
- overall status
- target bake time
- linked recipe formula
- linked starter if applicable

### Step list
Steps should appear as large, readable cards.

Each step should show:
- step name
- planned time or window
- planned duration
- current state
- active timer if any
- qualitative target if present
  - target rise
  - expected temperature range
  - poke test or dough condition notes

### Primary action per step
Each step should surface only one main action:

- if `pending` → **Start**
- if `running` → **Complete**
- if complete → **View details**
- if needed → **Shift timeline**

The screen must not become overloaded with controls.

---

## 7.3 Step state logic
Step behavior must be defined clearly.

### Step statuses
- `pending`
- `running`
- `done`
- `skipped`

### Rules
1. Every step starts as `pending`
2. Pressing **Start** changes it to `running` and saves `actualStart`
3. Pressing **Complete** changes it to `done` and saves `actualEnd`
4. Skipping changes it to `skipped`
5. A step does **not** change logical status automatically just because time passed
6. If time has passed but the step is not completed, the UI may show an **overdue/late** label, but that is only a derived UI label, not a true status

This is important because real baking does not strictly follow the clock.

---

## 7.4 Timers
The app should support **timers for individual steps**.

### Timer behavior
- each timer is attached to a step
- the timer can start from the step’s planned duration
- the user can complete the step earlier or later
- when the timer ends, the app sends a standard local notification
- timer completion does **not** automatically complete the step

### UX principle
Timers support the workflow, but the user remains in control of the actual state.

---

## 7.5 Shift Timeline
This is a core feature and should not be treated as secondary.

### Purpose
When a step runs late, the user needs to shift the remaining schedule quickly.

### Interaction model
From a step, the user can select `Shift timeline` and choose:
- `+15 min`
- `+30 min`
- `+1 h`
- `Custom`

### Effect
The action shifts forward:
- future planned step times
- future windows
- future reminders

### Rule
Only future steps that are not yet completed are shifted.
Completed or skipped steps are not affected.

---

## 7.6 Templates, formulas, and reusable structure
The original idea of templates is good, but the product model should be simplified.

### Recommended model
Use:
- `RecipeFormula`
- `Bake`
- `BakeStep`

Instead of creating a separate heavyweight template concept, treat a reusable formula as the main reusable object.

### RecipeFormula
This is the reusable formula:
- name
- type
- total flour
- total water
- hydration
- salt
- inoculation
- flour mix if relevant
- notes
- default step structure

### Bake
This is the real execution instance:
- linked to a recipe formula
- linked to a real date
- linked to a starter if applicable
- contains real timings
- contains actual execution values

### Result
The product remains simpler, while still supporting:
- reusable structures
- editable defaults
- generated timelines

---

## 7.7 Recipe formulas must be modifiable and calculable
You specified that templates should be:
- modifiable
- calculable

This should be interpreted as:
- a saved `RecipeFormula` is editable
- step timings can be generated from a target bake time
- the app can calculate a step schedule from defaults
- the user can still manually edit the resulting schedule

At MVP stage, calculation should remain simple:
- forward or backward from time anchors
- based on step defaults
- editable by the user after generation

No advanced predictive system is needed.

---

## 7.8 Minimal interface with advanced fields hidden
The overall UX should be minimal.

### Rule
Secondary and nerdier data should live in:
- expandable sections
- advanced fields
- detail screens

They should not dominate:
- onboarding
- Today
- core bake flow
- quick starter logging

---

## 7.9 First launch
On first launch, the app should not force a heavy onboarding flow.

### Initial empty state
The user should see:
- CTA: `New bake`
- secondary CTA: `Add starter`
- low-emphasis CTA: `Explore tips`

### UX principle
The app should let the user begin immediately.

---

## 8. Main Product Flows

## 8.1 Create recipe formula
Suggested flow:
1. enter name
2. choose type
3. enter core baking parameters
4. define default steps or use defaults
5. save

This must be short and practical.

---

## 8.2 Create bake from formula
Suggested flow:
1. choose recipe formula
2. choose target bake date/time
3. choose starter if needed
4. confirm
5. generate step timeline automatically

This is one of the most important flows in the app.

---

## 8.3 Manage active step
Suggested flow:
1. open bake
2. open current step
3. tap Start
4. timer begins
5. local reminder fires when needed
6. user completes, skips, or shifts timeline
7. schedule updates

---

## 8.4 Log starter refresh
Suggested flow:
1. open starter or Today reminder
2. enter main weights
3. save
4. update `lastRefresh`
5. recalculate next due date

This flow should be very fast.

---

## 8.5 Starter reminders
Starter reminders should be simple and reliable.

### Logic
- reminder on the day the starter is due
- optional reminder again the next day if no refresh was logged

### Derived UI state
Starter status should be derived, not deeply modeled as a state machine.

Suggested UI labels:
- `ok`
- `due today`
- `overdue`

Calculated from:
- `lastRefresh`
- `refreshIntervalDays`

---

## 8.6 Bake status
Bake status should be derived from step activity.

### Bake statuses
- `planned`
- `in_progress`
- `completed`
- `cancelled`

### Rules
- if at least one step is `running`, bake is `in_progress`
- if all steps are `done` or `skipped`, bake is `completed`
- if created but not started, bake is `planned`
- cancellation is manual

---

## 9. Data Model Direction

## 9.1 Starter
Keep these fields:

- `name`
- `type`
- `hydration`
- `flourMix`
- `containerWeight`
- `storageMode`
- `refreshIntervalDays`
- `remindersEnabled`
- `lastRefresh`
- `notes`

### Product decision
`flourMix` and `containerWeight` should remain in the product.

They make sense because:
- they support real starter maintenance
- they can be set once and reused
- they do not need constant repetition in the main flow

---

## 9.2 StarterRefresh
Recommended structure:

### Core fields
- `starterId`
- `dateTime`
- `flourWeight`
- `waterWeight`
- `starterWeightUsed`
- `ratioText`
- `putInFridgeAt`
- `notes`

### Advanced fields
- `ambientTemp`
- `photoUri`

---

## 9.3 RecipeFormula
Recommended fields:
- `id`
- `name`
- `type`
- `totalFlourWeight`
- `totalWaterWeight`
- `hydrationPercent`
- `saltWeight`
- `saltPercent`
- `inoculationPercent`
- `servings`
- `notes`
- `defaultSteps`
- `flourMix`

This is the main reusable entity.

---

## 9.4 Bake
Recommended fields:
- `id`
- `name`
- `type`
- `dateCreated`
- `targetBakeDateTime`
- `recipeFormulaId`
- `starterId`
- `inoculationPercent`
- `totalFlourWeight`
- `totalWaterWeight`
- `totalDoughWeight`
- `hydrationPercent`
- `servings`
- `status`
- `notes`

### Product decision
`rating` should be removed from the MVP core.
It adds little value compared to the complexity and noise it introduces.

---

## 9.5 BakeStep
Recommended fields:
- `id`
- `bakeId`
- `order`
- `type`
- `nameOverride`
- `description`
- `plannedStart`
- `plannedDurationMinutes`
- `flexibleWindowStart`
- `flexibleWindowEnd`
- `actualStart`
- `actualEnd`
- `reminderOffsetMinutes`
- `temperatureRange`
- `volumeTarget`
- `status`
- `notes`

### Optional advanced
- `photoUri`

### Product note
The window fields are valuable because they support the reality that fermentation is flexible and not perfectly deterministic.

---

## 9.6 Knowledge model
The knowledge layer should start as static bundled content.

Possible `KnowledgeItem` structure:
- `id`
- `title`
- `category`
- `tags`
- `summary`
- `content`
- `relatedStepTypes`
- `relatedStarterStates`

However, this content does **not** need to be stored in the user persistence layer at MVP stage.

---

## 10. Knowledge Base Direction

## 10.1 Role of knowledge
Knowledge should mainly exist to provide:
- contextual tips
- troubleshooting help
- lightweight reference content

It should **not** become a huge editorial section.

---

## 10.2 Source of truth
The knowledge content should come from **local files**.

You specified that the info can be inserted as a file and all the knowledge comes from there.
This aligns perfectly with a local JSON-based approach.

---

## 10.3 Recommended MVP implementation
### Level 1: contextual tips
Tips should appear:
- next to fields
- near steps
- in troubleshooting moments
- inside starter and bake flows

### Level 2: lightweight Knowledge tab
A small frontend section is useful because:
- the content already exists
- local JSON is cheap to maintain
- it makes the knowledge visible and usable beyond inline tips

### Recommendation
Yes, include a **Knowledge** tab, but keep it light.

---

## 10.4 Knowledge topics already identified
The attached knowledge material supports these kinds of topics:
- starter basics
- fridge starter maintenance
- sluggish starter
- baker’s math
- hydration ranges
- bulk fermentation
- proofing and cold retard
- timing and temperature
- troubleshooting dense results
- troubleshooting overproofing
- troubleshooting crumb issues

This content is suitable for:
- short articles
- contextual help
- category lists
- related tips

---

## 11. Final Navigation Structure

Recommended iPhone tab bar:
1. **Today**
2. **Bakes**
3. **Starter**
4. **Knowledge**

### Reasoning
`Bakes` must come before `Starter` because the product’s true center is baking, with starter as a supporting feature.

---

## 12. Technical Strategy

## 12.1 Core technical goals
The tech stack must:
- minimize manual intervention
- reduce setup friction
- reduce integration points
- reduce bug surface
- let AI generate code with high predictability
- remain testable fast
- preserve native iOS feeling

### Critical preference
Since the project is built in a vibe-coding workflow, the stack should be as straightforward and Apple-native as possible.

---

## 12.2 Final stack recommendation
Use:

1. **Swift**
2. **SwiftUI**
3. **SwiftData**
4. **UserNotifications**
5. **local JSON files**
6. **no external backend**
7. **no external database**
8. **no auth**
9. **no cloud sync**
10. **ideally no third-party libraries**

This is the recommended definitive direction.

---

## 12.3 Why native iOS
You explicitly prefer a native app and want to test iOS development.

### Therefore avoid
- React Native
- Flutter
- Expo
- Capacitor
- hybrid wrappers

These would add:
- more setup
- more abstraction
- more plugin risk
- more debugging complexity
- less direct alignment with your goal

### Native direction
Use **Swift + SwiftUI** for the cleanest path.

---

## 12.4 Why SwiftUI
SwiftUI is the right choice because:
- native iPhone feel
- fast layout iteration
- low-boilerplate UI
- easier for AI to generate consistently
- simple to structure with tabs, navigation stacks, lists, sheets and forms

This fits the product shape very well.

---

## 12.5 Why SwiftData
SwiftData is the recommended local persistence layer.

### Why it fits
- local structured data
- low setup
- simpler than Core Data
- readable for AI-assisted coding
- aligned with the app’s small, clear data model
- enough for offline-first personal MVP

### Why not Core Data
Core Data would add more mental and implementation overhead than necessary for this case.

### Why not external storage
No external DB is needed because the app is:
- single user
- local
- internal test
- non-syncing
- low complexity

---

## 12.6 No external database
No external database is required.

This means:
- no Supabase
- no Firebase
- no custom backend
- no server
- no auth layer
- no API layer

All user data can be stored on device.

### Data stored locally
- starters
- refresh logs
- recipe formulas
- bakes
- bake steps
- app settings

### Knowledge content
Knowledge should stay in bundled local files, not in a remote DB.

---

## 12.7 Notifications
Use **UserNotifications** with **local notifications only**.

### Notification logic
- schedule step reminders locally
- schedule starter reminders locally
- reschedule them when bake timelines shift
- tap on a notification should deep link into the correct bake or starter context

### Important behavioral decision
For reliable use with the app closed:
- rely on scheduled local notifications
- do **not** rely on a live background timer model

This is the robust path for iPhone.

---

## 12.8 Timers vs notifications
Timer behavior should remain part of the in-app workflow and visual state.

Reliability with app closed should come from:
- persisted data
- local scheduled notifications

This avoids fragile background behavior.

---

## 12.9 Knowledge implementation
Use **JSON files bundled in the app**.

### Why
- content is static
- easy to maintain
- easy to version
- easy for AI to modify
- suitable for both inline tips and a small Knowledge tab

### Important decision
Knowledge content does **not** need to live inside SwiftData.

### Best split
- **SwiftData** for user-generated and operational data
- **JSON bundle** for static knowledge content

---

## 12.10 iOS target
Because this is a personal tool and internal test only, it is acceptable to target:
- **iOS 26 only**

This simplifies implementation and avoids retro-compatibility work.

---

## 13. Technical Architecture

## 13.1 Architecture principle
Do not use heavy architecture patterns.

Avoid:
- enterprise modularization
- excessive dependency injection
- elaborate clean architecture layers
- overly abstract state management libraries

The app should remain:
- clear
- folder-based
- feature-oriented
- easy for AI to understand

---

## 13.2 Recommended project structure

```text
Levain/
├── App/
│   ├── LevainApp.swift
│   ├── AppRouter.swift
│   └── AppEnvironment.swift
├── Models/
│   ├── Starter.swift
│   ├── StarterRefresh.swift
│   ├── RecipeFormula.swift
│   ├── Bake.swift
│   ├── BakeStep.swift
│   ├── KnowledgeItem.swift
│   └── AppSettings.swift
├── Features/
│   ├── Today/
│   ├── Bakes/
│   ├── Starter/
│   ├── Knowledge/
│   └── Shared/
├── Services/
│   ├── NotificationService.swift
│   ├── BakeScheduler.swift
│   ├── KnowledgeLoader.swift
│   └── DateFormattingService.swift
├── Persistence/
│   ├── ModelContainerFactory.swift
│   └── SeedDataLoader.swift
├── Resources/
│   ├── knowledge.json
│   └── Seed/
└── DesignSystem/
    ├── Theme.swift
    ├── Components/
    └── Extensions/
```

### Purpose
This is simple enough to stay manageable and structured enough to scale slightly during MVP iteration.

---

## 13.3 Logical modules
### App
App startup and routing

### Models
SwiftData models and Codable structs

### Features
Feature-based UI folders

### Services
Operational logic:
- scheduling
- notifications
- knowledge loading
- date formatting

### Persistence
Model container setup and optional seeding

### Resources
Bundled JSON content and other local files

### DesignSystem
Shared theme, components, and view helpers

---

## 14. Persistence Layer

## 14.1 SwiftData entities
Recommended persistent entities:
- `Starter`
- `StarterRefresh`
- `RecipeFormula`
- `Bake`
- `BakeStep`
- `AppSettings`

### Optional
`KnowledgeItem` can remain non-persistent and decoded from JSON instead.

---

## 14.2 Relationship direction
Recommended logical relationships:
- Starter → many StarterRefresh
- Starter → many Bake
- RecipeFormula → many Bake
- Bake → many BakeStep

---

## 14.3 Persistence recommendation
Use **SwiftData** with:
- `@Model`
- local `ModelContainer`
- straightforward queries
- lightweight derived logic

No cloud sync layer is required.

---

## 15. Testing Strategy

## 15.1 General approach
Do not over-invest in exhaustive test infrastructure for this MVP.

The goal is **fast confidence**, not enterprise QA.

---

## 15.2 Unit tests
Recommended minimal unit tests:
- generation of bake steps from `RecipeFormula`
- timeline shift logic
- derived starter due state
- derived bake status
- notification scheduling logic

---

## 15.3 UI tests
Recommended minimal UI tests:
- create formula
- create bake
- start and complete a step
- log starter refresh

This is enough for an internal MVP.

---

## 16. Dependency Strategy

Use **as few dependencies as possible**.

### Recommendation
Ideally:
- zero third-party libraries

### Reason
This reduces:
- setup time
- upgrade issues
- compatibility issues
- AI confusion
- unnecessary complexity

This is especially important in a vibe-coding workflow.

---

## 17. Implementation Principles for AI-Assisted Development

Since the app will be built with a strong AI-assisted coding workflow, the implementation should follow these principles:

1. **Use one clear stack only**
   - Swift
   - SwiftUI
   - SwiftData
   - UserNotifications
   - bundled JSON

2. **Keep the data model stable**
   Avoid changing names and structures continuously once implementation starts.

3. **Generate feature by feature**
   Do not ask the AI to generate the whole app as one giant block.

4. **Prefer direct, simple architecture**
   Avoid unnecessary abstraction.

5. **Avoid third-party tools unless a real problem appears**
   Default to Apple-native APIs.

6. **Treat timers as UI helpers and notifications as the closed-app reliability layer**
   This avoids fragile implementations.

7. **Keep advanced fields hidden**
   The AI should implement progressive disclosure, not cluttered forms.

---

## 18. Final Product Decisions Locked In

These decisions are now considered definitive:

### Product
- iPhone-only
- internal test MVP
- fast validation build
- minimal UX
- baking-first product
- starter as secondary support
- recipe formulas reusable
- formulas editable and calculable
- step timers required
- standard notifications only
- reliable behavior with app closed through local notifications
- advanced data hidden
- knowledge used mainly as tips
- lightweight Knowledge tab allowed and recommended
- project remains personal and simple

### Data
- container weight stays
- flour mix stays
- rating removed from MVP core
- steps do not auto-complete
- late is a UI label, not logical status
- knowledge is local static content

### Technical
- Swift
- SwiftUI
- SwiftData
- UserNotifications
- local JSON
- no backend
- no external DB
- no auth
- no sync
- no third-party libraries if possible
- iOS 26 only is acceptable

---

## 19. Final Recommendation Summary

This app should be built as a **native iPhone app using SwiftUI and SwiftData**, with all user data stored locally and all knowledge content bundled in local JSON files.

The technical setup should remain intentionally simple:
- no backend
- no cloud
- no auth
- no external services
- no complex architecture
- no premature infrastructure

The UX should stay centered on:
- Today
- active bakes
- step execution
- timing
- notifications
- timeline shifting
- starter reminders
- reusable formulas
- lightweight contextual knowledge

This is the most coherent way to:
- validate the product fast
- keep development smooth
- reduce setup issues
- make AI-generated implementation more reliable
- stay true to the goal of testing native iOS development
