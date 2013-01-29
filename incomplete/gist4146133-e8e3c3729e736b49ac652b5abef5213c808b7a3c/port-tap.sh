#!/bin/sh

if [ -z "$1" ]; then 
	echo usage: $0 url
	exit
fi

URL = $1
echo $URL #statement for debugging
prefix="$(type -p port)"; prefix="${prefix%/bin/port}"
portdir = "${url##*/}" #The end part of the url, used as a folder to put the sources in
FILE_PATH = {$prefix}/var/macports/sources/{$portdir}

#The comments here are just placeholders until I figure out how to parse URLs in shell scripts
if #the URL is a git url (git://)
	git clone $URL $FILE_PATH
elif #the URL is an hg url
	hg clone $URL $FILE_PATH
elif #the URL is an svn url
	svn co $URL $FILE_PATH
else #curl should be able to handle pretty much anything else
	curl $URL $FILE_PATH
fi

#edit {$PREFIX}/etc/macports/sources.conf to include file://$FILE_PATH (not sure how to do this -- I'm guessing sed?)
