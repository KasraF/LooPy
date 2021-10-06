#!/usr/bin/env bash

if [[ ! -d vscode ]]; then
    echo "vscode directory not found. Did you initialize the submodules?";
	exit 1;
elif [[ ! -d monaco-editor ]]; then
    echo "monaco-editor directory not found. Did you initialize the submodule?";
	exit 1;
elif [[ ! -d server ]]; then
    echo "server directory not found. Did you initialize the submodules?";
	exit 1;
fi;

echo -n 'Building vscode... ';
cd vscode;
yarn &> ../build.log && yarn compile &>> ../build.log && yarn run gulp editor-distro &>> ../build.log;
cd ../;
echo 'Done!';

echo -n 'Building monaco-editor... ';
cd monaco-editor;
yarn release &>> ../build.log;
cd ../;
echo 'Done!';

echo -n 'Building server... ';
cd server;
mvn clean package -Pserver &>> ../build.log;
cd ../;
echo 'Done!';
