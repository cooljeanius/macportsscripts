macportsscripts
===============

Various little scripts for MacPorts. There used to be only one, but since then I've added more.

Installation
============

The `macportsscripts` port now points to this repo! Simply do `sudo port install macportsscripts` and all the scripts will be put in your path.

Usage
=====
- `Port-Configuration.sh`: Simply run it and it will print some useful information for you.
- `avidemux-build.sh`: This one does **not** work reliably, but you can try running it to see if it will build avidemux for you...
- `gen_macports_patches.sh`: I actually do **not** use this one myself, but apparently you give it two directories as arguments, and it will generate patches between the two for use with MacPorts...
- `install_macports.sh`: If you are installing `macportsscripts` via its port, you probably won't need this script, as you should already have MacPorts installed.
- `lintportindex.tcl`: check a PortIndex for duplicate portnames
- `macports_34482_fix.pl`: If you have a broken MacPorts registry, just run this script and it should fix it for you (assuming that it broke in a particular way)
- `macportstrac.sh`: interact with trac (specifically, query/view trac tickets)
- `macportsupdate.sh`: Just run this script and it will update your MacPorts stuff for you
- `mp-trac-category-ports.sh`: Used on the wiki
- `port-copy.sh`: I do **not** use this one myself either, but apparently it will make a copy of a port's portfile for diffing against if you are updating it or something...
- `port-depcheck.sh`: This is probably the script I use the most. You give it the name of an installed port, and then it will scan the files that that port has installed to see what it links against. After finding what it links against, it will match these libraries to the ports that provide them, and then it will output a diff between the ports that the port actually links against, and the ports that the port declares as library dependencies. `+`es in the diff (highlighted as green when uploaded to MacPorts's trac) mark the names of ports that can be added as library dependencies, while `-`es in the diff (marked as red when uploaded to MacPorts's trac) mark the names of ports that can be removed as library dependencies.
- `port-fetch-all.sh`: This was the original script that originally made up phw's old `macportsscripts` port. It takes the name of a port as an argument, and will fetch all the dependencies of that port.
- `port-patch.sh`: I do **not** use this one myself either, but apparently it will generate patches for portfiles...
- `port-unprovided.sh`: This script will scan your MacPorts prefix for stray files in it that are **not** provided by any ports. Pass it the `--help` flag for more info.
- `recursive_port_binary_distributable.tcl.sh`: check the binary distributability of a port and all of its dependencies
- `testport-script.sh`: a more generalized version of `avidemux-build.sh`. Test-installs a port into a custom prefix.

License
=======

The portfile originally listed the license for this port as being BSD, so I guess that is what it shall stay as...
