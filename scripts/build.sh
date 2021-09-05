#!/usr/bin/env bash
set -euo pipefail

CURR_DIR=$PWD;

cd vscode;
START_TIME=$SECONDS
echo -ne "Building VSCode:\t";
if BUILD_RESULTS=$(yarn 2>&1); then
    if BUILD_RESULTS=$(yarn compile 2>&1); then
        echo "OK ("$(($SECONDS - $START_TIME))"s)";
        START_TIME=$SECONDS;
        cd "$CURR_DIR/synthesizer";
        echo -ne "Building Synthesizer:\t";
        if BUILD_RESULTS=$(mvn clean install -Plocal -DskipTests); then
            echo "OK ("$(($SECONDS - $START_TIME))"s)";
        else
            echo "FAILED";
			echo "$BUILD_RESULTS";
        fi;
    else
        echo "FAILED (yarn compile):";
        echo "$BUILD_RESULTS";
    fi;
else
    echo "FAILED (yarn):";
    echo "$BUILD_RESULTS";
fi;

cd $CURR_DIR;
