#!/macports/bin/bash

declare prefix=${2:-"/macports"}

(   cd  $( dirname ${0} )

declare -a info=( $( find "${prefix}"/var/macports/sources/rsync.macports.org/release/ports -iname "${1}" | tr '/' ' ' ) )
declare portName=${info[$(( ${#info[@]}-1 ))]}
declare portCategory=${info[$(( ${#info[@]}-2 ))]}

mkdir -p portfiles/${portCategory}/${portName}
cp ${prefix}/var/macports/sources/rsync.macports.org/release/ports/${portCategory}/${portName}/Portfile \
   portfiles/${portCategory}'/'${portName}/'Portfile.orig'

) ; wait
