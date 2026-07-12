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

### Installing Docker & NVIDIA Container Toolkit (Ubuntu/Debian)

If you don't have Docker or the NVIDIA toolkit installed, you can install them by running:

```bash
# 1. Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 2. Add your user to the docker group (so you don't need sudo)
sudo usermod -aG docker $USER
newgrp docker

# 3. Install the NVIDIA Container Toolkit (for GPU support)
sudo ./install_nvidia_docker.sh
```
---

## Quick Start

```bash
# 1. Clone / enter this repo
cd /path/to/arty-induction

# 2. Build & launch with CPU rendering (first run takes ~10 min to build)
./run.sh

# Or launch with NVIDIA GPU acceleration (requires NVIDIA Container Toolkit)
./run.sh --gpu

# 3. When finished, press Ctrl+C in the terminal.
```

The Gazebo window and RViz2 will open automatically.

---

## Sensor Topics

| Topic | Message Type | Description |
|-------|-------------|-------------|
| `/drone/front_depth/image_raw` | `sensor_msgs/Image` | Front RGB Camera |
| `/drone/front_depth/depth/image_raw` | `sensor_msgs/Image` | Front Depth Camera (32FC1 format) |
| `/drone/tof/left` | `sensor_msgs/Range` | Left wall ToF (3m range) |
| `/drone/tof/right` | `sensor_msgs/Range` | Right wall ToF (3m range) |
| `/drone/gps/fix` | `sensor_msgs/NavSatFix` | GPS position |
| `/simple_drone/sonar/out` | `sensor_msgs/Range` | Altitude sonar (built-in) |
| `/drone/imu/out` | `sensor_msgs/Imu` | IMU (built-in) |

## Command Topics

| Topic | Message Type | Description |
|-------|-------------|-------------|
| `/simple_drone/cmd_vel` | `geometry_msgs/Twist` | Velocity command (body frame) |
| `/simple_drone/takeoff` | `std_msgs/Empty` | Trigger takeoff |
| `/simple_drone/land` | `std_msgs/Empty` | Trigger landing |

---

## Exploring Topics (open a second terminal inside the container)

```bash
# Open a shell in the running container
docker exec -it drone_corridor_sim bash

# List all active topics
ros2 topic list

# Watch left wall distance
ros2 topic echo /drone/tof/left

# Watch GPS fix
ros2 topic echo /drone/gps/fix

# Manually command the drone (fly forward at 0.5 m/s)
ros2 topic pub /simple_drone/cmd_vel geometry_msgs/msg/Twist \
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

## Candidate Task

**Your task:** implement an autonomous flight controller to navigate past all 7 obstacles and reach the corridor exit. 
The drone must take off, find the green banner to enter the corridor, and use the depth/ToF sensors to dodge obstacles.

### Auto-Building Python Scripts
We have set up the environment so that any `.py` file you place in the `scripts/` directory will be **automatically compiled and installed** when you launch `./run.sh`. 
You do not need to edit `CMakeLists.txt`.

### Useful ROS2 commands to verify your solution

```bash
# Watch your node's logic in real-time
ros2 topic echo /simple_drone/cmd_vel

# Check if sensors are publishing
ros2 topic hz /drone/front_depth/depth/image_raw
ros2 topic hz /drone/tof/left
```

---

## GPU Acceleration (Recommended)

To run the simulation smoothly with camera feeds, you should use GPU acceleration.
Instead of manually editing the compose file, simply run the launcher with the GPU flag:

```bash
./run.sh --gpu
```
*(Requires the NVIDIA Container Toolkit to be installed on your host machine)*

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

## References & Helpful Resources

**ROS 2 & Python Basics:**
- [Writing a simple Publisher and Subscriber (Python)](https://docs.ros.org/en/humble/Tutorials/Beginner-Client-Libraries/Writing-A-Simple-Py-Publisher-And-Subscriber.html)
- [rclpy API Documentation](https://docs.ros2.org/latest/api/rclpy/index.html)
- [OpenCV Python Tutorials](https://docs.opencv.org/4.x/d6/d00/tutorial_py_root.html) (useful for Green Banner detection)

**Documentation:**
- [sjtu_drone (ROS2)](https://github.com/NovoG93/sjtu_drone) — the base drone model
- [gazebo_ros_pkgs](https://github.com/ros-simulation/gazebo_ros_pkgs) — Gazebo ↔ ROS2 bridge
- [ROS2 Humble Docs](https://docs.ros.org/en/humble/)
- [sensor_msgs/Image](https://docs.ros2.org/humble/api/sensor_msgs/msg/Image.html)
- [sensor_msgs/Range](https://docs.ros2.org/humble/api/sensor_msgs/msg/Range.html)
- [geometry_msgs/Twist](https://docs.ros2.org/humble/api/geometry_msgs/msg/Twist.html)
