#!/bin/bash
# This script was taken from https://trac.macports.org/wiki/howto/AdvancedDailyAdm

if [ -z "$(which port)" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 0
fi

if [ -L "$(which port)" ]; then
	REAL_PORT=$(readlink "$(which port)")
	echo "Warning: $(which port) is a symlink to ${REAL_PORT}."
	export MP_PREFIX=$(dirname $(dirname ${REAL_PORT}))
	echo "Assuming MP_PREFIX is actually ${MP_PREFIX}."
else
	export MP_PREFIX=$(dirname $(dirname "$(which port)"))
fi


#!${MP_PREFIX}/bin/bash

if [ -z "$MP_PREFIX" ]; then
	export MP_PREFIX=/macports
# "/macports" was what was originally used in this script
fi

declare prefix=${1:-"$MP_PREFIX"}

#!${prefix}/bin/bash

declare rsyncMacportsOrg="/var/macports/sources/rsync.macports.org/release/ports"

(   cd $( dirname ${0} )

declare outputFile
declare patchFile

for port in $(find portfiles -name 'Portfile')
do
    outputFile=${port%/*}/patch-${port##*/}
    rm ${outputFile} 2>/dev/null
    diff -u \
        ${prefix}${rsyncMacportsOrg}/${port#*/} \
        ${port} \
    > ${outputFile}
    echo "created patch for ${port}"
    mv ${port} ${port}.OK
done

) ; wait
