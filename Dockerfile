# Use the official Flutter SDK image
FROM ghcr.io/cirruslabs/flutter:stable

# Install cmake, ninja, clang, pkg-config for flutter linux
RUN apt-get update && apt-get install -y cmake ninja-build clang pkg-config libgtk-3-dev liblzma-dev

WORKDIR /app

# Configure cache directories
ENV PUB_CACHE=/cache/pub-cache
ENV GRADLE_USER_HOME=/cache/gradle-cache
RUN mkdir -p $PUB_CACHE $GRADLE_USER_HOME

# Copy pubspec files and get dependencies
# COPY pubspec.yaml pubspec.lock ./
# RUN flutter pub get

# Copy the rest of the application code and build
# Commented out to avoid building the app during image creation, this will be handled externally by makefile
# COPY . .
# RUN flutter build apk --release
