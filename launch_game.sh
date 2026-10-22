#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

echo "=================================================="
echo "    Launching LUCKBOUND: The Seven Gates (Godot) "
echo "=================================================="

if command -v godot >/dev/null 2>&1; then
    exec godot scenes/main_menu.tscn
elif [ -f /home/joel/.local/bin/godot ]; then
    exec /home/joel/.local/bin/godot scenes/main_menu.tscn
else
    echo "Godot not found in PATH or ~/.local/bin/godot."
    echo "Opening web edition in Firefox..."
    exec firefox "$DIR/web/index.html"
fi
