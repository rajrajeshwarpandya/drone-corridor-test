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
echo "║   Drone Corridor Simulation — ROS2 Humble + Gazebo  ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Topics:                                             ║"
echo "║    /drone/lidar/scan   → front 2D LiDAR             ║"
echo "║    /drone/tof/left     → left wall ToF              ║"
echo "║    /drone/tof/right    → right wall ToF             ║"
echo "║    /drone/gps/fix      → GPS NavSatFix              ║"
echo "║    /drone/cmd_vel      → velocity command input      ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Quick check:  ros2 topic list                       ║"
echo "║  Echo sensor:  ros2 topic echo /drone/lidar/scan     ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

exec "$@"
