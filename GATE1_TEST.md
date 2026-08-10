# Pause Guardian movement-reminder field test

This test validates the first real reminder behavior inside Garmin's native Run activity. Simulator results cannot substitute for it.

Before starting, install and configure the field using the [user guide](docs/USER_GUIDE.md). Seeing `Oxx` on the watch confirms that the field loaded, not that the reminder behavior passed.

## What counts as a pass

The field test passes only when all automatic observations below are present and the manual facts are confirmed on a physical Instinct 2. `O7F` alone is not enough because Connect IQ cannot report whether the reminder was felt or replace the external memory profiler.

## Setup record

```text
watch retail variant:
firmware:
SDK / compiler: 9.2.0
build: test-0.2.0
Auto Pause setting:
DND / vibration setting:
battery mode:
test location and time:
```

## Required checks

- [ ] Start the native outdoor Run profile, acquire GPS, and confirm Pause Guardian shows `Oxx`.
- [ ] Manually stop for 20 seconds. Confirm `01`, meaning at least 18 callbacks and no gap over two seconds.
- [ ] While manually stopped, move continuously for at least 10 seconds. Confirm `02`, meaning fresh speed/location, speed at least 1.4 m/s, six seconds, and at least six metres.
- [ ] Trigger Auto Pause. Confirm `04`, meaning authoritative `Activity.Info.timerState` reported both `PAUSED` and manual `STOPPED`. Confirm Auto Pause does not trigger the reminder.
- [ ] Manually stop with Garmin's pause/save screen visible and remain stationary for ten seconds. Confirm there is no vibration.
- [ ] While still manually stopped, run continuously for at least ten seconds. Confirm one three-pulse reminder is physically felt after qualifying movement; `08` only proves the call was attempted.
- [ ] Keep moving for another 20 seconds. Confirm there is no second reminder during the same pause episode.
- [ ] Resume, manually stop again, and repeat the movement test. Confirm the reminder re-arms for the new pause episode.
- [ ] Stay manually stopped with the display allowed to sleep for five minutes. Confirm callback continuity (`10`) and movement data recovery within two seconds afterward.
- [ ] Resume, end the activity, and start another. Confirm the field-test session resets and the prior `Lxx` summary appears.
- [ ] Confirm sampled memory remains at or below 24 KiB (`20`) and review the SDK profiler separately.
- [ ] Confirm checkpoint storage reads back after relaunch (`40`).
- [ ] Leave the watch stationary for 60 seconds: no movement observation and no vibration.
- [ ] Add the field to a non-running profile: movement observation remains clear.

## Result

```text
final O-mask:
01 callback threshold observed (yes/no):
02 movement tuple threshold observed (yes/no):
04 authoritative states observed (yes/no):
vibration attempted:
vibration physically felt:
five-minute recovery latency (timed manually):
20 sampled memory threshold observed (yes/no):
external profiler maximum:
persisted L-mask:
notes:
```

The field test is accepted only when the required automatic observations and physical facts pass. If callbacks, fresh telemetry, state distinction, or haptics fail behind Garmin's pause screen, stop this architecture rather than weakening the reminder detector.

## How to report a failure

Keep the final `Oxx` and `Lxx` values, note which checklist item failed, and record whether the field was visible or Garmin's pause screen was visible. A failure behind the native pause screen is useful platform evidence; it should not be hidden by loosening detector thresholds.
