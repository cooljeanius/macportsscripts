#!/bin/bash
# Fetches all the dependencies of a port

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

for i in `port -q rdeps $1`
do
	port fetch $i &
done
