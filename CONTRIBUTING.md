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

## Continuous integration

`.github/workflows/ci.yml` runs on every pull request and on pushes to `main`:

- **Repository checks**: manifest and resource XML are well-formed, and no keys or build output are tracked.
- **Build and test**: installs the Connect IQ SDK and `instinct2` device files on Linux, makes a release build and package with a throwaway key generated for that run, then runs the Run No Evil suite in the simulator under Xvfb.

Garmin requires a signed-in account to download SDKs and device files, so the build job needs three repository secrets (Settings → Secrets and variables → Actions):

| Secret | Value |
| --- | --- |
| `GARMIN_USERNAME` | Garmin developer account email |
| `GARMIN_PASSWORD` | Garmin developer account password |
| `CIQ_AGREEMENT_HASH` | Run `connect-iq-sdk-manager-cli agreement view` locally once, read the SDK license agreement, and copy the acceptance hash it prints |

Without them, pull requests skip the build job with a warning naming the missing secrets, and pushes to `main` fail. CI never uses the real store signing key.

The test step fails unless at least `CIQ_MIN_TESTS` tests pass (21 by default, set in `scripts/ci-run-tests.sh`). Raise it when you add tests.

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

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
