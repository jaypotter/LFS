#!/bin/sh
docker build . -t lfs
docker run --privileged -it lfs
