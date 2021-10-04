#!/bin/bash

jobid=$1

while true; do sleep 5; cat dereplication.o${jobid}; echo ''; qstat -u $(whoami) | grep "${jobid}"; echo ''; done
