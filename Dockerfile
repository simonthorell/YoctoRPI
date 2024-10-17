FROM ubuntu:22.04

# Update system and add the packages required for Yocto builds.
# Use DEBIAN_FRONTEND=noninteractive, to avoid image build hang waiting
# for a default confirmation [Y/n] at some configurations.

ENV DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y gawk wget git-core diffstat unzip texinfo \
    gcc-multilib build-essential chrpath socat file cpio python3 \
    python3-pip python3-pexpect xz-utils debianutils iputils-ping \
    libsdl1.2-dev xterm tar locales net-tools rsync sudo vim curl zstd \
    liblz4-tool libssl-dev bc lzop libgnutls28-dev efitools git-lfs

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

ARG USER_UID=1000
ARG USER_GID=1000
ARG USER_NAME=dev
ARG HOME_DIR=/yocto

# Create a group and user with the provided UID, GID, and username, but set a custom home directory
RUN groupadd -g ${USER_GID} ${USER_NAME} && \
    useradd -m -u ${USER_UID} -g ${USER_NAME} -s /bin/bash -d ${HOME_DIR} ${USER_NAME} && \
    usermod -aG sudo ${USER_NAME} && \
    echo "${USER_NAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p ${HOME_DIR}/build && \
    mkdir -p ${HOME_DIR}/sources && \
    mkdir -p ${HOME_DIR}/dl && \
    mkdir -p ${HOME_DIR}/sstate && \
    mkdir -p ${HOME_DIR}/.repo && \
    mkdir -p ${HOME_DIR}/project && \
    chown -R ${USER_NAME}:${USER_NAME} ${HOME_DIR}

# Switch to the new non-root user
USER ${USER_NAME}