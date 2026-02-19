FROM ghcr.io/cirruslabs/flutter:3.32.3

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

# Configure cache directories
ENV PUB_CACHE=/cache/pub-cache
ENV GRADLE_USER_HOME=/cache/gradle-cache
RUN mkdir -p $PUB_CACHE $GRADLE_USER_HOME

# To avoid: fatal: detected dubious ownership in repository at '/sdks/flutter'
# Pass this during build: --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g)
ARG USER_ID
ARG GROUP_ID
RUN echo "Using UID: $USER_ID and GID: $GROUP_ID"
RUN chown -R $USER_ID:$GROUP_ID $PUB_CACHE $GRADLE_USER_HOME
RUN chown -R $USER_ID:$GROUP_ID /sdks/flutter

USER $USER_ID:$GROUP_ID

# Pre-cache Flutter artifacts for Linux, Android, and Web to speed up subsequent builds
WORKDIR /dummy_app_only_for_cache
RUN flutter create . && flutter pub get
RUN flutter precache --linux
RUN flutter build linux
RUN flutter precache --web
RUN flutter build web
RUN flutter precache --android
RUN flutter build apk

WORKDIR /app


# Copy pubspec files and get dependencies
# Commented out to avoid building the app during image creation, this will be handled externally by makefile
# COPY pubspec.yaml pubspec.lock ./
# RUN flutter pub get

# Copy the rest of the application code and build
# Commented out to avoid building the app during image creation, this will be handled externally by makefile
# COPY . .
# RUN flutter build apk --release
