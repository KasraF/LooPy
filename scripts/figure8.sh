#!/usr/bin/env bash
set -euo pipefail

CURR_DIR=$PWD;

BENCHMARKS=(
	"cond_benchmarks"
	"frangel_github"
	"loopy_frangel_benchmarks"
	"multiple_spec_benchmarks"
	"old_benchmarks"
	"user_study_candidate_benchmarks"
	"frangel_control"
	"geeksforgeeks"
	"loopy_benchmarks"
	"multivariable_benchmarks"
	"user_study_benchmarks"
	"conala_benchmarks"
	"count_distinct_variants"
)

if [[ -d synthesizer ]]; then
    cd synthesizer;
fi;

if [[ ! -f pom.xml ]]; then
    echo "Please navigate to the root of the LooPy repository before running this script.";
    exit 1;
fi;

echo -n "Compiling... ";
if BUILD_RESULTS=$(mvn clean package -Pbenchmark -DskipTests); then
    echo "OK";
	for benchset in ${BENCHMARKS[*]}; do
		echo "Running Benchmark set: " $benchset;
		java -Xmx14G -jar target/snippy-server-0.1-SNAPSHOT-jar-with-dependencies.jar -- $benchset;
		echo;
	done;
else
    echo "Compiling the synthesizer failed:";
    echo "$BUILD_RESULTS";
fi;

cd $CURR_DIR;
