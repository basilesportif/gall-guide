/-  fordex=fordexample, *fordexample2
/+  *server, default-agent, base=base64
/=  html-as-html
  /:  /===/app/fordexample/example
    /html/
/=  html-as-mime
  /:  /===/app/fordexample/example
    /mime/
|%
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  $:  [%0 name:fordex =age]
  ==
::
+$  card  card:agent:gall
::
--
=|  state=versioned-state
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =.  state  [%0 [first='Hoon' last='Cool Guy'] age=74]
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
        %print-state
      ~&  >>  state
      `this
        %print-vars
      ~&  >>  html-as-html
      ~&  >>  html-as-mime
      `this
    ==
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--
