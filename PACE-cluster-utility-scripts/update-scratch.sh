#!/bin/bash
## Updates timestamps on all files in Scratch.
for file in $(cat SCRATCH.TO.BE.DELETED | sed "s/'//g"); do touch $file; ls -l $file; done
