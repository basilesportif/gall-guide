

### actions for `backy` to seed it and dump file
```
:group-store &group-action [%add-group [~zod %fakegroup] [%invite *(set ship)] %.n]
:group-push-hook &group-update [%add-members [~zod %fakegroup] (sy ~[~zod ~timluc ~dopzod])]

:group-store &group-action [%add-group [~zod %secondgroup] [%invite *(set ship)] %.n]
:group-push-hook &group-update [%add-members [~zod %secondgroup] (sy ~[~timluc ~marpem ~nibfeb])]

:group-push-hook &group-update [%add-members [~zod %secondgroup] (sy ~[~risruc ~rabsef])]

## backy
:backy &backy-action [%set-timer ~s4]
:backy &backy-action [%cancel-timer %.y]
:backy &backy-action [%add-group [~zod %fakegroup]]
:backy &backy-action [%add-group [~zod %secondgroup]]
:backy &backy-action [%write-users %.y]]
```
