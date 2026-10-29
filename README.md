# Pause Guardian

[![CI](https://github.com/PawanPatil19/pause-guardian/actions/workflows/ci.yml/badge.svg)](https://github.com/PawanPatil19/pause-guardian/actions/workflows/ci.yml)

Pause Guardian is an experimental Garmin data field for runners and cyclists who sometimes resume moving but forget to resume their activity recording.

The current release is **Gate 1**, a diagnostic build for the Garmin Instinct 2. It proves whether Garmin continues delivering timer, GPS, and vibration access while the native activity is manually paused. It installs on a physical watch and displays its diagnostic field, but it is not yet the finished forgotten-resume reminder.

> Pause Guardian never resumes, saves, or changes an activity. Garmin remains in control of the recording. This project is independent and is not affiliated with or endorsed by Garmin.

## The idea

A completed version should notice this sequence:

1. You manually pause a Run or Bike activity.
2. You start moving again without pressing resume.
3. Movement continues long enough to rule out a few accidental steps.
4. Your watch vibrates to remind you that recording is still paused.

Before building that detector, Gate 1 tests the hard platform question: can a Connect IQ data field still receive fresh information and vibrate behind Garmin's native pause screen?

## What this build does

- Runs as a data field inside Garmin's native Run activity.
- Distinguishes manual `STOPPED` from Auto Pause `PAUSED` using `Activity.Info.timerState`.
- Checks whether callbacks and fresh GPS data continue during a manual stop.
- Sends one three-pulse vibration probe five seconds after a manual stop.
- Samples memory use and stores a compact result from the previous session.
- Rejects missing GPS, poor-quality GPS, repeated cached samples, callback gaps, and incomplete movement windows.

It does **not** detect forgotten resumes as a finished product, support cycling yet, run as a background phone app, or resume an activity automatically.

## Current status

| Area | Status |
| --- | --- |
| Instinct 2 build and package | Verified with Connect IQ SDK 9.2.0 |
| Automated tests | 15 passed, 0 failed |
| Physical installation | Verified on an Instinct 2 |
| Data field visible in native Run | Verified |
| Full manual-pause feasibility test | In progress; follow [the Gate 1 checklist](GATE1_TEST.md) |
| Forgotten-resume reminder | Planned after Gate 1 passes |

## Install and use

Pause Guardian is not in the Connect IQ Store yet. The current build must be compiled and installed by USB.

1. Follow the [complete user guide](docs/USER_GUIDE.md) to build and copy `PauseGuardian.prg` to the watch.
2. On the Instinct 2, hold **MENU** and open **Activities & Apps → Run → Run Settings → Data Screens**.
3. Select a data screen, edit its data fields, and select an individual field slot.
4. Choose **Connect IQ → Pause Guardian G1**.
5. Start an outdoor Run and keep the field visible while completing [GATE1_TEST.md](GATE1_TEST.md).

If **Connect IQ** is not visible, first select an individual field slot. The Connect IQ category appears at the field-selection level, not at the top of the Data Screens menu.

## Reading the field

The value is deliberately only three characters so it fits the smallest Instinct 2 data-field layouts.

- `Oxx` is the observation mask for the current session.
- `Lxx` is the previous stored mask, shown for ten seconds after launch or reset.

The final two characters are hexadecimal. Several observations can be combined: for example, `O03` means both `01` and `02` have been observed.

| Bit | Evidence collected |
| --- | --- |
| `01` | At least 18 stopped-state callbacks, with no gap over two seconds |
| `02` | Running profile, usable GPS, speed of at least 1.4 m/s, six seconds, and at least six metres of displacement |
| `04` | Authoritative timer data reported both manual `STOPPED` and Auto Pause `PAUSED` |
| `08` | The three-pulse vibration call was attempted without an exception |
| `10` | Stopped-state callbacks remained continuous for five minutes |
| `20` | Sampled app memory stayed at or below 24 KiB |
| `40` | The latest diagnostic checkpoint was stored |

`O7F` means every automatic observation bit is set. It is still not a physical pass: the watch API cannot confirm that the user actually felt the vibration, and the external SDK profiler must be checked separately.

## Build and test

Requirements:

- macOS with [Garmin Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/)
- Connect IQ SDK 9.2.0 with the `instinct2` device package
- Java supported by the Garmin SDK
- A private Connect IQ developer key stored outside this repository

```sh
task_ciq_sdk="$(cat "${HOME}/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"

# Build and run the Run No Evil suite.
"$task_ciq_sdk/bin/monkeyc" -d instinct2 -f monkey.jungle \
  -o bin/PauseGuardianTests.prg -y /ABS/PATH/developer_key.der -w -t -l 1
"$task_ciq_sdk/bin/monkeydo" bin/PauseGuardianTests.prg instinct2 -t

# Build the signed USB-sideload artifact.
"$task_ciq_sdk/bin/monkeyc" -d instinct2 -f monkey.jungle \
  -o bin/PauseGuardian.prg -y /ABS/PATH/developer_key.der -w -r -O 2z -l 1

# Export the signed multi-variant package.
"$task_ciq_sdk/bin/monkeyc" -f monkey.jungle \
  -o bin/PauseGuardian.iq -y /ABS/PATH/developer_key.der -w -r -e -O 2z -l 1
```

Generated binaries and developer keys are intentionally excluded from Git.

## Device support

This draft targets the `instinct2` Connect IQ product, which covers the base Instinct 2 hardware variants represented by Garmin's device package. Instinct 2S, Instinct 2X, and other Garmin families are not declared in the manifest yet.

Supporting more watches is possible, but each family must be compiled, checked for screen and memory limits, and physically tested during a manual pause. Adding a product ID alone would overstate compatibility.

## Documentation

- [User guide](docs/USER_GUIDE.md): build, install, configure, use, and troubleshoot the field
- [Gate 1 physical test](GATE1_TEST.md): the acceptance checklist for a real Instinct 2
- [Architecture](docs/ARCHITECTURE.md): data flow, components, state handling, and safety boundaries
- [Verification record](VERIFICATION.md): automated and physical evidence collected so far
- [Contributing](CONTRIBUTING.md): development setup, test commands, and device-support requirements
- [Releasing](RELEASING.md): versioning, signing, GitHub Releases, and the Connect IQ Store rollout
- [Changelog](CHANGELOG.md): what changed in each version

## Roadmap

1. Complete Gate 1 on a physical Instinct 2.
2. Build the conservative movement detector and reminder cooldown.
3. Validate false positives across real stops, GPS conditions, and Auto Pause.
4. Add cycling after running behavior is reliable.
5. Expand to Garmin devices that pass build, layout, memory, simulator, and physical-pause checks.
6. Prepare a Connect IQ Store release with user settings and a non-technical setup flow.

## Privacy and safety

Pause Guardian works locally on the watch. This build has no account, network service, analytics, advertising, or phone companion. It reads activity state and position only to calculate on-watch diagnostic evidence. It never resumes or modifies the user's activity. See the full [privacy policy](PRIVACY.md).

## License

Pause Guardian is released under the [MIT License](LICENSE).
