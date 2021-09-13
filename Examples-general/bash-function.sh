#!/bin/bash

## Bash function example with "return" which exits the function prematurely (via exit status 0)

func() {
	echo 'started function'
	return 0
	# Command that should not show up in output:
	echo 'exited function'
}

# Execute func
echo 'running function'
func
echo 'script after function'
