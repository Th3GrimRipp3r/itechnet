;----------------------------------------------------------------------------
; * Name    :    Cookies
; * Author  :    Radien (brandon) orginally Phil of GeekShed
;                IRC: channel #damdevil in irc.damdevil.org
;                Web: http://code.google.com/p/itechnet/source/browse/trunk/mIRC%20Scripts/Radien/
; * Version :    0.1
; * Date    :    May 13th, 2011
; * Notes   :    Type /cookies *nick* (-/+)#of cookies
;                You don't need the + if your giving cookies
;----------------------------------------------------------------------------

alias cookies {
  if ($1 != $null && $2 != $null) {
    unset %cookiesval
    unset %cookiecount
    unset %cookiework
    unset %cookiewordtwo
    set %cookiesval $read(cookies.txt, s, $1)
    if ($readn == 0) {
      set %cookiecount $2
    }
    else {
      set %cookiecount $calc(%cookiesval + $2)
      /write -dl $+ $readn cookies.txt
    }
    if ($2 == 1 || $2 == -1) {
      set %cookieword cookies
    }
    else {
      set %cookieword cookies
    }
    if (%cookiecount == 1) {
      set %cookiewordtwo cookies
    }
    else {
      set %cookiewordtwo cookies
    }
    /write cookies.txt $1 %cookiecount
    /describe $active gives $1 $2 %cookieword $+ . $1 has received %cookiecount %cookiewordtwo $+ .
  }
  else {
    echo -a Error: The format of this command is /cookie <nickname> <cookie_count>
  }

}


