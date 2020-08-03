::  picky.hoon
::  chat admin dashboard backend
::
/-  *picky, md=metadata-store, store=chat-store, group
/+  dbug, default-agent, group-lib=group, resource
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
    (poke-action !<(action vase))
  ==
  [cards this]
  ++  poke-action
    |=  =action
    ^-  (quip card _state)
    ?-    -.action
        %load-chats
      ~&  >>  groups-summary:hc
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
++  groups-summary
  ^-  group-summaries
  =/  xs=(list [gp=group-path:md cp=app-path:md])
    my-group-chats
  =|  gs=group-summaries
  |-
  ?~  xs  gs
  =/  rid=resource
    (de-path:resource gp.i.xs)
  =*  chat-path  cp.i.xs
  =/  m=(unit mailbox:store)
    (scry-mailbox chat-path)
  ?~  m  $(xs t.xs)
  =/  g=(unit group:group)
    (scry-group:grp rid)
  ?~  g  $(xs t.xs)
  =/  =group-summary
    ?:  (~(has by gs) rid)
      (~(got by gs) rid)
    (init-group-summary u.g)
  =.  chats.group-summary
    (~(put in chats.group-summary) chat-path)
  =.  stats.group-summary
    (calc-stats stats.group-summary envelopes.u.m)
  $(xs t.xs, gs (~(put by gs) rid group-summary))
++  init-group-summary
  |=  [g=group:group]
  ^-  group-summary
  :-  *(set path)
  %-  malt
  %+  turn  ~(tap in (all-members g))
  |=(user=ship [user *user-summary])
::  includes admins members to handle DM case
::
++  all-members
  |=  g=group:group
  =/  admins=(set ship)
    (~(gut by tags.g) %admin *(set ship))
  (~(uni in admins) members.g)
++  scry-mailbox
  |=  pax=path
  .^
    (unit mailbox:store)
    %gx
    (scot %p our.bowl)
    %chat-store
    (scot %da now.bowl)
    %mailbox
    (snoc `path`pax %noun)
  ==
++  calc-stats
  |=  [stats=(map ship user-summary) es=(list envelope:store)]
  ^-  (map ship user-summary)
  |-
  ?~  es  stats
  ?.  (~(has by stats) author.i.es)
    $(es t.es)
  ?.  (after-date ~d30 when.i.es)
    stats
  =/  us=user-summary
    (~(got by stats) author.i.es)
  =.  stats
    %+  ~(put by stats)
      author.i.es
    :*  ?:((after-date ~d7 when.i.es) +(num-week.us) num-week.us)
        +(num-month.us)
    ==
  $(es t.es)
++  after-date
  |=  [interval=@dr d=@da]
  (gte d (sub now.bowl interval))
++  is-my-group
  |=  gp=group-path:md
  ?&
    ?=([%ship @ @ ~] gp)
    =(i.t.gp (scot %p our.bowl))
  ==
++  my-group-chats
  ^-  (list [group-path:md app-path:md])
  =/  xs=(list [group-path:md app-path:md])
    %~  tap  in
    =/  ai=(jug app-name:md [group-path:md app-path:md])
      .^
       (jug app-name:md [group-path:md app-path:md])
       %gy
       (scot %p our.bowl)
       %metadata-store
       (scot %da now.bowl)
       /app-indices
      ==
    (~(gut by ai) %chat *(set [group-path:md app-path:md]))
  %+  skim  xs
  |=([g=group-path:md *] (is-my-group g))
--
