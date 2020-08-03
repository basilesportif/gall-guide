/-  *resource, store=chat-store
|%
+$  action
  $%  [%load-chats ~]
      [%dummy ~]
  ==
+$  group-summaries  (map resource group-summary)
+$  group-summary
  $:  chats=(set path)
      stats=(map ship user-summary)
  ==
+$  user-summary
  $:  num-week=@
      num-month=@
  ==
--
