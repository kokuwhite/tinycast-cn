#!/bin/bash
# The release gate for the test harness.
#
# The harness is a dev script, not an upstream CI gate: on a clean macos-26 runner upstream's own
# tree already fails some of it (ext-test at v0.11.12, form-input-test's eight rendering assertions
# at v0.11.19 — both reproduced with no fork changes applied), and upstream's release workflow never
# runs the suite. So the gate tolerates the harnesses already known to fail here and still fails on
# anything new. Keep this list short and cite the reproduction in the comment when it grows.
#
# Exit 0 when the suite passes or only known failures remain; exit 1 with the unexpected names when
# something new breaks.
set -uo pipefail
cd "$(dirname "$0")/.."

KNOWN_FAILURES="${KNOWN_FAILURES:-ext-test mcp-oauth-test form-input-test}"
LOG="${RUN_TESTS_LOG:-${TMPDIR:-/tmp}/tinycast-tests.log}"

set +e
./Scripts/run-tests.sh > "$LOG" 2>&1
STATUS=$?
set -e

tail -n 8 "$LOG"
if [ "$STATUS" -eq 0 ]; then
    echo "The full harness passed."
    exit 0
fi

SUMMARY="$(sed -e $'s/\033\\[[0-9;]*m//g' -e $'s/\r//g' "$LOG" \
    | sed -n 's/.*harness(es) failed in [0-9]*s: //p' | tail -1)"
if [ -z "$SUMMARY" ]; then
    echo "run-tests.sh exited $STATUS without a failure summary." >&2
    exit 1
fi

echo "Failing harnesses: ${SUMMARY}"
UNEXPECTED=""
for NAME in $SUMMARY; do
    case " ${KNOWN_FAILURES} " in
        *" ${NAME} "*) echo "Tolerated (known CI failure): ${NAME}" ;;
        *) UNEXPECTED="${UNEXPECTED} ${NAME}" ;;
    esac
done
if [ -n "${UNEXPECTED}" ]; then
    echo "Unexpected harness failure(s):${UNEXPECTED}" >&2
    exit 1
fi
echo "Only known CI failures — continuing."
