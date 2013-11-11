#!/bin/bash
# This script was taken from https://trac.macports.org/wiki/howto/AdvancedDailyAdm

#
# usage:
# ${1}: the macports install path
#

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

(   cd  $( dirname ${0} )

printf  "\n"
echo        '+----------------+'
echo        '| macportsupdate |'
echo        '+----------------+'

declare prefix=${1:-"$MP_PREFIX"}

#!${prefix}/bin/bash

set -e

declare rsyncMacportsOrg='/var/macports/sources/rsync.macports.org/release/ports'

echo    "selfupdating & syncing all repositories in ${prefix}"
installPath=${prefix}
${installPath}/bin/port -d selfupdate
if [ -d newPorts/_resources ]; then
	cp -Rv  newPorts/_resources \
        	${installPath}${rsyncMacportsOrg}
fi

printf    "\ncopy additional files to the ports \n"
for filesDir in $(find portfiles -type d -name 'files')
do
    mkdir -p ${installPath}${rsyncMacportsOrg}/${filesDir#*portfiles/}
    cp -Rv ${filesDir}/* \
           ${installPath}${rsyncMacportsOrg}/${filesDir#*portfiles/}
done

printf    "\npatching the portfiles \n"
for portPatch in $(find portfiles -type f -name 'patch-Portfile')
do
    patchFile=$( sed -En -e '1,1p' ${portPatch} | tr -s "\t" " " | cut -f2 -d ' ' )
    patch -u <${portPatch} ${patchFile}
done

echo ''
${installPath}/bin/port outdated

printf    "\nupgrading the outdated ports \n"
for outDated in $(${installPath}/bin/port outdated | sed -e '1,1d' | tr -s " \t" | cut -f 1 -d ' ')
do 
    ${installPath}/bin/port -cuRp upgrade ${outDated}
done


printf    "\nremoving macport saved files \n"
# shellcheck and `find(1)`'s own warning messages conflict here w.r.t. what
# to do with the argument to `find -iname` here...
find ${installPath} -iname "*.mpsaved" -delete
find ${installPath} -iname "*.mp_*" -delete

printf    "\nremoving inactive ports \n"
${installPath}/bin/port installed | sed -e '1,1d' -e '/active/d' | xargs -n2 ${installPath}/bin/port uninstall

) ; wait
