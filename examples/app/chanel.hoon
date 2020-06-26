/-  chanel
/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 counter=@]
    ==
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state=versioned-state
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%chanel initialized successfully'
  =.  state  [%0 0]
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%chanel recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >>  state
      ~&  >>>  bowl  `this
      ::
        %print-subs
      ~&  >>  &2.bowl  `this
      ::
        %poke-self
      ?>  (team:title our.bowl src.bowl)
      :_  this
      ~[[%pass /poke-wire %agent [our.bowl] %poke %noun !>([%receive-poke 2])]]
      ::
        [%receive-poke @]
        ~&  >  "got poked from {<src.bowl>} with val: {<+.q.vase>}"  `this
    ==
    ::
      %poketime-action
      ~&  >>>  !<(action:poketime vase)
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
      ~&  >>  "got counter subscription from {<src.bowl>}"  `this
  ==
++  on-leave
  |=  =path
  ~&  "got counter leave request from {<src.bowl>}"  `this
++  on-peek   on-peek:def
++  on-agent
  |=  [=wire =sign:agent:gall]
  ^-  (quip card _this)
  ?+    wire  (on-agent:def wire sign)
      [%counter @ ~]
      ?+  -.sign  (on-agent:def wire sign)
        %fact
      =/  val=@  !<(@ q.cage.sign)
      ~&  >>  "counter val on {<src.bowl>} is {<val>}"
      `this
      ==
      ::
      [%poke-wire ~]
    ?~  +.sign
      ~&  >>  "successful {<-.sign>}"  `this
    (on-agent:def wire sign)
  ==
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
