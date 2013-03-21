;----------------------------------------------------------------------------
; * Name    :    Anope Services Alias
; * Author  :    Radien (brandon)
;                IRC: channel #damdevil in irc.damdevil.org
;                Web: http://code.google.com/p/itechnet/source/browse/trunk/mIRC%20Scripts/Radien/
; * Version :    0.2
; * Date    :    May 13th, 2011
; * Notes   :    You type /xop vop/hop/sop/aop/fop *nick*
;                You can remove alias from line 1 and put in your
;                Aliases part of mIRC or leave it like so and 
;                put in Remotes
;----------------------------------------------------------------------------

alias xop {
  if ($$1 == vop) { cs $v2 $active add $$2 | cs access $active add $$2 3 | cs sync $active }
  if ($$1 == hop) { cs $v2 $active add $$2 | cs access $active add $$2 4 | cs sync $active }
  if ($$1 == sop) { cs $v2 $active add $$2 | cs access $active add $$2 5 | cs sync $active }
  if ($$1 == aop) { cs $v2 $active add $$2 | cs access $active add $$2 10 | cs sync $active }
  if ($$1 == fop) { cs access $active add $$2 9999 | cs sync $active } 
}
