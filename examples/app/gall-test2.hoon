::  example of Hoon code
/+  server, default-agent, verb, dbug
|%
+$  versioned-state
  $%  [%0 state-zero]
  ==
::
+$  state-zero
  $:  counter=@
  ==
::
+$  card  card:agent:gall
::
--
=|  state=versioned-state
%-  agent:dbug
^-  agent:gall
=<
::  start agent
::
|_  =bowl:gall
+*  this      .
    gc    ~(. +> bowl)
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =.  state  state(counter 200)
  `this
++  on-save
  ^-  vase
  !>(state) 
++  on-load 
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  'on-load'
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
    %0
    `this(state prev)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?>  (team:title our.bowl src.bowl)
    ?+    q.vase  (on-poke:def mark vase)
        %connect-eyre
      ~&  >  '%connect-eyre'
      :_  this
      :~
        [%pass /bind %arvo %e %connect [~ /'~gall-test2'] %gall-test2]
      ==

        %print-state
      ~&  >>  state
      =.  state  state(counter +(counter.state))
      `this
    ==
      %handle-http-request
    :_  this
    =+  !<([eyre-id=@ta =inbound-request:eyre] vase)
    ~&  >>  inbound-request
    %+  give-simple-payload:app:server  eyre-id
    %+  require-authorization:app:server  inbound-request
    poke-handle-http-request
  ==
::
++  on-watch
  |=  =path
    ^-  (quip card _this)
    ?+    path  (on-watch:def path)
        [%http-response *]
      `this
    ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo
  |=  [=wire =sign-arvo]
  ^-  (quip card _this)
  ?+    wire  (on-arvo:def wire sign-arvo)
      [%bind ~]
    `this
  ==
++  on-fail   on-fail:def
--
::  start helper core
::
|_  bowl=bowl:gall
++  poke-handle-http-request
  |=  =inbound-request:eyre
  ^-  simple-payload:http
  =+  gen=gen:server
  =/  url  (parse-request-line:server url.request.inbound-request)
  ?+    site.url  not-found:gen
      [%'~gall-test2' ~]
    %-  json-response:gen
    %-  json-to-octs:server
    [%s 'timtime for al']
  ==
--
