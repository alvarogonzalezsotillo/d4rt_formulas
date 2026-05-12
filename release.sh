#|/bin/bash
echo "Ejecutando $0 en directorio $(pwd)"

build_release_files(){
  make build-container build-builders test build-android-release-container
}

get_release_files(){
  #find . | grep flutter-apk | apk$
  echo ./build/app/outputs/flutter-apk/app-release.apk
}

main(){
  TAG=${GITHUB_REF#refs/tags/}
  build_release_files
  APK="$(get_release_files)"
  gh release create $TAG $APK
}

main
