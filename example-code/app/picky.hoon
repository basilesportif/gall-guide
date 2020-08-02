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
+$  chat-path  path
+$  user-summary
  $:  msgs=(list envelope:store)
      num-week=@
      num-month=@
  ==
+$  chat-summary
  [=chat-path length=@ activity=(map ship user-summary)]
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
      =/  v
        %-  ~(run by my-chats:hc)
        |=  cs=(set chat-path)
        (~(run in cs) |=([pax=chat-path] (stats:hc pax)))
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
  ^-  (jug group-path:md chat-path)
  =/  my-groups=(list group-apps)
    (skim groups-metadata is-my-group)
  =/  only-chats=(list group-apps)
    %+  skim
      (turn my-groups yank-chats)
      has-chat
  %-  ~(gas by *(jug group-path:md chat-path))
  %+  turn  only-chats
    |=  ga=group-apps
    [-.ga (sy (turn +.ga app-to-chat))]
++  is-my-group
  |=  ga=group-apps
  ?&
    ?=([%ship @ *] -.ga)
    =(i.t.-.ga (scot %p our.bowl))
  ==
++  app-to-chat
  |=  r=md-resource:md
  ^-  chat-path
  app-path.r
++  is-chat
  |=  rs=md-resource:md
  =(app-name.rs %chat)
++  has-chat
  |=  ga=group-apps
  ?~(+.ga %.n %.y)
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
  |=  pax=chat-path
  .^
    (unit mailbox:store)
    %gx
    (scot %p our.bowl)
    %chat-store
    (scot %da now.bowl)
    %mailbox
    (snoc `path`pax %noun)
  ==
++  stats
  |=  pax=chat-path
  ^-  chat-summary
  =/  m=(unit mailbox:store)
    (scry-mailbox pax)
  ?~  m  *chat-summary
  :*  pax
      length.config.u.m
      (chat-activity envelopes.u.m)
  ==
++  after-date
  |=  [interval=@dr d=@da]
  (gte d (sub now.bowl interval))
++  chat-activity
  |=  es=(list envelope:store)
  ^-  (map ship user-summary)
  =/  msg-cutoff=@  20
  =|  acc=(map ship user-summary)
  |-
  ?~  es  acc
  =*  e  i.es
  =/  us=user-summary
    (~(gut by acc) author.e *user-summary)
  =.  us
    :*  ?:((lth (lent msgs.us) msg-cutoff) (snoc msgs.us e) msgs.us)
        ?:((after-date ~d7 when.e) +(num-week.us) num-week.us)
        ?:((after-date ~d30 when.e) +(num-month.us) num-month.us)
    ==
  $(es t.es, acc (~(put by acc) author.e us))
--
