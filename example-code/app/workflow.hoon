/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-0
    ==
+$  state-0  [%0 counter=tape]
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this     .
    default  ~(. (default-agent this %.n) bowl)
::
++  on-init
  ~&  >  'on-init'
  `this(state [%0 "skl"])
++  on-save
  ^-  vase
  !>(state)
++  on-load
  ~&  >  '%workflow loaded'
  ::  something that sets new state to old state
  on-load:default
++  on-poke  on-poke:default
::
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
