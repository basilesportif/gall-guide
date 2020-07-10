/+  *server
|=  [[now=@da eny=@ bek=beak]]
|=  [authorized=? =request:http]
^-  simple-payload:http
%-  json-response:gen
%-  json-to-octs
%-  pairs:enjs:format
:~
  [%ship (ship:enjs:format p.bek)]
  [%now [%s (scot %da now)]]
  [%logged-in [%b authorized]]
==
