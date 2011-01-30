alias banall { 
  var %x = $chan(0) 
  while (%x) { 
    mode $chan(%x) $$1 $+ bbbbbb $$2-
    dec %x 
  } 
}

