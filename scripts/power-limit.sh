#!/usr/bin/env bash
# Cap each NVIDIA GPU at 280W (vs the RTX 3090's stock 350W TGP).
# Costs ~4% inference t/s, saves ~20% power, drops die temps 10–15 °C.
# Run with sudo. Override the limit by passing watts: ./power-limit.sh 300
set -e
nvidia-smi -pm 1                 # persistence mode (limit survives sessions)
nvidia-smi -pl "${1:-280}"       # apply power limit
nvidia-smi --query-gpu=index,name,power.limit,power.draw,temperature.gpu --format=csv
