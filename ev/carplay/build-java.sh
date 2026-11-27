#!/bin/sh
# Compile the CarPlay EV Java (java/) for Iap2ServerApp: javac against Android 19 with the
# iAP2 compile stubs (stubs/, not shipped), d8, baksmali. Out: smali/ (what the iAP2 build
# adds; ~/hmg-private/tools/srcfix/apply21.py copies it in). Needs ANDROID_HOME (platforms/
# android-19, build-tools/34.0.0), javac, baksmali.
set -e
HERE=$(cd "$(dirname "$0")" && pwd)
AJ=${ANDROID_HOME:?}/platforms/android-19/android.jar
D8=$ANDROID_HOME/build-tools/34.0.0/lib/d8.jar
W=$(mktemp -d); trap 'rm -rf "$W"' EXIT
python3 -I "$HERE/gen-profiles.py" >/dev/null
mkdir -p "$W/stubs" "$W/classes"
javac -source 8 -target 8 -nowarn -Xlint:-options -bootclasspath "$AJ" -d "$W/stubs" $(find "$HERE/stubs" -name '*.java')
javac -source 8 -target 8 -nowarn -Xlint:-options -bootclasspath "$AJ" -cp "$W/stubs" -d "$W/classes" $(find "$HERE/java" -name '*.java')
(cd "$W/classes" && find . -name '*.class' | LC_ALL=C sort > ../list && jar cf ../ev.jar @../list)
java -cp "$D8" com.android.tools.r8.D8 --min-api 18 --release --lib "$AJ" --classpath "$W/stubs" --output "$W" "$W/ev.jar"
rm -rf "$HERE/smali"
baksmali d --api 18 -o "$HERE/smali" "$W/classes.dex"
find "$HERE/smali" -name '*.smali' | sed "s#$HERE/smali/##" | LC_ALL=C sort
