# Pause Guardian — Gate 1

An instrumented Garmin Connect IQ data field for validating whether an Instinct 2 can observe fresh activity data and deliver haptics while a native Run activity is manually stopped.

Pause Guardian is an independent experimental project and is not affiliated with or endorsed by Garmin.

This first draft is intentionally diagnostic-only. It never resumes an activity and does not yet issue movement-based reminders.

It targets the base Instinct 2 product family (including Solar, Dual Power, and dēzl variants) at Connect IQ 3.2 or newer. Instinct 2S and 2X are not included in this draft.

## What the field shows

- `Oxx`: live automatic observation mask.
- `Lxx`: the previous persisted mask, shown for ten seconds after launch/reset.

Bits are cumulative evidence, not a self-certified pass:

- `01`: at least 18 stopped-state callbacks with no gap over two seconds.
- `02`: running profile, usable GPS, speed at least 1.4 m/s, six seconds, and six metres of displacement.
- `04`: authoritative `Activity.Info.timerState` reported both manual `STOPPED` and Auto Pause `PAUSED`. Timer-event callbacks are persisted separately and cannot earn this bit.
- `08`: the three-pulse vibration call was attempted without an exception.
- `10`: stopped-state callbacks remained continuous for five minutes.
- `20`: sampled app memory remained at or below 24 KiB.
- `40`: the latest diagnostic checkpoint was stored.

The watch cannot confirm that a vibration was physically felt, so even `O7F` still requires the physical checklist.

## Install on the watch

1. Connect the Instinct 2 to the Mac by USB.
2. Copy `bin/PauseGuardian.prg` into the watch's `GARMIN/APPS` directory.
3. Eject the watch cleanly.
4. On the watch, open Run settings and add **Pause Guardian G1** to a data-field slot.
5. Complete [GATE1_TEST.md](GATE1_TEST.md) before enabling reminder behavior.

## Build and test

The project uses Garmin Connect IQ SDK 9.2.0 and a private developer key outside this repository.

```sh
task_ciq_sdk="$(cat "${HOME}/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
"$task_ciq_sdk/bin/monkeyc" -d instinct2 -f monkey.jungle \
  -o bin/PauseGuardianTests.prg -y /ABS/PATH/developer_key.der -w -t -l 1
"$task_ciq_sdk/bin/monkeydo" bin/PauseGuardianTests.prg instinct2 -t
```
