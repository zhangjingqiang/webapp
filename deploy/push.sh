#!/bin/sh
set -x

LC=$(git rev-parse --short HEAD)
docker build -t zhangjingqiang/webapp:${LC} .
docker push zhangjingqiang/webapp:${LC}
kubectl set image deployment webapp webapp=zhangjingqiang/webapp:${LC}
