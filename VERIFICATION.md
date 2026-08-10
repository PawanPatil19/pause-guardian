# Verification record

Verified on 2026-08-10 with Garmin Connect IQ SDK/compiler 9.2.0 and target `instinct2`.

## Automated

- Exact-target test build: successful, no warnings.
- Run No Evil: 15 passed, 0 failed, 0 errors.
- Normal data-field simulator launch: successful; no app exception.
- Exact-target release build: successful, no warnings.
- Package export: successful, 2 of 2 Instinct 2 hardware variants built.

Covered behaviors include one-shot probe timing, timer rollover/discontinuity, authoritative STOPPED/PAUSED distinction, callback continuity and revocation, null and cached telemetry, exact six-second/six-metre windows, geodesic scaling, memory threshold semantics, persistence semantics, and five-minute callback continuity.

## Physical watch

- Signed PRG copied to a connected Garmin Instinct 2 successfully.
- The watch loaded the app after a clean USB eject.
- `Pause Guardian G1` appeared in the Connect IQ category for an individual Run data-field slot.
- The data field rendered successfully in the native Run activity.

These checks establish installation and basic runtime compatibility. They do not establish the manual-pause behaviors in the Gate 1 checklist.

## Signed artifacts

```text
a42215bc5a705a42eaa571d2e32fdd4ba9be1fab26c7d98fd63d99e6f2e70a96  bin/PauseGuardian.prg
918f3cd4f77703268ee0a4521db6e5129f71044318dd90c1a874c523b5b8fb6e  bin/PauseGuardian.iq
```

The `.prg` is the USB-sideload artifact. The `.iq` is the signed multi-variant package.

## Not yet verified

The physical installation is verified, but the full manual-pause test is not complete. Only a physical Instinct 2 can establish that callbacks, fresh GPS values, and a physically felt vibration remain available behind Garmin's native manual-pause screen. Complete [GATE1_TEST.md](GATE1_TEST.md); do not describe this build as a functioning forgotten-resume reminder until that gate passes.
