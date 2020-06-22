|%
+$  action
  $%  [%increase-counter step=@ud]
      [%poke-remote target=ship]
      [%poke-self target=ship]
      [%subscribe src=ship]
      [%leave src=ship]
      [%kick paths=(list path) subscriber=ship]
  ==
--
