#!/usr/bin/env bash

# Virtual audio sink for headless CI so soundd (sounddevice/PortAudio) can open
# an output stream. Sourced under `bash -e`; pulseaudio refuses to run as root,
# so start it as the current (non-root) user and guard every command with
# `|| true` so a missing/uncooperative pulseaudio never aborts the step before
# pytest runs.

pulseaudio --check 2>/dev/null || pulseaudio --start --exit-idle-time=-1 2>/dev/null || true
pactl load-module module-null-sink sink_name=virtual_audio >/dev/null 2>&1 || true
pactl set-default-sink virtual_audio >/dev/null 2>&1 || true
