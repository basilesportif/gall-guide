# backy: a Program to Call the Arvo OS
Gall isn't just for making "full" applications; it also comes in very handy for clearly coordinating actions and data flows that are tricky and fragile in normal operating systems like Unix. 

So far, we've made the following types of calls to Arvo:
* Gall, by poking other apps and using the Gall framework in general
* Eyre, to serve HTTP resources to "Earth"
* Iris, to call "Earth" HTTP resources
* `scry`s to Gall directly to `peek` into agent state

In this lesson, we're going to walk through the source of `%backy`, a program I use on my main ship to back up the user lists of all the groups I own to text files.

To do this, we need to:
1. run a timer at a user-specified interval (say, every 5 minutes)
2. get the changes from a data store (group membership)
3. write those changes out to disk each time


## Example Code
The code for this lesson lives [here](https://github.com/timlucmiptev/backy). Follow the instructions in the README there to install (you can use the `install.sh` script, or just copy `app`, `mar`, and `sur` directories as usual).

Once the code is committed, run `|rein %home [& %backy]`.

## Getting Started

### A Peek at `group-store`
To see concretely what we're trying to do, run `|rein %home [& %dbug]` on a real ship you use. Then navigate to `/~debug` on that ship, and click through to `apps` ->  `group-store` and then click the `query state` button there.

You'll see a big list of all the groups you're in and their members. If we open `/sur/group.hoon`, we see that `groups` is a `(map resource group)`, and in `/sur/resource.hoon`, we see that `resource` is a [ship term].

So we want `%backy` to accept pokes with `resource`s, monitor the `group` associated with that `resource`, and then every time a timer goes off, write the users from each monitored group to Clay (and to Unix, if mounted).

We're now ready to see how `%backy` backs up our data.

### `%backy` App State
`%backy` tracks three things in its state:
1. `monitored`, a set of all groups to track
2. `interval`, a relative time that is the interval between save events
3. `timer`, the next time in the future that the Behn timer will go off (can be used to cancel an upcoming timer)

## Behn Timers
Requesting a Behn timer is very simple: you send a card to Behn and tell it what time you want it to ping you back. That's it. Note that the only guarantee is that the ping will happen some time *after* the time you pass, so don't use this for ultra-precise timing needs.

We set our timer first in `on-init`, in line 32, which calls the `reset-timer` arm in our helper core (line 88).  That code saves the old timer, updates the timer interval to the passed value, and updates the timer to a time in the future: `now + interval`.

Then in line 107, we check whether the `old-timer` is in the past (less than now). If so, we just pass a `card` to Behn (`start-timer`), and if not we send Behn a message to cancel and then to start.

### Start a Timer
`start-timer` in line 90 is simple: it passes the card `[%pass /timer %arvo %b %wait timer.state]` to Behn, which just says to send a message back to us (in `on-arvo`) at the specified time. We use the wire `/timer`.

In line 76, we handle the message back on that `/timer` wire.  In line 79 we call `reset-timer` again, and then pass its `card`s along with `card`s to write the groups' users to disk. We'll look at that latter part later.

### Check the Next Timer
Let's look now at when the next backup is scheduled to happen. Run `:backy +dbug` in the Dojo. You should see something like:
```
[%0 monitored={} interval=~m5 timer=~2020.7.23..14.42.16..ce5d]
```
The date in `timer` is the next time that Behn will call back to `%backy`.

### Cancel a Timer
What if we want to cancel a timer? All you need to do is pass a `card` to Behn with the *exact* time of a previously requested timer, and it will be cancelled.  This is why we save our timer in `state` each time we create a new one (line 105).

Whenever `reset-timer` is called, it checks whether the `old-timer` is in the future (line 107). If it is, it creates a card using `cancel-timer`, and passing `old-timer` as the sample.  This creates the `card` `[%pass /timer %arvo %b %rest old-timer]`. Behn will receive this, look up `old-timer` in a map of timers it keeps, and cancel it if it is yet to go off.

Note that we use the `/timer` wire here also, as in `start-timer`. Cancelling a timer does *not* send a message to `on-arvo`, so we don't need to handle that case there.

### Summary
And...that's it! You now know how to set and cancel Behn timers.  If you wanted to set multiple timers, you'd just use different wire names and handle them separately in `on-arvo`.

## Writing to Clay
(*Note*: throughout this section we'll use the `wain` data structure, which is just `(list cord)`. This represents the lines of a text file.)

`%backy`'s helper core has a `write-users` arm that returns the `card`s needed to write usernames in each group to Clay.  It is called in two places: line 79 in `on-arvo` (when the timer goes off) and in line 120 in `add-group` (when a new group is added to `monitored.state`). In `on-arvo` we `weld` these `card`s together with `card`s to reset the timer, and in `add-group` we simply return them along with the altered `state`.

By doing our writes in this way, we've abstracted them out as simple `card`s passed to Arvo/Clay, which lets us combine them with other Arvo operations (like the Behn timer call in `on-arvo`). So let's look now at how our write `card`s are created.

We'll start in line 160, where we see the final form of the `card` passed to Clay:
```
[%pass /write-users %arvo %c %info (foal:space:userlib pax cay)]
```
`write-users` is the wire we are sending on (although Clay doesn't return anything on a write), and then `%arvo %c` indicates this card is for Clay, as we've seen with other vanes. The `%info` task edits something in Clay, and takes a `[des=desk dit=nori]` as its tail. This data structure represents an edit to a point in Clay's path, and we can generate one representing a write by using the `foal:space:userlib` gate.

(Note that `foal:space:userlib` returns a `toro`, but that's just a `[@ta nori]`, and a `desk` is a `@tas`, so `toro` nests under `[desk nori]`).

Inside the `write-file` arm, we use the provided `path` and `wain` sample to create a `card` for Clay.

### Clay and `cage`s

#### Writing Marked Data to Clay
You'll note that we pass `foal` a `path` and a `cage`. Clay uses `cage`s (`[mark vase]`) structures to write data.

The final element in the `path` you pass will be the `mark` that Clay stores (e.g. `txt` in `/my/clay/file/txt`). If the `cage`'s mark is different from the destination `mark`, Clay tries to find a path from cage mark to destination mark.

Example:
```
::  example path -- mark is `%txt`
/my/clay/file/txt

::  example cage -- mark is `%noun`
[%noun a-vase]
```
In the above, Clay tries to find a path from `%noun` to `%txt`, which it can, because `mar/txt/hoon` has a `grab` arm for `noun`.

In line 148, we make a cage marked `txt` (which stores its data as a `wain`), and our `path` also ends in `txt`, so no conversion is needed. However, line 158 could just as easily have been `noun+!>(lines)`, because there is a conversion path from `%noun` to `%txt`.

(Note that we use the syntax `txt+!>(lines)` to mean `[%txt !>(lines)]`)

#### Checking for a Resource in Clay
In line 165, we use `(? %cu p)` to scry Clay for a path's existence.

#### Reading Marked Data from Clay
When Clay reads marked data, it uses the file extension mark (i.e. `/txt`) to choose the mark to `re-inflate` it with.  In line 166, we know that our incoming path is a `txt` mark, so we use a `%cx` scry to read the path, and then cast to a `wain`, since `txt` mark inflate to `wain`.

### Turning `monitored` Groups into Write `card`s
In line 127, we `run` the `group-info` gate on all members of the `monitored.state` `set`. `++group-info` produces `[path wain]`, i.e. a `path` we want to write to, and a `wain` of all the text lines we will write.

In `++group-info` we make a path based on the `resource`'s info, and then we `scry` for the group associated with the `resource`, turn its usernames into `cord`s, and return a `(list cord)`, i.e. a `wain`.

In line 128 we `turn` that list with gate `write-file`, which produces a Clay write `card` for each `path` and list of usernames (the `wain`). Then those Clay `card`s are passed back to Gall by `on-arvo` and `add-group`.

## Adding a Group
This is very straightforward. We simply take an `%add-group` action `card` with a `resource`, add that `resource` to `monitored.state` in the `add-group` arm. In line 117 we scry `group-store` for the `resource` and throw an error if it doesn't exist.

Finally, as seen in the prior section, we write all groups to Clay whenever a new group is added to monitoring

## Trying It Out
We can see this in action now. We just need to add a couple groups as seed data, and then we'll run some commands against `%backy` and see what they do.

### Seed Some Group Data
The below commands will add 2 new groups to the `group-store` Gall agent, and then add some members to them.
```
:group-store &group-action [%add-group [~zod %fakegroup] [%invite *(set ship)] %.n]
:group-store &group-action [%add-group [~zod %secondgroup] [%invite *(set ship)] %.n]
:group-push-hook &group-update [%add-members [~zod %fakegroup] (sy ~[~zod ~timluc ~dopzod])]
:group-push-hook &group-update [%add-members [~zod %secondgroup] (sy ~[~zod ~timluc ~bislut])]
```

And these commands run operations within `%backy`:
```
::  command to add a group to `monitored`
::  you'll see this group written to Clay
> :backy &backy-action [%add-group [~zod %fakegroup]]

::  add %secondgroup to monitored
::  both groups will be written to Clay
> :backy &backy-action [%add-group [~zod %secondgroup]]

::  reset-timer
::  you'll start to see files written every 20 seconds after this
::  you'll also see a "timer cancelled" message: that's the prior 5min timer
> :backy &backy-action [%reset-timer ~s20]

::  go to 10 minute write intervals
> :backy &backy-action [%reset-timer ~m10]

::  verify that timer is 10 minutes in the future
> :backy +dbug

::  verify file existence
> +ls %/bak-groups/~zod
```

## Summary
If you've done any Unix sysadmin before, you'll recognize that this task would be a) maybe possible b) really annoying c) *very* unstructured. You'd need a chron job (have fun!), find out the configuration format for the group program running (likely a proprietary database), and then write some Bash scripts to wire it all together. Type-checking? Ha.

`%backy` is about 170 lines long, but it's very clearly organized, all the messages it sends to itself and Arvo are typed, and it's very clean to modify and extend.  We were also able to reuse and compose actions like `reset-timer` and `write-users` while being confident in their types.

Gall fully supports [platforms, not applications](https://ngnghm.github.io/blog/2015/12/25/chapter-7-platforms-not-applications), and so enables entirely new, structured ways of interacting with other agents and the operating system.
