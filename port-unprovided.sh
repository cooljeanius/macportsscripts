#!/bin/sh
#TODO: Add support for different prefixes

if [ -d /opt/local ]; then
	for directory in /opt/local/*
	do
		if [ -z "`port provides ${directory}/* | grep "is not provided by a MacPorts port."`" ]; then
			echo "${directory}: no unprovided files found here"
		else
			port provides ${directory}/* | grep "is not provided by a MacPorts port."
		fi
	done
else
	echo "This script does not support alternate prefixes yet, sorry."
fi
