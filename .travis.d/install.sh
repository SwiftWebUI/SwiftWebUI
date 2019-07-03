#!/bin/bash

# our path is:
#   /home/travis/build/NozeIO/Noze.io/

if ! test -z "$SWIFT_SNAPSHOT_NAME"; then
  # Install Swift
  wget "${SWIFT_SNAPSHOT_NAME}"

  TARBALL="`ls swift-*.tar.gz`"
  echo "Tarball: $TARBALL"

  TARPATH="$PWD/$TARBALL"

  cd $HOME # expand Swift tarball in $HOME
  tar zx --strip 1 --file=$TARPATH
  pwd

  export PATH="$PWD/usr/bin:$PATH"
  which swift

  if [ `which swift` ]; then
    echo "Installed Swift: `which swift`"
  else
    echo "Failed to install Swift?"
    exit 42
  fi
fi

swift --version


# Environment

TT_SWIFT_BINARY=`which swift`

echo "${TT_SWIFT_BINARY}"
