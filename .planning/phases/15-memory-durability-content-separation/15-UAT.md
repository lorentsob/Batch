# Phase 15 UAT Checklist

## Goal

Confirm that memory durability, backup/restore, and bundled system-content separation behave correctly on a real device and on a fresh local store.

## Checklist

- [ ] Install a build with existing user data on an iPhone, then install the new build over it and verify starter, refresh log, saved recipes, bakes, and bake steps remain intact.
- [ ] Open the Starter tab settings sheet and export a backup JSON file.
- [ ] Delete the app or reset the local store, reinstall, import the exported backup, and verify the restored data matches the original logical state.
- [ ] After restore, verify bake and starter notifications are resynced and no stale reminders remain.
- [ ] Launch the app on a fresh empty store without demo seed and verify `Nuovo bake` still shows the bundled system templates.
- [ ] Launch the app with `LEVAIN_SEED_SAMPLE_DATA=1` and verify demo seed still works for internal testing without replacing the bundled system-template source.

## Notes

- Any failure involving missing user data after an app update is Phase 15 critical and blocks closure.
- If backup or restore mismatches are found, capture the JSON payload used for the round-trip before modifying the store again.
