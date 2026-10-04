#!/bin/sh
# Removes the service and turns Steam's CEF remote debugging back off.
systemctl --user disable --now steam-overlay-access.service 2>/dev/null
rm -f "${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user/steam-overlay-access.service"
systemctl --user daemon-reload
rm -f "$HOME/.steam/steam/.cef-enable-remote-debugging" "$HOME/.local/share/Steam/.cef-enable-remote-debugging"
echo "Removed. Restart Steam to close its debugging port."
