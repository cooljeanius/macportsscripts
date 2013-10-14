#!/bin/bash
# A script to check the dependencies of a port against which libraries the port actually 
# links against.
# `otool` is an OS X thing (from cctools), so do NOT go expecting to run this on 
# other platforms

if [ -z "$(which port)" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 1
fi
if [ -z "$1" ]; then
	echo "Usage: $(basename $0) portname"
	exit 1
fi
if [ -z "$(port list $1)" ]; then
	echo "Error: port $1 not found"
	exit 1
fi
if [ "$(port installed $1)" = "None of the specified ports are installed." ]; then
	echo "$(port installed $1)"
	exit 1
fi

tempfoo=$(basename $0)
# I added the suffix stuff before I knew that `mktemp` already added one for you;
# I left them in anyway though because why not
# TODO:
# -[ ] Handle other special timezones besides EDT
# -[ ] Actually, just handle the output of `date` better in general
if [ "$(date | cut -d\  -f5)" != "EDT" ]; then
	SUFFIX_PT1=$(date | cut -d\  -f5 | tr -d :)
	SUFFIX_PT2=$(date | cut -d\  -f7)
else
	SUFFIX_PT1=$(date | cut -d\  -f4 | tr -d :)
	SUFFIX_PT2=$(date | cut -d\  -f6)
fi

SUFFIX=${SUFFIX_PT1}${SUFFIX_PT2}

# The first few times I tried this script I had some trouble with my $TMPDIR;
# that is why I am making sure it exists and is set here.
if [ -z "$TMPDIR" ]; then
	export TMPDIR=/tmp
fi
# This might be a paradox, but I cannot think of a better way to make sure that
# this call to mkdir will actually succeed...
if [ ! -d $TMPDIR -a -w ${TMPDIR}/.. ]; then
	mkdir -p $TMPDIR
fi

# TODO: 
# -[ ] Make a function (or use a loop) to do this so I do not have to copy-n-paste as much
TMPFILE0=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}0.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Cannot create zeroth temp file, exiting..."
	exit 1
fi
TMPFILE1=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}1.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Cannot create first temp file, exiting..."
	exit 1
fi
TMPFILE2=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}2.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Cannot create second temp file, exiting..."
	exit 1
fi
TMPFILE3=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}3.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Cannot create third temp file, exiting..."
	exit 1
fi
TMPFILE4=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}4.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Cannot create fourth temp file, exiting..."
	exit 1
fi

delete_tmpfiles() {
    for TMPFILE_TO_DELETE in $TMPFILE0 $TMPFILE1 $TMPFILE2 $TMPFILE3 $TMPFILE4; do
    	if [ -w $TMPDIR -a -w $TMPFILE_TO_DELETE ]; then
        	rm -f $TMPFILE_TO_DELETE
    	fi
    done
}

# This one gets a special case because there are more reasons to delete it:
delete_tmpfile3() {
    if [ -w $TMPDIR -a -w $TMPFILE3 ]; then
        rm -f $TMPFILE3
    fi
}

if [ -L `which port` ]; then
	REAL_PORT=$(readlink `which port`)
	echo "Warning: `which port` is a symlink to ${REAL_PORT}."
	export MP_PREFIX=$(dirname $(dirname ${REAL_PORT}))
	echo "Assuming MP_PREFIX is actually ${MP_PREFIX}."
else
	export MP_PREFIX=$(dirname $(dirname `which port`))
fi

if [ -z "$MP_PREFIX" ]; then
	export MP_PREFIX=/opt/local
fi

# TODO:
# -[ ] Figure out if it is safe to remove the dependencies that are probably due to libtool overlinking
# -[ ] Actually do the removing

echo "Finding MacPorts libraries that $1 links against..."
# I should find a way to not have to pipe so much stuff through `cut` here...
# http://trac.macports.org/ticket/38428
MACH_O_FILES=$(port -q contents $1 | xargs /usr/bin/file | grep Mach-O | cut -d\: -f1 | cut -d\  -f1 | uniq)
if [ ! -z "$MACH_O_FILES" ]; then
	LINKED_AGAINST_LIBS=$(echo $MACH_O_FILES | xargs otool -L | grep "\ version\ " | grep "$MP_PREFIX" | sort | uniq | cut -d\  -f1) 
	echo "$LINKED_AGAINST_LIBS" >> $TMPFILE0
	SYMBOLS=$(for macho in $MACH_O_FILES; do if [ ! -z "$macho" ]; then nm -m $macho 2>/dev/null && echo ""; fi && echo ""; done && echo "")
	echo "$SYMBOLS" >> $TMPFILE4
	echo "" >> $TMPFILE4
	if [ ! -z "$LINKED_AGAINST_LIBS" ]; then
		# This is the part where we actually get the ports linked against:
		echo $(cat $TMPFILE0 | xargs port -q provides 2>/dev/null | grep "is provided by" | tee -a /dev/tty | cut -d\: -f2 | sort | uniq) | sed "s|$1 ||" | tr \  \\n >> $TMPFILE1
		if [ ! -z "$SYMBOLS" -a -e $TMPFILE4 ]; then
			# TODO:
			# -[ ] add an environment variable or flag that can be set to skip this step
			echo "Checking symbols in linked-against libraries..."
			for MP_LIBRARY in $(echo ${LINKED_AGAINST_LIBS} | uniq | xargs basename | uniq | cut -d. -f1 | uniq | cut -d\- -f1 | uniq); do
				echo "Checking to see if $1 actually uses symbols from ${MP_LIBRARY}... \c"
				if [ ! -z "$(grep $MP_LIBRARY $TMPFILE4)" ]; then
					echo "yes"
				else
					PORT_TO_REMOVE="`cat $TMPFILE0 | uniq | sort | uniq | xargs port -q provides 2>/dev/null | grep \"is provided by\" | uniq | sort | uniq | grep $MP_LIBRARY | uniq | sort | uniq | cut -d\: -f2 | uniq | sort | uniq`"
					echo "no, removing \"$(printf ${PORT_TO_REMOVE} | tr \\n \  )\" from list of dependencies.."
					sed -i "s|$(printf ${PORT_TO_REMOVE} | tr \\n \  )||" ${TMPFILE1}
					NEW_TMPFILE1="$(cat ${TMPFILE1} | uniq | sort | uniq)"
					echo $NEW_TMPFILE1 | tr \  \\n > ${TMPFILE1}
				fi
			done
		else
			echo "Warning: libraries have no symbols... (how did that happen?)"
		fi
	else
		echo "$1 does not actually link against any MacPorts libraries, exiting..."
		delete_tmpfiles
		exit 1
	fi
else
	echo "$1 does not actually contain any mach-o binaries, exiting..."
	delete_tmpfiles
	exit 1
fi

if [ $(port -q version | cut -d: -f2 | cut -d. -f1) -eq 2 -a $(port -q version | cut -d: -f2 | cut -d. -f2) -lt 2 ]; then
	if [ ! -z "`port -q installed libtool`" ];then
		echo "Finding which linkages might be due to libtool over-linking..."
		LIBTOOL_ARCHIVES=$(port -q contents $1 | xargs file | grep "libtool library file" | cut -d\: -f1 | cut -d\  -f1 | uniq)
		if [ ! -z "$LIBTOOL_ARCHIVES" ]; then
			DEPENDENCY_LIBS=$(cat $LIBTOOL_ARCHIVES | grep "dependency_libs" | tr \  \\n | grep "$MP_PREFIX" | grep \.la)
			# TODO:
			# -[ ] Handle the dangling single-quotes in a way that does not confuse the syntax highlighting in my text editor...
			if [ ! -z "$DEPENDENCY_LIBS" ]; then
				echo $DEPENDENCY_LIBS
				echo "Checking which ports provide dependency_libs entries in these libtool archives..."
				DEPENDENCY_PROVIDERS=$(echo $DEPENDENCY_LIBS | xargs port -q provides | cut -d\: -f2 | uniq | sort | uniq | tr -d [:blank:] | sed "s|$1||" | tr -d [:blank:] | uniq | tee -a /dev/tty)
				echo $DEPENDENCY_PROVIDERS >> $TMPFILE3
			else
				echo "libtool archives have already been cleared of dependency_libs; libtool over-linking likely is not a problem..."
				delete_tmpfile3
			fi
		else
			echo "Actually, no libtool archives were found, so never mind."
			delete_tmpfile3
		fi
	else
		echo "You do not have the libtool port installed; no need to check for libtool over-linking."
		delete_tmpfile3
	fi
else
	echo "Checking libtool archives for overlinking should not be necessary for your MacPorts version (`port -q version`), unless you have NOT rebuilt everything since you updated..."
	echo "This script does NOT know whether or not you have rebuilt as such though, so we shall assume the best of you and skip the libtool-archives check."
	echo "(the libtool-archives check was just a back-up check in case the check with \`nm(1)\` failed, anyways, so skipping it should be harmless)"
	delete_tmpfile3
fi

echo "Finding the libraries that $(port file ${1}) lists as dependencies..."
ACTIVE_VARIANTS=$(port -q installed ${1} | grep \(active\) | cut -d\  -f4)
echo "${1} is installed with the following active variants: ${ACTIVE_VARIANTS}"
echo "So we shall find the dependencies for those variants..."
# I would like there to be a `lib_depof:` type of pseudo-portname to use here: 
# https://trac.macports.org/ticket/38381
port info --line --depends_lib $1 ${ACTIVE_VARIANTS} | tr ',' '\n' | tee -a /dev/tty | awk -F ':' '{ print $NF; }' | sort | uniq >> $TMPFILE2

echo "Comparing the list of library linkages with the list of library dependencies..."
DIFF_CONTENTS=$(diff -iwBu --strip-trailing-cr $TMPFILE2 $TMPFILE1)
if [ -z "$DIFF_CONTENTS" ]; then
	echo "No difference in dependencies, exiting."
	delete_tmpfiles
	exit 1
else
	DIFF_FILE=$TMPDIR/${1}-deps.${SUFFIX}.diff
	echo "$DIFF_CONTENTS" | tee $DIFF_FILE
	echo "Output a diff file to $DIFF_FILE"
fi
