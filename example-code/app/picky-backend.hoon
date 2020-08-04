::  picky.hoon
::  chat admin dashboard backend
::
/-  *picky, md=metadata-store, store=chat-store, group
/+  dbug, default-agent, group-lib=group, resource
|%
+$  versioned-state
    $%  state-0
        state-1
        state-2
    ==
::
+$  state-0
    $:  [%0 counter=@]
    ==
+$  state-1  [%1 =chat-cache]
+$  state-2  [%2 =chat-cache =gs-cache]
::
+$  card  card:agent:gall
::
--
%-  agent:dbug
=|  state-2
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
  :-  subscribe-chat-updates:hc
  this(state [%2 *^chat-cache [*time ~m10 *group-summaries]])
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ~&  >  '%picky  recompiled successfully'
  ^-  (quip card _this)
  =/  old  !<(versioned-state old-state)
  ?-  -.old
      %2  `this(state old)
    ::
      %1
    `this(state [%2 chat-cache.old [*time ~m10 *group-summaries]])
    ::
      %0
    :-  subscribe-chat-updates:hc
    this(state [%2 *^chat-cache [*time ~m10 *group-summaries]])
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  ::  refresh group-summaries cache on every request
  ::
  =.  state  load-group-summaries:hc
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
        %messages
      =/  msgs=(list msg)
        (user-group-msgs:hc +.action)
      ~&  >>  msgs
      `state
      ::
        %group-summary
      ~&  >>  (~(get by gs.gs-cache.state) rid.action)
      `state
      ::
        %all-groups
      ~&  >>  gs.gs-cache.state
      `state
        %alter-cache-ttl
      `state(ttl.gs-cache ttl.action)
    ==
  --
++  on-agent
  |=  [=wire =sign:agent:gall]
  |^  ^-  (quip card _this)
  ?+    -.sign  (on-agent:def wire sign)
      %fact
    ?+    p.cage.sign  (on-agent:def wire sign)
        %chat-update
      (handle-chat-update !<(update:store q.cage.sign))
    ==
  ==
  ++  handle-chat-update
    |=  =update:store
    ^-  (quip card _this)
    =*  ccs  chat-cache.state
    ?.  ?=([%message * *] update)
      `this
    =*  k  [path.update author.envelope.update]
    ?.  (~(has by ccs) k)
      `this
    =/  msgs=(list envelope:store)
      (~(got by ccs) k)
    =.  ccs  (~(put by ccs) k [envelope.update msgs])
    `this
  --
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
::
::  HELPER CORE
::
|_  =bowl:gall
+*  grp  ~(. group-lib bowl)
++  subscribe-chat-updates
  ^-  (list card)
  ?:  %-  ~(any in `(set [wire ship term])`~(key by wex.bowl))
        |=([=wire *] ?=([%chat-store-updates ~] wire))
    ~
  ~[[%pass /chat-store-updates %agent [our.bowl %chat-store] %watch /updates]]
::  uses gs-cache in state, regardless of staleness
::
++  user-group-msgs
  |=  [user=ship group-rid=resource num-msgs=@]
  ^-  (list msg)
  =/  gs=(unit group-summary)
    (~(get by gs.gs-cache.state) group-rid)
  ?~  gs  ~
  =|  acc=(list msg)
  |-
  ?:  =(0 num-msgs)  (flop acc)
  =^  m=(unit msg)  chat-cache.state
    (pop-newest-msg ~(tap in chats.u.gs) user chat-cache.state)
  ?~  m  (flop acc)
  $(acc [u.m acc], num-msgs (dec num-msgs))
::  pops the newest msg in all chats; returns updated chat-cache
::
++  pop-newest-msg
  |=  [chats=(list path) user=ship cc=^chat-cache]
  ^-  [(unit msg) _cc]
  =/  ms=(list msg)
    %+  murn  chats
    |=(cp=path (first-msg cp user cc))
  =/  sorted=(list msg)
    (sort ms |=([m1=msg m2=msg] (gte when.e.m1 when.e.m2)))
  ?~  sorted  [~ cc]
  =*  k  [chat-path.i.sorted user]
  =.  cc
    %+  ~(put by cc)  k
    (slag 1 (~(gut by cc) k ~))
  [`i.sorted cc]
++  first-msg
  |=  [cp=path user=ship cc=^chat-cache]
  ^-  (unit msg)
  =/  e=(list envelope.store)
    (~(gut by cc) [cp user] ~)
  ?~  e  ~
  `[cp i.e]
::
::
++  update-chat-cache
  |=  xs=(list [gp=group-path:md chat-path=app-path:md])
  =*  ccs  chat-cache.state
  |-  ^-  ^chat-cache
  ?~  xs  ccs
  =/  m=(unit mailbox:store)
    (scry-mailbox chat-path.i.xs)
  ?~  m  $(xs t.xs)
  $(xs t.xs, ccs (cache-mailbox chat-path.i.xs u.m))
::  caches a chat-store if it's uncached
::
++  cache-mailbox
  |=  [chat-path=path m=mailbox:store]
  ^-  ^chat-cache
  =*  ccs  chat-cache.state
  ?~  envelopes.m  ccs
  ::  make sure this chat-path not here before we flop
  ?:  (~(has by ccs) [chat-path author.i.envelopes.m])
    ccs
  =/  es  (flop envelopes.m)
  |-
  ?~  es  ccs
  =/  user-msgs=(list envelope:store)
    (~(gut by ccs) [chat-path author.i.es] ~)
  =.  ccs
    %+  ~(put by ccs)
      [chat-path author.i.es]
    [i.es user-msgs]
  $(es t.es)
::
::
::  recomputes group-summaries cache if invalid
::  also refreshes chat-cache if gs-cache invalid
::
++  load-group-summaries
  ^-  _state
  ?:  (gte (add updated.gs-cache.state ttl.gs-cache.state) now.bowl)
    state
  =/  mgc  my-groups-chats
  =.  chat-cache.state  (update-chat-cache mgc)
  =.  gs-cache.state  [now.bowl ttl.gs-cache.state (summarize-groups mgc)]
  state
::  do NOT call this directly; use load-group-summaries to get caching
::
++  summarize-groups
  ~&  >>  "summarize-groups "
  |=  xs=(list [gp=group-path:md chat-path=app-path:md])
  ^-  group-summaries
  =|  gs=group-summaries
  |-
  ?~  xs  gs
  =/  rid=resource
    (de-path:resource gp.i.xs)
  =/  g=(unit group:group)
    (scry-group:grp rid)
  ?~  g  $(xs t.xs)
  =/  gsum=group-summary
    ?:  (~(has by gs) rid)
      (~(got by gs) rid)
    (init-group-summary u.g)
  =.  chats.gsum
    (~(put in chats.gsum) chat-path.i.xs)
  =.  stats.gsum
    (calc-stats stats.gsum chat-path.i.xs)
  $(xs t.xs, gs (~(put by gs) rid gsum))
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
++  calc-stats
  |=  [stats=(map ship user-summary) chat-path=path]
  =/  num-msgs=@  10
  =/  users=(list ship)
    ~(tap in ~(key by stats))
  |-  ^+  stats
  ?~  users  stats
  =/  us=user-summary
    (~(got by stats) i.users)
  =/  es=(list envelope:store)
    (~(gut by chat-cache) [chat-path i.users] ~)
  =.  stats
    %+  ~(put by stats)  i.users
    (update-user-summary us es)
  $(users t.users)
++  update-user-summary
  |=  [us=user-summary msgs=(list envelope:store)]
  |-  ^-  user-summary
  ?~  msgs  us
  ?.  (after-date ~d30 when.i.msgs)  us
  =.  us
    :*  ?:((after-date ~d7 when.i.msgs) +(num-week.us) num-week.us)
        +(num-month.us)
    ==
  $(msgs t.msgs)
++  after-date
  |=  [interval=@dr d=@da]
  (gte d (sub now.bowl interval))
::
::
++  is-my-group
  |=  gp=group-path:md
  =/  rid=resource
    (de-path:resource gp)
  ?:  =(entity.rid our.bowl)
    %.y
  =/  g=(unit group:group)
    (scry-group:grp rid)
  ?~  g  %.n
  =/  admins=(set ship)
    (~(gut by tags.u.g) %admin *(set ship))
  (~(has in admins) our.bowl)
++  my-groups-chats
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
--
