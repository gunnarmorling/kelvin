#!/usr/bin/env sh
set -ev

# constants
BINARY_NAME="kelvin"

buildTarget() {
  OS=$1
  ARCH=$2
  TARGET="$OS-$ARCH"

  if [[ $OS == "windows" ]]; then
    BINARY_NAME="$BINARY_NAME.exe"
  fi

  # Read latest git tag
  if $(git describe --abbrev=0 --tags); then
    GIT_TAG=$(git describe --abbrev=0 --tags)
  else
    GIT_TAG="unknown"
  fi

  # configure paths
  DIST_PATH=$GOPATH/dist
  OUTPUT_PATH=$DIST_PATH/"$BINARY_NAME-$TARGET-$GIT_TAG"
  OUTPUT_BINARY=$OUTPUT_PATH/$BINARY_NAME

  # Start go build
  echo ===== Building $TARGET =====
  export GOOS=$OS
  export GOARCH=$ARCH
  go build -ldflags "-X main.applicationVersion=${GIT_TAG}" -v -o $OUTPUT_BINARY

  # make binary executable
  $(chmod +x $OUTPUT_BINARY)
  
  # include license and readme
  $(cp README.md $OUTPUT_PATH/README.txt)
  $(cp LICENSE $OUTPUT_PATH/LICENSE.txt)

  # build archive
  if [[ $OS == "windows" ]]; then
    $(zip -r $OUTPUT_PATH.zip $OUTPUT_PATH)
  else
    $(tar cfvz $OUTPUT_PATH.tar.gz $OUTPUT_PATH)
  fi
  echo ===== $TARGET build successfull =====
}

# MAIN
echo Start
buildTarget freebsd amd64
#buildTarget darwin amd64
buildTarget windows amd64
#buildTarget linux amd64
echo Done