# Store/Hook/View Architecture

```
:ghooks &ghooks-action [%scry-group [~zod %fakegroup]]

%gy scry is in ghooks

%gx scry is in /lib/group.hoon in scry-group
```

## Store
- database for 1 or more "applications"
- usually read/write only by local
- restricted scry
- mirrored to each user of the store
- subscribed to through pulls generally

## Hooks
- push: layer in front of the local store
- pull: call out to remote stores

## Views
- coordinate multiple store and hook calls
