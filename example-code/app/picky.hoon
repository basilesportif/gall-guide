::  picky.hoon
::  chat admin dashboard backend
::
/-  picky, md=metadata-store
/+  dbug, default-agent, group-lib=group
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
=|  state-0
=*  state  -
^-  agent:gall
=<
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
    hc    ~(. +> bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%picky initialized successfully'
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%picky recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
  ?+    mark  (on-poke:def mark vase)
      %picky-action
    (poke-action !<(action:picky vase))
  ==
  [cards this]
  ++  poke-action
    |=  =action:picky
    ^-  (quip card _state)
    ?-    -.action
        %load-chats
      ~&  >>  my-chats:hc
      `state
        %dummy
      `state
    ==
  --
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
|_  =bowl:gall
+*  grp  ~(. group-lib bowl)
+$  group-info
  [group-path:md (list md-resource:md)]
++  my-chats
  =/  my-groups=(list group-info)
    (skim groups-metadata is-my-group)
  =/  with-chats=(list group-info)
    %+  skim
      (turn my-groups yank-chats)
      has-chat
  with-chats
++  is-my-group
  |=  gi=group-info
  ?&
    ?=([%ship @ *] -.gi)
    =(i.t.-.gi (scot %p our.bowl))
  ==
++  is-chat
  |=  rs=md-resource:md
  =(app-name.rs %chat)
++  has-chat
  |=  gi=group-info
  ?~(+.gi %.n %.y)
++  yank-chats
  |=  gi=group-info
  ^-  group-info
  [-.gi (skim +.gi is-chat)]
++  groups-metadata
  ^-  (list group-info)
  %-  denest-groups
  .^
    (jug group-path:md md-resource:md)
    %gy
    (scot %p our.bowl)
    %metadata-store
    (scot %da now.bowl)
    /group-indices
  ==
++  denest-groups
  |=  ginfo=(jug group-path:md md-resource:md)
  ^-  (list group-info)
  %~  tap  by
  %-  ~(run by ginfo)
    |=  ms=(set md-resource:md)
  ~(tap in ms)
--
