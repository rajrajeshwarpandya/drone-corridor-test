# Drone Corridor Simulation
## ROS2 Humble + Gazebo Classic — Docker Environment

A **one-command simulation** for learning drone control via ROS2 topics.
The drone (sjtu_drone quadrotor) must navigate a 20m corridor with
obstacles using:
- **Front 2D LiDAR** — obstacle detection
- **Left/Right ToF sensors** — wall distance
- **GPS** — global position

---

## Prerequisites

| Tool | Min version |
|------|-------------|
| Docker | 24+ |
| docker-compose | 2.20+ |
| Linux host with X11 | (for Gazebo GUI) |

---

## Quick Start

```bash
# 1. Allow Docker to use your display
xhost +local:docker

# 2. Clone / enter this repo
cd /path/to/arty-induction

# 3. Build & launch (first run takes ~10 min to build)
docker-compose up --build

# 4. When finished
docker-compose down
xhost -local:docker
```

The Gazebo window and RViz2 will open automatically.

---

## Sensor Topics

| Topic | Message Type | Description |
|-------|-------------|-------------|
| `/drone/lidar/scan` | `sensor_msgs/LaserScan` | Front 2D LiDAR (270° FOV, 10m range) |
| `/drone/tof/left` | `sensor_msgs/Range` | Left wall ToF (3m range) |
| `/drone/tof/right` | `sensor_msgs/Range` | Right wall ToF (3m range) |
| `/drone/gps/fix` | `sensor_msgs/NavSatFix` | GPS position |
| `/drone/sonar` | `sensor_msgs/Range` | Altitude sonar (built-in) |
| `/drone/imu/out` | `sensor_msgs/Imu` | IMU (built-in) |

## Command Topics

| Topic | Message Type | Description |
|-------|-------------|-------------|
| `/drone/cmd_vel` | `geometry_msgs/Twist` | Velocity command (body frame) |
| `/drone/takeoff` | `std_msgs/Empty` | Trigger takeoff |
| `/drone/land` | `std_msgs/Empty` | Trigger landing |

---

## Exploring Topics (open a second terminal inside the container)

```bash
# Open a shell in the running container
docker exec -it drone_corridor_sim bash

# List all active topics
ros2 topic list

# Watch LiDAR data in real time
ros2 topic echo /drone/lidar/scan

# Watch GPS fix
ros2 topic echo /drone/gps/fix

# Watch left wall distance
ros2 topic echo /drone/tof/left

# Manually command the drone (fly forward at 0.5 m/s)
ros2 topic pub /drone/cmd_vel geometry_msgs/msg/Twist \
  "{linear: {x: 0.5, y: 0.0, z: 0.0}, angular: {z: 0.0}}"

# Plot LaserScan in RQT
ros2 run rqt_graph rqt_graph
```

---

## Package Structure

```
drone_corridor_sim/
├── urdf/
│   └── sjtu_drone_extended.urdf.xacro   ← drone model + sensors
├── worlds/
│   └── corridor.world                   ← Gazebo environment
├── launch/
│   └── corridor_sim.launch.py           ← starts everything
├── config/
│   └── rviz2_config.rviz                ← pre-configured view
└── scripts/
    └── corridor_demo_node.py            ← ⭐ your starting point
```

---

## Junior Engineer Task

The `corridor_demo_node.py` node does the following:
1. **Takeoff** — climbs to 1.5 m altitude
2. **Fly** — moves forward at 0.4 m/s
3. **Hover** — stops if LiDAR detects obstacle < 2 m ahead

**Your task:** implement obstacle avoidance so the drone can navigate
past all 3 obstacles and reach the corridor exit.

### Hints

```python
# In _do_fly():

# Left wall too close → drift right
if self.tof_left_dist < 0.8:
    cmd.linear.y = -0.2

# Right wall too close → drift left
if self.tof_right_dist < 0.8:
    cmd.linear.y = 0.2

# Obstacle ahead → slow and steer around it
if self.front_obstacle:
    cmd.linear.x = 0.1
    cmd.linear.y = -0.3   # try going right
```

### Useful ROS2 commands to verify your solution

```bash
# Watch your node's logic in real-time
ros2 topic echo /drone/cmd_vel

# Check if sensors are publishing
ros2 topic hz /drone/lidar/scan
ros2 topic hz /drone/tof/left
```

---

## GPU Acceleration (Optional)

If your machine has an NVIDIA GPU, edit `docker-compose.yml`:

1. Comment out: `- LIBGL_ALWAYS_SOFTWARE=1`
2. Uncomment the `deploy:` block at the bottom

Then rebuild: `docker-compose up --build`

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Black Gazebo window | Software rendering is slow — wait 30s on first run |
| `cannot open display` | Run `xhost +local:docker` on the host first |
| Topics not showing | Wait for drone to fully spawn (~7s after launch) |
| Build fails on sjtu_drone | Check internet connection; it clones from GitHub |
| Drone falls through ground | Physics issue — try increasing Z spawn to 0.5 in launch args |

---

## References

- [sjtu_drone (ROS2)](https://github.com/NovoG93/sjtu_drone) — the base drone model
- [gazebo_ros_pkgs](https://github.com/ros-simulation/gazebo_ros_pkgs) — Gazebo ↔ ROS2 bridge
- [ROS2 Humble Docs](https://docs.ros.org/en/humble/)
- [sensor_msgs/LaserScan](https://docs.ros2.org/humble/api/sensor_msgs/msg/LaserScan.html)
- [sensor_msgs/Range](https://docs.ros2.org/humble/api/sensor_msgs/msg/Range.html)
