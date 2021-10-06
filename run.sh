#!/usr/bin/env bash

CURR_DIR=$(pwd);

if [[ ! -d target ]]; then
   if [[ ! -d server ]]; then
       echo "server directory not found. Did you initialize the submodules and build them first?";
       exit 1;
   fi;
   cd server;
fi;

# The environment variables
SERVER_PORT=8080

SERVER_PORT=$SERVER_PORT java -jar target/snippy-server-0.1-SNAPSHOT.jar;

cd $CURR_DIR;
