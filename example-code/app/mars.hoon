
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
    $:  [%0 =files last-id=(unit knot)]
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
  =/  public-filea  [%file-server-action !>([%serve-dir /'~mars-public' /app/mars/public %.y %.n])]
  =/  private-filea  [%file-server-action !>([%serve-dir /'~mars-private' /app/mars/private %.n %.n])]
  =.  state  [%0 *files ~]
  :_  this
  :~  [%pass /srv %agent [our.bowl %file-server] %poke public-filea]
      [%pass /srv %agent [our.bowl %file-server] %poke private-filea]
      [%pass /bind %arvo %e %connect [~ /'~mars-manual'] %mars]
      [%pass /bind %arvo %e %connect [~ /'~mars-managed'] %mars]
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
      =+  !<([id=@ta =inbound-request:eyre] vase)
      ~&  >>  "{<url.request.inbound-request>}"
      ?:  =(url.request.inbound-request '/~mars-manual')
        (open-manual-stream id)
      ?>  =(url.request.inbound-request '/~mars-managed')
        :_  state
      %+  give-simple-payload:app:srv  id
      %+  require-authorization:app:srv  inbound-request
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
      ::
        %http-stream-close
      ?~  last-id.state
        `state
      :_  state(last-id ~)
      :~  [%give %kick ~[/http-response/[u.last-id.state]] ~]
      ==
      ::
        %serve-gen
      :_  state
      [[%pass /bind %arvo %e %serve [~ pax.action] %home gen.action ~]]~
      ::
        %disconnect
      ~&  >>>  "disconnecting at {<bind.action>}"
      :_  state
      [[%pass /bind %arvo %e %disconnect bind.action]]~
    ==
  ++  get-url
    |=  =url
    ^-  request:http
    [%'GET' url ~ ~]
  ++  open-manual-stream
    |=  id=@ta
    ^-  (quip card _state)
    :_  state(last-id `id)
    =/  octs
      %-  json-to-octs:srv
      (json [%s 'Notice that your browser is still \'loading\'; close connection using %http-stream-close action'])
    =/  header-cage
      [%http-response-header !>([200 ['content-type' 'application/json']~])]
    =/  data-cage
    [%http-response-data !>(`octs)]
    :~
      [%give %fact ~[/http-response/[id]] header-cage]
      [%give %fact ~[/http-response/[id]] data-cage]
    ==
  ++  handle-http-request
    |=  req=inbound-request:eyre
    ^-  simple-payload:http
    =,  enjs:format
    %-  json-response:gen:srv
    %-  pairs
    :~
      [%msg [%s 'hello my friends']]
      [%intent [%s 'peaceful']]
      [%ship [%s (scot %p our.bowl)]]
    ==
  --
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  |^
  ?:  ?=(%eyre -.sign-arvo)
    ~&  >>  "Eyre returned: {<+.sign-arvo>}"
    `this
  ?:  ?=(%iris -.sign-arvo)
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
++  on-watch
  |=  =path
  ?:  ?=([%http-response *] path)
    ~&  >>>  "watch request on path: {<path>}"
    `this
  (on-watch:def path)
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-fail   on-fail:def
--
