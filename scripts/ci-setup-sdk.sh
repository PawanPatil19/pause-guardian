#!/usr/bin/env bash
# Installs the Connect IQ SDK and the device files listed in manifest.xml.
# Needs GARMIN_USERNAME, GARMIN_PASSWORD and CIQ_AGREEMENT_HASH in the environment.
set -euo pipefail

sdk_version="${CIQ_SDK_VERSION:-9.2.0}"

missing=""
for name in GARMIN_USERNAME GARMIN_PASSWORD CIQ_AGREEMENT_HASH; do
  if [ -z "${!name:-}" ]; then missing="$missing $name"; fi
done
if [ -n "$missing" ]; then
  echo "::error::Missing repository secrets:$missing. See CONTRIBUTING.md > Continuous integration."
  exit 1
fi

go install github.com/lindell/connect-iq-sdk-manager-cli@latest
manager="$(go env GOPATH)/bin/connect-iq-sdk-manager-cli"

"$manager" agreement accept --acceptance-hash="$CIQ_AGREEMENT_HASH"
"$manager" login
"$manager" sdk set "$sdk_version"
"$manager" device download --manifest=manifest.xml --include-fonts

sdk_bin="$("$manager" sdk current-path --bin)"
echo "$sdk_bin" >> "$GITHUB_PATH"
echo "Connect IQ SDK $sdk_version ready at $sdk_bin"
