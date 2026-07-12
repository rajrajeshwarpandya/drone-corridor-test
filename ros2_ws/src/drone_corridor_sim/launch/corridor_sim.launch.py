#!/usr/bin/env python3
"""
corridor_sim.launch.py
======================
Launches the full drone corridor simulation:
  1. Gazebo Classic with corridor.world
  2. robot_state_publisher  (URDF → TF)
  3. spawn_entity           (drone into Gazebo)
  4. RViz2                  (pre-configured view)
  5. corridor_demo_node     (takeoff + fly demo)
"""

import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import (
    DeclareLaunchArgument,
    IncludeLaunchDescription,
    TimerAction,
    ExecuteProcess,
)
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration, Command
from launch_ros.actions import Node


def generate_launch_description():

    pkg_sim   = get_package_share_directory("drone_corridor_sim")
    pkg_gazebo = get_package_share_directory("gazebo_ros")

    # ── Arguments ─────────────────────────────────────────────
    use_sim_time_arg = DeclareLaunchArgument(
        "use_sim_time", default_value="true",
        description="Use Gazebo simulation time"
    )
    use_rviz_arg = DeclareLaunchArgument(
        "use_rviz", default_value="true",
        description="Launch RViz2"
    )
    x_arg = DeclareLaunchArgument("x", default_value="-2.0", description="Spawn X")
    y_arg = DeclareLaunchArgument("y", default_value="5.0",  description="Spawn Y")
    z_arg = DeclareLaunchArgument("z", default_value="0.3",  description="Spawn Z")

    use_sim_time = LaunchConfiguration("use_sim_time")
    use_rviz     = LaunchConfiguration("use_rviz")

    # ── Paths ─────────────────────────────────────────────────
    world_file   = os.path.join(pkg_sim, "worlds", "corridor.world")
    urdf_file    = os.path.join(pkg_sim, "urdf",   "sjtu_drone_extended.urdf.xacro")
    rviz_config  = os.path.join(pkg_sim, "config", "rviz2_config.rviz")

    # ── 1. Gazebo Classic ─────────────────────────────────────
    gazebo = IncludeLaunchDescription(
        PythonLaunchDescriptionSource(
            os.path.join(pkg_gazebo, "launch", "gazebo.launch.py")
        ),
        launch_arguments={
            "world":   world_file,
            "verbose": "false",
            "pause":   "false",
        }.items(),
    )

    # ── sjtu_drone needs its drone.yaml for physics params ────
    from ament_index_python.packages import get_package_share_directory as gpsd
    drone_yaml = os.path.join(gpsd("sjtu_drone_bringup"), "config", "drone.yaml")

    # ── 2. Robot State Publisher ──────────────────────────────
    robot_state_publisher = Node(
        package="robot_state_publisher",
        executable="robot_state_publisher",
        name="robot_state_publisher",
        parameters=[{
            "robot_description": Command(
                ["xacro ", urdf_file, " params_path:=", drone_yaml]
            ),
            "use_sim_time": use_sim_time,
        }],
        remappings=[("/tf", "tf"), ("/tf_static", "tf_static")],
    )

    # ── 3. Spawn drone into Gazebo ────────────────────────────
    #   Delayed 3 s to let Gazebo start fully
    spawn_drone = TimerAction(
        period=3.0,
        actions=[
            Node(
                package="gazebo_ros",
                executable="spawn_entity.py",
                name="spawn_drone",
                arguments=[
                    "-topic", "robot_description",
                    "-entity", "sjtu_drone",
                    "-x", LaunchConfiguration("x"),
                    "-y", LaunchConfiguration("y"),
                    "-z", LaunchConfiguration("z"),
                ],
                output="screen",
            )
        ],
    )

    # ── 4. RViz2 ──────────────────────────────────────────────
    rviz2 = TimerAction(
        period=5.0,
        actions=[
            Node(
                package="rviz2",
                executable="rviz2",
                name="rviz2",
                arguments=["-d", rviz_config],
                parameters=[{"use_sim_time": use_sim_time}],
                condition=None,
                output="log",
            )
    return LaunchDescription([
        use_sim_time_arg,
        use_rviz_arg,
        x_arg, y_arg, z_arg,
        gazebo,
        robot_state_publisher,
        spawn_drone,
        rviz2,
    ])

