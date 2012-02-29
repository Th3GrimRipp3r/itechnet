alias links {
  .enable #DAL-Links2
  .links
}

menu @servers {
  refresh map:linksandshow baseNo
  save to desktop:drawsave -q100 @Servers "C:\Documents and Settings\All Users\Desktop\wIRCServerMap.jpeg"
}

#DAL-Links2 off
;a typical /LINKS Line
raw 364:*:{
  %sg.firstserver = 1
  %sg.secondserver = 1
  if ( %sg.links. [ $+ [ $2 ] ] != $null ) set %sg.firstserver %sg.links. [ $+ [ $2 ] ] 
  else {
    inc %sg.linkscount
    set %sg.links. [ $+ [ $2 ] ] %sg.linkscount
    set %sg.firstserver %sg.linkscount
    set %sg.servers. [ $+ [ %sg.linkscount ] ] $2
    set %sg.hop. [ $+ [ %sg.linkscount ] ] $4
  }
  if ( %sg.links. [ $+ [ $3 ] ] != $null ) set %sg.secondserver %sg.links. [ $+ [ $3 ] ]
  else {
    inc %sg.linkscount
    set %sg.links. [ $+ [ $3 ] ] %sg.linkscount
    set %sg.secondserver %sg.linkscount
    set %sg.servers. [ $+ [ %sg.linkscount ] ] $3
    set %sg.hop. [ $+ [ %sg.linkscount ] ] $4
  }
  if ( ( %sg.setting.basemyserver == 1 ) || ( %sg.firstserver != %sg.secondserver ) ) {
    set %sg.link.con. [ $+ [ %sg.firstserver ]  $+ ] . [ $+ [ %sg.secondserver ] ] 1
    set %sg.link.con. [ $+ [ %sg.secondserver ]  $+ ] . [ $+ [ %sg.firstserver ] ] 1 
    if (%temp.debug == ON) echo @DeBug.Servers $2 $3 %sg.links. [ $+ [ $2 ] ] %sg.links. [ $+ [ $3 ] ] %sg.linkscount %sg.firstserver %sg.secondserver
  }
  if ($4 > %sg.hop.max) { set %sg.hop.max $4 }
  halt
}
;End of /LINKS list.
raw 365:*:{
  echo -at 12-(1313info12!11MAP: Retrieved Links, Calculating Map Items.. Please be patient...12)-  
  .disable #DAL-Links2
  set %sg.language EN
  unset %sg.links.*
  .timer -om 1 10 showservergraph 
  set %sg.setting.showonlinks $false
  halt
}
#DAL-Links2 end
alias linksandshow {
  unset %con.* %no.* %distAngle %txcolor %digits %m 
  unset %sg.* %lev.* %graphised.* %sg.hop.*
  unset %place* %pos* %x.* %y.*
  unset %sibling.* %unc.* %rec.*
  unset %origindeg.* %stDist.* %endDist.*
  unset %n %r %Pi %debug %i %j 
  unset %t %highest %unleveledcount %greatestlev 
  unset %k %deep %maxx %maxy %minx %miny 
  unset %temp.debug
  if ( %sg.Language == $null ) { set %sg.language EN }
  echo -at 12-(1313info12!11MAP: Getting links for map... please wait...12)-  
  if ( $1 == $null ) set %sg.setting.basemyserver 0
  elseif ( $1 == baseNo ) set %sg.setting.basemyserver 0
  else set %sg.setting.basemyserver 1
  set %sg.hop.max 0
  set %sg.max.con 0
  set %sg.setting.showonlinks $true
  set %sg.linkscount 0
  .enable #DAL-Links2
  .disable #RAW.FailOver
  links
}
alias showservergraph {
  ;initialisation
  %n = %sg.linkscount
  ;element count
  %r = 50 
  ;distance of two elements
  %Pi = 3.141592
  %debug = 0
  ;create connections table
  %i = 1
  :contable1
  %j = 1
  :contable2
  if ( $sglinkcon(%i,%j) == 1 ) set %con. [ $+ [ %i  ] $+ ] . [ $+ [ %j ] ] 1
  else set %con. [ $+ [ %i ] $+ ] . [ $+ [ %j ] ] 0
  if (%j < %n) { inc %j | goto contable2 }
  if (%i < %n) { inc %i | goto contable1 }
  ;calculate levels
  %i = 1
  :calclevs1
  %lev. [ $+ [ %i ] ] = -1
  if (%i < %n) { inc %i | goto calclevs1 }
  %highest = 1
  ;element having the highest level
  %i = 0
  :calclevs2
  %j = 1
  :calclevs3
  if (%lev. [ $+ [ %j ] ] > -1) goto 220
  %unleveledcount = 0 |  %greatestlev = -1
  %k = 1
  :calclevs4
  if ( $con(%j,%k) > 0 ) {
    if ( %lev. [ $+ [ %k ] ] == -1 ) inc %unleveledcount
    if ( %lev. [ $+ [ %k ] ] > %greatestlev ) {
      set %greatestlev %lev. [ $+ [ %k ] ]
    }
  }
  if (%k < %n ) { inc %k | goto calclevs4 }
  if ( ( %unleveledcount < 2 ) && ( %i == $calc( %greatestlev + 1 ) ) ) { set %lev. [ $+ [ %j ] ] %i | if ( %i > %lev. [ $+ [ %highest ] ] ) { %highest = %j } }
  :220
  if (%j < %n ) { inc %j | goto calclevs3 } | if (%i < $calc(%n -1) ) { inc %i | goto calclevs2 }
  ;graphisation
  window -p $sgtext(win) | clear $sgtext(win) | drawfill -h $sgtext(win) 1 0 1 1
  %i = 1
  :graph1
  %graphised. [ $+ [ %i ] ] = 0
  if (%i < %n) { inc %i | goto graph1 }
  %deep = 1
  %no.1 = %highest
  %origindeg.1 = -1
  %maxx = -10000
  %maxy = -10000
  %minx = +10000
  %miny = +10000
  %posX.1 = $calc($window($sgtext(win)).w /2)
  %posY.1 = $calc($window($sgtext(win)).h /2)
  :1000
  %placeX. [ $+ [ $no(%deep) ] ] = %posX. [ $+ [ %deep ] ]
  %placeY. [ $+ [ $no(%deep) ] ] = %posY. [ $+ [ %deep ] ]
  if ( %posX. [ $+ [ %deep ] ] > %maxx ) %maxx = %posX. [ $+ [ %deep ] ]
  if ( %posX. [ $+ [ %deep ] ] < %minx ) %minx = %posX. [ $+ [ %deep ] ]
  if ( %posY. [ $+ [ %deep ] ] > %maxy ) %maxy = %posY. [ $+ [ %deep ] ]
  if ( %posY. [ $+ [ %deep ] ] < %miny ) %miny = %posY. [ $+ [ %deep ] ]
  %graphised. [ $+ [ $no(%deep) ] ] = 1
  %unc. [ $+ [ %deep ] ] = 0
  %x = 1
  :graph2
  if ( ( $con($no(%deep),%x) == 1 ) && ( %graphised. [ $+ [ %x ] ] == 0 ) ) inc %unc. [ $+ [ %deep ] ]
  if (%x < %n) { inc %x | goto graph2 }
  if (%temp.debug == ON) echo @DeBug.Servers UNC %unc. [ $+ [ %deep ] ]
  if ( %unc. [ $+ [ %deep ] ] == 0 ) goto 1400
  if ( %origindeg. [ $+ [ %deep ] ] > -1 ) {
    %stDist. [ $+ [ %deep ] ] = $calc( %origindeg. [ $+ [ %deep ] ] -90 + 180 / ( %unc. [ $+ [ %deep ] ] + 1 ) )
    %endDist. [ $+ [ %deep ] ] = $calc( %origindeg. [ $+ [ %deep ] ] +90 - 180 / ( %unc. [ $+ [ %deep ] ] + 1 ) )
  }
  else { %stDist. [ $+ [ %deep ] ] = 0 | %endDist. [ $+ [ %deep ] ] = 360 }
  %sibling. [ $+ [ %deep ] ] = 0
  %rec. [ $+ [ %deep ] ] = 1
  :1115
  %i = %rec. [ $+ [ %deep ] ]
  if ( ( %graphised. [ $+ [ %i ] ] == 0 ) && ( $con($no(%deep),%i) == 1) ) {
    inc %sibling. [ $+ [ %deep ] ]
    if ( %unc. [ $+ [ %deep ] ] == 1 ) { %distAngle = %origindeg. [ $+ [ %deep ] ] | goto 1145 }
    if ( %origindeg. [ $+ [ %deep ] ] == -1 ) {
      %distAngle = $calc( %stDist. [ $+ [ %deep ] ] + ( %sibling. [ $+ [ %deep ] ] - 1 ) * ( %endDist. [ $+ [ %deep ] ] - %stDist. [ $+ [ %deep ] ] ) / %unc. [ $+ [ %deep ] ] )
      goto 1145
    }
    %distAngle = $calc( %stDist. [ $+ [ %deep ] ] + ( %sibling. [ $+ [ %deep ] ] - 1 ) * ( %endDist. [ $+ [ %deep ] ] - %stDist. [ $+ [ %deep ] ] ) / $calc( %unc. [ $+ [ %deep ] ] - 1 ) )
    :1145
    if ( %distAngle < 0 ) set %distAngle %distAngle + 360
    inc %deep
    set %no. [ $+ [ %deep ] ] %i
    %origindeg. [ $+ [ %deep ] ] = %distAngle
    %posX. [ $+ [ %deep ] ] = $calc( %posX. [ $+ [ $calc( %deep - 1 ) ] ] + $cos( $calc( %distAngle * %Pi / 180 ) ) * %r )
    %posY. [ $+ [ %deep ] ] = $calc( %posY. [ $+ [ $calc( %deep - 1 ) ] ] - $sin( $calc( %distAngle * %Pi / 180 ) ) * %r )
    goto 1000
  }
  :1200
  if ( %rec. [ $+ [ %deep ] ] < %n ) { inc %rec. [ $+ [ %deep ] ] | goto 1115 }
  :1400
  if ( %deep > 1 ) { dec %deep | goto 1200 }
  ;visualisation

  %i = 1
  :visual1
  %x. [ $+ [ %i ] ] = $calc( ( %placeX. [ $+ [ %i ] ] - %minx ) / ( %maxx - %minx ) * $window($sgtext(win)).w *4/5 + $window($sgtext(win)).w / 10)
  %y. [ $+ [ %i ] ] = $calc( ( %placeY. [ $+ [ %i ] ] - %miny ) / ( %maxy - %miny ) * $window($sgtext(win)).h *7/10 + $window($sgtext(win)).h / 10)
  %j = 1
  :visual2
  if ( $con(%i,%j) == 1 ) drawline -h $sgtext(win) 14 $calc(%lev. [ $+ [ %i ] ] + %lev. [ $+ [ %j ] ] +1) %x. [ $+ [ %i ] ] %y. [ $+ [ %i ] ] %x. [ $+ [ %j ] ] %y. [ $+ [ %j ] ]
  if (%j < %n) { inc %j | goto visual2 }
  if (%i < %n) { inc %i | goto visual1 }
  %i = 1
  :visual3
  %sg.max.con. [ $+ [ %i ] ] = $sg.getlinks(%i)
  if (%sg.max.con. [ $+ [ %i ] ] > 0) { dec %sg.max.con. [ $+ [ %i ] ] }
  if (%sg.max.con. [ $+ [ %i ] ] > %sg.max.con ) { set %sg.max.con %sg.max.con. [ $+ [ %i ] ] }
  %txcolor = 0
  %lev.tmp = %sg.max.con. [ $+ [ %i ] ]
  if (%lev.tmp < 1)  %color.dot = 9
  if (%lev.tmp = 1)  %color.dot = 8
  if (%lev.tmp = 2)  %color.dot = 7
  if (%lev.tmp = 3)  %color.dot = 5
  if (%lev.tmp > 3)  %color.dot = 4
  if ( %i > 9 )  %digits = 2
  else  %digits = 1
  set %sg.i.srv $gettok( %sg.servers. [ $+ [ %i ] ] ,1-2,46)
  set %m $len(%sg.i.srv)
  if (%sg.servers. [ $+ [ %i ] ] = $server) { drawdot -h $sgtext(win) 14 $calc($calc(6+ %lev. [ $+ [ %i ] ] ) * 3) %x. [ $+ [ %i ] ] %y. [ $+ [ %i ] ] | %color.txt = 4 }
  else { drawdot -h $sgtext(win) 12 $calc($calc(7+ %lev. [ $+ [ %i ] ] ) * 2) %x. [ $+ [ %i ] ] %y. [ $+ [ %i ] ] | %color.txt = 0 }
  drawdot -h $sgtext(win) %color.dot $calc($calc(6+ %lev. [ $+ [ %i ] ] ) * 2) %x. [ $+ [ %i ] ] %y. [ $+ [ %i ] ]
  drawtext -oh $sgtext(win) 1 "Arial" 17 $calc(%x. [ $+ [ %i ] ] -5* %digits) $calc(%y. [ $+ [ %i ] ] -10) %i
  drawtext -oh $sgtext(win) %color.txt "Arial" 14 $calc(%x. [ $+ [ %i ] ] -5* %digits - %m * 2) $calc(%y. [ $+ [ %i ] ] +10) %sg.i.srv
  drawtext -h $sgtext(win) 0 "Arial" 13 $calc(%x. [ $+ [ %i ] ] -5* %digits - %m * 2) $calc(%y. [ $+ [ %i ] ] +22) %lev.tmp leaf(s).
  drawtext -h $sgtext(win) 0 "Arial" 13 $calc(%x. [ $+ [ %i ] ] -5* %digits - %m * 2) $calc(%y. [ $+ [ %i ] ] +32) %sg.hop. [ $+ [ %i ] ] hop(s).
  if (%i < %n) { inc %i | goto visual3 }
  drawdot $sgtext(win)
  drawtext -bh $sgtext(win) 0 1 "Arial" 14 20 35 $upper($gettok($server,1,46)) - $upper($sg.servernet)
  drawtext -bh $sgtext(win) 0 1 "Arial" 14 20 50 %sg.linkscount Total Servers Online.
  drawtext -bh $sgtext(win) 0 1 "Arial" 14 20 65 %sg.hop.max Max hop(s) - %sg.max.con Max leaf(s).
  drawtext -bh $sgtext(win) 0 1 "Arial" 14 20 80 Dated: $fulldate
  ;finalisation
  unset %con.* %no.* %distAngle %txcolor %digits %m 
  unset %sg.* %lev.* %graphised.* %sg.hop.*
  unset %place* %pos* %x.* %y.*
  unset %sibling.* %unc.* %rec.*
  unset %origindeg.* %stDist.* %endDist.*
  unset %n %r %Pi %debug %i %j 
  unset %t %highest %unleveledcount %greatestlev 
  unset %k %deep %maxx %maxy %minx %miny 
  unset %temp.debug
  set %sg.Language EN
  window -a  $sgtext(win)
  echo -at 12-(1313info12!11MAP: Finished...You can save the image by right clicking on it...12)-  
}
alias sg.getlinks {
  var %sg.tmp = 0
  var %sg.maxed = 0
  while (%sg.tmp <= %sg.linkscount) {
    inc %sg.tmp
    %sg.maxed = $calc(%sg.maxed + $sglinkcon($1,%sg.tmp))
  }
  return %sg.maxed
}
alias ifTrue { if ($1) return $2- }
alias con { %t = con. $+ $1 $+ . $+ $2 | return % [ $+ [ %t ] ] }
alias sglinkcon { %t = sg.link.con. $+ $1 $+ . $+ $2 | return % [ $+ [ %t ] ] }
alias no { %t = no. [ $+ [ $1 ] ] | return % [ $+ [ %t ] ] }
alias drawtest {
  set %sg.language EN
  window -p $sgtext(win)
  drawtext -bh $sgtext(win) 11 8 "Arial" 14 40 40 irc.ContraIRC.Net
  drawtext -bh $sgtext(win) 11 1 "Times New Roman" 18 $calc($window($sgtext(win)).w - 130) $calc($window($sgtext(win)).h - 40) ServerGraph v1 by <someone>
}
alias sgtext {
  if ($1 == process) return @Servers...
  if ($1 == win) return @Servers
  if ($1 == init) return Initialisation...
  if ($1 == contable) return Creating connections table...
  if ($1 == calclevs) return Calculating levels...
  if ($1 == graph) return Allocating elements...
  if ($1 == vislines) return Drawing lines...
  if ($1 == visdots) return Drawing servers...
  if ($1 == final) return Finalizing...
  if ($1 == OK) return OK
}
alias sg.servernet {
  %tmp.cnt = 0
  while ($gettok($server,%tmp.cnt,46) != $null) {
    inc %tmp.cnt
    %tmp.chk = $gettok($server,%tmp.cnt,46)
    if ((org = %tmp.chk) || (net = %tmp.chk) || (com = %tmp.chk)) {
      %tmp.bef = $calc(%tmp.cnt - 1)
      return $gettok($server,%tmp.bef,46) $+ . $+ %tmp.chk
    }
  }
  %tmp.bef = $calc(%tmp.cnt - 1)
  return Unknown $+ . $+ $gettok($server,%tmp.bef,46)
}
