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

clean_build_cache(){
  $DOCKER builder prune --all --force
}

build_image(){
    $DOCKER build --build-arg USER_ID=$(id -u) --build-arg GROUP_ID=$(id -g) --progress=plain -t d4rt-formulas-builder -f Dockerfile .
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

spi_options(){
    if [ -e /run/user/$(id -u)/at-spi/bus_0 ]
    then
      printf " %s " "--env AT_SPI_BUS=/run/user/$(id -u)/at-spi/bus_0"
    fi

    if [ -e /run/user/$(id -u)/at-spi ]
     then
      printf " %s " "--volume=/run/user/$(id -u)/at-spi:/run/user/$(id -u)/at-spi"
    fi
    if [ -e /dev/dri ]
    then
      printf " %s " "--device /dev/dri"
    fi
}

exec_in_container(){
    SPIOPTIONS=$(spi_options)
    local GRAPHICOPTIONS=$(graphic_options)
    local BUILDCACHE=./.build-container-cache
    mkdir -p $BUILDCACHE

    $DOCKER run \
            -it \
            --userns=keep-id \
            --user $(id -u):$(id -g) \
            --init \
            --rm \
            $GRAPHICOPTIONS \
            $SPIOPTIONS \
            -p ${WEBPORT:-8081}:8081 \
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

    if [ "$1" = "cleancache" ]; then
        clean_build_cache
        return $?
    fi


    if [ "$1" = "exec" ]; then
        exec_in_container ${@:2}
        return $?
    fi

    echo "Usage: $0 {build|cleancache|exec <command>}"
    return 1
}

main "$@"
