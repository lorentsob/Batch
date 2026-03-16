# TASK — Verify and optimize Xcode development workflow (Preview / Simulator / Build speed)

Goal:
Reduce rebuild time during development and enable fast iteration using SwiftUI previews,
incremental builds, and correct Debug configuration.

The agent must:

1. Inspect current project configuration
2. Detect wrong build settings
3. Detect wrong scheme configuration
4. Detect preview usage
5. Apply safe optimizations
6. Do NOT change app logic
7. Do NOT change target structure unless required
8. Do NOT change Release configuration

Project: Levain iOS app
IDE: Xcode
Language: Swift / SwiftUI


--------------------------------------------------
STEP 1 — Detect project targets and schemes
--------------------------------------------------

Check:

- all targets
- all schemes
- which scheme is used for Run
- which configuration Run uses

Verify:

Run configuration must be DEBUG

Expected:

Run → Debug
Test → Debug
Profile → Release
Archive → Release

If Run is not Debug → fix it


--------------------------------------------------
STEP 2 — Verify build configuration (Debug)
--------------------------------------------------

For main app target:

Check Build Settings:

Swift Compiler - Code Generation

Verify:

SWIFT_OPTIMIZATION_LEVEL (Debug) = -Onone
SWIFT_COMPILATION_MODE (Debug) = incremental

If not → set them

Expected:

Debug must be optimized for speed, not performance


--------------------------------------------------
STEP 3 — Verify incremental build is enabled
--------------------------------------------------

Check:

Build Settings → Compilation Mode

Must be:

Incremental

NOT:

Whole Module

If Whole Module in Debug → change to Incremental


--------------------------------------------------
STEP 4 — Verify scheme build targets
--------------------------------------------------

Open Scheme → Edit Scheme → Build

Check which targets are built when running

Remove unnecessary targets from Run build action.

Only required:

- main app target
- required frameworks
- required packages

Do NOT remove dependencies needed for run


--------------------------------------------------
STEP 5 — Verify SwiftUI Preview support
--------------------------------------------------

Search project for:

#Preview
PreviewProvider

Check:

- how many views support preview
- if previews compile
- if preview canvas works

If previews missing in main views:

Add preview blocks ONLY if safe.

Example:

#Preview {
    ContentView()
}

Do not modify logic.


--------------------------------------------------
STEP 6 — Verify simulator workflow
--------------------------------------------------

Check current workflow assumptions:

Does the project require full rebuild every run?

Test:

small UI change
→ run again

Verify if incremental build is used.


--------------------------------------------------
STEP 7 — Verify build cleaning usage
--------------------------------------------------

Search docs / scripts / instructions for:

clean build
Shift+Cmd+K
xcodebuild clean

If clean is used in normal workflow → remove it.

Clean must be used only for errors.


--------------------------------------------------
STEP 8 — Verify packages / dependencies impact build time
--------------------------------------------------

Check:

Swift Packages
Frameworks
Local packages

If heavy dependencies always rebuild:

ensure they are not part of main target unnecessarily.

Do NOT remove packages without confirmation.


--------------------------------------------------
STEP 9 — Verify Debug vs Release separation
--------------------------------------------------

Ensure:

Debug
- incremental
- no optimization
- fast build

Release
- optimized
- whole module allowed

Do not modify Release settings.


--------------------------------------------------
STEP 10 — Report result
--------------------------------------------------

Agent must output:

1. Current configuration
2. Problems found
3. Changes applied
4. Remaining limitations
5. Suggestions for faster workflow


Expected final state:

- Debug incremental build
- Correct scheme
- Minimal build targets
- Preview enabled
- Fast Cmd+R cycle
- No unnecessary clean
- Simulator rebuild minimized


--------------------------------------------------
IMPORTANT RULES
--------------------------------------------------

Do not:

- change app architecture
- change data model
- change navigation
- change package versions
- change signing
- change bundle id

Only modify:

- scheme
- debug build settings
- preview support
- build configuration