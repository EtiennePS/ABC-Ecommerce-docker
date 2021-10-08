#!/bin/sh

if [ "$1" = 'time' ]; then
	echo `date +"%Y-%m-%dT%H:%M:%SZ"`
else
	eval $1
fi