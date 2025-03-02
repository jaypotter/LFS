#!/bin/sh
docker build . -t step1
docker run --privileged -it step1
