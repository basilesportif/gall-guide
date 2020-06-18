# Poke and Watch
Back in the [App Structure lesson](arms.md), we said that the `on-poke` and `on-watch` arms listen for input/calls. We're going to use them both to do that in this lesson, as well as work with the `on-agent` and `on-leave` arms that handle responses from those calls.

Both `on-poke` and `on-watch` allow outside processes on the same ship or other ships to call your ship. The difference is that poke is for "one-time" calls, and watch is for subscriptions.

## Preamble
There are a couple common things we should introduce now, since we'll start to see them a lot.

### bowl: Our Agent's Metadata
TODO: fill out


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

### Poking from an Agent
Now we're going to send a poke directly from our agent. We'll poke ourselves, but, as you'll see, we can send pokes to any agent on any ship.
```
::  at the Dojo, run:
> :poketime %poke-self

::  output:
>   "got poked with val:"
>   [%receive-poke 2]
>>  "got a poke-ack"
```
Three things happened here, and we'll look at them both in detail
1. We sent an outgoing poke to ourselvess
2. We handled the poke to ourselves.
3. We got back a `%poke-ack` confirming the poke was received.

#### Sending a Poke to an Agent
When we run `:poketime %poke-self` from the Dojo, Gall receives that message, and calls our `on-poke` arm with parameters `%noun` as the mark and `%poke-self` inside the vase. In line 36 we switch on the mark--in this case it's a `%noun`. Then in line 39 we switch on the value inside the vase; here it's `%poke-self`, so we return the card below:
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
`wire` is a path that is used mainly for `watch` and subscriptions. I set it as `/pokepath` here, but we could have used anything (`~` would make the most sense for pokes, but I just wanted to demonstrate the battle station's full power).

It's considered best practice to switch first on the wire, and then on the sign (see [here in B3 for discussion](https://urbit.org/blog/precepts-discussion)).  So we switch on the wire, match `[%pokepath ~]`, and then match when the head of `sign` is `%poke-ack**.


# TODO: below is a WIP

## Custom Marks

## watch: Subscribe to Events

### do `on-leave`
