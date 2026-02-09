
all: clean-container build-linux-debug-container

build-container:
	./flutterw --build-container

clean-container: build-container
	./flutterw clean

pub-get-container: build-container
	./flutterw pub get

build-android-release-container: pub-get-container
	./flutterw build apk --release

build-linux-debug-container: pub-get-container
	./flutterw build linux --debug

build-web-debug-container: pub-get-container
	./flutterw build web --debug

run-linux-debug-container: pub-get-container
	./flutterw run -d linux

run-web-debug-container: pub-get-container
	./flutterw run --web-port $${WEB_PORT:-8081} -d web-server

run-linux-debug-native: build-linux-debug-container
	./build/linux/x64/debug/bundle/d4rt_formulas

run-web-debug-native: build-web-debug-container
	cd build/web && python3 -m http.server $${WEB_PORT:-8081}

ai:
	qwen --prompt-interactive --yolo "Read CLAUDE.md. Implement first task not already done in TODO.md"
