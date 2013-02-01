#!/bin/bash
# Script for users to use to report information that might be relevant when reporting tickets.
# Inspired by Homebrew's `brew --config`

if [ -z "`which port`" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 0
fi

echo "Configuration:"
echo "\"port\" command found at `which port`"
echo "Tcl found at `which tclsh`"
echo "MacPorts is at `port version | tr V v`"
echo "You have `port -q installed | wc -l | tr -d [:blank:]` ports installed"
echo "\"port platform\" reports: `port platform`"
echo "Computer hardware architecture (uname -m) is `uname -m`"
echo "OS kernel version is: `uname -v`"
if [ -z "`which xcodebuild`" ]; then
	echo "Xcode CLT not found, please install them."
else
	echo "xcodebuild found at `which xcodebuild`"
	echo "Xcode is `xcodebuild -version`"
	echo "The following Xcode sdks were found:"
	xcodebuild -showsdks
fi
echo "Environment:"
env
echo "This script was run as \"$0\" by user \"`whoami`\" in `pwd`"
