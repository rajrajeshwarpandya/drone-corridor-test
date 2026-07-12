# Autonomous Drone Corridor Simulation — Project Summary

This document provides a comprehensive overview of the `drone_corridor_sim` project, its architecture, custom modifications, and how it functions as a testing environment for robotics candidates.

---

## 1. Project Architecture

The project is built on **ROS 2 Humble** and **Gazebo Classic**, fully containerized using Docker to ensure cross-platform consistency.

### Containerization & Build System
- **`Dockerfile`**: Sets up the Ubuntu 22.04 base image, installs ROS 2 Humble, Gazebo, and necessary plugins. It automatically clones the base drone repository and builds the ROS 2 workspace.
- **`docker-compose.yml` & `docker-compose.gpu.yml`**: Define the services. The architecture supports two modes:
  - **CPU Mode**: Uses software rendering (slower, but universally compatible).
  - **GPU Mode**: Passes through the host's NVIDIA GPU for hardware-accelerated rendering and physics, crucial for processing 30fps camera feeds without lagging the simulation.
- **`run.sh`**: The main entry point script. It handles X11 GUI forwarding (so Gazebo can open on the host machine) and accepts the `--gpu` flag to switch between compose files.

---

## 2. The Drone (`sjtu_drone`)

The simulation uses a modified version of the `sjtu_drone` quadrotor. Out of the box, the drone comes with basic movement plugins, an RGB camera, and sonar.

### Custom Sensor Modifications (`sjtu_drone_extended.urdf.xacro`)
To make the obstacle-avoidance task feasible and realistic, the drone's URDF was heavily extended with new virtual sensors:

1. **Front Depth Camera**:
   - **Type**: `gazebo_ros_camera` (configured as a depth camera).
   - **Function**: Simulates a modern stereo/depth camera (like Intel RealSense or OAK-D). It outputs a `32FC1` floating-point depth map where each pixel represents the distance to an obstacle in meters.
   - **Topic**: `/drone/front_depth/depth/image_raw`

2. **Left & Right Time-of-Flight (ToF) Sensors**:
   - **Type**: `gazebo_ros_ray_sensor` (single-ray LiDARs).
   - **Function**: Pointed exactly 90 degrees to the left and right of the drone. These provide a single float value representing the distance to the walls, allowing candidates to easily implement PID wall-centering logic.
   - **Topics**: `/drone/tof/left` and `/drone/tof/right`

3. **Built-in Sensors**:
   - **Front RGB Camera**: `/drone/front_depth/image_raw`
   - **Downward Sonar**: `/simple_drone/sonar/out` (used for altitude hold)
   - **GPS & Ground Truth**: `/drone/gps/fix` and `/simple_drone/gt_pose`

---

## 3. The Gazebo World (`corridor.world`)

The environment was custom-built for this test. It consists of:
- **Spawn Area**: An open space outside the corridor where the drone spawns at `(x=-2.0, y=5.0)`.
- **The Entrance**: A narrow opening marked by a floating **Green Banner**. Candidates must use basic Computer Vision (CV) on the RGB camera feed to detect the color green and locate the entrance.
- **The Corridor**: A long hallway (approx. 20 meters long) containing **7 challenging obstacles**. The obstacles are positioned at varying distances and alternating sides (left/center/right) to force the drone to actively strafe (dodge) rather than flying in a straight line.

---

## 4. The Candidate Task (The "Test")

The environment is designed to test a candidate's ability to combine State Machines, Computer Vision, and Sensor Data Processing in ROS 2. 

The intended solution requires writing a Python node (a "flight controller") that implements the following state machine:

1. **TAKEOFF**: Read the sonar topic. Publish upward velocity (`cmd_vel`) until the drone reaches ~1.5 meters, then hold that altitude.
2. **SEARCH**: Publish a lateral velocity (strafe left/right) while analyzing the RGB camera feed. Count green pixels to detect the entrance banner.
3. **ENTER**: Fly forward into the corridor.
4. **FLY (Obstacle Avoidance)**: The core challenge.
   - **Wall Centering**: Compare left and right ToF sensors. If Left > Right, strafe left to stay in the middle.
   - **Dodging**: Analyze the depth camera array. Split the image into Left, Center, and Right strips. If the Center depth drops below a critical threshold (e.g., 1.5m), determine which side (Left or Right) has a higher depth value and command a hard strafe in that direction.
5. **DONE**: Once the ground truth X-coordinate exceeds 20.0m, stop all movement and hover.

---

## 5. Summary of Files

| File | Purpose |
|------|---------|
| `run.sh` | Wrapper script to launch the Docker container with/without GPU. |
| `Dockerfile` | Defines the OS, ROS 2 installation, and workspace compilation. |
| `worlds/corridor.world` | The 3D environment with walls, banner, and obstacles. |
| `urdf/sjtu_drone_extended.urdf.xacro` | The drone model + custom depth/ToF sensors. |
| `launch/corridor_sim.launch.py` | Orchestrates spawning the world, the drone, and RViz. |

*Note: The completed solution (`corridor_nav_node.py`) has been removed from this workspace so it can be distributed as a clean test environment.*
