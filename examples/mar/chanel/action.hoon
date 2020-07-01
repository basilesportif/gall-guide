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
      :~  [%increase-counter counter]
          decrease-counter+counter
          [%example example]
          [%send-sub-data send-sub-data]
      ==
    ++  counter
      %-  ot:dejs
      :~  [%step ni:dejs]
      ==
    ++  example
      %-  ot:dejs
      :~  [%who (su:dejs fed:ag)]
          [%msg so:dejs]
          [%app so:dejs]
      ==
    ++  send-sub-data
      %-  ot:dejs
      :~  [%path pa:dejs]
          [%msg so:dejs]
      ==
    --
  --
--
