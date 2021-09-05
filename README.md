# LooPy

The source code for LooPy, the tool created for the OOPSLA 2021 paper "LooPy: Interactive Program Synthesis with Control Structures".

This is a meta-repository containing the instructions, build scripts, and necessary submodules to build a version of LooPy ready to run locally.

## Content
1. [Modules](#modules)
2. [Setup](#setup)
3. [Building](#building)
4. [Running](#running)
5. [Benchmarks](#benchmarks) 
6. [Programming Tasks](#programming-tasks)

## Modules
This repository is meant for simplifying the process of building LooPy, and is really just the following two repositories:

### Synthesizer
This repository contains the Enumerative Synthesizer that powers LooPy. It is an implementation of bottom-up enumerative synthesis with observational equivalence with control structures.

### VS Code
This repository is a fork of Microsoft's [VS Code Repository](https://github.com/microsoft/vscode) modified to include [Projection Boxes](https://cseweb.ucsd.edu/~lerner/papers/projection-boxes-chi2020.pdf) with LooPy support.

## Setup
To get these submodules, you can run the following git command:

``` sh
git submodule update --init --remote
```

After that, please make sure that the `vscode` and `synthesizer` exist and have files in them. 

Note that this is only for convenience, and as long as you have both repos checked out with the same directory structure (both under the same root) everything else here should still work.

The build scripts provided in this repo assume that certain applications are installed and exist on the `PATH`.

For building/running VS Code and the Projection Boxes, you need:
1. [NodeJS 14](https://nodejs.org/en/)
2. [Yarn](https://yarnpkg.com/)
3. [Python 3](https://www.python.org/downloads/)

For building/running the synthesizer, you need:
1. [Java >= 11](https://www.oracle.com/java/technologies/javase-downloads.html#JDK11)
2. [Maven](https://maven.apache.org/) 

## Building

> tldr; On Unix-like operating systems, you can build both modules by running
> 
> ``` sh
> ./scripts/build.sh
> ```

To build VS Code, you first need to get the necessary node modules, then compile the source to the javascript files:

``` sh
cd vscode;
yarn;
yarn compile;
cd ../;
```

To build the synthesizer and wrap it in an executable Jar file, you can just run:

``` sh
cd synthesizer;
mvn clean package -Plocal -DskipTests;
cd ../;
```

The `-Plocal` packages it for the local non-browser build, since LooPy currently doesn't work with the browser-based editor. 

This repo also includes a `build.sh` script that does both for you. :)

## Running

> tldr; On Unix-like operating systems, you can run LooPy using the script 
> 
> ``` sh
> ./scripts/vscode.sh
> ```

To use LooPy, you need to run this custom build of `vscode`, but it requires a set of environment variables to be correctly set before it works:

1. `SNIPPY_UTILS`: Absolute path to `vscode/src/snippy.py`
2. `RUNPY`: Absolute path to `vscode/src/run.py`
3. `IMGSUM`: Absolute path to `vscode/src/img-summary.py`
4. `SYNTH`: Absolute path to `synthesizer/target/snippy-server-0.1-SNAPSHOT-jar-with-dependencies.jar`
5. `PYTHON3`: Absolute path to your `python3` executable.
6. `JAVA`: Absolute path to your `java` executable.

You can also optionally set these environment variables:
1. `LOG_DIR`: Absolute path to where you would like the logs to be stored. By default, the operating system's temporary directory is used.
2. `HEAP`: Value for Java's `-Xmx` argument for the synthesizer. By default, nothing is used.

Once these are set, you can run LooPy with the `vscode/scripts/code` script for your operating system. 

e.g. in Bash, you can run LooPy using this command:

``` sh
cd vscode;
SNIPPY_UTILS=./src/snippy.py RUNPY=./src/run.py IMGSUM=./src/img-summary.py PYTHON3=$(which python3) JAVA=$(which java) SYNTH='../synthesizer/target/snippy-server-0.1-SNAPSHOT-jar-with-dependencies.jar' ./scripts/code.sh;
```

## Benchmarks

We have also provided scripts for running the benchmarks used to create the figures in the paper. You can find these in the same `scripts/` directory as above, with each figure having its own script.

By default, these scripts limit the JVM heapsize to 14 Gb. To replicate the results from the paper, we recommend increasing this to at least 24 Gb, by modifying the `-Xmx` maven option in those scripts.

## Programming Tasks

You can find the programming tasks used in the User Study in the `synthesizer/programming_tasks` directory.
