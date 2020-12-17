#!/bin/bash
#
# Resolve the location of the SmartGit installation.
# This includes resolving any symlinks.
PRG=$0
while [ -h "$PRG" ]; do
    ls=`ls -ld "$PRG"`
    link=`expr "$ls" : '^.*-> \(.*\)$' 2>/dev/null`
    if expr "$link" : '^/' 2> /dev/null >/dev/null; then
        PRG="$link"
    else
        PRG="`dirname "$PRG"`/$link"
    fi
done

SMARTGIT_BIN=`dirname "$PRG"`

# absolutize dir
oldpwd=`pwd`
cd "${SMARTGIT_BIN}"
SMARTGIT_BIN=`pwd`
cd "${oldpwd}"

ICON_NAME=syntevo-smartgit
TMP_DIR=`mktemp --directory`
DESKTOP_FILE=$TMP_DIR/syntevo-smartgit.desktop
cat << EOF > $DESKTOP_FILE
[Desktop Entry]
Version=1.0
Encoding=UTF-8
Name=SmartGit
Icon=$ICON_NAME
Keywords=git
Comment=Git-Client
Type=Application
Categories=Development;RevisionControl
Terminal=false
StartupNotify=true
StartupWMClass=SmartGit
Exec="$SMARTGIT_BIN/smartgit.sh" %u
MimeType=x-scheme-handler/git;x-scheme-handler/smartgit;x-scheme-handler/sourcetree;
EOF

# seems necessary to refresh immediately:
chmod 644 $DESKTOP_FILE

xdg-desktop-menu install $DESKTOP_FILE
xdg-icon-resource install --size  32 "$SMARTGIT_BIN/smartgit-32.png"  $ICON_NAME
xdg-icon-resource install --size  48 "$SMARTGIT_BIN/smartgit-48.png"  $ICON_NAME
xdg-icon-resource install --size  64 "$SMARTGIT_BIN/smartgit-64.png"  $ICON_NAME
xdg-icon-resource install --size 128 "$SMARTGIT_BIN/smartgit-128.png" $ICON_NAME

rm $DESKTOP_FILE
rm -R $TMP_DIR
