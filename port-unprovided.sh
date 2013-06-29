#!/bin/bash
# Lists unprovided files in your MacPorts prefix
#TODO: Add better support for different prefixes

if [ -z "`which port`" ]; then
    echo "MacPorts not found, this script is primarily for use with MacPorts."
    exit 0
fi

#TODO: Add support for multiple flags (learn how to do `case` syntax)
if [ "$1" == "--help" ]; then
	echo "Usage:"
	echo ""
	echo "--help					use this flag to display this help."
	echo "-v					use this flag to be verbose (doesn't actually work yet)."
	echo "-r					use this flag to recurse deep into your prefix."
	echo "--prefix=/placeholder/path/to/prefix	use this flag to select which prefix to use (defaults to /opt/local) (not actually implemented yet)."
	echo ""
	echo "Warning: only the first flag specified is actually recognized so far"
	echo ""
	exit 0
fi

# This tempfile creation part is mainly taken from port-depcheck.sh
#TODO: put this part in a common thing that can be `source`-ed
tempfoo=$(basename $0)

# The first few times I tried this script I had some trouble with my $TMPDIR;
# that's why I'm making sure it exists and is set here.
if [ -z "$TMPDIR" ]; then
    export TMPDIR=/tmp
fi
if [ ! -d $TMPDIR ]; then
    mkdir -p $TMPDIR
fi

# The "XXXX"es that `mktemp` replaces only work if they're at the very end
# i.e. they don't get replaced when there's a file extension at the end like I have here
if [ "$(date | cut -d\  -f5)" != "EDT" ]; then
    SUFFIX_PT1=$(date | cut -d\  -f5 | tr -d :)
    SUFFIX_PT2=$(date | cut -d\  -f7)
else
    SUFFIX_PT1=$(date | cut -d\  -f4 | tr -d :)
    SUFFIX_PT2=$(date | cut -d\  -f6)
fi

SUFFIX=${SUFFIX_PT1}${SUFFIX_PT2}

TMPFILE1=$(mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}.log)
if [ $? -ne 0 ]; then
    echo "$0: Can't create temp file, exiting..."
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

#TODO:
# - Set list of unprovided files to a machine-readable variable
# - read symlinks among files (delete broken ones?)
# - grep for .mp_#### files; these are ones that MacPorts has moved aside
# - when .mp_#### files are unprovided, that usually means they're safe to delete (so do so?)

if [ -d $MP_PREFIX ]; then
	if [ "$1" == "-r" ]; then
		echo "Generating list files in prefix, this might take a while..."
        echo "(Also make sure you have a large scrollback buffer)"
		for directory in $(find $MP_PREFIX/* \( -path $MP_PREFIX/var/macports -prune \) -o -print 2>/dev/null); do
			if [ -d ${directory} ]; then
				if [ -z "$(port provides ${directory}/* | grep "is not provided by a MacPorts port.")" ]; then
					echo "${directory}: no unprovided files found here"
				else
					port provides ${directory}/* | grep "is not provided by a MacPorts port." | tee -a $TMPFILE1
				fi
			fi
		done
	else
		for directory in ${MP_PREFIX}/*; do
			if [ -z "$(port provides ${directory}/* | grep "is not provided by a MacPorts port.")" ]; then
				echo "${directory}: no unprovided files found here"
			else
				port provides ${directory}/* | grep "is not provided by a MacPorts port." | tee -a $TMPFILE1
			fi
		done
	fi
fi
if [ ! -z "$(cat $TMPFILE1)" ]; then
    echo "List of unprovided files output to $TMPFILE1"
elif [ -w $TMPDIR -a -w $TMPFILE1 ]; then
    rm -f $TMPFILE1
fi
