#!/bin/bash
# Script for users to use to report information that might be relevant when reporting 
# tickets on trac.
# Inspired by Homebrew's `brew --config`

# TODO: set stuff to variables so commands don't have to be run twice
if [ -z "`which port`" ]; then
	echo "MacPorts not found; this script is primarily for use with MacPorts."
	exit 0
fi

if [ -x `which clear` ]; then
	clear
else
	echo ""
fi

echo "Configuration:"
echo ""

if [ -x `which port` ]; then
	sleep 1
	echo "\"port\" command found at `which port`"
else
	sleep 1
	echo "Warning: No \"port\" executable found."
fi
if [ -L `which port` ]; then
	REAL_PORT=$(readlink `which port`)
	echo "Warning: `which port` is a symlink to ${REAL_PORT}."
	export MP_PREFIX=$(dirname $(dirname ${REAL_PORT}))
	echo "Assuming your MacPorts prefix is actually ${MP_PREFIX}."
else
	export MP_PREFIX=$(dirname $(dirname `which port`))
	echo "Your MacPorts prefix is ${MP_PREFIX}"
fi
if [ -x `which tclsh` ]; then
	echo "First Tcl in path found at `which tclsh`"
	echo "All \"tclsh\"-es in your PATH:"
	# TODO: find a way to print line-by-line that actually works (see also below)
	for line in "$(which -a tclsh)"; do
		printf "${line}\n"
	done
	unset line
else
	echo "Warning: No \"tclsh\" executable found."
fi
if [ ! -z "`port version`" ]; then
	echo "MacPorts is at `port version | tr V v`"
else
	echo "Warning: could not determine the version of MacPorts."
fi
# This one takes a while so we won't bother testing it before actually running it
echo "You have `port -q installed | wc -l | tr -d [:blank:]` ports installed."
if [ ! -z "`port platform`" ]; then
	echo "\"port platform\" reports: `port platform`"
else
	echo "Warning: can't determine platform."
fi
if [ ! -z "`uname -m`" ]; then
	echo "Computer hardware architecture (uname -m) is `uname -m`"
else
	echo "Warning: can't determine architecture."
fi
if [ ! -z "`uname -v`" ]; then
	echo "OS kernel version is: `uname -v`"
else
	echo "Warning: can't determine kernel version."
fi
echo ""
sleep 1
if [ -z "`which xcodebuild`" ]; then
	echo "Xcode CLT not found, please install them."
else
	echo "xcodebuild found at `which xcodebuild`"
	echo "Xcode is `xcodebuild -version`"
	echo "The following Xcode sdks were found:"
	echo ""
	sleep 1
	for line in "$(xcodebuild -showsdks)\n"; do
		printf "${line}\n"
		sleep 1
	done
	unset line
fi
sleep 1
if [ -x `which clear` ]; then
	clear
else
	echo ""
fi

echo "Environment:"
echo ""
sleep 1
# The pipe through sed is for security (among other reasons)
for line in "$(env | sort | uniq | sed "s|$HOME|\\~|")"; do
	printf "${line}\n"
	sleep 1
done
unset line
echo ""
sleep 1
echo "This script was run as \"$0\" by user \"`whoami`\" in `pwd`"
