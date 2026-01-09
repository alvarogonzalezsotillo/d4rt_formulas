
flutter-container-exec = podman-compose run --entrypoint "$(1)"  flutter

build-podman:
	podman-compose build

clean-podman: build-podman
	$(call flutter-container-exec, flutter clean)

pub-get-podman: build-podman
	$(call flutter-container-exec, flutter pub get)

build-android-release-podman: pub-get-podman
	$(call flutter-container-exec, flutter build apk --release)

build-linux-debug-podman: pub-get-podman
	$(call flutter-container-exec, flutter build linux --debug)

run-linux-debug: build-linux-debug-podman
	build/linux/x64/debug/bundle/d4rt_formulas

run-web-release-podman: build-web-release-podman
	cd build/web && python3 -m http.server 8080
