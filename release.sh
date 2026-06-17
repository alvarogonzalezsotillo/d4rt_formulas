#!/bin/bash -x
echo "Ejecutando $0 en directorio $(pwd)"

build_release_files(){
  #make build-container build-builders test build-android-release-container build-linux-release-container build-web-release-container
  #make build-container build-builders test                                 build-linux-release-container build-web-release-container

  echo " ----> Listando archivos en pwd"
  find $(pwd)
  echo " <----"

  pushd build/web && zip -r ../../webapp.zip * && popd
  pushd build/linux/x64/release/bundle && zip -r ../../../../../linux-bin.zip * && popd
}

get_release_files(){
  echo ./build/app/outputs/flutter-apk/app-release.apk linux-bin.zip webapp.zip
}

create_release_in_github(){
    echo "Building release for TAG:$TAG VERSION:$VERSION"
    build_release_files
    FILES="$(get_release_files)"
    gh release create $TAG --notes "Automatic release" $FILES
}

update_gh_pages(){
  if [[ ! -d ./gh-pages ]]
  then
    git worktree add gh-pages origin/gh-pages
  fi

  cp -r build/web/* gh-pages/
  (
    pushd gh-pages
    git add .
    git commit -m "Update webapp from release $TAG"
    git push --force
    popd
  )

}

main(){
  if [[ -z "$GITHUB_REF" ]]
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
  #create_release_in_github
  update_gh_pages

}

main
