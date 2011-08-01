########################################################################
###                                         __  __  __               ###
###               ___  ____ __  _ ___  ___ / /_ \ \/ /               ###
###              / _ \' __/ _ `/ / -_)/ __/  _/  )  (                ###
###             / .__/_/  \___/ /\___/\__/\__/  /_/\_\               ###
###            /_/ -------- /__/ ---------------------               ###
###                                                                  ###
########################################################################
### ProjectX IRC 2 HTML v2.00 by Natrak <natrak@projectx.mx.dk>      ###
########################################################################
### This script logs what goes on in an IRC channel, converts it to  ###
### HTML and make it visible to user on the web. To see pxi2h in     ###
### action visit:                                                    ###
###   http://www.projectx.mx.dk/contact/spycam.html                  ###
########################################################################
### Goto http://www.projectx.mx.dk/contact/bugreport.shtml to send   ###
### bug reports, or http://www.projectx.mx.dk/contact/feedback.shtml ###
### to tell us what you think of this script.                        ###
########################################################################
### Configuration:
#

# The channel set to show online:
set pxi2h_chan(#channel) "/home/user/public_html/channel.html"
#
# The prefix to prevent stuff from being shown on the web:
set pxi2h(secret) "."
#
# Maximum number of lines shown on the web:
set pxi2h(maxlines) 15
#
# The page is set to refes every X seconds:
set pxi2h(refresh) 10
#
# The title of the page:
set pxi2h(title) "Canal #Channel - Rede BrasIRC.net"
#
# Text color:
set pxi2h(text) "#FFFFFF"
#
# Background color:
set pxi2h(bgcolor) "#000000"
#
# Heading color:
set pxi2h(heading) "#6666EE"
#
# Font type:
set pxi2h(font) "monospace"
#
### End of config.
########################################################################

proc pxi2h:style {event chan nick host arg} {
  global pxi2h_history
  set chan [pxi2h:findchan $chan]
  if {$chan == ""} { return }
  switch -- $event {
    actn { set text "* $nick $arg" }
    join { set text "*** $nick ($host) has joined $chan" }
    kick { set text "*** [lindex $arg 0] was kicked by $nick ([lrange $arg 1 end])" }
    mode { set text "*** $nick sets mode: $arg" }
    nick { set text "*** $nick is now known as $arg" }
    part { set text "*** $nick ($host) has left $chan" }
    pubm { set text "<$nick> $arg" }
    sign { set text "*** $nick ($host) has quit irc ($arg)" }
    topc { set text "*** $nick changes topic to '$arg'" }
  }
  set pxi2h_history($chan) [lappend pxi2h_history($chan) [pxi2h:control [pxi2h:convert $text]]]
  utimer 1 "pxi2h:make $chan"
}

proc pxi2h:dcc {hand idx arg} {
  global pxi2h
  if {[string tolower [lindex $arg 0]] == "on"} {
    set pxi2h(status) "on"
  } elseif {[string tolower [lindex $arg 0]] == "off"} {
    set pxi2h(status) "off"
  }
  putdcc $idx "ProjectX irc2html is $pxi2h(status)"
  return 1 
}

proc pxi2h:html {text} {
  return [pxi2h:unconvert [pxi2h:convert $text]]
}
proc pxi2h:control {text} {
 set temp $text
 set text ""
 set bold "0"
 set undr "0"
 set color "0"

 for {set i 0} {$i < [string length $temp]} {incr i} {
   set c [string index $temp $i]
   switch -- $c {
      { if {$bold == "1"} { set text "$text</B>"; set bold "0" } else { set text "$text<B>"; set bold "1" } }
      { if {$undr == "1"} { set text "$text</U>"; set undr "0" } else { set text "$text<U>"; set undr "1" } }
      { }
      { }
     default { set text "$text$c" }
   }
 }

 if {$bold == "1"} { set text "$text</B>" }
 if {$undr == "1"} { set text "$text</U>" }
 return $text
}
proc pxi2h:convert {text} {
  regsub -all , $text "" text
  regsub -all 0 $text "" text
  regsub -all 1 $text "" text
  regsub -all 2 $text "" text
  regsub -all 3 $text "" text
  regsub -all 4 $text "" text
  regsub -all 5 $text "" text
  regsub -all 6 $text "" text
  regsub -all 7 $text "" text
  regsub -all 8 $text "" text
  regsub -all 9 $text "" text
  regsub -all {\]} $text "p!c1" text
  regsub -all {\[} $text "p!c2" text
  regsub -all {\}} $text "p!c3" text
  regsub -all {\{} $text "p!c4" text
  regsub -all {\$} $text "p!c5" text
  regsub -all {\"} $text "p!c6" text
  regsub -all {\;} $text "p!c7" text
  regsub -all {\\} $text "p!c8" text
  regsub -all {\/} $text "p!c9" text
  regsub -all & $text "\\&amp;" text
  regsub -all < $text "\\&lt;" text
  regsub -all > $text "\\&gt;" text
  regsub -all \" $text "\\&quot;" text
  regsub -all "  " $text "\\&nbsp; " text
  return $text
}
proc pxi2h:unconvert {text} {
  regsub -all {p!c1} $text "\]" text
  regsub -all {p!c2} $text "\[" text
  regsub -all {p!c3} $text "\}" text
  regsub -all {p!c4} $text "\{" text
  regsub -all {p!c5} $text "\$" text
  regsub -all {p!c6} $text "\"" text
  regsub -all {p!c7} $text "\;" text
  regsub -all {p!c8} $text "\\" text
  regsub -all {p!c9} $text "\/" text
  return $text
}

proc pxi2h:make {chan} {
  global pxi2h_history pxi2h pxi2h_chan server
  if {[llength $pxi2h_history($chan)] > $pxi2h(maxlines)} { set pxi2h_history($chan) [lrange $pxi2h_history($chan) 1 end] }
  set nicks ""
  foreach nick [chanlist $chan] { 
    if {[isop $nick $chan]} {
      set nicks "$nicks @[pxi2h:convert $nick]"
    } elseif {[isvoice $nick $chan]} {
      set nicks "$nicks +[pxi2h:convert $nick]"
    } else {
      set nicks "$nicks [pxi2h:convert $nick]"
    } 
  }
  set nicks [lsort -increasing $nicks]
  set html [open $pxi2h_chan($chan) w]
  puts $html "<HTML>\n<HEAD>\n <TITLE>$pxi2h(title)</TITLE>\n <META HTTP-EQUIV=\"Refresh\" CONTENT=\"$pxi2h(refresh)\">\n</HEAD>"
  puts $html "<BODY TEXT=\"$pxi2h(text)\" BGCOLOR=\"$pxi2h(bgcolor)\" LINK=\"$pxi2h(heading)\" VLINK=\"$pxi2h(heading)\">"
  puts $html " <FONT COLOR=\"$pxi2h(heading)\"><FONT SIZE=\"+1\" FACE=\"sans-serif\">$chan</FONT> <FONT SIZE=\"-1\" FACE=\"monospace\">\[[lindex [getchanmode $chan] 0]\]: '[pxi2h:html [topic $chan]]'</FONT></FONT><P>"
  puts $html " <FONT SIZE=\"-1\" FACE=\"$pxi2h(font)\">"
  puts $html "  <B>Server.</B>: [string range $server 0 [expr [string last ":" $server] - 1]]<BR>"
  puts $html "  <B>Users..</B>: [pxi2h:unconvert $nicks]<BR>\n  <HR SIZE=\"1\">"
  close $html
  set html [open $pxi2h_chan($chan) a]
  if {$pxi2h(status) == "on"} {
    for {set i 0} {$i < [llength $pxi2h_history($chan)]} { incr i } {
      puts $html "  \[[strftime "%H:%M"]\][pxi2h:unconvert [lindex $pxi2h_history($chan) $i]]<BR>"
    }
  } else {
    puts $html "  <BR><CENTER><B>O F F L I N E !</B></CENTER><P>"
  }
  puts $html " </FONT>\n <HR SIZE=\"1\">\n <CENTER><FONT SIZE=\"-1\" FACE=\"sans-serif\"><I>Powered by <A HREF=\"http://www.egghelp.org/\">www.egghelp.org</A></I></FONT></CENTER>\n</BODY>\n</HTML>"
  close $html
}

proc pxi2h:findchan {chan} {
  global pxi2h_chan
  foreach ele [array names pxi2h_chan] {
    if {[string tolower $ele] == [string tolower $chan]} { return $ele }
  }
}

proc pxi2h:ctcp {nick host handle dest keyword arg} {
  if {![string compare $keyword "ACTION"]} { pxi2h:style "actn" $dest $nick $host $arg }
}
proc pxi2h:join {nick host handle chan} {
  pxi2h:style "join" $chan $nick $host ""
}
proc pxi2h:kick {nick host handle chan knick arg} {
  pxi2h:style "kick" $chan $nick $host "$knick $arg"
}
proc pxi2h:mode11x {nick host handle chan arg} {
  if {[lindex $arg 0] == "+k"} { set mode [lindex $arg 0] } else { set mode [lrange $arg 0 end] }
  pxi2h:style "mode" $chan $nick $host $mode
}
proc pxi2h:mode13x {nick host handle chan arg mnick} {
  if {[lindex $arg 0] == "+k"} { set mode [lindex $arg 0] } else { set mode "[lrange $arg 0 end] $mnick" }
  pxi2h:style "mode" $chan $nick $host $mode
}
proc pxi2h:nick {nick host handle chan newnick} {
  pxi2h:style "nick" $chan $nick $host $newnick
}
proc pxi2h:part {nick host handle chan rest} {
  pxi2h:style "part" $chan $nick $host ""
}
proc pxi2h:pubm {nick host handle chan arg} {
  global pxi2h
  if {[string range $arg 0 0] != $pxi2h(secret)} { pxi2h:style "pubm" $chan $nick $host $arg }
}
proc pxi2h:sign {nick host handle chan arg} {
  pxi2h:style "sign" $chan $nick $host $arg
}
proc pxi2h:topc {nick host handle chan topic} {
  if {$nick != "*"} { pxi2h:style "topc" $chan $nick $host $topic }
}

bind dcc +m irc2html pxi2h:dcc
bind ctcp - ACTION pxi2h:ctcp
bind join - * pxi2h:join
bind kick - * pxi2h:kick
if {[lindex $version 1] < "01030000"} {
  bind mode - * pxi2h:mode11x
} else {
  bind mode - * pxi2h:mode13x
}
bind nick - * pxi2h:nick
bind part - * pxi2h:part
bind pubm - * pxi2h:pubm
bind sign - * pxi2h:sign
bind topc - * pxi2h:topc

set pxi2h(ver) "2.00"
if {![info exists pxi2h(status)]} { set pxi2h(status) "on" }
foreach ele [array names pxi2h_chan] {
  if {![info exists pxi2h_history($ele)]} { set pxi2h_history($ele) "" }
  pxi2h:make $ele
}
putlog "\[ProjectX\] irc2html v$pxi2h(ver) loaded."
