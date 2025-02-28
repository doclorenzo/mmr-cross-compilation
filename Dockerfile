FROM arm64v8/ubuntu:22.04
RUN apt update && apt install -y locales \
    && locale-gen en_US en_US.UTF-8 \
    && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 \
    && export LANG=en_US.UTF-8 \
    && apt install -y software-properties-common \
    && add-apt-repository universe \
    && apt update && apt install -y curl

RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    python3-flake8-docstrings python3-pip python3-pytest-cov \
    ros-dev-tools ros-humble-ament-cmake ros-humble-rclcpp \
    ros-humble-geometry-msgs ros-humble-std-msgs ros-humble-can-msgs

RUN rosdep init && rosdep update --rosdistro humble && apt install ros-humble-sensor-msgs
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc
