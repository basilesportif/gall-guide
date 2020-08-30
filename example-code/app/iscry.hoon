::  iscry.hoon
::  simple scry returns to demonstrate mechanics
::
/+  dbug, default-agent
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0
    $:  [%0 friend=ship]
    ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-0
=*  state  -
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%iscry initialized successfully'
  `this(friend.state ~timluc-miptev)
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%iscry recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-peek
  |=  pax=path
  ^-  (unit (unit cage))
  ?+    pax  (on-peek:def pax)
      [%y %result ~]
    =/  =arch
      :-  ~
      %-  ~(put by *(map @ta ~))
        ['fake-dir' ~]
    ``noun+!>(arch)
    ::
      [%x %friend ~]
    ``noun+!>(friend)
    ::
      [%x %no-result ~]
    [~ ~]
  ==
++  on-poke   on-poke:def
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
