# Pause Guardian user guide

This guide installs and configures the movement-reminder field test on a Garmin Instinct 2. The current build is for outdoor testing and is not available in the Connect IQ Store.

## What you need

- A Garmin Instinct 2 supported by the `instinct2` Connect IQ device package
- A Mac with Garmin Connect IQ SDK 9.2.0 installed
- The Instinct 2 device package downloaded in SDK Manager
- A Connect IQ developer signing key
- A USB data cable

## 1. Build the watch file

From the repository root:

```sh
task_ciq_sdk="$(cat "${HOME}/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"

"$task_ciq_sdk/bin/monkeyc" -d instinct2 -f monkey.jungle \
  -o bin/PauseGuardian.prg -y /ABS/PATH/developer_key.der -w -r -O 2z -l 1
```

A successful build creates `bin/PauseGuardian.prg`. Keep the developer key private and outside the repository.

## 2. Copy it to the watch

1. Connect the Instinct 2 to the Mac with a USB data cable.
2. Wait for the Garmin storage volume to appear.
3. Open the watch volume and then its `GARMIN/APPS` folder.
4. Copy `bin/PauseGuardian.prg` into that folder.
5. Eject the Garmin volume cleanly before disconnecting the cable.
6. Let the watch return to its normal watch face.

Do not copy the `.iq` package to `GARMIN/APPS`. USB sideloading uses the `.prg` file.

## 3. Add the field to Run

On the Instinct 2:

1. Hold **MENU**.
2. Open **Activities & Apps**.
3. Select **Run**.
4. Open **Run Settings**.
5. Open **Data Screens**.
6. Select an existing screen or add a new one.
7. Edit the data fields and select one individual field slot.
8. Select **Connect IQ**.
9. Select **Pause Guardian Test**.

The important detail is step 7. **Connect IQ may not appear until an individual field slot is selected.**

## 4. Confirm the installation

1. Start an outdoor Run.
2. Move to the data screen containing Pause Guardian.
3. Confirm the field shows a three-character value such as `O20`, `O60`, or another `Oxx` combination.

The exact value depends on which observations have already been collected. Seeing `Oxx` confirms that the field is loaded; it does not mean the physical feasibility test has passed.

## 5. Test the reminder

Use the full [movement-reminder checklist](../GATE1_TEST.md). In summary:

1. Acquire GPS and start an outdoor Run.
2. Manually stop the activity and leave Garmin's native pause screen visible.
3. Remain stationary for at least ten seconds and confirm there is no reminder.
4. While still manually stopped, run continuously for at least ten seconds.
5. Confirm one three-pulse reminder after the watch observes at least six seconds and six metres of qualifying movement.
6. Keep moving and confirm it does not remind a second time during the same pause.
7. Resume, manually pause again, and confirm the reminder can trigger in the new pause episode.
8. Inspect the observation mask afterward.
9. Test Auto Pause separately and confirm it never triggers the reminder.
10. Complete the five-minute stopped/sleep test.

The field can be on another data page while Garmin's native pause screen is visible. The test is specifically checking whether Garmin keeps the data field alive in that situation.

## Understand `Oxx` and `Lxx`

- `O` means observations from the current session.
- `L` means the last stored session and appears briefly after launch or reset.
- The final two characters are a hexadecimal combination of evidence bits.

| Bit | Meaning |
| --- | --- |
| `01` | Stopped callbacks continued at the required rate |
| `02` | Fresh qualifying movement was observed while manually stopped |
| `04` | Manual Stop and Auto Pause were distinguished |
| `08` | A movement-triggered reminder vibration was attempted |
| `10` | Callback continuity lasted five minutes |
| `20` | Sampled memory stayed within the diagnostic threshold |
| `40` | A checkpoint was stored |

Examples:

- `O00`: no observation bits collected yet
- `O09`: `01` and `08` are set
- `O7F`: all automatic bits are set, but manual vibration and profiler checks are still required
- `L49`: the previous session stored `01`, `08`, and `40`

## Troubleshooting

### Connect IQ does not appear in Data Screens

Select an individual data-field slot first. Connect IQ is a field category inside the slot picker, not a top-level Data Screens option.

### Pause Guardian Test does not appear

- Confirm that `PauseGuardian.prg` was copied to `GARMIN/APPS`.
- Confirm that the watch volume was ejected cleanly.
- Disconnect the cable and allow the watch to finish loading apps.
- Restart the watch once, then check the individual field-slot picker again.
- Rebuild specifically with `-d instinct2`; a binary built for another Garmin product will not load.

### The watch shows `Lxx`

This is expected for ten seconds after launch or reset. It is the previous stored result and will change to the current `Oxx` value.

### There is no vibration

- Confirm system vibration is enabled and Do Not Disturb is off.
- Confirm the activity was manually stopped, not Auto Paused.
- Acquire a good outdoor GPS fix before starting.
- Run continuously for at least ten seconds while the timer remains manually stopped.
- Record the failure in the field-test checklist. A missing vibration behind the pause screen may be a platform limitation, not a detector bug.

### `02` never appears

Use an outdoor Run with a good GPS fix. While manually stopped, move continuously for at least ten seconds at running speed. The detector intentionally rejects missing, low-quality, repeated, slow, or interrupted samples.

## Uninstall

Connect the watch by USB and remove the Pause Guardian PRG from `GARMIN/APPS`, then eject the watch cleanly. Garmin may shorten the installed filename, for example to `PAUSEGRD.PRG`; identify the matching app entry carefully before removing it.
