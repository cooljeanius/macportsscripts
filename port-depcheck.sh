#!/bin/bash
# A script to check the dependencies of a port against which libraries the port actually 
# links against.
# `otool` is an OS X thing so don't go expecting to run this on other platforms

if [ -z "$(which port)" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 0
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
if [ "$(date | cut -d\  -f5)" != "EDT" ]; then
	SUFFIX_PT1=$(date | cut -d\  -f5 | tr -d :)
	SUFFIX_PT2=$(date | cut -d\  -f7)
else
	SUFFIX_PT1=$(date | cut -d\  -f4 | tr -d :)
	SUFFIX_PT2=$(date | cut -d\  -f6)
fi

SUFFIX=${SUFFIX_PT1}${SUFFIX_PT2}

# The first few times I tried this script I had some trouble with my $TMPDIR;
# that's why I'm making sure it exists and is set here.
if [ -z "$TMPDIR" ]; then
	export TMPDIR=/tmp
fi
if [ ! -d $TMPDIR ]; then
	mkdir -p $TMPDIR
fi

TMPFILE1=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}1.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Can't create first temp file, exiting..."
	exit 1
fi
TMPFILE2=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}2.XXXXXX)
if [ $? -ne 0 ]; then
	echo "$0: Can't create second temp file, exiting..."
	exit 1
fi

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
# - Set list of libraries to a variable
# - Check libtool archives for dependency_libs entries and see if any linkages are due to libtool overlinking
# - Check libraries with nm(1) to see if they actually use symbols from the libraries they link against

echo "Finding MacPorts libraries that $1 links against..."
# I should find a way to not have to pipe so much stuff through `cut` here...
# http://trac.macports.org/ticket/38428
echo $(port -q contents $1 | xargs file | grep Mach-O | cut -d\: -f1 | cut -d\  -f1 | uniq | xargs otool -L | grep "\ version\ " | grep "$MP_PREFIX" | sort | uniq | cut -d\  -f1 | xargs port -q provides | tee -a /dev/tty | cut -d\: -f2 | sort | uniq) | sed "s|$1 ||" | tr \  \\n >> $TMPFILE1

echo "Finding the libraries that ${1}'s portfile lists as dependencies..."
# I'd like there to be a `lib_depof:` type of pseudo-portname to use here: 
# https://trac.macports.org/ticket/38381
port info --line --depends_lib $1 | tr ',' '\n' | tee -a /dev/tty | awk -F ':' '{ print $NF; }' | sort | uniq >> $TMPFILE2

echo "Comparing the two lists..."
DIFF_CONTENTS=$(diff -iwBu --strip-trailing-cr $TMPFILE2 $TMPFILE1)
if [ -z "$DIFF_CONTENTS" ]; then
	echo "No difference in dependencies, exiting."
    if [ -w $TMPDIR -a -w $TMPFILE1 ]; then
        rm -f $TMPFILE1
    fi
    if [ -w $TMPDIR -a -w $TMPFILE2 ]; then
        rm -f $TMPFILE2
    fi
	exit 1
else
	DIFF_FILE=$TMPDIR/${1}-deps.${SUFFIX}.diff
	echo "$DIFF_CONTENTS" | tee $DIFF_FILE
	echo "Output a diff file to $DIFF_FILE"
fi
