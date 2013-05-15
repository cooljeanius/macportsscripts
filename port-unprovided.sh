#!/bin/bash
# Lists unprovided files in your MacPorts prefix
#TODO: Add better support for different prefixes

if [ -z "`which port`" ]; then
    echo "MacPorts not found, this script is primarily for use with MacPorts."
    exit 0
fi

#TODO: Add support for multiple flags (learn how to do `case` syntax)
if [ "$1" == "--help" ]; then
	echo "Usage:"
	echo ""
	echo "--help					use this flag to display this help."
	echo "-v					use this flag to be verbose (doesn't actually work yet)."
	echo "-r					use this flag to recurse deep into your prefix."
	echo "--prefix=/placeholder/path/to/prefix	use this flag to select which prefix to use (defaults to /opt/local) (not actually implemented yet)."
	echo ""
	echo "Warning: only the first flag specified is actually recognized so far"
	echo ""
	exit 0
fi

export MP_PREFIX=$(dirname $(dirname `which port`))
if [ -z "$MP_PREFIX" ]; then
	export MP_PREFIX=/opt/local
fi

if [ -d $MP_PREFIX ]; then
	if [ "$1" == "-r" ]; then
		echo "Generating list files in prefix, this might take a while..."
		for directory in $(find ${MP_PREFIX}/* | tee /dev/tty); do
			if [ -d ${directory} ]; then
				if [ -z "$(port provides ${directory}/* | grep "is not provided by a MacPorts port.")" ]; then
					echo "${directory}: no unprovided files found here"
				else
					port provides ${directory}/* | grep "is not provided by a MacPorts port."
				fi
			fi
		done
	else
		for directory in ${MP_PREFIX}/*; do
			if [ -z "$(port provides ${directory}/* | grep "is not provided by a MacPorts port.")" ]; then
				echo "${directory}: no unprovided files found here"
			else
				port provides ${directory}/* | grep "is not provided by a MacPorts port."
			fi
		done
	fi
fi
