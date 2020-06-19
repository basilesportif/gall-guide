/-  poketime
/+  default-agent
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 counter=@ud]
    ==
::
+$  card  card:agent:gall
::
--
=|  state=versioned-state
^-  agent:gall
=<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%poketime initialized successfully'
  =.  state  [%0 0]
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%poketime recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?>  (team:title our.bowl src.bowl)
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >>  state
      ~&  >>>  bowl  `this
      ::
        %poke-self
      :_  this
      ~[[%pass /poke-self/pokepath %agent [~zod %poketime] %poke %noun !>([%receive-poke 2])]]
      ::
        [%receive-poke @]
        ~&  >  "got poked with val: "
        ~&  >  +.q.vase  `this
    ==
    ::
      %poketime-action
      ~&  >  !<(action:poketime vase)
      =^  cards  state
      (handle-action !<(action:poketime vase))
      [cards this]
  ==
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+     path  (on-watch:def path)
      [%counter ~]
    ~&  >>  "got counter subscription"  `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%poke-self %pokepath ~]
    ~&  >>  -.sign  `this
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::  start helper core
|_  bowl=bowl:gall
++  handle-action
  |=  =action:poketime
  ^-  (quip card _state)
  ?-    -.action
      %increase-counter
    `state(counter (add step.action counter.state))
    ::
      %subscribe
    :_  state
    ~[[%pass /poketime/(scot %p src.action)/counter %agent [src.action %poketime] %watch /counter]]
    ::
      %leave
    :_  state
    ~[[%pass /poketime/(scot %p src.action)/counter %agent [src.action %poketime] %leave ~]]
  ==
--
