#!/bin/bash
# This script was taken from https://trac.macports.org/wiki/Avidemux/Avidemux_2.6_script_MacOSX_10.6.8

# Build avidemux 2.6 (SVN revision 7891)
#
# Project: avidemux - SVN,
# http://developer.berlios.de/svn/?group_id=1402
#
# see also:
# http://www.avidemux.org/nightly/source/
# 
# SVN 2.6.0 builds for MacOSX
# http://www.avidemux.org/smf/index.php?topic=8034.0
# http://www.avidemux.org/smf/index.php?board=5.0
# http://avidemux.dyndns.org/index.php?lang=en&subject=Avidemux&texttag=Avidemux

unset CDPATH IFS LC_ALL PATH MP_PREFIX

# set a different prefix from the normal one because this script installs a new MacPorts there
MP_PREFIX='/opt/macports-avidemux'
IFS=$' \t\n'
LC_ALL=C
PATH="${MP_PREFIX}/bin:/bin:/sbin:/usr/bin:/usr/sbin"

export IFS LC_ALL PATH MP_PREFIX

# tell tar command not to archive extended attributes (e.g. resource forks) to ._* archive members
export COPYFILE_DISABLE=true                   
# ditto; for pre Mac OS X 10.5 systems
export COPY_EXTENDED_ATTRIBUTES_DISABLED=true  

declare -rx avidemux_tmp_dir='/tmp/avidemux-svn-build' || exit 1
declare -rx avidemux_src_dir='/tmp/avidemux-svn-build/avidemux_2.6_branch_mean' || exit 1

# make sure a root shell is used
if [[ $(id -u) -ne 0 ]] || [[ "${HOME}" != '/var/root' ]]; then
   echo 'This script must be run in a root shell to prevent sudo timeout!' 1>&2
   echo 'Use: sudo -H -i' 1>&2
   exit 1
fi

# prevent idle sleep
pmset -a force sleep 0 displaysleep 0 disksleep 0

rm -rf "${avidemux_tmp_dir}"

mkdir "${avidemux_tmp_dir}" || { echo "Could not make directory: ${avidemux_tmp_dir}"; exit 1; }

cd "${avidemux_tmp_dir}" || exit 1

# do some clean-up to avoid search path issues 
# (such as linking to wrong .dylib files, including incompatible .h files, ...)
rm -rf /usr/local-avidemux
[[ -d '/opt/local' ]] && mv -iv /opt/local /opt/local-off
[[ -d '/usr/local' ]] && mv -iv /usr/local /usr/local-off
[[ -d "${MP_PREFIX}-off" ]] && { echo "directory already exists: ${MP_PREFIX}-off"; exit 1; }
[[ -d "${MP_PREFIX}" ]] && sudo mv -iv "${MP_PREFIX}" "${MP_PREFIX}-off"

# additional option to add /usr/local to valid search paths
#ln -isv /opt/macports-avidemux /usr/local  

# build custom MacPorts in ${MP_PREFIX}
# cf. http://guide.macports.org/#installing.macports.source.multiple
unset PATH
export PATH='/bin:/sbin:/usr/bin:/usr/sbin'
curl -L -O https://distfiles.macports.org/MacPorts/MacPorts-2.0.4.tar.bz2
tar -xjf MacPorts-2.0.4.tar.bz2
cd MacPorts-2.0.4 || exit 1
./configure --prefix="${MP_PREFIX}" --with-tclpackage=${MP_PREFIX}/tcl --with-applications-dir="${MP_PREFIX}/Applications"
make
make install

# dscl . -read /Users/macports
dscl . -change /Users/macports NFSHomeDirectory /opt/local/var/macports/home "${MP_PREFIX}/var/macports/home"

cd "${avidemux_tmp_dir}" || exit 1

unset PATH
export PATH="${MP_PREFIX}/bin:/bin:/sbin:/usr/bin:/usr/sbin"

port -v selfupdate

port -f install gawk
#port -f install llvm-3.1
port -f install clang-3.1
port -f install avidemux +aac+dts+lame+ogg+x264+xvid
port -f install qt4-mac
port -f install libarchive +lzma
port -f install opencore-amr

port -f uninstall avidemux

port -f uninstall gtk2
port -f install gtk3

sleep 3

cd "${avidemux_tmp_dir}" || exit 1

# download avidemux 2.6 SVN revision 7891
# cf. http://developer.berlios.de/svn/?group_id=1402
svn checkout -r 7891 http://svn.berlios.de/svnroot/repos/avidemux/branches/avidemux_2.6_branch_mean || 
   { echo "svn checkout failed (see http://developer.berlios.de/svn/?group_id=1402)."; exit 1; }


cd "${avidemux_src_dir}" || exit 1


# change owner & group of ffmpeg package to root:wheel
cd "${avidemux_src_dir}"/avidemux_core/ffmpeg_package || exit 1
for ffmpegfile in ffmpeg-0.10.2.tar.bz2; do
   ls -l "$ffmpegfile" || { echo "No ffmpeg file: ${ffmpegfile}"; exit 1; }
   tar -xf "$ffmpegfile"
   rm -f "$ffmpegfile"
   sleep 1
   chown -R root:wheel .
   sleep 1
   tar -cjf "$ffmpegfile" ffmpeg-0.10.2 || exit 1
   rm -rf ffmpeg-0.10.2
   ls -l "$ffmpegfile" || { echo "No ffmpeg file: ${ffmpegfile}"; exit 1; }
done


cd "${avidemux_tmp_dir}" || exit 1

chown -R root:wheel .

cd "${avidemux_src_dir}" || exit 1


# make sure we have: CMAKE_SYSTEM_PROCESSOR: x86_64
cat <<-'EOF' | sed '/^#/d' | ed -s avidemux_core/CMakeLists.txt
H
1a

if (CMAKE_SIZEOF_VOID_P MATCHES "8")
set(CMAKE_SYSTEM_PROCESSOR "x86_64")
set(arch "x86_64")
else()
set(CMAKE_SYSTEM_PROCESSOR "i386")
set(arch "i386")
endif()

.
wq
EOF


# edit bootStrapOsx.bash

cat <<-'EOF' | sed -e '/^#/d' -e 's/^ #/#/' | ed -s bootStrapOsx.bash
H
/\(-DCMAKE_EDIT_COMMAND\)/s|| -DCMAKE_PREFIX_PATH=/opt/macports-avidemux -DCMAKE_LIBRARY_PATH=/opt/macports-avidemux/lib -DCMAKE_INCLUDE_PATH=/opt/macports-avidemux/include \1|
/export BASE_INSTALL_DIR="opt\/local"/a

unset BASE_INSTALL_DIR
export BASE_INSTALL_DIR=/usr/local-avidemux
# use clang
#export CC="clang-mp-3.1"
#export CXX="clang++-mp-3.1"
# use verbose clang
export CC="clang-mp-3.1 -v"
export CXX="clang++-mp-3.1 -v"
export CMAKE_PREFIX_PATH=/opt/macports-avidemux
export CMAKE_LIBRARY_PATH=/opt/macports-avidemux/lib
export CMAKE_INCLUDE_PATH=/opt/macports-avidemux/include
export LDFLAGS="-arch x86_64 -L/opt/macports-avidemux/lib -headerpad_max_install_names -Wl,-framework,Cocoa"
#export LDFLAGS="-arch x86_64 -L/opt/macports-avidemux/lib -headerpad_max_install_names -framework Cocoa"
export CFLAGS="-arch x86_64 -I/opt/macports-avidemux/include -I/opt/macports-avidemux/include/gtk-3.0 -I/opt/macports-avidemux/include/glib-2.0 -I/opt/macports-avidemux/lib/glib-2.0/include -I/opt/macports-avidemux/include/cairo -I/opt/macports-avidemux/include/pango-1.0 -I/opt/macports-avidemux/include/gtk-3.0/gdk -I/opt/macports-avidemux/include/gtk-3.0/unix-print -I/opt/macports-avidemux/include/gdk-pixbuf-2.0 -I/opt/macports-avidemux/include/atk-1.0 -I/opt/macports-avidemux/include/gio-unix-2.0"
export CXXFLAGS="${CFLAGS}"

.
/cmake \$PKG/a

sleep 1
 # replace gcc option ' -shared ' with ' -dynamiclib ' in link.txt files
egrep -Ilsr -Z -e ' -shared ' . | 
   xargs -0 -n 1 /bin/sh -c 'printf "%s\n" H "g/ -shared /s// -dynamiclib /g" wq | /bin/ed -s "${1}"' argv0

sleep 1

 # edit cmake_install.cmake files:  "lib..*\.dylib"  -->  "${CMAKE_INSTALL_PREFIX}/lib/lib..*\.dylib"
printf '\n\n%s\n\n' "${BUILDDIR}: install_name_tool search & replace:   \"lib..*.dylib\"   -->   \"\${CMAKE_INSTALL_PREFIX}/lib/lib..*.dylib\""
egrep -Ilsr -Z -e 'install_name_tool' . | xargs -0 egrep -Ils '"lib..*\.dylib"' 
echo

egrep -Ilsr -Z -e 'install_name_tool' . | 
   xargs -0 egrep -Ils -Z '"lib..*\.dylib"' |
   xargs -0 -n 1 /bin/sh -c 'printf "%s\n" H "g/\"\(lib..*\.dylib\)\"/s||\"\${CMAKE_INSTALL_PREFIX}/lib/\1\"|g" wq | /bin/ed -s "${1}"' argv0

sleep 1

.
/Process buildPluginsGtk/i

 # fix:
 #   Undefined symbols for architecture x86_64:
 #     "flyASharp::download()", referenced from:
 #         vtable for flyASharp in DIA_flyAsharp.cpp.o
 #   ld: symbol(s) not found for architecture x86_64
 # see:
 # http://stackoverflow.com/questions/1693634/undefined-symbols-vtable-for-and-typeinfo-for
 # http://www.parashift.com/c++-faq-lite/strange-inheritance.html#faq-23.10

cat <<-'EDSCRIPT' | sed '/^#/d' | ed -s avidemux_plugins/ADM_videoFilters6/asharp/DIA_flyAsharp.h
H
/\([[:blank:]]*\)uint8_t.*download.*void.*/s//\1 virtual uint8_t    download(void) = 0;/
/\([[:blank:]]*\)uint8_t.*upload.*void.*/s//\1 virtual uint8_t    upload(void) = 0;/
wq
EDSCRIPT

.
/Process buildPluginsGtk/a

 # undo again
cd $TOP
cat <<-'EDSCRIPT' | sed '/^#/d' | ed -s avidemux_plugins/ADM_videoFilters6/asharp/DIA_flyAsharp.h
H
/\([[:blank:]]*\)uint8_t.*download.*void.*/s//\1uint8_t    download(void);/
/\([[:blank:]]*\)uint8_t.*upload.*void.*/s//\1uint8_t    upload(void);/
wq
EDSCRIPT

.
wq
EOF


chmod +x bootStrapOsx.bash

#./bootStrapOsx.bash
#./bootStrapOsx.bash --debug --without-qt4 --without-gtk --with-cli                # cli
#./bootStrapOsx.bash --debug --without-qt4 --with-gtk --with-plugins --with-cli    # gtk
#./bootStrapOsx.bash --debug --without-gtk --with-qt4 --with-plugins --with-cli    # qt

./bootStrapOsx.bash --debug --with-gtk --with-qt4 --with-cli --with-plugins       # cli & gtk & qt


# manual install of missing .dylib files

printf '\n%s\n\n' 'manual install of missing .dylib files'

(
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/muxers
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/audioDecoder
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/audioDevices
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/audioEncoders
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/demuxers
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/videoEncoders
mkdir -p /usr/local-avidemux/lib/ADM_plugins6/videoFilters
#mkdir -p /usr/local-avidemux/lib/ADM_plugins6/videoDecoders
)

(
cd "${avidemux_src_dir}" || exit 1
find . -name "*.dylib" | grep -i _muxers | grep -i _mx_ | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/muxers
find . -name "*.dylib" | grep -i _audioDecoders | grep -i _ad_ | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/audioDecoder
find . -name "*.dylib" | grep -i Device | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/audioDevices
find . -name "*.dylib" | grep -i _audioEncoders | grep -i _ae_ | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/audioEncoders
find . -name "*.dylib" | grep -i _demuxers | grep -i _dm_ | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/demuxers
find . -name "*.dylib" | grep -i _videoEncoder | grep -i _ve_ | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/videoEncoders
find . -name "*.dylib" | grep -i _videoFilters | grep -E -i '_hf_|_vf_' | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/videoFilters
find . -name "*.dylib" | grep -i ffmpeg | xargs -I{} cp -v {} /usr/local-avidemux/lib
#find . -name "*.dylib" | grep -i videoDecoders | grep -iv _core | xargs -I{} cp -v {} /usr/local-avidemux/lib/ADM_plugins6/videoDecoders
)


echo

# sanitize .dylib install names
find /usr/local-avidemux -type f -name "*.dylib" -print0 | while IFS="" read -r -d "" dylibpath; do
   echo install_name_tool -id "$dylibpath" "$dylibpath"
   install_name_tool -id "$dylibpath" "$dylibpath"
done | nl

echo


if [[ ! -x '/opt/macports-avidemux/bin/gsettings' ]] || [[ ! -d '/opt/macports-avidemux/include/gsettings-desktop-schemas' ]]; then

   # fix: 
   # GLib-GIO-ERROR **: No GSettings schemas are installed on the system
   curl -L -O http://ftp.gnome.org/pub/GNOME/sources/gsettings-desktop-schemas/3.4/gsettings-desktop-schemas-3.4.1.tar.xz || exit 1
   bsdtar -xf gsettings-desktop-schemas-3.4.1.tar.xz || exit 1
   cd gsettings-desktop-schemas-3.4.1
   ./configure --prefix=/opt/macports-avidemux
   make 
   make install

else

   printf '\n%s\n\n' 'gsettings-desktop-schemas already installed!'

fi


echo
echo "print missing dylibs:  ... make sure there is no dylib missing in install directory /usr/local-avidemux ..."
find /usr/local-avidemux "${avidemux_src_dir}" -iname "*.dylib" | xargs basename | sort | uniq -u


#cd /tmp
#rm -rf "${avidemux_tmp_dir}"


[[ -d '/opt/local-off' ]] && mv -iv /opt/local-off /opt/local
[[ -d '/usr/local-off' ]] && mv -iv /usr/local-off /usr/local

dscl . -change /Users/macports NFSHomeDirectory "${MP_PREFIX}/var/macports/home" /opt/local/var/macports/home 

exit 0

