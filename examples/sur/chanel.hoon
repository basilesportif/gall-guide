|%
+$  action
  $%  [%increase-counter step=@ud]
      [%decrease-counter step=@ud]
      [%example who=ship msg=@t app=term friends=(set ship)]
      [%send-sub-data =path msg=@t]
  ==
--
