cmake_minimum_required(VERSION 3.8)
project(drone_corridor_sim)

if(CMAKE_COMPILER_IS_GNUCXX OR CMAKE_CXX_COMPILER_ID MATCHES "Clang")
  add_compile_options(-Wall -Wextra -Wpedantic)
endif()

# ── Find dependencies ─────────────────────────────────────────
find_package(ament_cmake REQUIRED)
find_package(rclpy REQUIRED)
find_package(std_msgs REQUIRED)
find_package(sensor_msgs REQUIRED)
find_package(geometry_msgs REQUIRED)

# ── Install Python scripts (standalone executables) ───────────
# Automatically find and install any .py scripts candidates create
file(GLOB PYTHON_SCRIPTS "scripts/*.py")
if(PYTHON_SCRIPTS)
  install(PROGRAMS
    ${PYTHON_SCRIPTS}
    DESTINATION lib/${PROJECT_NAME}
  )
endif()

# ── Install package resources ─────────────────────────────────
install(DIRECTORY
  urdf
  worlds
  launch
  config
  models
  DESTINATION share/${PROJECT_NAME}
)

ament_package()
