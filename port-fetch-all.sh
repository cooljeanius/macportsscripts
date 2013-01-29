#!/bin/bash
if [ $# -ne 1 ]
then
	echo "Usage: `basename $0` PORTNAME"
	echo "To fetch all dependencies for a port"
	exit 1
fi

for i in `port -q rdeps $1`
do
	port fetch $i &
done
