;----------------------------------------------------------------------------
; * Name    :    BNC Connect
; * Author  :    Radien (brandon)
;                IRC: channel #damdevil in irc.tornadoircc.om
;                Web: http://code.google.com/p/itechnet
; * Version :    0.1
; * Date    :    May 13th, 2011
; * Notes   :    Type /bnc TornadoIRC to connect to first in the list
;----------------------------------------------------------------------------

alias bnc {
  if ($1- == TornadoIRC) { server -m irc.example.com:8890 user:pass }
  if ($1- == FireFlyIRC) { server -m irc.example.com:8890 user:pass }
  if ($1- == GeekShed) { server -m irc.example.com:8890 user:pass }
  if ($1- == AllredNC) { server -m irc.example.com:8890 user:pass }
}

