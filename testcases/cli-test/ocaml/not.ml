let not x = 
    ((x - 1) lxor (x land (x - 1))) lsr 62
;;
 
not 0;;
 
not 1;;
 
not (-1);;
 
not (1 lsl 62);;
