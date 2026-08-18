#!/bin/bash
# exit on error
set -e
# exit on undefined
set -u
# pipe error propagation
set -o pipefail

echo "Ejecutando $0 en directorio $(pwd)"



build_release_files(){

    build_web()(
        make build-web-debug-container
        pushd build/web && zip -r ../../webapp.zip * && popd
    )

    build_android()(
        make build-android-release-container
    )

    build_linux()(
        make build-linux-release-container
        pushd build/linux/x64/release/bundle && zip -r ../../../../../linux-bin.zip * && popd
    )

    build_common()(
        make generate-build-info build-container build-builders clean-container test
    )

    build_common
    if $BUILD_WEBPAGE
    then
        build_web
    fi
    if $BUILD_ANDROID
    then
        build_android
    fi
    if $BUILD_LINUX
    then
        build_linux
    fi
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
    gh release create $RELEASE_NAME --notes "Automatic release" $FILES
}

update_gh_pages(){
    local GHPAGESDIR=gh-pages-worktree
 
    if is_github_action
    then
        echo "VOY A HACER ESO DEL USER.NAME"
        git config user.name "$GITHUB_ACTOR"
        git config user.email "$GITHUB_ACTOR@automatic-release"
        git fetch origin gh-pages:gh-pages
    else
        echo "NO VOY A HACER ESO DEL USER.NAME, ESTOY EN LOCAL"

    fi
    
    if [[ ! -d $GHPAGESDIR ]]
    then
        git worktree add $GHPAGESDIR gh-pages
    fi

    cp -r build/web/* $GHPAGESDIR

    
    pushd $GHPAGESDIR
    git add .
    git commit -m "Update webapp from release $TAG"
    git push --force origin gh-pages
    popd
}

is_github_action(){
    [ ${GITHUB_REF+x} ]
}

parse_args(){
    # Parse scripts params and set global variables. If no parameters, defaults to --all
    # called from main()
    # -w --webpage -> BUILD_WEBPAGE
    # -l --linux -> BUILD_LINUX
    # -a --android -> BUILD_ANDROID
    # -g --gh-pages -> BUILD_GHPAGES BUILD_WEBPAGE
    # -r --release -> CREATE_RELEASE
    #    --all     -> BUILD_WEBPAGE BUILD_LINUX BUILD_ANDROID BUILD_GHPAGES CREATE_RELEASE
    # -h --help -> Show help and exit
    BUILD_WEBPAGE=false
    BUILD_LINUX=false
    BUILD_ANDROID=false
    BUILD_GHPAGES=false
    CREATE_RELEASE=false

    if [[ $# -eq 0 ]]; then
        set -- --all
    fi

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -w|--webpage)
                BUILD_WEBPAGE=true
                shift
                ;;
            -l|--linux)
                BUILD_LINUX=true
                shift
                ;;
            -a|--android)
                BUILD_ANDROID=true
                shift
                ;;
            -g|--gh-pages)
                BUILD_GHPAGES=true
                BUILD_WEBPAGE=true
                shift
                ;;
            -r|--release)
                CREATE_RELEASE=true
                shift
                ;;
            --all)
                BUILD_WEBPAGE=true
                BUILD_LINUX=true
                BUILD_ANDROID=true
                BUILD_GHPAGES=true
                CREATE_RELEASE=true
                shift
                ;;
            -h|--help)
                echo "Usage: $0 [options]"
                echo ""
                echo "Options:"
                echo "  -w, --webpage    Build web version"
                echo "  -l, --linux      Build Linux version"
                echo "  -a, --android    Build Android version"
                echo "  -g, --gh-pages   Update gh-pages (implies --webpage)"
                echo "  -r, --release    Create GitHub release (needs at least one build)"
                echo "      --all        Build everything and create release and gh-pages (default)"
                echo "  -h, --help       Show this help message"
                exit 0
                ;;
            *)
                echo "Error: Unknown option '$1'"
                echo "Run '$0 --help' for usage information"
                exit 1
                ;;
        esac
    done

    echo "BUILD_WEBPAGE=$BUILD_WEBPAGE"
    echo "BUILD_LINUX=$BUILD_LINUX"
    echo "BUILD_ANDROID=$BUILD_ANDROID"
    echo "BUILD_GHPAGES=$BUILD_GHPAGES"
    echo "CREATE_RELEASE=$CREATE_RELEASE"

    if $CREATE_RELEASE && !($BUILD_WEBPAGE || $BUILD_LINUX || $BUILD_ANDROID)
    then
        echo "Error: a release needs at least one type of build"
        echo "Run '$0 --help' for usage information"
        exit 2
    fi    
}


main(){
    parse_args "$@"

    local COMMIT_HASH=$(git rev-parse HEAD)
    local COMMIT=${COMMIT_HASH:0:7}
    
    if ! is_github_action
    then
        echo "Not running in GitHub Actions, using local commit hash"
        TAG=release-$COMMIT
    else
        TAG=${GITHUB_REF#refs/tags/}-$COMMIT
    fi
    if [[ ! $TAG == release-* ]]
    then
        echo "Not a release tag, it should start with 'release-', skipping build"
        exit 0
    fi
    RELEASE_NAME=${TAG#release-}

    echo "Building release for TAG:$TAG RELEASE_NAME:$RELEASE_NAME"

    if $BUILD_WEBPAGE || $BUILD_LINUX || $BUILD_ANDROID; then
        build_release_files
    fi

    if $CREATE_RELEASE; then
        create_release_in_github
    fi

    if $BUILD_GHPAGES; then
        update_gh_pages
    fi
}

main "$@"
