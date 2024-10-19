FROM ubuntu:22.04

# Update system and add the packages required for Yocto builds.
# Use DEBIAN_FRONTEND=noninteractive, to avoid image build hang waiting
# for a default confirmation [Y/n] at some configurations.

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update && apt install -y gawk wget git-core diffstat unzip \ 
    texinfo gcc-multilib build-essential chrpath socat file cpio \
    python3 python3-pip python3-pexpect xz-utils debianutils \
    libsdl1.2-dev xterm tar locales net-tools rsync sudo vim curl zstd \
    liblz4-tool libssl-dev bc lzop libgnutls28-dev efitools git-lfs \
    iputils-ping iproute2 nftables shfmt && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# Set up locales
RUN locale-gen en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# Yocto needs 'source' command for setting up the build environment, so replace
# the 'sh' alias to 'bash' instead of 'dash'.
RUN rm /bin/sh && ln -s bash /bin/sh

# Install repo
ADD https://storage.googleapis.com/git-repo-downloads/repo /usr/local/bin/
RUN chmod 755 /usr/local/bin/repo

# Setup user and paths
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

# Create a group and user with the provided UID, GID, and username, but set a custom home directory
RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_NAME} -s /bin/bash -d ${YOCTO_DIR} ${USER_NAME} && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p ${PROJECT_DIR} && \
    mkdir -p ${BUILD_DIR} && \
    mkdir -p ${REPO_DIR} && \
    mkdir -p ${SOURCES_DIR} && \
    mkdir -p ${DL_DIR} && \
    mkdir -p ${SSTATE_DIR} && \
    chown -R ${USER_NAME}:${USER_NAME} ${YOCTO_DIR}

# Set the DL_DIR and SSTATE_DIR environment variables
ENV DL_DIR=${DL_DIR}
ENV SSTATE_DIR=${SSTATE_DIR}
ENV BUILDDIR=${BUILD_DIR}
ENV SOURCES_DIR=${SOURCES_DIR}
ENV PROJECT_DIR=${PROJECT_DIR}
ENV BB_ENV_PASSTHROUGH_ADDITIONS="DL_DIR SSTATE_DIR BUILDDIR SOURCES_DIR PROJECT_DIR"

# Switch to the new non-root user
USER ${USER_NAME}