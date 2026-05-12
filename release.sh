#|/bin/bash
echo "Ejecutando $0 en directorio $(PWD)"
echo "---> Variables de entorno relacionadas con GitHub:"
env | grep GITHUB_
echo "<-----"
TAG=${GITHUB_REF#refs/tags/}
make build-android-release-container
APK=$(find . | grep apk$)

