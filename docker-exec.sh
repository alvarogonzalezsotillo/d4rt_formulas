#!/bin/bash

set -e

detect_container(){

    if [ "$DOCKER" != "" ]
    then
        return 0
    elif command -v podman > /dev/null 2>&1
    then
        DOCKER=podman
    elif command -v docker > /dev/null 2>&1
    then     
        DOCKER=docker
    else
        echo "Error: no container manager detected (like 'docker' or 'podman'), please define DOCKER variable"
        exit 2
    fi
}


build_image(){
    $DOCKER build -t d4rt-formulas-builder -f Dockerfile .
}

graphic_options(){

    is_x11(){
        [ "$XDG_SESSION_TYPE" = "x11" ] || [ "$DISPLAY" != "" ]
    }

    is_wayland(){
        [ "$XDG_SESSION_TYPE" = "wayland" ] || [ "$WAYLAND_DISPLAY" != "" ]
    }
    
    if is_x11
    then
        echo "--env DISPLAY=$DISPLAY --volume /tmp/.X11-unix:/tmp/.X11-unix --security-opt=label=disable"
    elif is_wayland
    then
        echo "--env=XDG_RUNTIME_DIR=/run/user/$(id -u) --volume=/run/user/$(id -u)/wayland:/run/user/$(id -u)/wayland --group-add=video"
    else
        echo "WARNING: no graphic environment" 1>&2
    fi
}

exec_in_container(){
    local SPIOPTIONS="--env AT_SPI_BUS=/run/user/$(id -u)/at-spi/bus_0 --volume=/run/user/$(id -u)/at-spi:/run/user/$(id -u)/at-spi  --device=/dev/dri"

    local GRAPHICOPTIONS=$(graphic_options)
    local BUILDCACHE=./.build-container-cache
    mkdir -p $BUILDCACHE

    $DOCKER run \
            -it \
            --init \
            --rm \
            $GRAPHICOPTIONS \
            $SPIOPTIONS \
            -v $BUILDCACHE:/cache:z \
            -v .:/app:z \
            -e FLUTTER_FLAVOR=prod \
            d4rt-formulas-builder \
            "$@"
}

main(){
    detect_container

    if [ "$1" = "build" ]; then
        build_image
        return $?
    fi

    if [ "$1" = "exec" ]; then
        exec_in_container ${@:2}
        return $?
    fi

    echo "Usage: $0 {build|exec <command>}"
    return 1
}

main "$@"
