# Releasing

## Version

The version lives in one place: `BUILD_ID` in `source/PauseGuardianSession.mc`. It follows semantic versioning (`MAJOR.MINOR.PATCH`, with `-g1` for Gate 1 diagnostic builds). The release tag is `v` plus that value, and `CHANGELOG.md` must have a section with the same version. The release workflow refuses a tag that does not match.

Connect IQ asks for the version again when you upload to the store. Enter the same value.

## Signing key

Every store version must be signed with the same developer key. Losing or replacing it means publishing a new app with a new store listing. `CIQ_SIGNING_KEY_B64` must hold the same key you use for the first store upload, for every release after it. GitHub secrets can't be read back, so keep the original key offline with at least one backup outside GitHub, and never commit it.

The release workflow reads it from the `CIQ_SIGNING_KEY_B64` repository secret:

```sh
base64 -i /ABS/PATH/developer_key.der | pbcopy   # macOS: copies the value to paste into the secret
```

It also needs the `GARMIN_USERNAME`, `GARMIN_PASSWORD`, and `CIQ_AGREEMENT_HASH` secrets described in `CONTRIBUTING.md`.

## Steps

The release workflow reuses `scripts/ci-setup-sdk.sh` and `scripts/ci-run-tests.sh` from the CI setup, so CI must be merged first.


1. Move the `Unreleased` entries in `CHANGELOG.md` into a version section headed `## [x.y.z] - YYYY-MM-DD` (for the first tag, date the `0.1.0-g1` heading and delete its "Not tagged yet" line).
2. Set `BUILD_ID` to the same version.
3. Open a pull request, wait for CI, and merge it.
4. Tag `main` and push the tag. For `v0.1.0-g1`, wait until the license, CI, versioning, and session-test PRs have all merged, since its changelog lists them:

   ```sh
   git tag v0.1.0-g1
   git push origin v0.1.0-g1
   ```

5. The **Release** workflow runs the test suite, then builds the signed `.prg` and `.iq`, records their SHA-256 checksums, and creates a GitHub Release. Tags with a pre-release suffix (such as `-g1` or `-beta.1`) are marked as pre-releases.
6. Record the checksums in `VERIFICATION.md`.

## Connect IQ Store rollout

Default plan: beta first, then public.

1. **Beta.** Upload the `.iq` from the GitHub Release as a beta app in the Connect IQ developer dashboard. Share it with testers and complete the physical checklist on each supported device.
2. **Public.** When beta testing finds no blocking issues, upload the same version as the public app with its store listing, screenshots, and the privacy policy.

Diagnostic `-g1` builds are not intended for the public store.
