FROM arm64v8/ubuntu:22.04
RUN apt update && apt install -y locales
RUN locale-gen en_US en_US.UTF-8
RUN update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN apt install -y software-properties-common
RUN add-apt-repository universe
RUN apt update && apt install curl -y
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null
RUN apt update
RUN apt install -y python3-flake8-docstrings 
RUN apt install -y python3-pip 
RUN apt install -y python3-pytest-cov 
RUN DEBIAN_FRONTEND=noninteractive apt install -y ros-dev-tools
RUN apt install -y ros-humble-ament-cmake
RUN apt install -y ros-humble-rclcpp
RUN apt install -y ros-humble-geometry-msgs
RUN apt install -y ros-humble-std-msgs
RUN apt install -y ros-humble-can-msgs
RUN rosdep init
RUN rosdep update --rosdistro humble
COPY MMR/mmr-kria-drive/ /home
RUN rosdep install --from-paths /home/src --rosdistro humble --ignore-src -y --skip-keys "fastcdr rti-connext-dds-6.0.1 urdfdom_headers"
RUN apt install ros-humble-sensor-msgs

