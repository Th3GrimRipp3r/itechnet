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


