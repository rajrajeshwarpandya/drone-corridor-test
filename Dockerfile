# ============================================================
# Drone Corridor Simulation
# Base: ROS2 Humble Desktop Full + Gazebo Classic 11
# ============================================================
FROM osrf/ros:humble-desktop-full

ARG DEBIAN_FRONTEND=noninteractive

# ── System dependencies ──────────────────────────────────────
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Gazebo Classic 11
    gazebo \
    libgazebo-dev \
    gazebo-common \
    # ROS2 ↔ Gazebo bridge (Classic)
    ros-humble-gazebo-ros-pkgs \
    ros-humble-gazebo-ros \
    ros-humble-gazebo-plugins \
    # Robot description tools
    ros-humble-xacro \
    ros-humble-robot-state-publisher \
    ros-humble-joint-state-publisher \
    # Visualization
    ros-humble-rviz2 \
    ros-humble-rqt \
    ros-humble-rqt-graph \
    # Build tools
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-pip \
    git \
    wget \
    curl \
    vim \
    # X11 / GUI support
    libgl1-mesa-glx \
    libgl1-mesa-dri \
    x11-apps \
    mesa-utils \
    && rm -rf /var/lib/apt/lists/*

# ── Python deps for demo node ────────────────────────────────
RUN pip3 install --no-cache-dir transforms3d numpy

# ── Create ROS2 workspace ────────────────────────────────────
ENV ROS_WS=/root/ros2_ws
WORKDIR ${ROS_WS}/src

# ── Clone sjtu_drone (ROS2 branch) ──────────────────────────
RUN git clone --depth 1 -b ros2 \
    https://github.com/NovoG93/sjtu_drone.git \
    sjtu_drone

# ── Copy our custom package ──────────────────────────────────
# (mounted at runtime via volume for live editing)
COPY ros2_ws/src/drone_corridor_sim ${ROS_WS}/src/drone_corridor_sim

# ── Install ROS deps via rosdep ──────────────────────────────
WORKDIR ${ROS_WS}
RUN bash -c "source /opt/ros/humble/setup.bash && \
    rosdep update && \
    rosdep install -r -y \
        --from-paths src \
        --ignore-src \
        --rosdistro humble" || true

# ── Build workspace ──────────────────────────────────────────
RUN bash -c "source /opt/ros/humble/setup.bash && \
    colcon build \
        --symlink-install \
        --cmake-args -DCMAKE_BUILD_TYPE=Release"

# ── Environment setup ────────────────────────────────────────
ENV GAZEBO_MODEL_PATH=/root/ros2_ws/src/sjtu_drone/sjtu_drone_description/models:${GAZEBO_MODEL_PATH}
ENV GAZEBO_PLUGIN_PATH=/root/ros2_ws/install/sjtu_drone_gazebo/lib:${GAZEBO_PLUGIN_PATH}

# ── Copy entrypoint ──────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# ── Expose ports (QGroundControl MAVLink — future use) ───────
EXPOSE 14550/udp

WORKDIR ${ROS_WS}
ENTRYPOINT ["/entrypoint.sh"]
CMD ["ros2", "launch", "drone_corridor_sim", "corridor_sim.launch.py"]
