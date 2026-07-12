#!/bin/bash

# Script to easily run the drone simulation with or without GPU support
# Usage: 
#   ./run.sh          (Builds and runs with CPU software rendering)
#   ./run.sh --gpu    (Builds and runs with NVIDIA GPU acceleration)

echo "=========================================="
echo "    Drone Simulation Docker Runner"
echo "=========================================="

# Base compose file
COMPOSE_ARGS="-f docker-compose.yml"

if [[ "$1" == "--gpu" ]]; then
    echo "[INFO] Configuring for NVIDIA GPU acceleration..."
    COMPOSE_ARGS="$COMPOSE_ARGS -f docker-compose.gpu.yml"
else
    echo "[INFO] Configuring for CPU (Software Rendering)..."
    echo "[TIP]  Use './run.sh --gpu' to enable GPU support."
    COMPOSE_ARGS="$COMPOSE_ARGS -f docker-compose.cpu.yml"
fi

echo "[INFO] Running: docker compose $COMPOSE_ARGS up --build"
echo "=========================================="

# Allow Docker container to connect to host's X11 server for GUI
echo "[INFO] Configuring X11 permissions for GUI..."
xhost +local:root >/dev/null 2>&1 || true

# Execute the docker compose command
docker compose $COMPOSE_ARGS up --build
