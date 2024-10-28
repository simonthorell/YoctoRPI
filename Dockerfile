FROM ubuntu:22.04

# Setup user and path arguments
ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_NAME=dev
ARG YOCTO_DIR=/yocto
ARG PROJECT_DIR=${YOCTO_DIR}/project
ARG BUILD_DIR=${YOCTO_DIR}/build
ARG REPO_DIR=${YOCTO_DIR}/.repo
ARG SOURCES_DIR=${YOCTO_DIR}/sources
ARG DL_DIR=${YOCTO_DIR}/dl
ARG SSTATE_DIR=${YOCTO_DIR}/sstate
ARG TMP_DIR=${YOCTO_DIR}/tmp

# Set the localizations
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# When installing apt packages, we don't want to be prompted for input
ENV DEBIAN_FRONTEND=noninteractive

# Do all the modifications to the image with a single RUN command
# to reduce the number of layers. This will make the image smaller.
# Start with updating the package list
RUN apt update && \
    # Install the required packages with -y to avoid being prompted
    apt install -y \
    \
    # Python tools
    # Yocto requires Python 3 for its build system
    python3 python3-pip python3-pexpect \
    \
    # Network tools
    # Git is used by Yocto to download source code repositories
    git-core \
    # Wget downloads files from the internet (used to retrieve Yocto layers and sources)
    wget \
    \
    # File tools
    # File is used to determine file types (important in build scripts to identify file formats)
    file \
    # Diffstat generates statistics from diff files (used for patch management in Yocto builds)
    diffstat \
    # Gawk processes text files for pattern scanning and processing (required by Yocto scripts)
    gawk \
    \
    # Compression tools
    # Unzip extracts files from zip archives (used for fetching and unpacking Yocto layers or external resources)
    unzip \
    # Cpio is used to create and extract cpio archives (Yocto uses it to build root filesystems)
    cpio \
    # Xz-utils provides tools to compress and decompress files (commonly used in Yocto to handle tarball sources)
    xz-utils \
    # Zstd is a fast lossless compression algorithm (used in various parts of Yocto builds)
    zstd \
    # Liblz4-tool is a high-speed compression utility (Yocto can use this for compressing images or archives)
    liblz4-tool \
    \
    # Build tools
    # Texinfo is used to generate documentation (required by the GNU project, part of some Yocto recipes)
    texinfo \
    # GCC-multilib compiles code for multiple architectures (needed for cross-compilation in Yocto) - does not work with aarch64!
    # gcc-multilib \
    # Build-essential is a collection of packages needed to compile software (fundamental to Yocto's build process)
    build-essential \
    # Chrpath is used to modify the rpath in ELF executables (useful for fixing binary paths after Yocto builds)
    chrpath \
    \
    # Other tools used by this project
    # Used for menuconfig in the kernel
    tmux \
    # Git based tool by Google to manage multiple repositories
    repo \
    # Locales is used to set the locale on the system (Yocto builds may require a specific locale for consistent behavior)
    locales \
    # Sudo is used for root privileges (required by runqemu to set up networking)
    sudo \
    # iproute2 and iptables are required by runqemu for networking 
    iproute2 iptables && \
    # terminal multiplexer for running menuconfig
    \
    \
    \
    # Finished installing packages. Continue with the configuration
    \
    \
    # Clean up the package cache to reduce the image size
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    \
    # Set the locale to en_US.UTF-8 and update the locale
    locale-gen en_US.UTF-8 && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 && \
    \
    # Set the shell to bash because it is required by Yocto
    rm /bin/sh && ln -s bash /bin/sh && \
    \
    # Create a non-root user with the same UID and GID as the host user with sudo privileges
    groupadd -g "${USER_GID}" "${USER_NAME}" && \
    useradd -m -u "${USER_UID}" -g "${USER_NAME}" -s /bin/bash -d "${YOCTO_DIR}" "${USER_NAME}" && \
    usermod -aG sudo "${USER_NAME}" && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    \
    # Set up the project folder structure for the created user
    mkdir -p "${PROJECT_DIR}" "${BUILD_DIR}" "${REPO_DIR}" "${SOURCES_DIR}" "${DL_DIR}" "${SSTATE_DIR}" "${TMP_DIR}" && \
    chown -R "${USER_NAME}:${USER_NAME}" "${YOCTO_DIR}"


# Switch to the new non-root user
USER ${USER_NAME}

# Set the DL_DIR and SSTATE_DIR environment variables
# ENV PROJECT_DIR=${PROJECT_DIR}
# ENV SOURCES_DIR=${SOURCES_DIR}
ENV BUILDDIR=${BUILD_DIR}
ENV DL_DIR=${DL_DIR}
ENV SSTATE_DIR=${SSTATE_DIR}
ENV TMPDIR=${TMP_DIR}

# Allow them to pass into the yocto build environment
ENV BB_ENV_PASSTHROUGH_ADDITIONS="BUILDDIR DL_DIR SSTATE_DIR TMPDIR"