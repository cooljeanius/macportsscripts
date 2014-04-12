#!/bin/sh

# usage: supply a port name as an argument

if [ -z "$(which port)" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 1
fi
if [ -z "$1" ]; then
	echo "Usage: $(basename $0) portname"
	exit 1
fi
if [ -z "$(port list $1)" ]; then
	echo "Error: port $1 not found"
	exit 1
fi

echo "checking to see if any of the rdeps of $1 will have to be built from source..."

for depport in `port -q rdeps $1`; do
  echo "checking distributability of ${depport}... \c"
  #TODO: stop hardcoding this path:
  tclsh /opt/local/var/macports/sources/rsync.macports.org/release/tarballs/base/portmgr/jobs/port_binary_distributable.tcl -v ${depport}
done
