::  picky.hoon
::  chat admin dashboard backend
::
/-  picky, md=metadata-store, store=chat-store
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
      ~&  >>  (~(run by my-chats:hc) |=(rs=(set md-resource:md) (~(run in rs) scry-mailbox:hc)))
      `state
      ::
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
+$  group-apps
  [group-path:md (list md-resource:md)]
++  my-chats
  ^-  (jug group-path:md md-resource:md)
  =/  my-groups=(list group-apps)
    (skim groups-metadata is-my-group)
  =/  only-chats=(list group-apps)
    %+  skim
      (turn my-groups yank-chats)
      has-chat
  %-  ~(gas by *(jug group-path:md md-resource:md))
    %+  turn  only-chats
    |=  gi=group-apps
    [-.gi (sy +.gi)]
++  is-my-group
  |=  gi=group-apps
  ?&
    ?=([%ship @ *] -.gi)
    =(i.t.-.gi (scot %p our.bowl))
  ==
++  is-chat
  |=  rs=md-resource:md
  =(app-name.rs %chat)
++  has-chat
  |=  gi=group-apps
  ?~(+.gi %.n %.y)
++  yank-chats
  |=  gi=group-apps
  ^-  group-apps
  [-.gi (skim +.gi is-chat)]
++  groups-metadata
  ^-  (list group-apps)
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
  ^-  (list group-apps)
  %~  tap  by
  %-  ~(run by ginfo)
    |=  ms=(set md-resource:md)
  ~(tap in ms)
++  scry-mailbox
  |=  r=md-resource:md
  .^
    (unit mailbox:store)
    %gx
    (scot %p our.bowl)
    %chat-store
    (scot %da now.bowl)
    %mailbox
    (snoc `path`app-path.r %noun)
  ==
--
