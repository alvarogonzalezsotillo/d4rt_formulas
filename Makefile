
all: clean-container build-linux-debug-container

build-container:
	./docker-exec.sh build

clean-container: build-container
	./docker-exec.sh exec flutter clean

pub-get-container: build-container
	./docker-exec.sh exec flutter pub get

build-android-release-container: pub-get-container
	./docker-exec.sh exec flutter build apk --release

build-linux-debug-container: pub-get-container
	./docker-exec.sh exec flutter build linux --debug

build-web-debug-container: pub-get-container
	./docker-exec.sh exec flutter build web --debug

run-linux-debug-container: pub-get-container
	./docker-exec.sh exec flutter run -d linux

run-web-debug-container: pub-get-container
	./docker-exec.sh exec flutter run --web-port $${WEB_PORT:-8081} -d web-server

run-linux-debug-native: build-linux-debug-container
	./build/linux/x64/debug/bundle/d4rt_formulas

run-web-debug-native: build-web-debug-container
	cd build/web && python3 -m http.server $${WEB_PORT:-8081}
