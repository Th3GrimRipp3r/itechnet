#####################################################
## Xbox Live GamerTag Status' by Danneh/GrimReaper ##
#####################################################
##                 Initial Setup                   ##
#####################################################

set xblchar "."

#####################################################
##                    End Setup                    ##
#####################################################

proc xblinfo {nick host hand chan search} {
  if {[lsearch -exact [channel info $chan] +xblinfo] != -1} {
    set xbllogo "\0030,9Xbox\003 Live"
    set xblsite "Live.xbox.com"
    set xblstatusfound "off"
    if {$search == ""} {
      putserv "PRIVMSG $chan :$xbllogo, Please enter a GamerTag to search for.."
    } else {
      set xblsrcurl1 [urlencode [regsub -all { } $search +]]
      set xblsrcurl2 [encurl $search]
      set xblsrcurl3 "/en-GB/member/${xblsrcurl2}"
      if {[catch {set xblsrcsock [socket -async $xblsite 80]} sockerr]} {
        return 0
      } else {
        puts $xblsrcsock "GET $xblsrcurl3 HTTP/1.0"
        puts $xblsrcsock "Host: $xblsite"
        puts $xblsrcsock "User-Agent: Opera 9.6"
        puts $xblsrcsock ""
        flush $xblsrcsock
        while {![eof $xblsrcsock]} {
          set xblstatus " [gets $xblsrcsock] "
          if {$xblstatusfound == "on"} {
            putserv "PRIVMSG $chan :$xbllogo status for $search:  [recode "${xblstatus}"]"
            close $xblsrcsock
            return 0
          }
          if {[regexp -all {<div id="CurrentActivity">} $xblstatus]} {
            set xblstatusfound "on"
          }
        }
        close $xblsrcsock
        return 0
      }
    }
  }
}

proc encurl {string} {
  return [string map {" " %20} "$string"]
}
          
proc urlencode {string} {
  return [subst [regsub -nocase -all {([^a-z0-9+])} $string {%[format %x [scan "\\&" %c]]}]]
}
proc recode { textin } {
  return [string map {&quot; \" &middot; � &amp; &} [subst [regsub -nocase -all {&#([0-9]{1,5});} $textin {\u\1}]]]
}
bind pub - ${xblchar}xbl xblinfo
setudef flag xblinfo
putlog "Xbox Live Gamertag status' by Danneh/GrimReaper"