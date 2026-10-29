# Privacy policy

Last updated: 2026-10-28

Pause Guardian is a Garmin Connect IQ data field. This policy covers every build published from this repository, including Connect IQ Store releases.

## What the app reads

While a Garmin activity is open and the Pause Guardian field is on a data screen, the app reads on the watch:

- activity timer state (running, manually stopped, Auto Paused)
- current speed, position, and GPS accuracy, through Garmin's `Positioning` permission
- the activity profile (for example, Run)
- the app's own memory use

These values are used only to calculate the field's result on the watch.

## What the app stores

The app keeps one small summary of the last activity session in the watch's Connect IQ app storage: diagnostic flags, timer-event flags, callback counts, the longest callback gap, and peak memory use. It does not store positions, routes, speeds, or timestamps of where you were.

Uninstalling the app removes this storage.

## What the app sends

Nothing. Pause Guardian has no network access, phone companion, account, analytics, advertising, or third-party SDK. No data leaves the watch through this app.

Garmin's own handling of your activity data is covered by Garmin's privacy policy, not this one.

## Changes

Changes to this policy are recorded in this file's Git history. A release that changes what the app reads, stores, or sends will update this policy first.

## Contact

Open an issue at https://github.com/PawanPatil19/pause-guardian/issues.
