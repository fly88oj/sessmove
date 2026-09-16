#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-or-later
# Build a .dmg installer image for macOS (run on macOS).
# Usage: packaging/build-dmg.sh [target-triple]   (default: host triple)
set -euo pipefail

TRIPLE="${1:-$(rustc -vV | sed -n 's/^host: //p')}"
VERSION="$(sed -n 's/^version = "\(.*\)"/\1/p' Cargo.toml | head -1)"
STAGE="target/${TRIPLE}/release/dmg-stage"
OUT="target/${TRIPLE}/release/sessmove-${VERSION}-${TRIPLE}.dmg"
VOLNAME="sessmove-${VERSION}"

command -v hdiutil >/dev/null || { echo "hdiutil not found (macOS only)"; exit 1; }

rm -rf "${STAGE}"
mkdir -p "${STAGE}/bin" "${STAGE}/share/doc/sessmove"
cp "target/${TRIPLE}/release/sessmove" "${STAGE}/bin/"
cp "target/${TRIPLE}/release/agentpath" "${STAGE}/bin/"
cp README.md LICENSE "${STAGE}/share/doc/sessmove/"
cat > "${STAGE}/INSTALL.txt" <<EOF
sessmove ${VERSION} (${TRIPLE})

Install by copying the binaries to a directory on your PATH, e.g.:

  cp bin/sessmove bin/agentpath /usr/local/bin/

See share/doc/sessmove/README.md for usage.
EOF

rm -f "${OUT}"
hdiutil create -volname "${VOLNAME}" -srcfolder "${STAGE}" -ov -format UDZO "${OUT}"
echo "built ${OUT}"
