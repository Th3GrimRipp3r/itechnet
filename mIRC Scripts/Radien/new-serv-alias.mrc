;----------------------------------------------------------------------------
; * Name    :    New Services Alias
; * Author  :    Radien (brandon)
;                IRC: channel #damdevil in irc.tornadoircc.om
;                Web: http://code.google.com/p/itechnet
; * Version :    0.1
; * Date    :    May 13th, 2011
; * Notes   :    This works with Atheme flags settings just replace TornadoIRC
;                     with which ever network you chat on that uses Atheme
;                Anope's Access and xop lists
;                Aswell as sends a Sync command.
;----------------------------------------------------------------------------
alias vop {
  if ($network == TornadoIRC) { cs flags $active $$1 +vV | cs sync $active }
  elseif ($network != TornadoIRC) { cs vop $active add $$1 | cs access $active add $$1 3 | cs sync $active }
  else { halt }
}
alias chop {
  if ($network == TornadoIRC) { cs flags $active $$1 +vVhH | cs sync $active }
  elseif ($network != TornadoIRC) { cs hop $active add $$1 | cs access $active add $$1 4 | cs sync $active }
  else { halt }
}
alias sop {
  if ($network == TornadoIRC) { cs flags $active $$1 +vVhHoO | cs sync $active }
  elseif ($network != TornadoIRC) { cs sop $active add $$1 | cs access $active add $$1 5 | cs sync $active }
  else { halt }
}
alias aop {
  if ($network == TornadoIRC) { cs flags $active $$1 +vVhHoOa | cs sync $active }
  elseif ($network != TornadoIRC) { cs aop $active add $$1 | cs access $active add $$1 10 | cs sync $active }
  else { halt }
}
alias oop {
  if ($network == TornadoIRC) { cs flags $active $$1 +* | cs sync $active }
  elseif ($network != TornadoIRC) { echo this is a Access List only command | cs access $active add $$1 9999 | cs sync $active }
  else { halt }
}
