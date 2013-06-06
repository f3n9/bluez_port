#!/bin/bash
SRCDIR=`dirname $0`
DSTDIR=$1

if [ -z "$DSTDIR" ]
then
    echo "Usage: $0 <cm 10.1 dir>"
    exit 1
fi

# build/core/pathmap.mk: patch
echo "[build/core] Patch pathmap.mk"
cat $SRCDIR/patches/build_core.patch | patch -d $DSTDIR/build/core -p0 -N -r - -s


# external/bluetooth: 1. remove bluedroid
#                     2. copy bluez/glib/hcidump
echo "[external/bluetooth] removing bluedroid"
rm -rf $DSTDIR/external/bluetooth/*
echo "[external/bluetooth] adding bluez, glib and hcidump"
cp -r $SRCDIR/external/bluetooth/* $DSTDIR/external/bluetooth/

# packages/apps: 1. replace Bluetooth; 
#                2. replace Settings/src/com/android/settings/bluetooth
#                3. patch Phone
echo "[packages/apps] removing Bluetooth"
rm -rf $DSTDIR/packages/apps/Bluetooth

echo "[packages/apps] adding Bluetooth"
cp -r $SRCDIR/packages/apps/Bluetooth $DSTDIR/packages/apps/

echo "[packages/apps] removing Settings/src/com/android/settings/bluetooth"
rm -rf $DSTDIR/packages/apps/Settings/src/com/android/settings/bluetooth

echo "[packages/apps] adding Settings/src/com/android/settings/bluetooth"
cp -r $SRCDIR/packages/apps/Settings/src/com/android/settings/bluetooth $DSTDIR/packages/apps/Settings/src/com/android/settings/

echo "[packages/apps] patching Phone"
cat $SRCDIR/patches/Phone.patch | patch -d $DSTDIR/packages/apps/Phone -p1 -N -r - -s


# frameworks/base:
#           1. merge core/java/android/bluetooth/
#           2. merge core/java/android/server/
#           3. merge core/jni/
#           4. merge core/res/res/values/
#           5. remove services/java/com/android/server/BluetoothManagerService.java
#           6. apply patch frameworks_base.patch
#                   Android.mk
#                   core/java/com/android/internal/util/StateMachine.java
#                   core/jni/Android.mk
#                   core/jni/AndroidRuntime.cpp
#                   core/res/res/values/config.xml
#                   core/res/res/values/symbols.xml
#                   services/java/com/android/server/NetworkManagementService.java
#                   services/java/com/android/server/power/ShutdownThread.java
#                   services/java/com/android/server/SystemServer.java

echo "[frameworks/base] merging core"
cp -r $SRCDIR/frameworks/base/core $DSTDIR/frameworks/base/
echo "[frameworks/base] removing services/java/com/android/server/BluetoothManagerService.java"
rm -f $DSTDIR/frameworks/base/services/java/com/android/server/BluetoothManagerService.java
echo "[frameworks/base] applying patch frameworks_base.patch"
cat $SRCDIR/patches/frameworks_base.patch | patch -d $DSTDIR/frameworks/base -p0 -N -r - -s

echo "Done"
