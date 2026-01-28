#!/bin/bash

set -e

DOCKER=podman


build_image(){
  $DOCKER build -t d4rt-formulas-builder -f Dockerfile .
}

exec_in_container(){

  local XOPTIONS="--env DISPLAY=$DISPLAY --volume /tmp/.X11-unix:/tmp/.X11-unix --security-opt=label=disable"
  local WOPTIONS="--env=XDG_RUNTIME_DIR=/run/user/$(id -u) --volume=/run/user/$(id -u)/wayland:/run/user/$(id -u)/wayland --group-add=video"
  local SPIOPTIONS="--env AT_SPI_BUS=/run/user/$(id -u)/at-spi/bus_0 --volume=/run/user/$(id -u)/at-spi:/run/user/$(id -u)/at-spi  --device=/dev/dri"

  $DOCKER run \
    --rm \
    $XOPTIONS \
    $SPIOPTIONS \
    -v ./.build-container-cache:/cache:z \
    -v .:/app:z \
    -e FLUTTER_FLAVOR=prod \
    d4rt-formulas-builder \
    "$@"
}

if [ "$1" = "build" ]; then
  build_image
  exit $?
fi

if [ "$1" = "exec" ]; then
  exec_in_container ${@:2}
  exit $?
fi

echo "Usage: $0 {build|exec <command>}"
exit 1