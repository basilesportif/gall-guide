
## Troubleshooting

### Changes to JS code aren't registering in the browser?
* make sure you are watching the directory
* make sure you did `|commit %home` (the )
* use `Cmd-Shift-R` (Mac) or `Ctrl-Shift-R` (PC/Linux) in Chrome/Brave to force a reload. Safari uses `Cmd-Option-R`.

* Gall keeps running an old version of my app!
  - if there's a compile error, it will run an old version until a new version successfully compiles. 
  - Gall will **not** throw the same compile error twice in a row. This can be confusing if you don't get an error message, but still see that you're running the same version

### scry errors
```
scry failed for
ford: %hood failed for /~zod/home/0/app/...
```
Solution: run `|commit %home`


### mint-lost: Handle All State Cases
Usually caused by adding a new state, but not having a `?-` case to handle it.

### Reloading an App
As soon as you execute `|start %yourapp`, **the app is started forever.**  It doesn't matter whether it had errors upon loading. The only way to "remove" an app and have Gall stop monitoring it is to create a new ship and load the code in there.

### Fixing Errors
* doesn't throw the same error twice
* for this reason, I usually leave an `on-load` print debug while developing
* if no `on-load` is printing, it means my new version didn't compile
