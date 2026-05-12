#|/bin/bash -x
echo "Ejecutando $0 en directorio $(pwd)"

build_release_files(){
  make build-container build-builders test build-android-release-container build-linux-release-container build-web-release-container
}

get_release_files(){
  pushd build/web && zip -r ../../webapp.zip * && popd
  pushd build/linux/x64/release/bundle && zip -r ../../../../../linux-bin.zip * && popd
  echo ./build/app/outputs/flutter-apk/app-release.apk linux-bin.zip webapp.zip
}

main(){
  TAG=${GITHUB_REF#refs/tags/}
  build_release_files
  FILES="$(get_release_files)"
  gh release create $TAG $FILES
}

main
