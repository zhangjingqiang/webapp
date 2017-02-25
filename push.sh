#!/bin/sh

LC=$(git rev-parse --short HEAD)
docker build -t zhangjingqiang/webapp:${LC} .
docker push zhangjingqiang/webapp:${LC}
