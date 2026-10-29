#!/usr/bin/env bash
# Builds the test PRG and runs the Run No Evil suite in the simulator.
# Expects monkeyc, monkeydo and connectiq on PATH and a display (use xvfb-run).
set -euo pipefail

key="${1:?usage: ci-run-tests.sh <developer_key.der>}"
device="${CIQ_DEVICE:-instinct2}"
# Raise this when tests are added, so a build that silently drops test files cannot pass.
min_tests="${CIQ_MIN_TESTS:-15}"
output="bin/test-output.txt"

monkeyc -d "$device" -f monkey.jungle -o bin/PauseGuardianTests.prg -y "$key" -w -t -l 1

connectiq &
sim_pid=$!
trap 'kill "$sim_pid" 2>/dev/null || true' EXIT

# The simulator takes a variable time to start on a cold runner, so retry until
# monkeydo reaches it and prints a Run No Evil summary.
for attempt in 1 2 3 4 5 6; do
  sleep 5
  monkeydo bin/PauseGuardianTests.prg "$device" -t > "$output" 2>&1 || true
  if grep -Eq '^(PASSED|FAILED) \(' "$output"; then
    break
  fi
  echo "Simulator not ready (attempt $attempt); retrying."
done
cat "$output"

# Run No Evil ends with "PASSED (passed=N, failed=0, errors=0)" when every test passes.
summary="$(grep -Eo '^PASSED \(passed=[0-9]+, failed=0, errors=0\)' "$output" || true)"
if [ -z "$summary" ]; then
  echo "::error::Run No Evil tests did not all pass."
  exit 1
fi
passed="$(echo "$summary" | sed -E 's/.*passed=([0-9]+).*/\1/')"
if [ "$passed" -lt "$min_tests" ]; then
  echo "::error::Only $passed tests ran; expected at least $min_tests."
  exit 1
fi
echo "$passed tests passed."
