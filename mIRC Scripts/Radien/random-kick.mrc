;----------------------------------------------------------------------------
; * Name    :    Random Kick w/Reason
; * Author  :    Radien (brandon)
;                IRC: channel #damdevil in irc.tornadoirc.com
;                Web: http://code.google.com/p/itechnet/source/browse/trunk/mIRC%20Scripts/Radien/
; * Version :    0.1
; * Date    :    May 13th, 2011
; * Notes   :    Place in your Aliases and Press F5 after you clicked a nick
;----------------------------------------------------------------------------

;Aliases Script!
F5 { set %sniped $rand(1,7) 
  if (%sniped == 1) /kick $chan $$1 Everyone hates you so why not just leave? 
  if (%sniped == 2) /kick $chan $$1 Please leave so that the other users can enjoy their time without you
  if (%sniped == 3) /kick $chan $$1 You have been found wanted! (to leave) 
  if (%sniped == 4) /kick $chan $$1 out OUT $+ $+ !!  
  if (%sniped == 5) /kick $chan $$1 I give up $$1 have my foot, and leave?
  if (%sniped == 6) /kick $chan $$1 BOO
  if (%sniped == 7) /kick $chan $$1 $$1 $+ , have been Kicked by $me $+ , have a great day
}
