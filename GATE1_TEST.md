# Pause Guardian — Physical Gate 1

This test decides whether Garmin's native Run data-field architecture is viable. Simulator results cannot substitute for it.

## Setup record

```text
watch retail variant:
firmware:
SDK / compiler: 9.2.0
build: g1-0.1.0
Auto Pause setting:
DND / vibration setting:
battery mode:
test location and time:
```

## Required checks

- [ ] Start the native outdoor Run profile with Pause Guardian visible.
- [ ] Manually stop for 20 seconds. Confirm `01`, meaning at least 18 callbacks and no gap over two seconds.
- [ ] While manually stopped, move continuously for at least 10 seconds. Confirm `02`, meaning fresh speed/location, speed at least 1.4 m/s, six seconds, and at least six metres.
- [ ] Trigger Auto Pause. Confirm `04`, meaning authoritative `Activity.Info.timerState` reported both `PAUSED` and manual `STOPPED`. Confirm Auto Pause does not trigger the five-second probe.
- [ ] Manually stop with Garmin's pause/save screen visible. Confirm the three-pulse pattern is physically felt near five seconds; `08` only proves the call was attempted.
- [ ] Stay manually stopped with the display allowed to sleep for five minutes. Confirm callback continuity (`10`) and movement data recovery within two seconds afterward.
- [ ] Resume, end the activity, and start another. Confirm the diagnostic session resets and the prior `Lxx` summary appears.
- [ ] Confirm sampled memory remains at or below 24 KiB (`20`) and review the SDK profiler separately.
- [ ] Confirm checkpoint storage reads back after relaunch (`40`).
- [ ] Leave the watch stationary for 60 seconds: no movement observation and no vibration beyond the intentional five-second diagnostic probe.
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

Gate 1 is accepted only when the required automatic observations and physical facts pass. If callbacks, fresh telemetry, state distinction, or haptics fail behind Garmin's pause screen, stop this architecture rather than tuning the reminder detector.
