# Use Ubuntu 22.04 ARM64 as the base image
FROM arm64v8/ubuntu:22.04

# Set environment variables for non-interactive installations
ENV DEBIAN_FRONTEND=noninteractive \
    DISPLAY=:0 \
    QT_X11_NO_MITSHM=1 \
    PYTHONIOENCODING=utf-8

# Update and install basic dependencies
RUN apt update && apt install -y \
    build-essential \
    cmake \
    curl \
    git \
    gnupg2 \
    lsb-release \
    software-properties-common \
    locales \
    x11-apps \
    xauth \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libxtst-dev \
    libxi-dev \
    libxcb-xinerama0 \
    libxcb-randr0 \
    libxcb-xfixes0 \
    libxcb-shape0 \
    libxcb-render0 \
    libxcb-render-util0 \
    libxcb-xkb-dev \
    libxcb-glx0 \
    python3-pip \
    usbutils \
    libgpiod-dev \
    libgpiod2 \
    gpiod \
    v4l-utils \
    net-tools \
    iputils-ping \
    udev \
    wget \
    python3-dev \
    python3-setuptools \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Set the locale
RUN locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Add ROS 2 apt repository
RUN curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null

# Install ROS 2 Humble
RUN apt update && apt install -y \
    ros-humble-desktop \
    ros-humble-ros-base \
    python3-argcomplete \
    && apt clean && rm -rf /var/lib/apt/lists/*

# Install Python packages
RUN pip3 install -U \
    rosdep \
    colcon-common-extensions

# Initialize rosdep
RUN rosdep init || echo "rosdep already initialized" && \
    rosdep update

# Setup ROS environment
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

# Setup GPIO access
RUN groupadd -f -r gpio && \
    usermod -a -G gpio root && \
    echo 'SUBSYSTEM=="gpio", KERNEL=="gpiochip*", GROUP="gpio", MODE="0660"' > /etc/udev/rules.d/99-gpio.rules

# Setup USB access
RUN echo 'SUBSYSTEM=="usb", MODE="0666"' > /etc/udev/rules.d/99-usb.rules

# Create workspace directory
RUN mkdir -p /ros2_ws/src
WORKDIR /ros2_ws

# Copy USB detection script
COPY scripts/detect_usb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/detect_usb.sh

# Copy entrypoint script
COPY scripts/entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]