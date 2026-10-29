#!/usr/bin/env bash
# Installs the Connect IQ SDK and the device files listed in manifest.xml.
# Needs GARMIN_USERNAME, GARMIN_PASSWORD and CIQ_AGREEMENT_HASH in the environment.
# Writes skip=true to $GITHUB_OUTPUT when they are missing on a pull request.
set -euo pipefail

sdk_version="${CIQ_SDK_VERSION:-9.2.0}"
# connect-iq-sdk-manager-cli v0.8.4, pinned by commit because it receives the Garmin password.
manager_ref="ed5d91fbacc05ad561aa448640a539a73b6c6ace"

missing=""
for name in GARMIN_USERNAME GARMIN_PASSWORD CIQ_AGREEMENT_HASH; do
  if [ -z "${!name:-}" ]; then missing="$missing $name"; fi
done
if [ -n "$missing" ]; then
  if [ "${GITHUB_EVENT_NAME:-}" = "pull_request" ]; then
    echo "::warning::SDK build and tests skipped: missing repository secrets:$missing. See CONTRIBUTING.md > Continuous integration."
    echo "skip=true" >> "${GITHUB_OUTPUT:-/dev/null}"
    exit 0
  fi
  echo "::error::Missing repository secrets:$missing. See CONTRIBUTING.md > Continuous integration."
  exit 1
fi

go install "github.com/lindell/connect-iq-sdk-manager-cli@${manager_ref}"
manager="$(go env GOPATH)/bin/connect-iq-sdk-manager-cli"

"$manager" agreement accept --agreement-hash="$CIQ_AGREEMENT_HASH"
"$manager" login
"$manager" sdk set "$sdk_version"
"$manager" device download --manifest=manifest.xml --include-fonts

sdk_bin="$("$manager" sdk current-path --bin)"
echo "$sdk_bin" >> "$GITHUB_PATH"
echo "skip=false" >> "${GITHUB_OUTPUT:-/dev/null}"
echo "Connect IQ SDK $sdk_version ready at $sdk_bin"
