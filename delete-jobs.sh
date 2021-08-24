#!/bin/bash
qstat -u $(whoami) | grep -e '\sR\s' -e '\sQ\s' | awk '{print $1}' | sed 's/\..*//' | xargs qdel
# qstat -u $(whoami) | grep -e '\sR\s' -e '\sQ\s' | awk '{print $1}' | xargs -I ID qdel IDpace.gatech.edu
