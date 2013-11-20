#!/bin/bash
# This script was taken from https://trac.macports.org/wiki/Scripts/Point_Cloud_Library_1.5.1_script

# references:
# - http://www.pointclouds.org/about.html
# - http://www.pointclouds.org/downloads/
# - http://pointclouds.org/downloads/macosx.html
# - http://dev.pointclouds.org/projects/pcl/wiki/How_to_create_DMG_installers
# - http://pointclouds.org/documentation/tutorials/compiling_pcl_macosx.php
# - http://pointclouds.org/documentation/tutorials/building_pcl.php#building-pcl
# - http://www.kammerl.de/pcl/

# To reduce heat generation consider to increase fan rpm values by using smcFanControl 2.3, http://www.eidac.de/?p=207.
# smcFanControl is just an application.
# smcFanControl installs no permanent background processes or daemons.
# smcFanControl does NOT let you set a minimum speed to a value below Apple's defaults.
# To uninstall it, just drag it into the trash.

if [ "$(whoami)" != "root" ]; then
	sudo -H -i
fi

if [ ! -x /usr/local/bin/testport ]; then
    echo "This script requires the testport script to be installed as /usr/local/bin/testport"
    exit 1
fi

# cf. https://trac.macports.org/wiki/Scripts/testport_script
/usr/local/bin/testport -p -l /opt/macports-test-universal
export PATH="/opt/macports-test-universal/bin:/opt/macports-test-universal/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
alias testport='/usr/local/bin/testport'

export LC_ALL=C 

# clang-3.2 +universal
testport -l /opt/macports-test-universal clang-3.2 +universal configure.cc='/usr/bin/llvm-gcc-4.2' configure.cxx='/usr/bin/llvm-g++-4.2'


# MacPorts: tar: Write error: Broken pipe
# --->  Installing llvm-3.0 @3.0_4+universal
# Error: Target org.macports.install returned: shell command failed (see log for details)
# Error: Failed to install llvm-3.0
# Log for llvm-3.0 is at: /opt/macports-test-universal/var/macports/logs/_opt_macports-test-universal_var_macports_sources_rsync.macports.org_release_tarballs_ports_lang_llvm-3.0/llvm-3.0/main.log
#
# port log llvm-3.0
#    ...
#    :info:install bzip2/libbzip2: internal error number 1007.
#    ...
#    :info:install *** A special note about internal error number 1007 ***
#    ...
#    :info:install tar: Write error: Broken pipe
#    :info:install shell command " cd "/opt/macports-test-universal/var/macports/build/_opt_macports-test-universal_var_macports_sources_rsync.macports.org_release_tarballs_ports_lang_llvm-3.0/llvm-3.0/work/destroot" && /usr/bin/tar -cvf - . | /usr/bin/bzip2 -c9 > /opt/macports-test-universal/var/macports/software/llvm-3.0/llvm-3.0-3.0_4+universal.darwin_10.i386-x86_64.tbz2 " returned error 3
#    :error:install Target org.macports.install returned: shell command failed (see log for details)
#    ...

cd "$(port dir llvm-3.0)"/work/destroot
/usr/bin/tar -cvf - . | /usr/bin/bzip2 -c9 > /opt/macports-test-universal/var/macports/software/llvm-3.0/llvm-3.0-3.0_4+universal.darwin_10.i386-x86_64.tbz2 

# redo: clang-3.2 +universal
testport -l /opt/macports-test-universal clang-3.2 +universal configure.cc='/usr/bin/llvm-gcc-4.2' configure.cxx='/usr/bin/llvm-g++-4.2'


# MacPorts: tar: Write error: Broken pipe  (when installing llvm-3.2)
# ...
#cd "$(port dir llvm-3.2)"/work/destroot
#/usr/bin/tar -cvf - . | /usr/bin/bzip2 -c9 > /opt/macports-test-universal/var/macports/software/llvm-3.2/llvm-3.2-3.2-r157234_0+assertions+universal.darwin_10.i386-x86_64.tbz2 
#
# alternative to tar ... | bzip2 ...
#llvmdir='/opt/macports-test-universal/var/macports/software/llvm-3.2'
#tar -cvf "${llvmdir}/llvm-3.2.tar" .
#/usr/bin/bzip2 -c9 "${llvmdir}/llvm-3.2.tar" > "${llvmdir}/llvm-3.2-3.2-r157234_0+assertions+universal.darwin_10.i386-x86_64.tbz2"
#rm -v "${llvmdir}/llvm-3.2.tar"
#
# redo: clang-3.2 +universal
#testport -l /opt/macports-test-universal clang-3.2 +universal configure.cc='/usr/bin/llvm-gcc-4.2' configure.cxx='/usr/bin/llvm-g++-4.2'


# glib2 +universal
testport -l /opt/macports-test-universal glib2 +universal configure.cc='/usr/bin/llvm-gcc-4.2' configure.cxx='/usr/bin/llvm-g++-4.2'


# apple-gcc42 +universal
# gcc47 +universal
# gcc48 +universal
[[ -L '/usr/include/malloc.h' ]] && sudo mv -iv /usr/include/malloc.h /usr/include/malloc.h.moved
testport -l /opt/macports-test-universal apple-gcc42 +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'
testport -l /opt/macports-test-universal gcc47 +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'
testport -l /opt/macports-test-universal gcc48 +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'



# cmake +universal
testport -l /opt/macports-test-universal cmake +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'

# boost +universal
testport -l /opt/macports-test-universal boost +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'


# doxygen +universal
testport -l /opt/macports-test-universal doxygen +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'


# Error: You cannot install gd2 for the architecture(s) x86_64 i386 because
# Error: its dependency fontconfig only contains the architecture(s) x86_64.
# cf. "Error: Failed to install fontconfig", https://trac.macports.org/ticket/30329
# Non-fat file: /opt/macports-test-universal/lib/libfontconfig.dylib is architecture: x86_64
# Architectures in the fat file: /opt/macports-test-universal/lib/libfontconfig.dylib are: i386 x86_64 
# lipo -info /opt/macports-test-universal/lib/*.dylib | grep -i 'Non-fat file'
port -v installed pkgconfig libiconv expat freetype libiconv fontconfig
lipo -info /opt/macports-test-universal/lib/libfontconfig.dylib
port -n upgrade --force fontconfig +universal


# gd2 +universal
port clean --all gd2
testport -l /opt/macports-test-universal gd2 +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'

# netpbm +universal
testport -l /opt/macports-test-universal netpbm +universal configure.cc='/usr/bin/llvm-gcc-4.2' configure.cxx='/usr/bin/llvm-g++-4.2'

# graphviz +universal
port clean --all graphviz
testport -l /opt/macports-test-universal graphviz +universal configure.cc='/usr/bin/gcc-4.2' configure.cxx='/usr/bin/g++-4.2'


# redo: doxygen +universal
#testport -c -l /opt/macports-test-universal doxygen +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'
testport -l /opt/macports-test-universal doxygen +universal configure.cc='/usr/bin/llvm-gcc-4.2' configure.cxx='/usr/bin/llvm-g++-4.2'



# flann (not universal!)
testport -l /opt/macports-test-universal  flann  configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'


# py27-sphinx +universal
testport -l /opt/macports-test-universal  py27-sphinx +universal  configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'


# google-test +universal
# port info google-test
# google-test @1.5.0 (devel) (May 2012)
# googletest version >= 1.6.0 (http://code.google.com/p/googletest/)
# Google's framework for writing C++ tests on a variety of platforms. Used to build test units.
# testport -l /opt/macports-test-universal  google-test +universal  configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'


# eigen3 +universal
# qhull +universal
# libusb-devel +universal

export IFS=$' \t\n'
for portname in eigen3 qhull libusb-devel; do
   printf '\n\n%s\n\n' "testport -l /opt/macports-test-universal  ${portname} +universal  configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'"
   testport -l /opt/macports-test-universal  "${portname}" +universal  configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'
done



# vtk5 +universal+x11
port variants vtk5
testport -l /opt/macports-test-universal  vtk5 +universal+x11  configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'

# sudo port select --set python python27
# sudo port load rsync



# opencv +universal+python27
#testport -l /opt/macports-test-universal ffmpeg +universal
testport -l /opt/macports-test-universal ffmpeg-devel +universal configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'
testport -l /opt/macports-test-universal opencv +universal+python27 configure.cc='/opt/macports-test-universal/bin/clang-mp-3.2' configure.cxx='/opt/macports-test-universal/bin/clang++-mp-3.2'



# OpenNI
# install OpenNI in /usr/local-pcl
# https://github.com/OpenNI/OpenNI/

export PATH="/opt/macports-test-universal/bin:/opt/macports-test-universal/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
cd /Users/${SUDO_USER}/Downloads || exit
[[ ! -f OpenNI.zip ]] && { curl -L -o OpenNI.zip https://github.com/OpenNI/OpenNI/zipball/master || exit; }
rm -rf ./*OpenNI-*
unzip -qq OpenNI.zip
cd ./*OpenNI-*/Platform/Linux*/CreateRedist/
chmod +x RedistMaker 
export CC='/opt/macports-test-universal/bin/clang-mp-3.2' CXX='/opt/macports-test-universal/bin/clang++-mp-3.2'
export CFLAGS='-I/opt/macports-test-universal/include' LDFLAGS='-L/opt/macports-test-universal/lib'  
./RedistMaker 
cd ../Redist/OpenNI*
export X86_CXX=/opt/macports-test-universal/bin/clang++-mp-3.2
export X86_STAGING=/usr/local-pcl
chmod +x install.sh

cat <<-'EOF' | ed -s install.sh
H
/printf "copying shared libraries..."/a
mkdir -p $INSTALL_LIB
.
/printf "copying executables..."/a
mkdir -p $INSTALL_BIN
.
wq
EOF

./install.sh -c "${X86_STAGING}"


# sanitize .dylib install names
otool -L /usr/local-pcl/usr/lib/*
find /usr/local-pcl -type f -name "*.dylib" -print0 | while IFS="" read -r -d "" dylibpath; do
   echo install_name_tool -id "$dylibpath" "$dylibpath"
   install_name_tool -id "$dylibpath" "$dylibpath"
done | nl


otool -L /usr/local-pcl/usr/bin/* /usr/local-pcl/usr/lib/*
find /usr/local-pcl/usr/bin /usr/local-pcl/usr/lib -type f -print0 | xargs -0 otool -L | grep '\.\./\.\./' | sort -u

find /usr/local-pcl/usr/bin /usr/local-pcl/usr/lib -type f -print0 | while IFS="" read -r -d "" file; do
   old='../../Bin/x64-Release/libOpenNI.dylib'
   new='/usr/local-pcl/usr/lib/libOpenNI.dylib'
   sudo install_name_tool -change "$old" "$new" "$file"
done



dos2unixdir() {

crchar="$(printf "\r")"
grep -Ilsr -m 1 -Z -e "${crchar}" . | 
   xargs -0 -n 1 /bin/sh -c '
      crchar="$(printf "\r")"
      echo "crchar: ${1}"
      printf "%s\n" H ",g/${crchar}*$/s///g" wq | /bin/ed -s "${1}"
   ' argv0

return 0

}


# Sensor
# PrimeSensor Modules for OpenNI
# https://github.com/PrimeSense/Sensor

export PATH='/opt/macports-test-universal/bin:/opt/macports-test-universal/sbin:/usr/local-pcl/bin:/usr/bin:/bin:/usr/sbin:/sbin'

cd /Users/${SUDO_USER}/Downloads || exit
[[ ! -f Sensor.zip ]] && { curl -L -o Sensor.zip https://github.com/PrimeSense/Sensor/zipball/master || exit; }
rm -rf ./*Sensor-*
unzip -qq Sensor.zip
cd PrimeSense-Sensor-*
dos2unixdir
cd ../PrimeSense-Sensor-*/Platform/Linux/CreateRedist
export CC='/opt/macports-test-universal/bin/clang-mp-3.2' CXX='/opt/macports-test-universal/bin/clang++-mp-3.2'
export CFLAGS='-I/usr/include -I/opt/macports-test-universal/include -I/usr/local-pcl/usr/include -I/usr/local-pcl/usr/include/ni' LDFLAGS='-L/opt/macports-test-universal/lib -L/usr/local-pcl/usr/lib'  
xattr -d com.apple.quarantine RedistMaker

# remove -j option to make command in RedistMaker file
printf '%s\n' H '/-j$(calc_jobs_number)/s///' wq | ed -s RedistMaker

./RedistMaker 

cd ../Redist/Sensor-Bin-MacOSX-*
export X86_CXX=/opt/macports-test-universal/bin/clang++-mp-3.2
export X86_STAGING=/usr/local-pcl
chmod +x install.sh
./install.sh -c "${X86_STAGING}"


# sanitize .dylib install names

otool -L /usr/local-pcl/usr/bin/* /usr/local-pcl/usr/lib/*
find /usr/local-pcl/usr/lib /usr/local-pcl/usr/bin -type f -print0 | xargs -0 otool -L | grep '\.\./\.\./' | sort -u

find /usr/local-pcl/usr/lib /usr/local-pcl/usr/bin -type f -print0 | while IFS="" read -r -d "" file; do

   old1='../../Bin/x64-Release/libOpenNI.dylib'
   new1='/usr/local-pcl/usr/lib/libOpenNI.dylib'

   old2='../../Bin/x64-Release/libXnCore.dylib'
   new2='/usr/local-pcl/usr/lib/libXnCore.dylib'

   old3='../../Bin/x64-Release/libXnDDK.dylib'
   new3='/usr/local-pcl/usr/lib/libXnDDK.dylib'

   old4='../../Bin/x64-Release/libXnDeviceFile.dylib'
   new4='/usr/local-pcl/usr/lib/libXnDeviceFile.dylib'

   old5='../../Bin/x64-Release/libXnDeviceSensorV2.dylib'
   new5='/usr/local-pcl/usr/lib/libXnDeviceSensorV2.dylib'

   old6='../../Bin/x64-Release/libXnFormats.dylib'
   new6='/usr/local-pcl/usr/lib/libXnFormats.dylib'

   sudo install_name_tool -change "$old1" "$new1" -change "$old2" "$new2" -change "$old3" "$new3" -change "$old4" "$new4" -change "$old5" "$new5" -change "$old6" "$new6" "$file"

done


# sanitize .dylib install names
find /usr/local-pcl -type f -name "*.dylib" -print0 | while IFS="" read -r -d "" dylibpath; do
   echo install_name_tool -id "$dylibpath" "$dylibpath"
   install_name_tool -id "$dylibpath" "$dylibpath"
done | nl


otool -L /usr/local-pcl/usr/bin/* /usr/local-pcl/usr/lib/*


# not needed anymore
# cminpack 1.2.2 (in /usr/local-pcl)
# http://devernay.free.fr/hacks/cminpack/index.html
curl -L -O http://devernay.free.fr/hacks/cminpack/cminpack-1.2.2.tar.gz
rm -rf cminpack-1.2.2
tar -xf cminpack-1.2.2.tar.gz
cd cminpack-1.2.2
mkdir build
cd build
cmake -DUSE_FPIC=ON -DSHARED_LIBS=ON -DBUILD_EXAMPLES=OFF -DCMAKE_INSTALL_PREFIX=/usr/local-pcl ..
make
sudo make install
otool -L /usr/local-pcl/lib/libcminpack.dylib
sudo install_name_tool -id /usr/local-pcl/lib/libcminpack.1.0.90.dylib /usr/local-pcl/lib/libcminpack.1.0.90.dylib


# PCL 1.5.1 (2012.02.22)
# http://www.pointclouds.org/downloads/
cd /Users/${SUDO_USER}/Downloads
[[ ! -f 'PCL-1.5.1-Source.tar.bz2' ]] && curl -L -O http://www.pointclouds.org/assets/files/1.5.1/PCL-1.5.1-Source.tar.bz2
rm -rf PCL-1.5.1-Source
tar -xf PCL-1.5.1-Source.tar.bz2
cd PCL-1.5.1-Source
#dos2unixdir
export PATH='/opt/macports-test-universal/bin:/opt/macports-test-universal/sbin:/usr/local-pcl/bin:/usr/local-pcl/sbin:/usr/bin:/bin:/usr/sbin:/sbin'
mkdir build
cd build

# error: no member named 'at' in namespace 'pcl::io::ply' fixed in PCL 1.6
# see: http://www.pcl-users.org/Couldn-t-install-with-Homebrew-td4000766.html and 
#        http://dev.pointclouds.org/projects/pcl/repository/revisions/4918

# all three variants below did cause build / compiler (gcc) errors in the make build phase on Mac OS X 10.6.8
###env CC=/opt/macports-test-universal/bin/clang-mp-3.2 CXX=/opt/macports-test-universal/bin/clang++-mp-3.2 \
###env CC=/opt/macports-test-universal/bin/gcc-mp-4.7 CXX=/opt/macports-test-universal/bin/g++-mp-4.7 \
###env CC=/opt/macports-test-universal/bin/gcc-mp-4.8 CXX=/opt/macports-test-universal/bin/g++-mp-4.8 \

#env CC=/usr/bin/gcc-4.2 CXX=/usr/bin/g++-4.2 \
env CC=/opt/macports-test-universal/bin/gcc-apple-4.2 CXX=/opt/macports-test-universal/bin/g++-apple-4.2 \
  cmake -DCMAKE_PREFIX_PATH='/opt/macports-test-universal:/usr/local-pcl/usr' -DOPENNI_INCLUDE_DIR=/usr/local-pcl/usr/include/ni \
         -DOPENNI_LIBRARY=/usr/local-pcl/usr/lib/libOpenNI.dylib -DCMAKE_INSTALL_PREFIX=/usr/local-pcl ..


# edit cmake_install.cmake files:  "lib..*\.dylib"  -->  "${CMAKE_INSTALL_PREFIX}/lib/lib..*\.dylib"
printf '\n\n%s\n\n' "${PWD}: install_name_tool search & replace:   \"lib..*.dylib\"   -->   \"\${CMAKE_INSTALL_PREFIX}/lib/lib..*.dylib\""
egrep -Ilsr -Z -e 'install_name_tool' . | xargs -0 egrep -Ils '"lib..*\.dylib"' | nl

egrep -Ilsr -Z -e 'install_name_tool' . | 
   xargs -0 egrep -Ils -Z '"lib..*\.dylib"' |
   xargs -0 -n 1 /bin/sh -c 'printf "%s\n" H "g/\"\(lib..*\.dylib\)\"/s||\"\${CMAKE_INSTALL_PREFIX}/lib/\1\"|g" wq | /bin/ed -s "${1}"' argv0

# for use with gcc-mp-4.7 / g++-mp-4.7 and gcc-mp-4.8 / g++-mp-4.8 only
###egrep -Ilsr -Z -e ' \-Wl ' . | xargs -0 -n 1 /bin/sh -c 'printf "%s\n" H "g/ \-Wl /s|| |g" wq | /bin/ed -s "${1}"' argv0

make 
make install


find -x /usr/local-pcl/usr/bin /usr/local-pcl/usr/lib /usr/local-pcl/bin /usr/local-pcl/lib -type f -print0 | xargs -0 otool -L 2>/dev/null | less
find /usr/local-pcl/usr/bin /usr/local-pcl/usr/lib /usr/local-pcl/bin /usr/local-pcl/lib -type f -print0 | xargs -0 otool -L | grep '\.\./\.\./' | sort -u

