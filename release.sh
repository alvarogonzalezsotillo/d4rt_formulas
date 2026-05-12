#|/bin/bash
echo "Ejecutando $0 en directorio $(PWD)"

build_release_files(){
  make build-android-release-container
}

get_release_files(){
  #find . | grep apk$
  echo ./release.sh
}

main(){
  TAG=${GITHUB_REF#refs/tags/}
  build_release_files
  APK="$(get_release_files)"
  gh release create $TAG $APK
}

main
