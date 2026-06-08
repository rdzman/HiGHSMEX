#!/usr/bin/env bash

# removing previous container
docker rm -f highs-container 2>/dev/null || true
# building highsmex.mexa64
docker build --progress=plain -t highs-builder build
# renaming container
docker create --name highs-container highs-builder
# copy highsmex.mexa64 to repository
docker cp highs-container:/root/HiGHSMEX/highsmex.mexa64 ./highsmex.mexa64
# remove container
docker rm -f highs-container