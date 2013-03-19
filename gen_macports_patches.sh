#!/bin/bash
#
# Copyright (C) 2009 Roy Liu
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright notice,
#      this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#    * Neither the name of the author nor the names of any contributors may be
#      used to endorse or promote products derived from this software without
#      specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

# taken from https://trac.macports.org/ticket/21640

if [ -z "`which port`" ]; then
	echo "MacPorts not found, this script is primarily for use with MacPorts."
	exit 0
fi

if [[ ! -d "$1" || ! -d "$2" ]]; then

    echo "Please specify two directories."
    exit 1
fi

CURRENT=$PWD
WORK_DIR=$HOME/.cache/gen_macports_patches

rm -f patch.tgz
rm -rf $WORK_DIR/files-patch $WORK_DIR/files-add

mkdir -p $WORK_DIR
mkdir -p $WORK_DIR/files-patch
mkdir -p $WORK_DIR/files-add
rsync -r --delete --exclude=.svn --exclude=/.git --exclude=.DS_Store "$1"/ $WORK_DIR/src
rsync -r --delete --exclude=.svn --exclude=/.git --exclude=.DS_Store "$2"/ $WORK_DIR/dst

cd $WORK_DIR && diff -u -r src dst > tmp-diff; cd "$CURRENT"

# Create patch files.

rm -rf $WORK_DIR/tmp-dir
mv $WORK_DIR/dst $WORK_DIR/tmp-dir

cd $WORK_DIR && patch -p0 --dry-run < tmp-diff | sed \
    -e "s/^patching file src\\/\\(.*\\)\$/\\1/g" \
    -e "s/^patching file 'src\\/\\(.*\\)'\$/\\1/g" \
    > tmp-list-patch; cd "$CURRENT"
cd $WORK_DIR && patch -p0 -b -z ".orig" < tmp-diff; cd "$CURRENT"
cd $WORK_DIR/src && cat ../tmp-list-patch | xargs -I{} sh -c "diff -u \"{}\".orig \"{}\" > ../files-patch/patch-\"\$(basename \"{}\")\".diff"; cd "$CURRENT"

mv $WORK_DIR/tmp-dir $WORK_DIR/dst

# Create add files.

cd $WORK_DIR && cat tmp-diff | sed -n -e "s/^Only in dst\\(\\/\\{0,1\\}\\)\\(.*\\): \\(.*\\)\$/\\2\\1\\3/gp" > tmp-list-add; cd "$CURRENT"
cd $WORK_DIR && cat tmp-list-add | xargs -I{} echo "adding file 'dst/{}'"
cd $WORK_DIR && rsync -r --files-from=tmp-list-add dst files-add; cd "$CURRENT"

tar -C $WORK_DIR -c -z -f patch.tgz files-patch files-add
