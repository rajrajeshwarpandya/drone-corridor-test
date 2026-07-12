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
echo "║    /drone/front_depth/depth/image_raw   → depth cam ║"
echo "║    /drone/tof/left                      → left ToF  ║"
echo "║    /drone/tof/right                     → right ToF ║"
echo "║    /drone/gps/fix                       → GPS fix   ║"
echo "║    /simple_drone/cmd_vel                → velocity  ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Quick check:  ros2 topic list                       ║"
echo "║  Echo sensor:  ros2 topic echo /drone/tof/left       ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

exec "$@"
