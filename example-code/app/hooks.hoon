::  hooks.hoon
::  Groups and hooks
::
/-  hooks, *group, *resource
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
  ~&  >  '%hooks initialized successfully'
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%hooks recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
        %hooks-action  (handle-action !<(action:hooks vase))
    ==
  [cards this]
  ::
  ++  handle-action
    |=  =action:hooks
    ^-  (quip card _state)
    ?-    -.action
        %scry-group
      =/  g=(unit group)
        (scry-group:grp rid.action)
      ~&  >>>  "scry me a river: {<g>}"
      `state
      ::
        %scry-all
      =/  gs=(set resource)  scry-all-groups
      ~&  >>>  "scry:  {<gs>}"
      `state
    ==
  ++  scry-all-groups
    ^-  (set resource)
    =/  a=arch
      .^  arch
        %gy
        (scot %p our.bowl)
        %group-store
        (scot %da now.bowl)
        /groups
      ==
    %-  ~(run in ~(key by dir.a))
      (cork stab path-to-resource)
  ++  path-to-resource
    |=  =path
    ?>  ?=([%ship @ta @tas ~] path)
    ^-  resource
    [(ship (slav %p i.t.path)) (term i.t.t.path)]
  --
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
