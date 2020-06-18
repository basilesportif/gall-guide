# Poke and Watch
Back in the [App Structure lesson](arms.md), we said that the `on-poke` and `on-watch` arms listen for input/calls. We're going to use them both to do that in this lesson, as well as work with the `on-agent` arm that handles responses from those calls.

Both `on-poke` and `on-watch` allow outside processes on the same ship or other ships to call your ship. The difference is that poke is for "one-time" calls, and watch is for subscriptions.

## Preamble
There are a couple common things we should introduce now, since we'll start to see them a lot.

### bowl: Our Agent's Metadata


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
```
> :poketime %print-state
::  you'll see the state variable and the bowl printed
```
OK, so we've used this syntax a lot, and it's time to walk-through how it works.

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

Does `poke-ack` always come?

### Poke from the Dojo

### Programmatic Pokage

## watch: Subscribe to Events

## on-agent: respond
* do example where we call out to another Gall agent?
* do example of how we'd implement our own on-agent?

# TODO: MOVE tHIS STUFF TO JSON/MARKS
## to parse JSON
just choose what "type" you have at each level, and use the various piece functions to parse it

## parsing different types of JSON action/input with a mark
see `grab` here:
https://github.com/yosoyubik/canvas/blob/master/urbit/mar/canvas/view.hoon
then see how it uses `dejs` here:
https://github.com/yosoyubik/canvas/blob/master/urbit/lib/canvas.hoon#L10

## poke can use ANY mark--just has to be in `/mar`; uses `noun` -> `mark`
