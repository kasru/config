#!/bin/bash
#
# Resolve the location of the installation.
# This includes resolving any symlinks.
PRG=$0
BIN=$1

if [ -z "${BIN}" ]; then
  echo "usage: ${PRG} [directory with clion]"
  exit 2
fi

# absolutize dir
oldpwd=`pwd`
cd "${BIN}"
BIN=`pwd`/bin
cd "${oldpwd}"

ICON_NAME=jetbrains-clion
TMP_DIR=`mktemp --directory`
DESKTOP_FILE=$TMP_DIR/jetbrains-clion.desktop
cat << EOF > $DESKTOP_FILE
[Desktop Entry]
Version=1.0
Type=Application
Name=CLion
Icon=$BIN/clion.svg
Exec="$BIN/clion.sh" %f
Comment=A cross-platform IDE for C and C++
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-clion
EOF

# seems necessary to refresh immediately:
chmod 644 $DESKTOP_FILE

xdg-desktop-menu install $DESKTOP_FILE
#xdg-icon-resource install --size 128 "$BIN/clion.png" $ICON_NAME

rm $DESKTOP_FILE
rm -R $TMP_DIR
