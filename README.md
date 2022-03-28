# LooPy

The source code for LooPy, the tool created for the OOPSLA 2021 paper [LooPy: Interactive Program Synthesis with Control Structures](https://dl.acm.org/doi/10.1145/3485530).

This is a meta-repository containing the instructions, build scripts, and necessary submodules to build a version of LooPy ready to run locally.  

## Content
1. [Modules](#modules)
   - [Synthesizer](#synthesizer)
   - [VS Code](#vs-code)
2. [Setup](#setup)
3. [Building](#building)
4. [Running](#running)
5. [Benchmarks](#benchmarks) 
6. [Programming Tasks](#programming-tasks)
7. [F.A.Q.](#faq)

## Modules
This repository is meant for simplifying the process of building LooPy, and is really just the following two repositories:

### Synthesizer
This repository contains the Enumerative Synthesizer that powers LooPy. 
It is an implementation of bottom-up enumerative synthesis with observational equivalence with control structures.

It is a pretty straightforward (I hope) Maven project that compiles a combination Java/Scala codebase.
Some files/directories of note are:

- `src/main/scala/edu/ucsd/snippy/Snippy.scala`: The "main" file for the synthesizer, which defines multiple functions for running the synthesizer and getting a result.
- `src/main/scala/edu/ucsd/snippy/ast`: The package containing LooPy's grammar, implemented as separate classes. The `vocab` package uses the classes from this package to define the list of components that LooPy uses.
- `src/main/scala/edu/ucsd/snippy/eumeration`: The "simple" enumerators that, given a single context, enumerate all programs. This is in contrast to...
- `src/main/scala/edu/ucsd/snippy/solution`: ...the "solution" enumerators, that use various strategies for initializing, running and combining the results of multiple "simple" enumerators to create the complete solution.
- `src/main/java/edu/ucsd/snippy/parse`: An ANTLR parser in Java for Python. We use this to read the Python values from the synthesis task specifications.

### VS Code
This repository is a fork of Microsoft's [VS Code Repository](https://github.com/microsoft/vscode) modified to include [Projection Boxes](https://cseweb.ucsd.edu/~lerner/papers/projection-boxes-chi2020.pdf) with LooPy support.

To work with this codebase, a quick understanding of how Projection Boxes work can be helpful. 
"Projection Boxes" is a live programming environment for Python, and works by running the Python code in the background,
logging all the variable values at every point in the program into a JSON file, and visualizing that JSON file inside of VSCode.

It does this by copying your current python file to a file named `tmp.py` in the operating system's Temp directory (I will use `/tmp/tmp.py` here since that's the one for Linux, but this can be different based on your operating system. I think the Windows and MacOS ones are user-dependent).
It then runs `src/run.py` on that file:
``` sh
python3 src/run.py /tmp/tmp.py
```
to get the JSON file, written to `/tmp/tmp.py.out`.
And finally, it tries to read that file to visualize it.

Note that you need to provide the paths to `run.py`, your `python3` executable, etc. to Projection Boxes by setting certain environment variables. More on that [here](#running).

Finally, some files/directories of note are:
- `src/vs/editor/contrib/rtv/RTVDisplay.ts`: This is the "main" file for Projection Boxes. It registers it as a contribution to VSCode, runs the program, and creates the boxes. The `runProgram` function is a good place to start for understanding how Projection Boxes work.
- `src/vs/editor/contrib/rtv/RTVSynth.ts`: This file contains most of the logic for handling synthesis. Upon recognizing the `??` input, `RTVDisplay`'s code calls the `startSynthesis` function in this file, which handles the interaction from there until `stopSynthesis`. 
- `src/vs/editor/contrib/rtv/RTVUtils.ts`: A utilities file meant to be the interface between Projection Boxes/LooPy and the operating system. Since this code is vastly different between the local and browser version, we have two `RTVUtils` files which implement the same interface for each. This file implements the local version by reading the environment variables to get the file locations, going through the process of running the code as described above, and communicating with the synthesizer. 

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

## FAQ
> Building VSCode fails with the error message:
> ```
> gyp: name 'openssl_fips' is not defined while evaluating condition 'openssl_fips != ""' in binding.gyp while trying to load binding.gyp
> ```

This is because `openssl_fips` was deprecated, and the latest version of `node-gyp` does not include it. To fix this, 
please **uninstall your current version of node-gyp**, then manually install the latest version of `node-gyp` that still supports that variable. e.g.
```sh
yarn global add node-gyp@8.4.1
```

> VSCode builds and runs, but the Projection Boxes are empty, don't update, or show a `no such file temp.py.out` error.

This is probably because it cannot create/update the output file (as described [here](#vs-code)), and could have one of many causes. To debug this, first run it manually to see if that works:
``` sh
python3 src/run.py <your python file>
```
If that works without any errors and creates a corresponding `<your python file>.out` file, then make sure that the environment variables were set correctly, and use the _absolute path_ to the various files.
You can inspect those by opening the developer tools inside VSCode, and using the terminal to run `process.env[<variable name>]` for each of the variables.

