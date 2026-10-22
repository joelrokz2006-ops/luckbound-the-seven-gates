#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
cd "$DIR"

echo "=================================================="
echo "    Running LUCKBOUND Automated Test Suite        "
echo "=================================================="

godot --headless --script tests_or_debug/rng_test_runner.gd
godot --headless --script tests_or_debug/run_simulation.gd
