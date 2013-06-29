#!/bin/bash
# This script was taken from https://trac.macports.org/wiki/howto/AdvancedDailyAdm

if [ -z "`which port`" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 0
fi

if [ -L `which port` ]; then
	REAL_PORT=$(readlink `which port`)
	echo "Warning: `which port` is a symlink to ${REAL_PORT}."
	export MP_PREFIX=$(dirname $(dirname ${REAL_PORT}))
	echo "Assuming MP_PREFIX is actually ${MP_PREFIX}."
else
	export MP_PREFIX=$(dirname $(dirname `which port`))
fi


#!${MP_PREFIX}/bin/bash

if [ -z "$MP_PREFIX" ]; then
	export MP_PREFIX=/macports
# "/macports" was what was originally used in this script
fi

declare prefix=${2:-"$MP_PREFIX"}

#!${prefix}/bin/bash

(   cd  $( dirname ${0} )

if [ -z "$1" ]; then
	echo "Usage: `basename $0` portname"
	exit 1
fi
if [ -z "`port list $1`" ]; then
	echo "Error: port $1 not found"
	exit 1
fi

declare -a info=( $( find "${prefix}"/var/macports/sources/rsync.macports.org/release/ports -iname "${1}" | tr '/' ' ' ) )
declare portName=${info[$(( ${#info[@]}-1 ))]}
declare portCategory=${info[$(( ${#info[@]}-2 ))]}

mkdir -p portfiles/${portCategory}/${portName}
cp ${prefix}/var/macports/sources/rsync.macports.org/release/ports/${portCategory}/${portName}/Portfile \
   portfiles/${portCategory}'/'${portName}/'Portfile.orig'

) ; wait
