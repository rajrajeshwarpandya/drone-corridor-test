#!/bin/bash
set -e

# ── Source ROS2 base ─────────────────────────────────────────
source /opt/ros/humble/setup.bash

# ── Rebuild workspace if source changed (live-edit support) ──
cd /root/ros2_ws
colcon build \
    --symlink-install \
    --packages-select drone_corridor_sim \
    --cmake-args -DCMAKE_BUILD_TYPE=Release \
    2>&1 | tail -20

# ── Source the built workspace ────────────────────────────────
source /root/ros2_ws/install/setup.bash

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║   Drone Search Field — Stage 2                      ║"
echo "║   ROS2 Humble + Gazebo Classic                      ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Sensors:                                            ║"
echo "║    /drone/downward_cam/image_raw  → downward RGB    ║"
echo "║    /drone/gps/fix                 → GPS position    ║"
echo "║    /simple_drone/sonar/out        → altitude sonar  ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Controls:                                           ║"
echo "║    /simple_drone/cmd_vel          → velocity cmd    ║"
echo "║    /simple_drone/takeoff          → takeoff         ║"
echo "║    /simple_drone/land             → land            ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Mission: Find 5 blue targets, avoid the red zone!  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

exec "$@"
