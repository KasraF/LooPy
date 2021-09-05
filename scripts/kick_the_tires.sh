#!/usr/bin/env bash
set -euo pipefail

function loopy_test {
    START_TIME=$SECONDS;
    NAME=$1;
    COMMAND=$2;
    QUERY=$3;
    RS=$4;

    echo -ne $NAME":\t";

    # Then, run the Kick the Tires main, storing the output to RESULTS
    RESULTS=$(eval $COMMAND)

    # Now, make sure the results are what we expected
    if [[ $RESULTS ]]; then
        if [[ $(echo "$RESULTS" | grep $QUERY | wc -l) -eq $RS ]]; then
            echo "OK ("$(($SECONDS - $START_TIME))"s)";
        else
            echo "Running $NAME did not produce the expected output:";
            echo "----------------------------------------------------------";
            echo "$RESULTS";
            echo "----------------------------------------------------------";
            echo;
        fi;
    else
        echo "Running $NAME did not output any results:";
        echo "$RESULTS";
        echo;
    fi;
}

CURR_DIR=$PWD;

if [[ -d synthesizer ]]; then
    cd synthesizer;
fi;

if [[ ! -f pom.xml ]]; then
    echo "Please navigate to the root of the LooPy repository before running this script.";
    exit 1;
fi;

# First, recompile
START_TIME=$SECONDS
export MAVEN_OPTS="-Xmx14G";
echo -ne "Compiling:\t";
if BUILD_RESULTS=$(mvn clean compile -DskipTests); then
    echo "OK ("$(($SECONDS - $START_TIME))"s)";
    loopy_test 'BenchmarksCSV' 'mvn exec:java -Dexec.mainClass="edu.ucsd.snippy.BenchmarksCSV" -Dexec.args="cond_benchmarks 2"' 'cond_benchmarks' 12;
    loopy_test 'NoCFBenchmarks' 'mvn exec:java -Dexec.mainClass="edu.ucsd.snippy.NoCFBenchmarks" -Dexec.args="1"' 'json' 61;
    loopy_test 'IterSelectionBenchmarks' 'mvn exec:java -Dexec.mainClass="edu.ucsd.snippy.IterSelectionBenchmarks" -Dexec.args="2 1 1"' '_' 46;
    loopy_test 'SimBenchmarksCSV' 'mvn exec:java -Dexec.mainClass="edu.ucsd.snippy.SimBenchmarksCSV" -Dexec.args="cond_benchmarks 2"' 'cond_benchmarks' 12;
else
    echo "Compiling the synthesizer failed:";
    echo "$BUILD_RESULTS";
fi;

cd $CURR_DIR;
