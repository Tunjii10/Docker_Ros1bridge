# Usu Ubuntu 20.04 (Focal) for ARMv8 (64-bit)
FROM arm64v8/ubuntu:focal

# Set noninteractive frontend to avoid prompts
ENV DEBIAN_FRONTEND=noninteractive

# # Set up ROS Noetic environment variables
# ENV ROS_DISTRO=noetic
# ENV LANG=C.UTF-8
# ENV LC_ALL=C.UTF-8

# Set ROS install paths as environment variables
ENV ROS1_INSTALL_PATH=/opt/ros/noetic
ENV ROS2_INSTALL_PATH=/home/blue/ros2_ws/install

# Install basic utilities and dependencies for ROS humble from source
RUN apt-get update && apt-get install -y \
    locales \
    lsb-release \
    gnupg2 \
    curl \
    wget \
    git \
    sudo \
    cmake \
    build-essential \
    python3-pip \
    libacl1-dev \
    # X11 and graphics dependencies for OGRE and RViz
    libx11-dev \
    libxaw7-dev \
    libxrandr-dev \
    libgl1-mesa-dev \
    libglu1-mesa-dev \
    libxext-dev \
    libxt-dev \
    libglfw3-dev \
    libglew-dev \
    # Additional graphics dependencies
    libassimp-dev \
    libfreetype6-dev \
    libfreeimage-dev \
    libzzip-dev \
    libxmu-dev \
    libxi-dev \
    freeglut3-dev \
    libasio-dev \
    libssl-dev \
    libtinyxml2-dev \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*



# Add the ROS repository
RUN sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add -

# Install ROS Noetic Desktop
RUN apt-get update && apt-get install -y \
    ros-noetic-ros-base \
    && rm -rf /var/lib/apt/lists/*

# Install Pip packages and ROS development tools
RUN python3 -m pip install -U \
    rosdep \
    rosinstall \
    rosinstall_generator \
    wstool \
    catkin_pkg \
    rospkg \
    rosdistro \
    lark-parser \
    empy==3.3.4 \
   # empy \
    lark \
    # empy \
    colcon-common-extensions \
    setuptools \
    vcstool \
    pytest-timeout \
    flake8-blind-except \
    flake8-builtins \
    flake8-class-newline \
    flake8-comprehensions \
    flake8-deprecated \
    flake8-import-order \
    flake8-quotes \
    "pytest>=5.3" \
    pytest-repeat \
    pytest-rerunfailures \
    importlib_metadata \
    && rm -rf /var/lib/apt/lists/*

# Install additional ROS tools
RUN apt-get update && apt-get install -y \
    python3-flake8-docstrings \
    python3-pip \
    python3-pytest-cov \
    ros-dev-tools \
    && rm -rf /var/lib/apt/lists/*

# install additional ROS dependencies
RUN apt-get update && \
    apt-get install -y \
    python3-rosdep \
    python3-rosinstall \
    python3-rosinstall-generator \
    python3-wstool \
    && rm -rf /var/lib/apt/lists/*

# Configure a new non-root user
ARG USERNAME=blue
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && usermod -a -G dialout $USERNAME

# Source ROS environment on shell startup for both root and user
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc \
    && echo "source /opt/ros/noetic/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc

# Source ROS 2 environment on shell startup for both root and user
RUN echo "source /home/blue/ros2_ws/install/setup.bash" >> /root/.bashrc \
    && echo "source /home/blue/ros2_ws/install/setup.bash" >> /home/$USERNAME/.bashrc \
    && echo "source /usr/share/bash-completion/completions/git" >> /home/$USERNAME/.bashrc

# Set ownership of user's home directory
RUN chown -R $USERNAME:$USERNAME /home/$USERNAME

# SHELL [ "/bin/bash" , "-c" ]
WORKDIR /home/$USERNAME/



## Install ROS 2 Humble from source
# Copy the bridge script into the container
COPY run_bridge.sh /home/blue/run_bridge.sh
RUN chmod +x /home/blue/run_bridge.sh && \
    chown $USERNAME:$USERNAME /home/blue/run_bridge.sh

# Copy the ROS 2 workspace into the container
COPY volume/ros2_ws/src /home/blue/ros2_ws/src

# Set up the ROS 2 workspace
WORKDIR /home/$USERNAME/ros2_ws

# rosdep init and update
RUN sudo apt-get update && \
    sudo rosdep init && \
    rosdep update && \
    rosdep install --from-paths src --ignore-src -r -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"

# build the ROS 2 workspace without the bridge
RUN /bin/bash -c "colcon build --symlink-install --packages-skip ros1_bridge && \
    #source the setup file
    source ${ROS1_INSTALL_PATH}/setup.bash && \
    source ${ROS2_INSTALL_PATH}/setup.bash && \
    colcon build --symlink-install --packages-select ros1_bridge --cmake-force-configure"

# # Start the bridge
# RUN /bin/bash -c "source ${ROS1_INSTALL_PATH}/setup.bash && \
#     source ${ROS2_INSTALL_PATH}/setup.bash && \
#     export ROS_MASTER_URI=http://192.168.2.95:11311 && \
#     ros2 run ros1_bridge dynamic_bridge "
# Set the default command


# CMD ["bash"]

USER $USERNAME

ENTRYPOINT ["/home/blue/run_bridge.sh"]


