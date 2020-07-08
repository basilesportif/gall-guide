::  mars.hoon
::  examples of HTTP going into and out of Mars
::
/-  mars
/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 last-response=client-response:iris]
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
  ~&  >  '%mars initialized successfully'
  =/  filea  [%file-server-action !>([%serve-dir /'~mars-static' /app/mars %.y])]
  =.  state  [%0 *client-response:iris]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke filea]
  ==
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%mars recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
        %mars-action  (handle-action !<(action:mars vase))
    ==
  [cards this]
  ::
  ++  handle-action
    |=  =action:mars
    ^-  (quip card _state)
    ?-    -.action
        %http-get
      :_  state
      :~  [%pass /[(scot %da now.bowl)] %arvo %i %request (get-url url.action) *outbound-config:iris]
      ==
    ==
  ++  get-url
    |=  url=@t
    ^-  request:http
    [%'GET' url ~ ~]
  --
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
