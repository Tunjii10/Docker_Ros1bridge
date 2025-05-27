#!/bin/bash

# Source ROS 1 and ROS 2 environments
source ${ROS1_INSTALL_PATH}/setup.bash
source ${ROS2_INSTALL_PATH}/setup.bash

# Set ROS master URI
export ROS_MASTER_URI=http://192.168.2.95:11311

# Start the dynamic bridge
exec ros2 run ros1_bridge dynamic_bridge

