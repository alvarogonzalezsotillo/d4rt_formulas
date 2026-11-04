FROM ghcr.io/gmeligio/flutter-android:3.47.9

USER root

# Install cmake, ninja, clang, pkg-config, and other tools for flutter linux
RUN apt-get update && apt-get install -y \
    cmake \
    ninja-build \
    clang \
    pkg-config \
    libgtk-3-dev \
    liblzma-dev \
    binutils-dev \
    build-essential \
    lld \
    binutils

# Create symlinks for the linker to ensure it's accessible
RUN ln -sf /usr/bin/ld.lld /usr/bin/ld

# Pass this during build: --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)
# Only important in docker, maybe use acls for docker instead of user mapping
ARG USER_ID
ARG GROUP_ID
RUN echo "Using UID: $USER_ID and GID: $GROUP_ID"

USER $USER_ID:$GROUP_ID

# Pre-cache Flutter artifacts for Linux, Android, and Web to speed up subsequent builds
USER flutter
WORKDIR /dummy_app_only_for_cache
RUN flutter create . && flutter pub get; \
    flutter config --enable-linux-desktop; \
    flutter config --enable-web; \
    flutter config --enable-android; \
    flutter precache --linux; \
    flutter precache --web; \
    flutter precache --android

WORKDIR /app
