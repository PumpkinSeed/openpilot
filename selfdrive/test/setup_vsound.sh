#!/usr/bin/env bash

# Give soundd a usable default audio device on headless CI. soundd uses
# python-sounddevice -> the system PortAudio, which here supports the ALSA and
# JACK backends but NOT PulseAudio, and CI runners have no sound card. So we
# point ALSA's default device at its built-in "null" PCM (discards output, needs
# no hardware or daemon). Sourced under `bash -e`: guard everything so audio
# setup can never abort the step before pytest runs.

cat > "$HOME/.asoundrc" <<'EOF'
pcm.!default { type null }
ctl.!default { type null }
EOF

# Bonus: load a real dummy ALSA card if the module happens to be available.
sudo modprobe snd-dummy 2>/dev/null || true

# Diagnostics (never fail the step) so audio problems stay visible in CI logs.
echo "vsound: ~/.asoundrc -> null default device"
echo "vsound: ALSA cards:"; cat /proc/asound/cards 2>/dev/null || echo "  (none)"
