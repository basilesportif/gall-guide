|%
+$  action
  $%  [%http-get url=@t]
      [%http-stream-close manual=?]
      [%serve-gen pax=path gen=path]
      [%disconnect bind=binding:eyre]
  ==
--
