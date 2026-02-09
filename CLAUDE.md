# Tools available
- This is a flutter app.
- Flutter and Dart are not installed locally. They are executed via a flutter wrapper script, like gradlew (gradle wrapper) for gradle.
- Flutter and Dart are installed in a podman container. This container is invoked via `./flutterw` bash script.
  - `./flutterw --build-container` to build the image and the container with flutter tools
  - `./flutterw --exec <args>` to execute bash commands inside the container
  - `./flutterw <args>` is a shorthand for `./flutter --exec flutter <args>`, so `./flutterw` and `flutter` are somewhat equivalent.
- Examples:
  - `flutter pub get` --> `./flutterw pub get`
  - `flutter run -d linux` --> `./flutterw run -d linux`
- See `./Makefile` for more examples.


# Workflow
- One feature at a time
- Create a git branch for each new feature
- After making changes, and before consider the feature is implemented
  - Allways pass all the tests and integration tests
  - Build the application for linux and web-server
  - Launch the apllication for web-server, with a timeout of 60s
- Dont merge the feature branch into master, the work will be reviewed by a human.
