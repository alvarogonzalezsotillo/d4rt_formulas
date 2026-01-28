
all: clean-podman build-linux-debug-podman build-linux-debug-podman

build-podman:
	./docker-exec.sh build

clean-podman: build-podman
	./docker-exec.sh exec flutter clean

pub-get-podman: build-podman
	./docker-exec.sh exec flutter pub get

build-android-release-podman: pub-get-podman
	./docker-exec.sh exec flutter build apk --release

build-linux-debug-podman: pub-get-podman
	./docker-exec.sh exec flutter build linux --debug

run-linux-debug: build-linux-debug-podman
	build/linux/x64/debug/bundle/d4rt_formulas

run-web-release-podman: build-web-release-podman
	cd build/web && python3 -m http.server 8080
