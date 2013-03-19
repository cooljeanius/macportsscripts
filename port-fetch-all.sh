#!/bin/bash
# Fetches all the dependencies of a port
# This was the original script that made up phw's original macportsscripts port.

if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` PORTNAME"
	echo "To fetch all dependencies for a port"
	exit 1
fi

if [ -z "`which port`" ]; then
    echo "MacPorts not found, this script is primarily for use with MacPorts."
    exit 0
fi

export MP_PREFIX=$(dirname $(dirname `which port`))
if [ -z "$MP_PREFIX" ]; then
	export MP_PREFIX=/opt/local
fi

for i in $(port -q rdeps $1 | tr -d [:blank:] | tr \\n \ )
do
	port -v checksum $i
# The call to "sleep" is to prevent this script from becoming a forkbomb
	sleep 1
done
