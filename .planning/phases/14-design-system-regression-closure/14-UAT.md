# Phase 14 UAT Checklist

## Goal

Confirm the design-system regression fixes match the five screenshots and keep the app light-only.

## Checklist

- [x] Enable iOS dark appearance and verify Home, Impasti, and Starter navigation chrome stay light.
- [x] Open `Nuovo bake` and verify the modal background stays `Theme.Surface.app`, not dark system gray.
- [x] Verify the top-right `Nuovo bake` CTA and the tab navigator never switch to dark styling in dark iOS appearance.
- [x] Cancel a bake and confirm the confirmation surface appears bottom-aligned, not as a misplaced popover.
- [x] After cancelling, confirm the summary card is red, the remaining timeline reads as archived, tips are hidden, and the final CTA changes to `Elimina impasto`.
- [x] Verify overdue timeline rows have bordered red chips and the dot is centered on the rail.
- [x] Delete a cancelled bake and confirm the app returns cleanly to the bake list with no stale detail view left onscreen.

## Notes

- If any remaining issue is purely visual, capture a fresh screenshot and compare it directly against `docs/DESIGN-SYSTEM.md`.
