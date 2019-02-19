#!/bin/bash -x

STUDIO_BIN=$1/bin

if [ ! -f $STUDIO_BIN/studio.sh ]; then
    echo "studio.sh not found"
    echo "usage: $0 studio.sh <android studio dir>"
    exit 2
fi

# absolutize dir
oldpwd=`pwd`
cd "${STUDIO_BIN}"
STUDIO_BIN=`pwd`
cd "${oldpwd}"

ICON_NAME=android-studio
TMP_DIR=`mktemp --directory`
DESKTOP_FILE=$TMP_DIR/android-android.desktop
cat << EOF > $DESKTOP_FILE
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=AndroidStudio
Keywords=studio
Comment=Android Studio
Type=Application
Categories=Development
Terminal=false
StartupNotify=true
StartupWMClass=SmartGit
Exec=$STUDIO_BIN/studio.sh
Icon=$ICON_NAME
EOF

# seems necessary to refresh immediately:
chmod 644 $DESKTOP_FILE

xdg-desktop-menu install $DESKTOP_FILE
#xdg-icon-resource install --size  32 "$STUDIO_BIN/studio-32.png"  $ICON_NAME
#xdg-icon-resource install --size  48 "$STUDIO_BIN/studio-48.png"  $ICON_NAME
#xdg-icon-resource install --size  64 "$STUDIO_BIN/studio-64.png"  $ICON_NAME
xdg-icon-resource install --size 128 "$STUDIO_BIN/studio.png" $ICON_NAME

rm $DESKTOP_FILE
rm -R $TMP_DIR

echo "Done."
