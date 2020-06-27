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
          [%exampleship who]
      ==
    ++  step
      %-  ot:dejs
      :~  [%step ni:dejs]
      ==
    ++  who
      %-  ot:dejs
      :~  [%who (su:dejs fed:ag)]
      ==
    --
  --
--
