# Verification record

Verified on 2026-08-10 with Garmin Connect IQ SDK/compiler 9.2.0 and target `instinct2`.

## Automated

- Exact-target test build: successful, no warnings.
- Run No Evil: 17 passed, 0 failed, 0 errors.
- Normal data-field simulator launch: successful; no app exception.
- Exact-target release build: successful, no warnings.
- Package export: successful, 2 of 2 Instinct 2 hardware variants built.

Covered behaviors include authoritative STOPPED/PAUSED distinction, callback continuity and revocation, null and cached telemetry, exact six-second/six-metre windows, movement-triggered reminder requests, one reminder per pause, re-arming only after resume, missing-state-sample handling, Auto Pause exclusion, geodesic scaling, memory threshold semantics, persistence semantics, and five-minute callback continuity.

## Physical watch

- Signed PRG copied to a connected Garmin Instinct 2 successfully.
- The watch loaded the app after a clean USB eject.
- The previous `Pause Guardian G1` diagnostic appeared in the Connect IQ category for an individual Run data-field slot.
- The data field rendered successfully in the native Run activity.

These checks establish installation and basic runtime compatibility. They do not establish the new movement-reminder behavior in the field-test checklist.

## Signed artifacts

```text
973af787197a587999fb3b74086cce7f79f8bd0f50a36f775c7df861daa2a889  bin/PauseGuardian.prg
f806e6cd8d978163025c8f30135610d96d7b19885b2e8633c37c9a16987f2f13  bin/PauseGuardian.iq
```

The `.prg` is the USB-sideload artifact. The `.iq` is the signed multi-variant package.

## Not yet verified

The previous diagnostic installation is verified, but the new `test-0.2.0` movement-reminder build has not yet been installed or field-tested. Only a physical Instinct 2 can establish that callbacks, fresh GPS values, and a physically felt reminder remain available behind Garmin's native manual-pause screen. Complete [GATE1_TEST.md](GATE1_TEST.md) before describing the behavior as validated.
