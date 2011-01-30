alias vop {
  cs vop $active add $$1
  if ($1 ison $active) { cs sync $active }
  else { halt }
}
alias chop {
  cs hop $active add $$1
  if ($1 ison $active) { cs sync $active }
  else { halt }
}
alias sop {
  cs sop $active add $$1
  if ($1 ison $active) { cs sync $active }
  else { halt }
}
alias aop {
  cs aop $active add $$1
  if ($1 ison $active) { cs sync $active }
  else { halt }
}
