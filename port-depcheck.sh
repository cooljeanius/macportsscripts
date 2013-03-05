#!/bin/bash

if [ -z "$1" ]; then
	echo "Usage: `basename $0` portname"
	exit 1
fi
if [ -z "`port list $1`" ]; then
	echo "Error: port $1 not found"
	exit 1
fi
if [ "`port installed $1`" = "None of the specified ports are installed." ]; then
	echo "`port installed $1`"
	exit 1
fi
tempfoo=`basename $0`
SUFFIX_PT1=$(date | cut -d\  -f5 | tr -d :)
SUFFIX_PT2=$(date | cut -d\  -f7)
SUFFIX=${SUFFIX_PT1}${SUFFIX_PT2}
if [ -z "$TMPDIR" ]; then
	export TMPDIR=/tmp
fi
if [ ! -d $TMPDIR ]; then
	mkdir -p $TMPDIR
fi
TMPFILE1=`mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}1.XXXXXX`
if [ $? -ne 0 ]; then
	echo "$0: Can't create first temp file, exiting..."
	exit 1
fi
TMPFILE2=`mktemp -q $TMPDIR/${tempfoo}.${SUFFIX}2.XXXXXX`
if [ $? -ne 0 ]; then
	echo "$0: Can't create second temp file, exiting..."
	exit 1
fi

echo $(port -q contents $1 | xargs file | grep Mach-O | cut -d\: -f1 | cut -d\  -f1 | uniq | xargs otool -L | grep "\ version\ " | grep /opt/local | cut -d\  -f1 | xargs port -q provides | cut -d\: -f2 | sort | uniq) | tr \  \\n >> $TMPFILE1
port echo depof:$1 | sort | uniq >> $TMPFILE2
DIFF_CONTENTS=`diff -iwBu $TMPFILE2 $TMPFILE1`
if [ -z "$DIFF_CONTENTS" ]; then
	echo "No difference in dependencies, exiting."
	exit 1
else
	DIFF_FILE=$TMPDIR/${1}-deps.${SUFFIX}.diff
	echo "$DIFF_CONTENTS" | tee $DIFF_FILE
	echo "Output a diff file to $DIFF_FILE"
fi
