# Use the official Flutter SDK image
FROM cirrusci/flutter:latest

# Set the working directory
WORKDIR /app

# Copy the pubspec.yaml and install dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy the rest of the application code
COPY . .

# Build the Flutter app for Android
RUN flutter build apk --release

# Use the following entrypoint if you want to run the app in a container
# ENTRYPOINT ["flutter", "run", "--release"]
