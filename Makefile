
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

run-linux-debug-container: build-linux-debug-container
	./docker-exec.sh exec /app/build/linux/x64/debug/bundle/d4rt_formulas

run-web-debug-container: build-web-debug-container
	cd build/web && python3 -m http.server 8080
