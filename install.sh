#!/bin/sh
# Enables Steam's CEF remote debugging and installs the daemon as a systemd
# user service. Run again after moving this directory.
set -e
DIR=$(cd "$(dirname "$0")" && pwd)
STEAM=${STEAM_DIR:-$HOME/.steam/steam}
[ -d "$STEAM" ] || STEAM=$HOME/.local/share/Steam
if [ ! -d "$STEAM" ]; then
    echo "Steam directory not found; set STEAM_DIR and run again." >&2
    exit 1
fi

python3 -c 'import websockets' 2>/dev/null || {
    echo "Missing Python module 'websockets' (Debian/Ubuntu: sudo apt install python3-websockets)." >&2
    exit 1
}
python3 -c 'import speechd' 2>/dev/null || command -v spd-say >/dev/null ||
    echo "Warning: no speech-dispatcher found (sudo apt install python3-speechd speech-dispatcher)." >&2

touch "$STEAM/.cef-enable-remote-debugging"

UNIT_DIR=${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user
mkdir -p "$UNIT_DIR"
cat > "$UNIT_DIR/steam-overlay-access.service" <<UNIT
[Unit]
Description=Steam Overlay Access (screen reader support for the Steam overlay)

[Service]
ExecStart=/usr/bin/env python3 "$DIR/soa_daemon.py"
Restart=on-failure
RestartSec=5

[Install]
WantedBy=default.target
UNIT
systemctl --user daemon-reload
systemctl --user enable --now steam-overlay-access.service
systemctl --user restart steam-overlay-access.service

echo "Installed. Restart Steam once so that it opens its debugging port."
