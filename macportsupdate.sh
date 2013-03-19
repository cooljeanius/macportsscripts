#!/bin/bash
# This script was taken from https://trac.macports.org/wiki/howto/AdvancedDailyAdm

#
# usage:
# ${1}: the macports install path
#

if [ -z "`which port`" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 0
fi

export MP_PREFIX=$(dirname $(dirname `which port`))

#!${MP_PREFIX}/bin/bash

if [ -z "$MP_PREFIX" ]; then
	export MP_PREFIX=/macports
# "/macports" was what was originally used in this script
fi

(   cd  $( dirname ${0} )

echo    "\n"'+----------------+'
echo        '| macportsupdate |'
echo        '+----------------+'

declare prefix=${1:-"$MP_PREFIX"}

#!${prefix}/bin/bash

declare rsyncMacportsOrg='/var/macports/sources/rsync.macports.org/release/ports'

echo    "selfupdating & syncing all repositories in ${prefix}"
installPath=${prefix}
${installPath}/bin/port -d selfupdate
if [ -d newPorts/_resources ]; then
	cp -Rv  newPorts/_resources \
        	${installPath}${rsyncMacportsOrg}
fi

echo    "\ncopy additional files to the ports"
for filesDir in $(find portfiles -type d -name 'files')
do
    mkdir -p ${installPath}${rsyncMacportsOrg}/${filesDir#*portfiles/}
    cp -Rv ${filesDir}/* \
           ${installPath}${rsyncMacportsOrg}/${filesDir#*portfiles/}
done

echo    "\npatching the portfiles"
for portPatch in $(find portfiles -type f -name 'patch-Portfile')
do
    patchFile=$( sed -En -e '1,1p' ${portPatch} | tr -s "\t" " " | cut -f2 -d ' ' )
    patch -u <${portPatch} ${patchFile}
done

echo ''
${installPath}/bin/port outdated

echo    "\nupgrading the outdated ports"
for outDated in $(${installPath}/bin/port outdated | sed -e '1,1d' | tr -s " \t" | cut -f 1 -d ' ')
do 
    ${installPath}/bin/port -cuRp upgrade ${outDated}
done


echo    "\nremoving macport saved files"
find ${installPath} -iname *.mpsaved -delete
find ${installPath} -iname *.mp_* -delete

echo    "\nremoving inactive ports"
${installPath}/bin/port installed | sed -e '1,1d' -e '/active/d' | xargs -n2 ${installPath}/bin/port uninstall

) ; wait
