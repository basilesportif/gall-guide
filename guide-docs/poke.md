# Poke and Watch
Back in the [App Structure lesson](arms.md), we said that the `on-poke` and `on-watch` arms listen for input/calls. We're going to use them both to do that in this lesson, as well as work with the `on-agent` and `on-leave` arms that handle responses from those calls.

Both `on-poke` and `on-watch` allow outside processes on the same ship or other ships to call your ship. The difference is that poke is for "one-time" calls, and watch is for subscriptions.

## Example Code for the Lesson
For this lesson, we will be using two fake ships to demonstrate communication between them. Make a fake `zod` and a fake `timluc`, mount them, and copy all code below to both of them.

After the code is copied, start our Gall agent on each with `|start %poketime`

In `/sur/poketime.hoon`:
```
|%
+$  action
  $%  [%increase-counter step=@ud]
      [%subscribe src=ship]
      [%leave src=ship]
  ==
--
```

In `/mar/poketime/action.hoon`:
```
/-  poketime
|_  act=action:poketime
++  grab
  |%
  ++  noun  action:poketime
  --
--
```

In `/app/poketime.hoon`:
```

```

## Preamble
There are a couple common things we should introduce now, since we'll start to see them a lot.

### the `=^` Idiom
One frequent pattern with pokes and watches is having a helper function modify the state, and also return some cards as actions. The `=^` is a very convenient rune that we'll use here and that you'll see in a lot of Gall code.

`=^` takes 3 children:
1. a new face (call it `p`)
2. a wing in the subject (call it `q`)
3. some Hoon to run that returns a cell
4. more Hoon

it assigns the head of (3)'s result to `p` and the tail to `q`. Then it runs the Hoon in (4), with `p` and the modified `q` in the subject.

This pattern comes in really handy when you want to combine getting a result, and updating your subject to some new state. In the case of `on-poke` and `on-watch`, the "result" is a list of `card`s, and the new state is our agent's state.

### Typical Form of `=^`
Notice below that the `state` of `this` will be updated by `some-action-handler`.
```
::  ... initial code of on-poke or on-watch
=^  cards  state  (some-action-handler:helper-core !<(action-type vase))
[cards this]
```

## poke: One-Time Call
Sending a poke to a Gall agent is easy; you can do it directly from the Dojo. Let's poke our app and examine what happens.

### Poke Basics
```
> :poketime %print-state
::  you'll see the state variable and the bowl printed
```
We've used this syntax a lot in prior lessons, and it's time to walk through how it works.

`on-poke` is a gate:
```
++  on-poke
  |=  [=mark =vase]
  ...
```

When you type `:poketime %print-state` in the Dojo, it sends a `poke` to the agent `%poketime`. `on-poke` expects a `mark` and a `vase`. You can read more about these in [Gall Types](gall_types.md), but a `mark` is a `@tas` representing a Ford mark as we saw in the [prior lesson](ford.md), and a vase is the data structure created by running `!>(some-data)`. Its head is a type, and its tail is a noun.

There are two formats you can type at the Dojo after `:agent-name` (`:poketime` in our case):
```
::  pokes with mark %noun and [%some-tas optional-data] inside the vase
> :poketime [%some-tas optional-data]

::  note the '&' instead of '%'
::  mymark MUST be a mark in /mar
::  renders required data using mymark, passes mymark as the mark parameter
::  puts required-data inside the vase
> :poketime &mymark required-data
```

Our `:poketime %print-state` example pokes with a mark of `%noun`. In line 36 we switch on the mark, and see it's a noun. Then we switch on `q.vase`, i.e. the value inside the vase. It's `%print-state`, so we run that code, which prints the `state` and `bowl`.

### Poking from an Agent
Now we're going to send a poke directly from our agent. We'll poke ourselves, but, as you'll see, we can send pokes to any agent on any ship.
```
::  at the Dojo, run:
> :poketime %poke-self

::  output:
>   "got poked with val:"
>   [%receive-poke 2]
>>  [%poke-ack p=~]
```
Three things happened here, and we'll look at them both in detail
1. We sent an outgoing poke to ourselvess
2. We handled the poke to ourselves.
3. We got back a `%poke-ack` confirming the poke was received.

#### Sending a Poke to an Agent
When we run `:poketime %poke-self` from the Dojo, Gall receives that message, and calls our `on-poke` arm with parameters `%noun` as the mark and `%poke-self` inside the vase. In line 39 we switch on the mark--in this case it's a `%noun`. Then in line 41 we switch on the value inside the vase; here it's `%poke-self`, so we do a check with `team:title` to make sure the poke source is us or one of our moons, and then we return the card below:
```
::  type: [%pass path %agent [ship agent-name] task]
::  task will usually be %poke, %leave, or %watch
::  when task starts with %poke, its format is [%poke cage]
::  a cage is a [mark vase] tuple, so we give the %noun mark, and then use !> to put our data in the vase
[%pass /pokepath %agent [~zod %poketime] %poke %noun !>([%receive-poke 2])]
```
(You can look at the [Gall Types](gall_types) appendix to see full details on `card` format).

That poke is processed by Gall and sent to us. Note that there is *nothing* special about sending it to ourselves--we could have written any ship name and agent name in the card, as long as they accept pokes.

#### Handling an Incoming Poke
Gall passes the above poke to us again, and again the mark is `%noun`. This time `q.vase` is `[%receive-poke 2]`, so that matches `[%receive-poke @]`, and we print that we got poked along with the tail of `q.vase`.

#### Ack'ing the Poke
When you send a `%poke` or `%watch`, your agent also gets a `%poke-ack` or `%watch-ack` back when it's received. Responses to calls to agents are always sent by Gall to the `on-agent` arm, which is a gate of form:
```
::  wire is a path; sign starts with %poke-ack, %watch-ack, %kick, or %fact
|=  [=wire =sign:agent:gall]
```
`wire` is a path that is used mainly for `watch` and subscriptions. I set it as `/poke-wire` here, but we could have used anything. Usually you won't need or want to handle the `%poke-ack`--this is just for demonstration of all the possibilities.

It's considered best practice to switch first on the wire, and then on the sign (see [here in B3 for discussion](https://urbit.org/blog/precepts-discussion)).  So we switch on the wire, match `[%pokepath ~]`, and then match when the head of `sign` is `%poke-ack**.


## Custom Marks for Poke
In the above, we moved with `%noun`. This is convenient for local CLI development, and I usually put some debug prints in my programs that I can poke. However, in general, you will want to explicitly define the types of pokes that can be done to your app by using custom types and marks.

Let's say we want to make an action type that can have 6 types of actions. It can increase our current counter, poke another instance of our agent, poke us, subscribe to updates to that counter, unsubscribe from those updates, or kick a subscriber.  To do this, we'll want to make both a custom mark and a custom type. In fact, we already did that in our example code, so let's look at those two files:
* `/sur/poketime.hoon`
* `/mar/poketime/action.hoon`

In `poketime.hoon`, we define a tagged union that has those 4 possibilities:
```
+$  action
  $%  [%increase-counter step=@ud]   ::  how big an increase to do
      [%poke-remote target=ship]     ::  the target ship on which to poke %poketime
      [%poke-self target=ship]       ::  poke your own ship (poking others will crash)
      [%subscribe src=ship]          ::  which ship to send the %poketime subscribe message to
      [%leave src=ship]              ::  which ship's %poketime subscription to leave
      [%kick paths=(list path) subscriber=ship]  ::kick a subscriber out of paths
```
And now, in order to send a custom mark called `poketime-action`, we created `mar/poketime/action` ([recall that in the last lesson we saw that "-" is treated as a sub-directory](ford.md)):
```
/-  poketime
|_  act=action:poketime
++  grab
  |%
  ++  noun  action:poketime
```
Our `grab` here just handles nouns, and converts them to the `action` type in `sur/poketime.hoon`. Notice that we use Ford to import that `sur` library.

So with that all in hand, we can see our custom mark in action!  All we have to do is use `&` before the name of our custom mark, and the Dojo will treat it as a custom mark, and try to render the following value from noun to it. Try out the following commands at the Dojo from `~zod`:
```
> :poketime &poketime-action [%poke-remote ~timluc]
::  you'll see a successful poke-ack locally, and a message on ~timluc

> :poketime &poketime-action [%poke-self ~zod]
::  this will work

> :poketime &poketime-action [%poke-self ~timluc]
::  this will fail with a "poke failed" error
::  this is because the %poke-self case uses ?>  (team:title our.bowl src.bowl) to block outside ships

> :poketime &poketime-action [%increase-counter 7]
> :poketime %print-state
::  you'll see that the counter went up by 7, and that wex and sup in bowl are empty

> :poketime &poketime-action [%subscribe ~timluc]
> :poketime %print-subs
::  you'll see that the wex element of bowl now has a value where before it was empty

> :poketime &poketime-action [%leave ~zod]
> :poketime %print-subs
::  you'll see that wex is empty again
```
Processing custom marks is very straightforward. In `on-poke`, where we used `?+` to switch on mark, we just add a case for `%poketime-action`.  Because the Gall agent type has to be fully general, it can't know what type of data our particular app will pass to `on-poke`. 

This is why we use vases: now that we've rendered our data with the `%poketime-action` mark, we know the vase contains a value of type `action:poketime` and so we can use `!<(action:poketime vase)` to get it out of the vase as an `action`. We then pass it to the `handle-action` gate in our helper core, and use `=^` as described in the Preamble of this lesson to capture the return head as `cards`, and tail as the value to update our `state` with.

`handle-action` itself is very simple. We can use `?-` to switch because we know all possible values for the head of the incoming `action`. For `%increase-counter`, we just add the `step` to the current counter value in the state and return the state.  For the `%subscribe`/`%leave` cases, we keep the state the and return cards whose contents we'll explain in the next section.

## How Subscriptions Work in Gall
Now we move from pokes, which are one-time calls, to subscriptions.

Gall tracks incoming and outgoing subscriptions, and stores them in the `bowl` of an agent:
* `wex` - outgoing subscriptions (uses `wire`)
* `sup` - incoming subscriptions (uses `path`)

### wire vs path
`wex` holds a `wire` that is used to receive acknowledgement of subscriptions, receive subscription facts/updates, and also to leave a subscription.

`sup` holds a `path` that is used to send out updates to all subscribers on the `path` and also to kick unwanted subscribers off the `path`.

- wire is for subscription metadata (acks, leaving)
- path is for the "content" of the subscription (sending out updates, kicking)

### Subscription Workflow
* subscription requests are created with `%pass` cards
* subscriptions requests contain
  - `wire` to listen for ack on, listen for updates, and to leave if desired
  - `path` that the host will send updates or kicks on
* subscriptions can be unilaterally terminated at any time
  - subscribers do it with `%leave` `%pass` cards on the `wire`
  - hosts do it with `%kick` `%give` cards on the `path`, or with `%kick` signs at the time of receiving the subscription

## Subscription Examples
We'll now look at examples of all parts of the workflow above.



* show how we use default-agent for acks

* show an example of how %watch-ack puts bad subscriptions and good ones in its sign. How do we print the leaf? Look in the default implementation of on-watch

* double subscription

* watch example
* kick example
* leave example

## on-leave
* `on-leave` mostly handled by Gall: you can't stop other ships from leaving. You can just do some extra stuff at that time if you have processing to do around the leave.

## Exercises
1. Make your own handlers for acks in `on-agent`
2. 
