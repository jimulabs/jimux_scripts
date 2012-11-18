#!/usr/bin/env bash

if [ "`ps -ALL | grep Xvfb | wc -l`" -eq "0" ]
then Xvfb :1 -screen 0 1024x768x24 &
fi

CONSOLE=""
if [ "$1" -eq "-c" ]; then
  CONSOLE="-console"
  echo "Launching with osgi console..."
fi

PWD="`pwd`"
ANDROID_SDK_HOME="`find ${PWD} -name 'android-sdk*' -type d`"
ECLIPSE_HOME="`find ${PWD} -name 'eclipse*' -type d | head -1`"

# workspace
WORKSPACE="$HOME/jimux-workspace"
SETTINGS_DIR="${WORKSPACE}/.metadata/.plugins/org.eclipse.core.runtime/.settings"
rm -fr $WORKSPACE
mkdir -p ${SETTINGS_DIR}

ADT_PREFS_PATH="${SETTINGS_DIR}/com.android.ide.eclipse.adt.prefs"
echo "Writing ADT prefs: ${ADT_PREFS_PATH}..."
cat > ${ADT_PREFS_PATH} <<EOF
com.android.ide.eclipse.adt.fixLegacyEditors=1
com.android.ide.eclipse.adt.sdk=${ANDROID_SDK_HOME}
eclipse.preferences.version=1
EOF


DISPLAY=:1 $ECLIPSE_HOME/eclipse -consolelog -application jimux.server -data jimux-workspace -clean $CONSOLE
