
all: build-container clean-container build-builders build-linux-debug-container

DATABASEFILE=~/.local/share/com.example.d4rt_formulas/d4rt_formulas/formulas.sqlite

FLUTTERW := $(shell if [ "$$CONTAINER_ID" = "" ]; then echo "./flutterw"; else echo "distrobox-host-exec $(CURDIR)/flutterw"; fi)

build-container:
	$(FLUTTERW) --build-container

clean:
	flutter clean
	[ -f $(DATABASEFILE) ] && rm $(DATABASEFILE) || true

clean-container:
	rm -r .build-container-cache
	$(FLUTTERW) clean


pub-get-container:
	$(FLUTTERW) pub get

test:
	$(FLUTTERW) test

build-builders:
	$(FLUTTERW) pub run build_runner build --delete-conflicting-outputs

build-android-release-container:
	$(FLUTTERW) build apk --release

build-linux-debug-container:
	$(FLUTTERW) build linux --debug

build-web-debug-container:
	$(FLUTTERW) build web --debug

# Zip web build for embedding as asset
assets/generated/webapp.zip: build/web
	mkdir -p assets/generated
	cd build/web && zip -r ../../assets/generated/webapp.zip .

build-webapp-zip: assets/generated/webapp.zip

run-linux-debug-container:
	$(FLUTTERW) run -d linux

run-web-debug-container:
	$(FLUTTERW) run --web-port $${WEB_PORT:-8081} -d web-server

run-linux-debug-native:
	flutter run -d linux

run-web-debug-native:
	flutter run --web-port $${WEB_PORT:-8081} -d web-server

ai:
	qwen --prompt-interactive --yolo "Read CLAUDE.md. Implement first task not already done in TODO.md"

run-emulator:
	flutter emulators --launch Medium_Phone
	flutter run -d emulator-5554
