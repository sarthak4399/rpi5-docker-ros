# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    QT_X11_NO_MITSHM=1

# Update and install dependencies
RUN apt update && apt install -y \
    build-essential \
    curl \
    gnupg2 \
    lsb-release \
    software-properties-common \
    locales \
    x11-apps \
    libx11-dev \
    libxcb-xinerama0 \
    libxcb-randr0 \
    libxcb-xfixes0 \
    libxcb-shape0 \
    libxcb-render0 \
    libxcb-render-util0 \
    libxcb-xkb-dev \
    libxcb-glx0 \
    python3-pip \
    python3-colcon-common-extensions \
    usbutils \
    gpio-utils \
    libgpiod-dev \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add ROS 2 Humble repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key | apt-key add - && \
    echo "deb http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2-latest.list

# Install ROS 2 Humble
RUN apt update && apt install -y ros-humble-desktop \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Source ROS 2 setup
RUN echo "source /opt/ros/humble/setup.bash" >> ~/.bashrc

# Allow GPIO access for Raspberry Pi 5
RUN groupadd -f -r gpio && \
    usermod -a -G gpio root

# Add a script to auto-detect USB devices
COPY detect_usb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/detect_usb.sh

# Configure entrypoint
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
