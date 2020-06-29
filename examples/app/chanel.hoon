/-  chanel
/+  default-agent, dbug
|%
+$  versioned-state
    $%  state-zero
    ==
::
+$  state-zero
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
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  ~&  >  '%chanel initialized successfully'
  =.  state  [%0 100]
  `this
++  on-save
  ^-  vase
  !>(state)
++  on-load
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  '%chanel recompiled successfully'
  `this(state !<(versioned-state old-state))
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  |^
  =^  cards  state
    ?+    mark  (on-poke:def mark vase)
        %chanel-action  (handle-action !<(action:chanel vase))
    ::
        %json
      ~&  >>  !<(json vase)
      `state
    ==
  [cards this]
  ::
  ++  handle-action
    |=  =action:chanel
    ^-  (quip card _state)
    ?-    -.action
        %increase
        `state(counter (add step.action counter.state))
    ::
        %decrease
        `state(counter (sub counter.state step.action))
    ::
        %example
        ~&  >>  +.action
        `state
    ::
        %send-sub-data
      :_  state
      ~[[%give %fact ~[path.action] [%json !>((json [%s msg.action]))]]]
    ==
  --
::
++  on-watch
  |=  =path
  ^-  (quip card _this)
  ?+    path  (on-watch:def path)
      [%example ~]
    ~&  >>>  "got %example subscription"
    `this
  ==
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
