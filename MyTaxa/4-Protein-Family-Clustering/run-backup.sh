#!/bin/bash
mkdir -p backup
ls | grep -v '^DB' | grep -v '.gz$' | xargs -I {} cp {} backup
