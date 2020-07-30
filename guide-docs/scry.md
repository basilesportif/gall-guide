# `on-peek` and scry
So far in this course we've stayed inside our own agents, poking them, altering their data, etc. However, one of Urbit's big wins is the ability to query (`scry`) data of *other* agents in a structured manner, when they allow it. In this sense, Gall agents aren't just "apps"--they play a similar role to databases.

For example, imagine that you want to find out all the groups a user is currently subscribed to. This is stored in every ship inside the `%group-store` Gall agent. That agent, in turn, exposes some of its internal data through `scry` queries using its `on-peek` arm.

In this lesson, in addition to our own `on-peek` arm, we'll examine some that already exist in the Gall agent-space that you can query on your own. By the end, you should be confident that you can grab any info that an agent exposes to your Urbit.

## Example Code
* [/app/iscry.hoon](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/iscry.hoon)

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

### `%x` or `%y`?
The `x` or `y` after the vane letter is called the `care`. The care indicates the response type expected
* queries with `%y` produce a `cage` with mark `%arch` and vase type `arch`
* queries with `%x` produce a cage with the mark at the end of the `path` queried; generally this mark will be `noun`

### Notes on `arch`
```
::  `arch` definition
+$  arch  [fil=(unit @uvI) dir=(map @ta ~)]
```
`@uvI` is the aura for a hash (of a file), and `dir` is a map of `knot`s representing `path`s or directories. This type is used by Clay for returning files/directories, and by Gall apps (such as `%group-store`) for returning all group paths in the store.

### Using `.^`
The first argument to `.^` is a mold used to cast the response. For `y` queries, this should be `arch`. For `x` ones, you generally put mark `noun` at the end of the path, and then cast with a mold that you know will work for the data inside the produced `vase`. We'll see examples of how to figure this out below.

### Example Queries
Since some of these queries are sent to `%group-store`, we need to add a dummy group so that they'll return data:
```
:group-store &group-action [%add-group [~zod %fakegroup] [%invite *(set ship)] %.n]
:group-push-hook &group-update [%add-members [~zod %fakegroup] (sy ~[~zod ~timluc ~dopzod])]
```

#### `%y` Queries
These should use a mold of type `arch`
```
::  all dirs and files in the root path
.^(arch %cy %)

::  all groups in the `%group-store` agent
.^(arch %gy /=group-store=/groups)
```

#### `%x` Queries
```
::  paths of all chats we're in
.^((set path) %gx /=chat-store=/keys/noun)

::  full group info for one group (with noun mold and noun mark)
.^(noun %gx /=group-store=/groups/ship/~zod/fakegroup/noun)

::  full group info for the same group, but with `(unit group)` mold
::  below line imports the `group.hoon` library
=g -build-file %/sur/group/hoon
.^((unit group:g) %gx /=group-store=/groups/ship/~zod/fakegroup/noun)
```

## `on-peek` Mechanics
When Gall receives a scry request with `%gx` or `%gy`, it translates the request and forwards it to the appropriate agent's `on-peek` arm. Once that arm produces a result, it passes it back to Gall, which does a check and then passes it back to the caller.

- happens in `++  ap-peek`, line 1223 of `sys/vane/gall.hoon`
- explain examples above
- explain the `(unit (unit cage))` translation

## start our app for chat admin
- walk through the on-peek in chat-store

- generally speaking, use `noun` and then coerce it

## look at gen/cat.hoon

## Code examples
- do `y` examples with Clay and group-store
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
