#!/macports/bin/bash
# This script was taken from https://trac.macports.org/wiki/howto/AdvancedDailyAdm
# I should probably update it to work with prefixes other than "/macports"

#
# usage:
# ${1}: the macports install path
#

(   cd  $( dirname ${0} )

echo -e "\n"'+----------------+'
echo        '| macportsupdate |'
echo        '+----------------+'

declare installPath=${1:-'/macports'}
declare rsyncMacportsOrg='/var/macports/sources/rsync.macports.org/release/ports'

echo    "selfupdating & syncing all repositories"
${installPath}/bin/port -d selfupdate
cp -Rv  newPorts/_resources \
        ${installPath}${rsyncMacportsOrg}

echo -e "\ncopy additional files to the ports"
for filesDir in $(find portfiles -type d -name 'files')
do
    mkdir -p ${installPath}${rsyncMacportsOrg}/${filesDir#*portfiles/}
    cp -Rv ${filesDir}/* \
           ${installPath}${rsyncMacportsOrg}/${filesDir#*portfiles/}
done

echo -e "\npatching the portfiles"
for portPatch in $(find portfiles -type f -name 'patch-Portfile')
do
    patchFile=$( sed -En -e '1,1p' ${portPatch} | tr -s "\t" " " | cut -f2 -d ' ' )
    patch -u <${portPatch} ${patchFile}
done

echo ''
${installPath}/bin/port outdated

echo -e "\nupgrading the outdated ports"
for outDated in $(${installPath}/bin/port outdated | sed -e '1,1d' | tr -s " \t" | cut -f 1 -d ' ')
do 
    ${installPath}/bin/port -cuRp upgrade ${outDated}
done


echo -e "\nremoving macport saved files"
find ${installPath} -iname *.mpsaved -delete
find ${installPath} -iname *.mp_* -delete

echo -e "\nremoving inactive ports"
${installPath}/bin/port installed | sed -e '1,1d' -e '/active/d' | xargs -n2 ${installPath}/bin/port uninstall

) ; wait
