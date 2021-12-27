#!/usr/bin/sudo bash

DESKTOP_FILE="/usr/share/applications/android-studio.desktop"

if [ -f "$DESKTOP_FILE" ]; then
    echo "Desktop file for Android Studio already exists" && exit
fi

if [ -z "$1" ]
  then
    echo "Missing the Installation path for Android Studio" && exit
fi

PATH=$1

[ "$UID" -eq 0 ] || exec sudo "$0" "$@" #asking for root permissions in order to create desktop file



echo "[Desktop Entry]" >> $DESKTOP_FILE
echo "Version=1.0" >> $DESKTOP_FILE
echo "Name=Android Studio" >> $DESKTOP_FILE
echo "Comment=Android IDE" >> $DESKTOP_FILE
echo "Exec=$PATH/bin/studio.sh" >> $DESKTOP_FILE
echo "Path=$PATH" >> $DESKTOP_FILE
echo "Icon=$PATH/bin/studio.svg" >> $DESKTOP_FILE
echo "Terminal=false" >> $DESKTOP_FILE
echo "Type=Application" >> $DESKTOP_FILE
echo "Categories=Development;" >> $DESKTOP_FILE