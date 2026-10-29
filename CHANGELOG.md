# Changelog

All notable changes are recorded here. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and versions follow [Semantic Versioning](https://semver.org/).

The `-g1` suffix marks Gate 1 diagnostic builds. It is dropped once the forgotten-resume reminder replaces the diagnostic.

## [Unreleased]

## [0.1.0-g1] - 2026-10-29

### Added

- Gate 1 diagnostic data field for the Garmin Instinct 2 (`instinct2`), first verified on 2026-08-10.
- `Oxx` observation mask and `Lxx` previous-session mask.
- Callback continuity, movement, timer-state, vibration, memory, and persistence observations.
- One-shot three-pulse vibration probe five seconds after a manual stop.
- 21 Run No Evil unit tests, covering the monitor and session storage.
- MIT license, privacy policy, CI, and a tag-driven release workflow.

### Changed

- The live `40` persistence bit is set only after the checkpoint read-back succeeds.
- Field label moved to `resources/strings.xml`.
- Build ID renamed from `g1-0.1.0` to `0.1.0-g1` so it is a valid semantic version. Signed artifacts change with it, so the checksums in `VERIFICATION.md` apply to the old ID only.
