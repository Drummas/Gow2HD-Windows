#!/usr/bin/env bash
# The checks a release has to pass before anything is created, in one place: both the push precheck and the manual
# publish step of .github/workflows/release.yml call this script, so the wording and the order cannot drift apart.
#
#   release_check.sh <version|""> <push|manual>
#
# <version> is the version without or with a leading "v"; empty means LAUNCHER_VERSION from launcher/src/config.h
# (the manual run's default). <mode> only picks the wording of the "bump the version" line.
#
# On success the resolved version is printed on stdout; everything else, including ::error:: lines and the
# information lines, goes to stderr. Exit 1 at the first failed check.
set -uo pipefail

INPUT="${1-}"
MODE="${2:-manual}"
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
BUILT=$(sed -n 's/^#define LAUNCHER_VERSION *"\(.*\)"/\1/p' "$ROOT/launcher/src/config.h")
REPO="${GITHUB_REPOSITORY:-$(git -C "$ROOT" config --get remote.origin.url 2>/dev/null | sed -E 's#.*github\.com[:/]##; s#\.git$##')}"

VER="${INPUT#v}"
if [ -z "$VER" ]; then VER="$BUILT"; fi
if [ -z "$VER" ]; then
  if [ "$MODE" = push ]; then
    echo "::error::no version to release: LAUNCHER_VERSION is missing from launcher/src/config.h" >&2
  else
    echo "::error::no version to release: set the version input or LAUNCHER_VERSION in launcher/src/config.h" >&2
  fi
  exit 1
fi
if ! printf '%s' "$VER" | grep -Eq '^[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?$'; then
  echo "::error::'$VER' is not a version like 0.1.2" >&2
  exit 1
fi
if [ "$VER" != "$BUILT" ]; then
  if [ "$MODE" = push ]; then AGAIN="push again"; else AGAIN="run again"; fi
  {
    echo "::error::v$VER cannot be released from this commit: the exe reports $BUILT (LAUNCHER_VERSION in"
    echo "launcher/src/config.h). Bump that constant, commit it, and $AGAIN -- otherwise the tag, the"
    echo "update check and the exe would disagree."
  } >&2
  exit 1
fi
if gh release view "v$VER" >/dev/null 2>&1; then
  echo "::error::release v$VER already exists (https://github.com/$REPO/releases/tag/v$VER). Bump LAUNCHER_VERSION to the next version instead of publishing this one again." >&2
  exit 1
fi
if git ls-remote --exit-code --tags origin "refs/tags/v$VER" >/dev/null 2>&1; then
  echo "::error::tag v$VER already exists on origin without a release pointing at it; delete it or pick another version." >&2
  exit 1
fi
if [ "$MODE" = push ]; then echo "v$VER is not tagged and not released: the action may publish it" >&2; fi
echo "$VER"
