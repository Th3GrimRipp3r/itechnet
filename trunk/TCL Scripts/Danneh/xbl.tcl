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
    set xbllogo "\0039X\00314box Live\003"
    set xblsite "Live.xbox.com"
    set xblstatusfound "0"
    if {$search == ""} {
      putserv "PRIVMSG $chan :$xbllogo, Please enter a GamerTag to search for.."
    } else {
      set xblsrcurl1 [urlencode [regsub -all { } $search +]]
      set xblsrcurl2 [encurl $search]
      set xblsrcurl3 "/en-GB/Profile?gamertag=${xblsrcurl2}"
      if {[catch {set xblsrcsock [socket -async $xblsite 80]} sockerr]} {
        return 0
      } else {
        puts $xblsrcsock "GET $xblsrcurl3 HTTP/1.0"
        puts $xblsrcsock "Host: $xblsite"
        puts $xblsrcsock "User-Agent: Opera 9.6"
        puts $xblsrcsock ""
        flush $xblsrcsock
        while {![eof $xblsrcsock]} {
          set xblstatus "[gets $xblsrcsock]"
          if {$xblstatusfound == "on"} {
            putserv "PRIVMSG $chan :$xbllogo status for \0037$search\003: [xblstrip [string trimleft [recode "${xblstatus}"]]]"
            close $xblsrcsock
            return 0
          }
          if {[regexp -all {<div class="custom">} $xblstatus]} {
            set xblstatusfound "on"
          }
        }
	 putserv "PRIVMSG $chan :Sorry, I couldn't find \0037$search\003 on $xbllogo"
        close $xblsrcsock
        return 0
      }
    }
  }
}
 
proc xblgsinfo {nick host hand chan search} {
  if {[lsearch -exact [channel info $chan] +xblinfo] != -1} {
    set xbllogo "\0039X\00314box Live\003"
    set xblsite "Live.xbox.com"
    if {$search == ""} {
      putserv "PRIVMSG $chan :$xbllogo, Please enter a GamerTag to search GamerScore for.."
    } else {
      set xblsrcurl1 [urlencode [regsub -all { } $search +]]
      set xblsrcurl2 [encurl $search]
      set xblsrcurl3 "/en-GB/Profile?gamertag=${xblsrcurl2}"
      if {[catch {set xblsrcsock [socket -async $xblsite 80]} sockerr]} {
        return 0
      } else {
        puts $xblsrcsock "GET $xblsrcurl3 HTTP/1.0"
        puts $xblsrcsock "Host: $xblsite"
        puts $xblsrcsock "User-Agent: Opera 9.6"
        puts $xblsrcsock ""
        flush $xblsrcsock
        while {![eof $xblsrcsock]} {
          set xblstatus "[gets $xblsrcsock]"
          if {[regexp -all {<div class="gamerscore">(.*?)</div>} $xblstatus match xblgamerscore]} {
            putserv "PRIVMSG $chan :$xbllogo GamerScore for \0037$search\003: $xblgamerscore"
	     close $xblsrcsock
	     return 0
          }
        }
	 putserv "PRIVMSG $chan :Sorry, I couldn't find \0037$search\003 on $xbllogo"
        close $xblsrcsock
        return 0
      }
    }
  }
}
 
 
proc encurl {string} {
  return [string map {" " %20} "$string"]
}
proc xblstrip {string} {
  return [regsub -all {<[^<>]+>} $string ""]
} 
proc urlencode {string} {
  return [subst [regsub -nocase -all {([^a-z0-9+])} $string {%[format %x [scan "\\&" %c]]}]]
}
proc recode { textin } {
  return [string map {&#174; \174 &quot; \" &middot; · &amp; &} [subst [regsub -nocase -all {&#([0-9]{1,5});} $textin {\u\1}]]]
}
bind pub - ${xblchar}xbl xblinfo
bind pub - ${xblchar}xblgs xblgsinfo
setudef flag xblinfo
putlog "Xbox Live Gamertag status' by Danneh/GrimReaper"
