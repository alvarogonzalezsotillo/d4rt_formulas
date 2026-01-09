
build-podman:
	podman-compose build

clean-podman: build-podman
	podman-compose run --entrypoint "flutter clean"  flutter


build-android-release-podman: build-podman
	podman-compose run --entrypoint "flutter build apk --release"  flutter

build-linux-debug-podman: build-podman
	podman-compose run --entrypoint "flutter build linux"  flutter

run-linux-debug: build-linux-debug-podman
	build/linux/x64/debug/bundle/d4rt_formulas

run-web-release-podman: build-web-release-podman
	podman-compose run --entrypoint "cd build/web && python3 -m http.server 8080"  flutter
