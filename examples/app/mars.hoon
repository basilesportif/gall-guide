::  mars.hoon
::  examples of HTTP going into and out of Mars
::
/-  mars
/+  srv=server, default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
    $:  [%0 =files]
    ==
::
+$  url  @t
::
+$  files  (map url (unit mime-data:iris))
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
  =/  public-filea  [%file-server-action !>([%serve-dir /'~mars-public' /app/mars/public %.y])]
  =/  private-filea  [%file-server-action !>([%serve-dir /'~mars-private' /app/mars/private %.n])]
  =.  state  [%0 *files]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke public-filea]
      [%pass /srv %agent [our.bowl %file-server] %poke private-filea]
      [%pass /'~mars-dynamic' %arvo %e %connect [~ /'~mars-dynamic'] %mars]
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
        %handle-http-request
      =+  !<([id=@ta req=inbound-request:eyre] vase)
      :_  state
      %+  give-simple-payload:app:srv  id
      %+  require-authorization:app:srv  req
      handle-http-request
    ==
  [cards this]
  ::
  ++  handle-action
    |=  =action:mars
    ^-  (quip card _state)
    ?-    -.action
        %http-get
      :_  state
      :~  [%pass /[url.action] %arvo %i %request (get-url url.action) *outbound-config:iris]
      ==
    ==
  ++  get-url
    |=  =url
    ^-  request:http
    [%'GET' url ~ ~]
  ++  handle-http-request
    |=  req=inbound-request:eyre
    ^-  simple-payload:http
    ~&  >>  req
    =,  enjs:format
    %-  json-response:gen:srv
    %-  json-to-octs:srv
    %-  pairs
    :~
      [%msg [%s 'hello my friends']]
      [%intent [%s 'peaceful']]
    ==
  --
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%e -.sign-arvo)
    ~&  >>  "Eyre returned: {<+.sign-arvo>}"
    `this
  ?:  ?=(%i -.sign-arvo)
  ?>  ?=(%http-response +<.sign-arvo)
    =^  cards  state
      (handle-response -.wire client-response.sign-arvo)
    [cards this]
  (on-arvo:def wire sign-arvo)
  ::
  ++  handle-response
    |=  [=url resp=client-response:iris]
    ^-  (quip card _state)
    ?.  ?=(%finished -.resp)
      ~&  >>>  -.resp
      `state
    ~&  >>  "got data from {<url>}"
    =.  files.state  (~(put by files.state) url full-file.resp)
    `state
  --
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
