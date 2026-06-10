#!/usr/bin/env bash

# Make soundd runnable on headless CI. Two requirements:
#  1. libportaudio2: sounddevice ships no PortAudio on Linux and dlopens the
#     system lib; op.sh setup doesn't install it, so soundd dies on import.
#  2. a default ALSA device: the runner has no sound card, so point ALSA's
#     default at its built-in "null" PCM (discards output, no hardware/daemon).
#     The system PortAudio is built with the ALSA backend (not PulseAudio).
# Sourced under `bash -e`: guard everything so audio setup never kills the step.

sudo apt-get install -y --no-install-recommends libportaudio2 2>/dev/null || true

cat > "$HOME/.asoundrc" <<'EOF'
pcm.!default { type null }
ctl.!default { type null }
EOF

# Prove the whole soundd audio path works before pytest runs, so failures show
# the real exception here instead of an opaque processNotRunning in the test.
python3 - <<'EOF' || true
import traceback
try:
  import sounddevice as sd
  print(f"vsound: portaudio {sd.get_portaudio_version()[1]}")
  s = sd.OutputStream(channels=1, samplerate=48000, blocksize=4096)
  s.start()
  print(f"vsound: OutputStream OK, active={s.active}, device={s.device}")
  s.stop(); s.close()
except Exception:
  print("vsound: sounddevice FAILED:")
  traceback.print_exc()
EOF
