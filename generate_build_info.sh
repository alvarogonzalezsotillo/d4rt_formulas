#!/bin/bash -x
# exit on error
set -e
# exit on undefined
set -u
# pipe error propagation
set -o pipefail

echo "Ejecutando $0 en directorio $(pwd)"

OUTPUT_FILE="assets/compile_constants.d4rt"
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT=${COMMIT_HASH:0:7}
if [ ${GITHUB_REF+x} ]
then
    TAG=${GITHUB_REF#refs/tags/}-$COMMIT
else
    TAG=release-$COMMIT
fi



{
    printf "{\n"
    printf '  "buildHost":"%s",\n' "$(uname -a)"
    printf '  "release":"%s",\n' "$TAG"
    printf '  "buildTimestamp":"%s",\n' "$(date --utc)"
    printf "}\n"
} > "$OUTPUT_FILE"

