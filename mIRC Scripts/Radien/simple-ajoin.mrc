;----------------------------------------------------------------------------
; * Name    :    Simple Auto Join
; * Author  :    Radien (brandon)
;                IRC: channel #damdevil in irc.damdevil.org
;                Web: http://code.google.com/p/itechnet/source/browse/trunk/mIRC%20Scripts/Radien/
; * Version :    0.1
; * Date    :    April 18th, 2012
; * Notes   :    Edit Data and place in remotes.
;----------------------------------------------------------------------------

on *:start: {
server irc.damdevil.org
server -m irc.ffirc.me.uk
server -m irc.ipocalypse.net
server -m irc.geekshed.net
server -m irc.example.com
}

on *:connect: {
if ($network == TornadoIRC) { nick Radien | msg nickserv id somepass | join #lobby,#damdevil,#as,#many,#channels,#here,#as,#you,#want }
if ($network == FireFlyIRC) { nick Radien | msg nickserv id somepass | join #firefly,#damdevil }
if ($network == iPocalypse) { nick Radien | msg nickserv id somepass | join #firefly,#damdevil }
if ($server == some.irc.server) { nick Radien | msg nickserv id somepass | join #firefly,#damdevil }
}
