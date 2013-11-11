#!/bin/bash

# testport  --  test install a specified port in /opt/macports-test (default)
# Taken from:
# https://trac.macports.org/wiki/Scripts/testport_script

# 1. move the /opt/local MacPorts system to ${opt_local_off} to make sure
#    it is not interfering with the custom ${MP_PREFIX} MacPorts build process
# 2. move /usr/local to ${usr_local_off} to make sure it is not interfering
#    with the custom ${MP_PREFIX} MacPorts build process
# 3. install a fresh MacPorts 2.0.4 system to "${MP_PREFIX}"
# 4. install the specified port to the custom ${MP_PREFIX} MacPorts system

# Small getopts tutorial, 
# http://wiki.bash-hackers.org/howto/getopts_tutorial

# usage:
# testport gawk
# testport -n -l /opt/macports-gnu gawk
# testport -r clang-3.1
# testport -c -e -v clang-3.1
# testport -s clang-3.1
# testport -r openal
# testport -c openal configure.cc='/opt/macports-test/bin/clang-mp-3.1' configure.cxx='/opt/macports-test/bin/clang++-mp-3.1'
# testport -c -u -l /opt/macports-test-universal


show_usage() {
   echo
   echo "$(basename ${0})  --  test install a specified port in /opt/macports-test (default)"
   echo
   echo "Usage: $(basename ${0}) [-c] [-d] [-e] [-h] [-n] [-p] [-r] [-s] [-u] [-v] [-l dir] portname"
   echo '
-c: clean all installed ports
-d: enable debug mode
-e: fetch & extract the distribution files for portname
-h: help
-n: delete /opt/macports-test (default) & perform a new MacPorts install from scratch
-p: print PATH variable value
-r: remove / uninstall specified port and exit
-s: build and install from source only
-u: update MacPorts system, upgrade outdated ports and exit (cleans work directories)
-v: enable verbose mode
-l dir: specify dir as location of MacPorts system (otherwise defaults to /opt/macports-test)
'
   return 0
}


trapcount=0
# cf. http://fvue.nl/wiki/Bash:_Error_handling
on_exit() {
   #set -xv
   trapcount=$((trapcount + 1))
   if [[ $trapcount -eq 1 ]]; then
      cd    # avoid: sudo: cannot get working directory
      #find -x "${tmpDir}" -ls 1>&2
      echo
      [[ -d "${tmpDir}" ]] && rm -rf "${tmpDir}"
      [[ -d "${usr_local_off}" ]] && sudo mv -iv "${usr_local_off}" /usr/local
      [[ -d "${opt_local_off}" ]] && sudo mv -iv "${opt_local_off}" /opt/local
      printf "\n\n\n"
      echo dscl . -change /Users/macports NFSHomeDirectory "${MP_PREFIX}/var/macports/home" "${dsclHome}"
      current_dscl_home="$(dscl . -read /Users/macports NFSHomeDirectory | sed 's/^NFSHomeDirectory: *//')"
      if [[ "${current_dscl_home}" != "${dsclHome}" ]]; then
         dscl . -change /Users/macports NFSHomeDirectory "${MP_PREFIX}/var/macports/home" "${dsclHome}"
      fi
      printf '\n\n%s\n\n\n' "export PATH=\"${MP_PREFIX}/bin:${MP_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin\""
  fi
   exit
}


do_clean_all() {
   [[ $(port installed | wc -l) -gt 1 ]] && port -f clean --all installed
   [[ $(port list inactive | wc -l) -gt 0 ]] && port -f uninstall inactive
   find -x "${MP_PREFIX}/var/macports/build" -maxdepth 3 -type d -name work -print0 | while IFS="" read -r -d "" dirpath; do
      portname="$( basename "$(dirname "${dirpath}")" )"
      echo port -f -v clean --all "${portname}"
      port -f -v clean --all "${portname}"
   done
   return 0
}

do_clean_work() {
  [[ $(port installed | wc -l) -gt 1 ]] && port -f clean --work installed
   find -x "${MP_PREFIX}/var/macports/build" -maxdepth 3 -type d -name work -print0 | while IFS="" read -r -d "" dirpath; do
      portname="$( basename "$(dirname "${dirpath}")" )"
      echo port -f -v clean --work "${portname}"
      port -f -v clean --work "${portname}"
   done
   return 0
}


do_update() {
   [[ $clean_all -eq 0 ]] && do_clean_work
   port selfupdate
   port outdated
   [[ $(port outdated | wc -l) -gt 1 ]] && port upgrade -R -u outdated
   return 0
}



unset CDPATH PATH IFS LC_ALL MP_PREFIX all_new 
IFS=$' \t\n'
LC_ALL=C
PATH='/sbin:/usr/bin:/bin:/usr/sbin:/sbin'
export IFS LC_ALL PATH


MP_PREFIX=""
all_new=0
update=0
remove=0
verbose=0
debug=0
printpath=0
extract=0
build_source=0
clean_all=0


while getopts ":cdehl:nprsuv" opt; do
  case "$opt" in
    c) 
      clean_all=1
      ;;
    d) 
      debug=1
      ;;
    e) 
      extract=1
      ;;
    h) 
      show_usage
      exit
      ;;
    l) 
      MP_PREFIX="$OPTARG"
      ;;
    n)
      all_new=1
      ;;
    p)
      printpath=1
      ;;
    r)
      remove=1
      ;;
    s) 
      build_source=1
      ;;
    u)
      update=1
      ;;
    v)
      verbose=1
      ;;
    \?)
      echo "Invalid option: -$OPTARG" 1>&2
      show_usage 1>&2
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument." 1>&2
      show_usage 1>&2
      exit 1
      ;;
  esac
done


shift $((OPTIND-1))

if [[ -z "$MP_PREFIX" ]]; then
   MP_PREFIX='/opt/macports-test'
fi

if [[ "$MP_PREFIX" == '/opt/local' ]]; then
   echo 'Use of /opt/local is not allowed!' 1>&2
   exit 1
fi

if [[ "$MP_PREFIX" == '/' ]]; then
   echo 'Use of / is not allowed!' 1>&2
   exit 1
fi

if [[ $(dirname "${MP_PREFIX}") != '/opt' ]]; then
   echo 'Use: /opt/somedir' 1>&2
   exit 1
fi

if [[ ! -d "$MP_PREFIX" ]]; then
   all_new=1
fi

if [[ $all_new -eq 1 ]]; then
   clean_all=0
   remove=0
   update=0
fi


declare -rx MP_PREFIX

unset PATH
PATH="${MP_PREFIX}/bin:${MP_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH


if [[ $(id -u) -ne 0 ]] || [[ "${HOME}" != '/var/root' ]]; then
   echo 'This script must be run in a root shell to prevent sudo timeout!' 1>&2
   echo 'Use: sudo -H -i' 1>&2
   exit 1
fi


if [[ $printpath -eq 1 ]]; then
   printf '\n\n%s\n\n\n' "export PATH=\"${MP_PREFIX}/bin:${MP_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin\""
   printf '%s\n\n\n' "alias testport='/usr/local/bin/testport'"
   exit
fi

if [[ $all_new -ne 1 ]] && [[ ! -x "${MP_PREFIX}/bin/port" ]]; then
   echo "No port command found at: ${MP_PREFIX}/bin/port" 1>&2
   exit 1
fi


# make sure the current working directory exists
pwd -P 1>/dev/null || exit 1

# prevent idle sleep
pmset -a force sleep 0 displaysleep 0 disksleep 0


sleep 1
unset usr_local_off opt_local_off tmpDir
usr_local_off="/usr/local-off-$(date '+%Y-%m-%d-%H_%M_%S')"
opt_local_off="/opt/local-off-$(date '+%Y-%m-%d-%H_%M_%S')"

tmpDir="$(mktemp -d /tmp/macports.XXXXXX)" || exit 1

declare -rx usr_local_off opt_local_off tmpDir

trap on_exit EXIT TERM HUP INT QUIT

dsclHome="$(dscl . -read /Users/macports NFSHomeDirectory | sed 's/^NFSHomeDirectory: *//')"
dscl . -change /Users/macports NFSHomeDirectory "${dsclHome}" "${MP_PREFIX}/var/macports/home"

echo

# make sure /usr/local is not interfering with MacPorts build processes for ${MP_PREFIX}
[[ -d '/usr/local' ]] && sudo mv -iv /usr/local "${usr_local_off}"

# make sure /opt/local is not interfering with MacPorts build processes for ${MP_PREFIX}
[[ -d '/opt/local' ]] && sudo mv -iv /opt/local "${opt_local_off}"

echo


if [[ $# -eq 0 ]]; then
   if [[ $clean_all -eq 1 ]] && [[ $update -eq 1 ]]; then
      do_clean_all
      do_update
      exit
   elif [[ $clean_all -eq 1 ]]; then
      do_clean_all
      exit
   elif [[ $update -eq 1 ]]; then
      do_update
      exit
   else
      echo
      echo 'No port to install (or remove) given!'
      show_usage 1>&2
      exit 1
   fi
fi


if [[ $all_new -eq 1 ]]; then

   if [[ -x "${MP_PREFIX}/bin/port" ]]; then
      [[ $(port installed | wc -l) -gt 1 ]] && port -f uninstall installed
   fi

   # since "rm -rf" is a dangerous command, we restrict its use to /opt/somedir
   if [[ -d "${MP_PREFIX}" ]] && [[ $(dirname "${MP_PREFIX}") == '/opt' ]]; then
      rm -rf "${MP_PREFIX}"
   fi

   # get a fresh MacPorts 2.0.4 install in ${MP_PREFIX} 

   cd "${tmpDir}" || exit 1

   # cf. http://guide.macports.org/#installing.macports.source.multiple
   unset PATH
   export PATH='/bin:/sbin:/usr/bin:/usr/sbin'
   curl -L -O https://distfiles.macports.org/MacPorts/MacPorts-2.0.4.tar.bz2 || exit 1
   tar -xjf MacPorts-2.0.4.tar.bz2
   cd MacPorts-2.0.4 || exit 1
   # --enable-werror --with-install-user=$owner --with-install-group=$group --with-directory-mode=$perms"
   ./configure --prefix="${MP_PREFIX}" --with-tclpackage="${MP_PREFIX}/tcl" --with-applications-dir="${MP_PREFIX}/Applications"

   make
   make install

   # get the Portfiles and update the system
   "${MP_PREFIX}/bin/port" selfupdate

fi  # all_new


cd "${tmpDir}" || exit 1

unset PATH
PATH="${MP_PREFIX}/bin:${MP_PREFIX}/sbin:/usr/bin:/bin:/usr/sbin:/sbin"
export PATH

echo

# clean up previous "${MP_PREFIX}" directory
if [[ $all_new -eq 0 ]] && [[ $remove -eq 0 ]] && [[ $build_source -eq 0 ]] && [[ -x "${MP_PREFIX}/bin/port" ]]; then
   if [[ $clean_all -eq 1 ]]; then
      do_clean_all
   elif [[ -d "$(port dir "$@")/work" ]]; then
      #port -f -v clean --all "$@"
      port -f -v clean --work "$@"
   fi
fi


if [[ $update -eq 1 ]]; then
   do_update
   exit
fi


if [[ $remove -eq 1 ]]; then
   if [[ $(port installed "$@" | wc -l) -gt 1 ]]; then
      printf '\n\n%s\n\n\n' "Uninstalling: $@"
      port -f clean --all "$@"
      port -f -v uninstall "$@"
   elif [[ -d "$(port dir "$@")/work" ]]; then
      printf '\n\n%s\n\n\n' "Removing: $(port dir "$@")/work"
      port -f -v clean --all "$@"
   else
      printf '\n\n%s\n\n\n' "Force uninstalling: $@"
      port -f -v clean --all "$@" || true
      port -f -v uninstall "$@" || true
   fi
   exit
fi


if [[ $extract -eq 1 ]] && [[ $verbose -eq 1 ]]; then
   port -f clean --all "$@"
   port -f -v extract "$@"
elif [[ $extract -eq 1 ]] && [[ $debug -eq 1 ]]; then
   port -f clean --all "$@"
   port -f -d extract "$@"
elif [[ $extract -eq 1 ]]; then
   port -f clean --all "$@"
   port -f extract "$@"
elif [[ $build_source -eq 1 ]] && [[ $verbose -eq 1 ]]; then
   port -f -s -v install "$@"
elif [[ $build_source -eq 1 ]] && [[ $debug -eq 1 ]]; then
   port -f -s -d install "$@"
elif [[ $build_source -eq 1 ]]; then
   port -f -s install "$@"
elif [[ $verbose -eq 1 ]]; then
   port -f -v install "$@"
elif [[ $debug -eq 1 ]]; then
   port -f -d install "$@"
else
   port -f install "$@"
fi


exit 0
