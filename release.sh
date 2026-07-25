#!/bin/bash -x
# exit on error
set -e
# exit on undefined
set -u
# pipe error propagation
set -o pipefail

echo "Ejecutando $0 en directorio $(pwd)"


build_release_files(){
    #make build-container build-builders test build-android-release-container build-linux-release-container build-web-release-container
    make build-container build-builders  clean-container test build-web-debug-container

    echo " ----> Listando archivos en pwd"
    find $(pwd)
    echo " <----"

    pushd build/web && zip -r ../../webapp.zip * && popd
    pushd build/linux/x64/release/bundle && zip -r ../../../../../linux-bin.zip * && popd
}


build_release_files(){

    build_web()(
        make build-web-release-container
        pushd build/web && zip -r ../../webapp.zip * && popd
    )

    build_android()(
        make build-android-release-container
    )

    build_linux()(
        make 
        pushd build/linux/x64/release/bundle && zip -r ../../../../../linux-bin.zip * && popd
        build-linux-release-container
    )

    build_common()(
        make build-container build-builders clean-container test
    )

    build_common
    build_web
    # build_android
    # build_linux

}

get_release_files(){
    local files=(
        ./build/app/outputs/flutter-apk/app-release.apk
        linux-bin.zip
        webapp.zip
    )
    for f in "${files[@]}"; do
        if [ -f "$f" ]; then
            echo "$f"
        fi
    done
}

create_release_in_github(){
    FILES="$(get_release_files)"
    gh release create $TAG --notes "Automatic release" $FILES
}

update_gh_pages(){
    local GHPAGESDIR=gh-pages-worktree
    if [[ ! -d $GHPAGESDIR ]]
    then
        git worktree add $GHPAGESDIR gh-pages
    fi

    cp -r build/web/* $GHPAGESDIR
    (
        pushd $GHPAGESDIR
        git add .
        git commit -m "Update webapp from release $TAG"
        git push --force
        popd
    )

}

main(){
    if [[ ! ${GITHUB_REF+x} ]]
    then
        echo "Not running in GitHub Actions, using local commit hash"
        COMMIT_HASH=$(git rev-parse HEAD)
        COMMIT=${COMMIT_HASH:0:7}
        TAG=version-$COMMIT
    else
        TAG=${GITHUB_REF#refs/tags/}
    fi
    if [[ ! $TAG == version-* ]]
    then
        echo "Not a release tag, it should start with 'version-', skipping release"
        exit 0
    fi
    VERSION=${TAG#version-}

    echo "Building release for TAG:$TAG VERSION:$VERSION"
    build_release_files

    #create_release_in_github
    update_gh_pages

}

main
