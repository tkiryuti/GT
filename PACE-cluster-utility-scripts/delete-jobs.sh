#!/bin/bash
# Deletes all jobs in the cluster queue that are status R (running) and Q (queued) using xargs
qstat -u $(whoami) | grep -e '\sR\s' -e '\sQ\s' | awk '{print $1}' | sed 's/\..*//' | xargs qdel
