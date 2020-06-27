
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

### I Don't See an Error, but My App Doesn't Work
Once Gall throws an error in compilation, it won't throw the same error again.  This means that even if your app still has problems, you won't see an error after '|commit'.

Becasue of this, I usually leave an `on-load` print debug in while developing. If I see the 'on-load' message print, it means that my app compiled successfully. If not, it means that I need to keep debugging the prior error.
