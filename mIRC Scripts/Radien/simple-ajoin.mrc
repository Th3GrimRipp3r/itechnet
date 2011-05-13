;----------------------------------------------------------------------------
; * Name    :    Simple Auto JOin
; * Author  :    Radien (brandon)
;                IRC: channel #damdevil in irc.tornadoircc.om
;                Web: http://code.google.com/p/itechnet
; * Version :    0.1
; * Date    :    May 13th, 2011
; * Notes   :    Edit Data and place in remotes.
;----------------------------------------------------------------------------

on *:start: {
server irc.tornadoirc.com
server -m irc.ffirc.me.uk
server -m irc.ipocalypse.net
server -m irc.geekshed.net
server -m irc.example.com
}

on *:connect: {
if ($network == TornadoIRC) { nick Radien | msg nickserv id somepass | join #lobby,#damdevil }
if ($network == FireFlyIRC) { nick Radien | msg nickserv id somepass | join #firefly,#damdevil }
if ($network == iPocalypse) { nick Radien | msg nickserv id somepass | join #hell }
}
