#****************************************************************************
# 
#     This file is part of the Quotes Database System (QdbS)
#     Copyright (C) 2003-2008 QdbS.org
#     
#     See docs/README.txt for contributors and authors.
# 
#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
# 
#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.
# 
#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#     $Id$
# 
#****************************************************************************

# INSTRUCTIONS:
# To use this script simply change the configuration options below and then
# load it into your eggdrop.
#
# To enable the in channel commands simply set the "qdbs" channel flag on
# the channel(s) which you wish the commands to work
#
# To have your eggdrop announce when a new quote has been approved set the
# channel flag "qdbs_announcenew" on the channel(s) which you wish to have
# new quotes announced to
#
# To restrict the number of lines a quote has when displayed in channel
# set the "qdbs_maxlines" channel flag to the number of lines. Any quote with
# more lines then this number will be sent as a private message instead of in
# channel.
#
# To restrict how often any quote can be displayed again set
# "qdbs_floodtimeout" to the number of seconds before a quote can be
# displayed again
#
# COMMANDS:
# !quote <quoteid> - Displays the specified quote
# !random          - Displays a random quote
# !top             - Displays the top rated quote
# !bottom          - Displays the bottom rated quote
# !latest          - Displays the latest quote
# !search <query>  - Search for quotes including the specified string
#
#
# CONFIGURATION:
# qdbs_server      - This should be set to the host name from the URL of
#                    your qdb
# qdbs_port        - This should usually be 80 unless your web server
#                    listens on another port
# qdbs_urlpath        - This should be the path to your QdbS installation
#
# EXAMPLE:
# If the URL to your qdb is http://www.qdbs.org/qdb/ then the following
# settings should be used:
# 
# set qdbs_server "www.qdbs.org"
# set qdbs_port 80
# set qdbs_urlpath "/qdb/"
#
# If your QdbS installation is version 1.* then you will need to use the
# XML addon available from http://www.qdbs.org (under downloads)
# When using the XML addon for 1.*, using the above example, you should
# use the qdbs_urlpath as follows:
#
# set qdbs_urlpath "/qdb/xml.php"

#######################
# Begin configuration #
#######################

set qdbs_server "quote.damdevil.org"
set qdbs_port 80
set qdbs_urlpath "/xml.php"

#######################
#  End configuration  #
#######################

# You should not need to edit anything below this line

bind pub - .random qdbs_random
bind pub - .quote qdbs_quote
bind pub - .top qdbs_top
bind pub - .bottom qdbs_bottom
bind pub - .latest qdbs_latest
bind pub - .search qdbs_search

setudef flag qdbs
setudef flag qdbs_announcenew
setudef int qdbs_maxlines
setudef int qdbs_floodtimeout

if !{[info exists qdbs_latestid]} {
	set qdbs_latestid 0
}
if !{[info exists qdbs_floodlist]} {
	set qdbs_floodlist ""
}

proc qdbs_random { nick uhost hand chan args } {
	if {[channel get $chan "qdbs"] == 0} { return }
	qdbs_getquote $nick $uhost $hand $chan $args "random"
}

proc qdbs_top { nick uhost hand chan args } {
	if {[channel get $chan "qdbs"] == 0} { return }
	qdbs_getquote $nick $uhost $hand $chan $args "top"
}

proc qdbs_bottom { nick uhost hand chan args } {
	if {[channel get $chan "qdbs"] == 0} { return }
	qdbs_getquote $nick $uhost $hand $chan $args "bottom"
}

proc qdbs_latest { nick uhost hand chan args } {
	if {[channel get $chan "qdbs"] == 0} { return }
	qdbs_getquote $nick $uhost $hand $chan $args "latest"
}

proc qdbs_quote { nick uhost hand chan args } {
	if {[channel get $chan "qdbs"] == 0} { return }
	if {[llength $args] < 1} { return }
	if {[regexp -nocase -- {\d+} $args]} {
		if {[qdbs_floodcheck $chan $args]} {
			putserv "PRIVMSG $chan :Already displayed quote \002${args}\002. No need to display it again"
			return
		}
		qdbs_getquote $nick $uhost $hand $chan $args $args
	}
}

proc qdbs_search { nick uhost hand chan args } {
	if {[channel get $chan "qdbs"] == 0} { return }
	if {[llength $args] < 1} { return }
	qdbs_dosearch $nick $uhost $hand $chan [join $args]
}

proc qdbs_getquote { nick uhost hand chan args quote } {
	global qdbs_server
	global qdbs_port
	global qdbs_urlpath
	
	if {[catch {socket -async $qdbs_server $qdbs_port} s]} {
		putlog "Error couldn't connect to the webserver; please inform the webmaster at http://${qdbs_server}:${qdbs_port}"
		return
	}
	
	set qdbs_maxlines [channel get $chan "qdbs_maxlines"]
	set sentaspm 0
	
	if {[string equal {} [fconfigure $s -error]]} {
		flush $s
		puts $s "GET ${qdbs_urlpath}?xml&quote=${quote} HTTP/1.1"
		puts $s "Host: ${qdbs_server}"
		puts $s "Connection: Close"
		puts $s "User-Agent: Mozilla/5.0 (compatible; QdbS-TCL/1.0;)"
		puts $s ""
		flush $s

		set quotedoline 0
		set quotelines ""
		
		while {![eof $s]} {
			gets $s line
			
			if {[regexp -nocase {<body>([^<]*)</body>} $line -> quoteline]} {
				lappend quotelines $quoteline
			} elseif {[regexp -nocase {<body>([^<]*)} $line -> quoteline]} {
				lappend quotelines $quoteline
				set quotedoline 1
			} elseif {$quotedoline == 1} {
				if {[regexp -nocase {([^<]*)</body>} $line -> quoteline]} {
					lappend quotelines $quoteline
					set quotedoline 0
				} else {
					lappend quotelines $line
				}
			} else {
				regexp -nocase {<url>([^<]*)</url>} $line -> quoteurl
				regexp -nocase {<id>([^<]*)</id>} $line -> quoteid
				regexp -nocase {<rating>([^<]*)</rating>} $line -> quoterating
			}
		}
		
		close $s
		
		if {[info exists quoteid]} {
			if {$quoteid != 0 } {
				if {[qdbs_floodcheck $chan $quoteid]} {
					putserv "PRIVMSG $chan :Already displayed quote \002${quoteid}\002. No need to display it again"
				} else {
					set sendto $chan
					if {$qdbs_maxlines != 0} {
						if {[llength $quotelines] > $qdbs_maxlines} {
							putserv "PRIVMSG $chan :Quote \002${quoteid}\002 is too long, sending as private message"
							set sendto $nick
							set sentaspm 1
						}
					}
					
					if !{$sentaspm} {
						qdbs_floodadd $chan $quoteid
					}
					
					putserv "PRIVMSG $sendto :\002Quote:\002 ${quoteid} \002Rating:\002 ${quoterating} \002URL:\002 ${quoteurl}"
					foreach curLine $quotelines {
						regsub -all -- {&amp;} $curLine {\&} curLine
						regsub -all -- {&lt;} $curLine {<} curLine
						regsub -all -- {&gt;} $curLine {>} curLine
						regsub -all -- {&quot;} $curLine {"} curLine
						putserv "PRIVMSG $sendto :${curLine}"
					}
				}
			} else {
				putserv "PRIVMSG $chan :\002Invalid quote!\002"
			}
		} else {
			putlog "Error: could not find <id></id> XML tags in HTTP response. (Incorrect configuration?)"
		}
	} else {
		putlog "Error couldn't connect to webserver plz inform the webmaster at http://${qdbs_server}:${qdbs_port}"
	}
}

proc qdbs_dosearch { nick uhost hand chan args } {
	global qdbs_server
	global qdbs_port
	global qdbs_urlpath
	
	regsub -all -- { } [join $args] {%20} search
	
	if {[catch {socket -async $qdbs_server $qdbs_port} s]} {
		putlog "Error couldn't connect to webserver plz inform the webmaster at http://${qdbs_server}:${qdbs_port}"
		return
	}
	
	if {[string equal {} [fconfigure $s -error]]} {
		flush $s
		puts $s "GET ${qdbs_urlpath}?xml&quote=search&search=${search} HTTP/1.1"
		puts $s "Host: ${qdbs_server}"
		puts $s "Connection: Close"
		puts $s "User-Agent: Mozilla/5.0 (compatible; QdbS-TCL/1.0;)"
		puts $s ""
		flush $s

		set quotedoline 0
		set quotelines ""
	
		while {![eof $s]} {
			gets $s line
			
			if {[regexp -nocase {<body>([^<]*)</body>} $line -> quoteline]} {
				lappend quotelines $quoteline
			} elseif {[regexp -nocase {<body>([^<]*)} $line -> quoteline]} {
				lappend quotelines $quoteline
				set quotedoline 1
			} elseif {$quotedoline == 1} {
				if {[regexp -nocase {([^<]*)</body>} $line -> quoteline]} {
					lappend quotelines $quoteline
					set quotedoline 0
				} else {
					lappend quotelines $line
				}
			} else {
				regexp -nocase {<id>([^<]*)</id>} $line -> quoteid
			}
		}
		
		set quotelines [join $quotelines]
		
		if {[info exists quoteid]} {
			if {$quoteid != 0 } {
				putserv "PRIVMSG $chan :Quotes that matched your search \"\002[join $args]\002\":"
				putserv "PRIVMSG $chan :${quotelines}"
			} else {
				putserv "PRIVMSG $chan :No quotes found for \"\002[join $args]\002\"!"
			}
		} else {
			putlog "Error: could not find <id></id> XML tags in HTTP response. (Incorrect configuration?)"
		}
	} else {
		putlog "Error couldn't connect to webserver plz inform the webmaster at http://${qdbs_server}:${qdbs_port}"
	}
}

proc qdbs_getlatestquoteid {min hour day month year} {
	global qdbs_server
	global qdbs_port
	global qdbs_urlpath
	global qdbs_latestid
	
	set dontgetlatestqid 1
	
	foreach channel [channels] {
		if {[channel get $channel "qdbs_announcenew"] && ![channel get $channel "inactive"]} {
			set dontgetlatestqid 0
		}
	}
	
	if {$dontgetlatestqid} { return }
	
	if {[catch {socket -async $qdbs_server $qdbs_port} s]} {
		putlog "Error couldn't connect to webserver plz inform the webmaster at http://${qdbs_server}:${qdbs_port}"
		return
	}
	#fileevent $s writable [list [namespace current]::async_callback_ip $s $arg $nick $hand $chan $arg]
	
	if {[string equal {} [fconfigure $s -error]]} {
		flush $s
		puts $s "GET ${qdbs_urlpath}?xml&quote=latest HTTP/1.1"
		puts $s "Host: ${qdbs_server}"
		puts $s "Connection: Close"
		puts $s "User-Agent: Mozilla/5.0 (compatible; QdbS-TCL/1.0;)"
		puts $s ""
		flush $s

		set quotedoline 0
		set quotelines ""
		
		while {![eof $s]} {
			gets $s line
			regexp -nocase {<id>([^<]*)</id>} $line -> quoteid
			regexp -nocase {<url>([^<]*)</url>} $line -> quoteurl
		}
		
		close $s
		
		if {[info exists quoteid]} {
			if {$quoteid != 0 } {
				if {$quoteid > $qdbs_latestid} {
					if {$qdbs_latestid > 0} {
						foreach channel [channels] {
							if {[channel get $channel "qdbs_announcenew"] && ![channel get $channel "inactive"]} {
								putserv "PRIVMSG $channel :Quote \002${quoteid}\002 has just been approved (\002${quoteurl}\002)"
							}
						}
					}
				}
				set qdbs_latestid $quoteid
			}
		} else {
			putlog "Error: could not find <id></id> XML tags in HTTP response. (Incorrect configuration?)"
		}
	} else {
		putlog "Error couldn't connect to webserver plz inform the webmaster at http://${qdbs_server}:${qdbs_port}"
	}
}

proc qdbs_floodadd { chan quoteid } {
	global qdbs_floodlist
	
	regsub -all -- \\\\ $chan \\\\\\\\ chan
	regsub -all -- \\\[ $chan \\\\\[ chan
	regsub -all -- \\\] $chan \\\\\] chan
	regsub -all -- \\\} $chan \\\\\} chan
	regsub -all -- \\\{ $chan \\\\\{ chan
	regsub -all -- \\\" $chan \\\\\" chan
	
	regsub -all -- {[^0-9]} $quoteid {} quoteid
	
	lappend qdbs_floodlist "${chan}:${quoteid}"
	
	utimer [channel get $chan "qdbs_floodtimeout"] "qdbs_flooddel ${chan} ${quoteid}"
}

proc qdbs_flooddel { chan quoteid } {
	global qdbs_floodlist
	
	set newfloodlist ""
	
	foreach flood $qdbs_floodlist {
		if {$flood != "${chan}:${quoteid}"} {
			lappend newfloodlist $flood
		}
	}
	
	set qdbs_floodlist $newfloodlist
}

proc qdbs_floodcheck { chan quoteid } {
	global qdbs_floodlist
	
	set isflood 0
	
	foreach flood $qdbs_floodlist {
		if {$flood == "${chan}:${quoteid}"} {
			set isflood 1
		}
	}
	
	return $isflood
}

qdbs_getlatestquoteid 0 0 0 0 0

bind time - "* * * * *" qdbs_getlatestquoteid

putlog "QdbS TCL 1.0: by Jobe @ irc.qdbs.org/#qdbs"
