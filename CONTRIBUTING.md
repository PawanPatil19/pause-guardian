# Contributing

Pause Guardian is in platform-feasibility testing. Contributions should preserve the distinction between evidence collected in the simulator and behavior confirmed on a physical Garmin watch.

## Development setup

1. Install [Garmin Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/).
2. Install and activate Connect IQ SDK 9.2.0.
3. Download the `instinct2` device package.
4. Create a Connect IQ developer signing key and keep it outside the repository.
5. Clone the repository and run the tests below.

The project has no vendored SDK, device definitions, signing key, or generated binary.

## Build commands

Set the SDK and key paths for your machine:

```sh
task_ciq_sdk="$(cat "${HOME}/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
task_developer_key="/ABS/PATH/developer_key.der"
```

Compile and run tests:

```sh
"$task_ciq_sdk/bin/monkeyc" -d instinct2 -f monkey.jungle \
  -o bin/PauseGuardianTests.prg -y "$task_developer_key" -w -t -l 1

# Start the Connect IQ simulator before monkeydo if it is not already running.
"$task_ciq_sdk/bin/connectiq"
"$task_ciq_sdk/bin/monkeydo" bin/PauseGuardianTests.prg instinct2 -t
```

Build a release PRG and package:

```sh
"$task_ciq_sdk/bin/monkeyc" -d instinct2 -f monkey.jungle \
  -o bin/PauseGuardian.prg -y "$task_developer_key" -w -r -O 2z -l 1

"$task_ciq_sdk/bin/monkeyc" -f monkey.jungle \
  -o bin/PauseGuardian.iq -y "$task_developer_key" -w -r -e -O 2z -l 1
```

## Before opening a change

- Exact-target compilation completes with warnings enabled.
- All Run No Evil tests pass on `instinct2`.
- The normal data field launches in the simulator without an app exception.
- Mask semantics and the physical checklist are updated when behavior changes.
- Generated files in `bin/` and all signing keys remain untracked.
- Claims in the README separate simulator results from physical-watch results.

## Adding detector behavior

Detector changes should include boundary tests for null telemetry, poor GPS, cached tuples, callback gaps, timer rollover, Auto Pause, movement duration, distance, and one-shot vibration behavior. Favor false-negative evidence during Gate 1: a platform capability should not pass because stale or ambiguous data was accepted.

## Adding a Garmin device

Do not add a product ID and call the device supported. For each device family:

1. Add the official product ID to `manifest.xml`.
2. Compile with the exact device definition and minimum supported API.
3. Run all automated tests and launch the normal field in its simulator.
4. Check every supported native field layout for clipping and readability.
5. Check code and data memory against that device's limits.
6. Sideload to physical hardware and complete the manual-pause checklist.
7. Record the evidence in `VERIFICATION.md` before updating the compatibility claim.

## Reporting physical results

Copy the result form from [GATE1_TEST.md](GATE1_TEST.md). Include watch variant, firmware, vibration settings, Auto Pause setting, battery mode, and any difference between Garmin's pause screen and the custom data page.

## License note

This repository does not yet include an open-source license. Discuss licensing with the maintainer before contributing code intended for redistribution.
