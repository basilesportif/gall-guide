# `on-peek` and scry
So far in this course we've stayed inside our own agents, poking them, altering their data, etc. However, one of Urbit's big wins is the ability to query (`scry`) data of *other* agents in a structured manner, when they allow it. In this sense, Gall agents aren't just "apps"--they play a similar role to databases.

For example, imagine that you want to find out all the groups a user is currently subscribed to. This is stored in every ship inside the `%group-store` Gall agent. That agent, in turn, exposes some of its internal data through `scry` queries.

In this lesson, rather than making our own `on-peek` arm for explanation, we'll examine some that already exist in the Gall agent-space that you can query on your own. By the end, you should be confident that you can grab any info that an agent exposes to your Urbit.

## `scry` Mechanics
`scry` uses a special rune, `.^` to query the Arvo namespace. This means that it can ask any vane a question about its current state, and get an answer, if the query is supported. `scry` is fast relative to other Urbit operations, since it's a read-only operation; this means that it doesn't have to write an event to disk.

`.^` takes a sample of `p=spec q=hoon`, i.e. a `mold` for the query's return value and the query itself. In practice, the query will have a form like:
```
::  query for Clay (%c) + %y
[%cy /example/path]

::  query for Gall (%g) + %x
[%gx /ship/gall-agent-name/time/example/path]
```
In all cases, the query starts with a `@tas` with the vane letter followed by `x` or `y`.

### `x` or `y`?


## `%group-store`

## start our app for chat admin
- walk through the on-peek in chat-store

## marks with Gall scry
from palfun:
> no, it's also mark based. the mold in .^ is just an assertion/coercion, for benefit of the call-side code

- generally speaking, use `noun` and then coerce it

## look at gen/cat.hoon

## Code examples
```
.^(arch %cy pax)
?~(fil.dir ~ [~ .^(* %cx pax)])

::  gets all the chat names/paths
.^((set path) %gx /=chat-store=/keys/noun)

::  gets all groups
.^(arch %gy /=group-store=/groups)
```

* `%y` means it returns `arch`, shallow filesystem node
```
+$  arch  [fil=(unit @uvI) dir=(map @ta ~)]
```
This is analogous to ++ankh:clay except that the we have neither our contents nor the ankhs of our children. The other fields are exactly the same, so p is a hash of the associated ankh, u.q, if it exists, is a hash of the contents of this node, and the keys of r are the names of our children. r is a map to null rather than a set so that the ordering of the map will be equivalent to that of r:ankh, allowing efficient conversion.

## Exercises
* implement an `on-peek`
