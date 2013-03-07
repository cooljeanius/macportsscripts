#!/macports/bin/bash

declare prefix=${1:-"/macports"}
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