#!/bin/bash

docker build -t host-result-page .

docker run -d \
  --name result-page \
  -p 80:80 \
  -v /home/user/res/:/mnt/res:ro \
   host-result-page