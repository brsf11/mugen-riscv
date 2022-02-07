#! /bin/bash

    sleep 60s
    pid=`ps -ef | grep "netdata -D" | grep -v grep | awk '{print $2}'`
    kill $pid
