#!/usr/bin/env port-tclsh
# check a PortIndex for duplicate portnames
set dumpall 0
set fd [open [lindex $argv 0]]
set counts [dict create]
while {[gets $fd line] >= 0} {
    set name [string tolower [lindex $line 0]]
    dict incr counts $name
    if {[dict get $counts $name] > 1} {
        puts stderr "Warning: [dict get $counts $name] occurrences of $name"
    }
    set len [lindex $line 1]
    set portinfo [read $fd $len]
    if {[catch {dict size $portinfo} result]} {
        puts stderr "Warning: failed to parse info for ${name}: $result"
        puts stderr "Info line for ${name}: $portinfo"
    }
}
close $fd
if {$dumpall} {
    dict for {n c} $counts {
        puts "$n $c"
    }
}
