# Poke and Watch

## Preamble: the `=^` Idiom
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
