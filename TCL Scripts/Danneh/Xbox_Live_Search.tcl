#####################################################
## Xbox Live GamerTag Status' by Danneh/GrimReaper ##
#####################################################
##                 Initial Setup                   ##
#####################################################

set xblchar "!"

#####################################################
##                    End Setup                    ##
#####################################################

proc xblinfo {nick host hand chan search} {
  if {[lsearch -exact [channel info $chan] +xblinfo] != -1} {
    set xbllogo "\0039X\00314box Live\003"
    set xblsite "Live.xbox.com"
    set xblstatusfound "off"
    if {$search == ""} {
      putserv "PRIVMSG $chan :$xbllogo, Please enter a GamerTag to search for.."
    } else {
      set xblsrcurl1 [urlencode [regsub -all { } $search +]]
      set xblsrcurl2 "/en-GB/member/${xblsrcurl1}"
      if {[catch {set xblsrcsock [socket -async $xblsite 80]} sockerr]} {
        return 0
      } else {
        puts $xblsrcsock "GET $xblsrcurl2 HTTP/1.0"
        puts $xblsrcsock "Host: $xblsite"
        puts $xblsrcsock "User-Agent: Opera 9.6"
        puts $xblsrcsock ""
        flush $xblsrcsock
        while {![eof $xblsrcsock]} {
          set xblstatus " [gets $xblsrcsock] "
          if {$xblstatusfound == "on"} {
            putserv "PRIVMSG $chan :$xbllogo [recode "${xblstatus}"]"
            close $xblsrcsock
          }
          if {[regexp -all {<div id="CurrentActivity">} $xblstatus]} {
            set xblstatusfound "on"
          }
        }
        close $xblsrcsock
      }
    }
  }
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