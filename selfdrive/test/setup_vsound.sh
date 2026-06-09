#!/usr/bin/env bash

# Provide an audio device for soundd (sounddevice/PortAudio) on headless CI.
# Sourced under `bash -e`, so guard every command with `|| true` — audio setup
# must never abort the step before pytest runs.

# Preferred: a dummy ALSA sound card. PortAudio opens this as the default device
# with no daemon required.
sudo modprobe snd-dummy 2>/dev/null || true

# Fallback: a PulseAudio null sink. pulseaudio refuses to run as root, so start
# it as the current (non-root) user.
if command -v pulseaudio >/dev/null 2>&1; then
  pulseaudio --check 2>/dev/null || pulseaudio --start --exit-idle-time=-1 2>/dev/null || true
  pactl load-module module-null-sink sink_name=virtual_audio >/dev/null 2>&1 || true
  pactl set-default-sink virtual_audio >/dev/null 2>&1 || true
fi

# Diagnostics (don't fail the step) so audio problems are visible in CI logs.
echo "vsound: ALSA cards:"; cat /proc/asound/cards 2>/dev/null || echo "  (none)"
echo "vsound: PulseAudio sinks:"; pactl list short sinks 2>/dev/null || echo "  (no pulseaudio)"
