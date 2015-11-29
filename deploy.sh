#! /bin/bash
# asteroid-stopwatch deploy script
# (C) Copyright 2015 by Tim Süberkrüb
set -e
echo "Setup environment setup for armv7a-vfp-neon-oe-linux-gnueabi ..."
source /usr/local/oecore-x86_64/environment-setup-armv7a-vfp-neon-oe-linux-gnueabi
echo "Running qmake ..."
qmake
echo "Running make ..."
make
echo "Deploying binary ..."
adb push asteroid-stopwatch /usr/bin/asteroid-stopwatch
echo "Deploying desktop file ..."
adb push asteroid-stopwatch.desktop /usr/share/applications/asteroid-stopwatch.desktop
echo "Keep display on ..."
adb shell mcetool -D on
echo "Running application ..."
adb shell env QT_QUICK_CONTROLS_STYLE=Nemo XDG_RUNTIME_DIR=/tmp /usr/bin/asteroid-stopwatch --platform wayland-egl
