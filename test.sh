#|/bin/bash
echo "Ejecutando $0 en directorio $(PWD)"
make build-container build-builders test
