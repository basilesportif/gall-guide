::  mars.hoon
::  Groups and hooks
::
/-  ghooks, *group
/+  default-agent, dbug, store=group-store, group-lib=group
|%
+$  versioned-state
    $%  state-0
    ==
::
+$  state-0
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
+*  this  .
    def   ~(. (default-agent this %|) bowl)
    grp   ~(. group-lib bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%ghooks initialized successfully'
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%ghooks recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
        %ghooks-action  (handle-action !<(action:ghooks vase))
    ==
  [cards this]
  ::
  ++  handle-action
    |=  =action:ghooks
    ^-  (quip card _state)
    ?-    -.action
        %scry-group
      =/  g=(unit group)
        (scry-group:grp rid.action)
      ~&  >>>  "scry me a river: {<g>}"
      `state
      ::
        %scry-all
      =/  gs=(set @t)  scry-all-groups
      ~&  >>>  "scry: {<gs>}"
      `state
      ::`state(local-groups (~(gas in state.local-groups) gs))
    ==
  ++  scry-all-groups
    ^-  (set @t)
    =/  a=arch
      .^  arch
        %gy
        (scot %p our.bowl)
        %group-store
        (scot %da now.bowl)
        /groups
      ==
    ~(key by dir.a)
  --
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
