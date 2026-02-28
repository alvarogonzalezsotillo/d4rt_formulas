
all: clean-container build-builders build-linux-debug-container

DB=~/.local/share/com.example.d4rt_formulas/d4rt_formulas/formulas.sqlite

build-container:
	./flutterw --build-container

clean:
	flutter clean
	[ -f $(DB) ] && rm $(DB)

clean-container: build-container
	./flutterw clean
	rm .build-container-cache

pub-get-container: build-container
	./flutterw pub get

test: 
	./flutterw test

build-builders: build-container
	./flutterw pub run build_runner build --delete-conflicting-outputs

build-android-release-container: 
	./flutterw build apk --release

build-linux-debug-container: 
	./flutterw build linux --debug

build-web-debug-container: 
	./flutterw build web --debug

run-linux-debug-container: 
	./flutterw run -d linux

run-web-debug-container: 
	./flutterw run --web-port $${WEB_PORT:-8081} -d web-server

run-linux-debug-native:
	flutter run -d linux

run-web-debug-native:
	flutter run --web-port $${WEB_PORT:-8081} -d web-server

ai:
	qwen --prompt-interactive --yolo "Read CLAUDE.md. Implement first task not already done in TODO.md"
