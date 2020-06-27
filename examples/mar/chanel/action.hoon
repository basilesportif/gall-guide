/-  chanel
=,  format
|_  act=action:chanel
++  grab
  |%
  ++  noun  action:chanel
  ++  json
    |=  jon=^json
    ::run noun through the action mold
    %-  action:chanel
    ::  returns a noun
    =<  (action jon)
    |%
    ++  action
      %-  of:dejs
      :~  [%increase step]
          decrease+step
          [%example example]
      ==
    ++  step
      %-  ot:dejs
      :~  [%step ni:dejs]
      ==
    ++  example
      %-  ot:dejs
      :~  [%who (su:dejs fed:ag)]
          [%msg so:dejs]
          [%app so:dejs]
      ==
    --
  --
--
