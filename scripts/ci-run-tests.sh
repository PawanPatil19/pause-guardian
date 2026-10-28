#!/usr/bin/env bash
# Builds the test PRG and runs the Run No Evil suite in the simulator.
# Expects monkeyc, monkeydo and connectiq on PATH and a display (use xvfb-run).
set -euo pipefail

key="${1:?usage: ci-run-tests.sh <developer_key.der>}"
device="${CIQ_DEVICE:-instinct2}"

monkeyc -d "$device" -f monkey.jungle -o bin/PauseGuardianTests.prg -y "$key" -w -t -l 1

connectiq &
sim_pid=$!
trap 'kill "$sim_pid" 2>/dev/null || true' EXIT
sleep 10

monkeydo bin/PauseGuardianTests.prg "$device" -t | tee bin/test-output.txt

# Run No Evil ends with "PASSED (passed=N, failed=0, errors=0)" when every test passes.
if ! grep -Eq '^PASSED \(passed=[0-9]+, failed=0, errors=0\)' bin/test-output.txt; then
  echo "::error::Run No Evil tests did not all pass."
  exit 1
fi
