Changes between versions:

v0.4.0: (Pushed December 12, 2013)
	- Handle cases when the MacPorts prefix is a symlink
	- Fix many `shellcheck` warnings
	- check to make sure all results are non-empty in port-configuration.sh
	- Multiple new scripts:
		- macportstrac.sh
		- testport_script.sh
		- Point\_Cloud\_Library\_1.5.1\_script.sh
	- Check linked-against-libraries with `nm` in port-depcheck.sh, to make sure that the port actually uses symbols from the libraries (there are environment variables that can be set to skip this check, read the text of the script for more)
	- Check libtool overlinking in port-depcheck.sh
	- be more apostrophe-phobic
	- compare dependencies of the port's active variants in port-depcheck.sh, instead of the default ones

v0.3.0: (Pushed May 15, 2013)
	- Now installs documentation
	- More statements printed in port-depcheck.sh
	- port-depcheck.sh now removes tempfiles
	- port-unprovided.sh now writes to a logfile and prints more warning messages
	- update printing of environment in Port-Configuration.sh
	- Provide description of all scripts in the Readme.md file

v0.2.0: (Pushed March 18, 2013)
	- Make sure prefix is checked in all scripts
	- More commentary in scripts
	- update version of MacPorts installed by install_macports.sh
	- other various improvements

v0.1.4: (Pushed March 4, 2013)
	- Multiple new scripts:
		- port-depcheck.sh
		- gen\_macports\_patches.sh
		- install_macports.sh
		- macportsupdate.sh
		- port-copy.sh
		- port-patch.sh
		- avidemux-build.sh
	- Improve port-unprovided.sh:
		- add `--help` option
		- add `-r` option for acting recursively

v0.1.3: (Pushed February 6, 2013) Include registry-fixing perl script from trac

v0.1.2: (Pushed February 1, 2013)
	- Add port-configuration.sh script
	- Make sure that MacPorts is actually installed in all scripts
	- Improve commentary in scripts

v0.1.1: (Pushed January 29, 2013)
	- Update the portfile
	- rename fetchall.sh to port-fetchall.sh

v0.1.0: (Pushed January 29, 2013) First tag in my fork

