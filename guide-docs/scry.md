# `on-peek` and scry
So far in this course we've stayed inside our own agents, poking them, altering their data, etc. However, one of Urbit's big wins is the ability to query (`scry`) data of *other* agents in a structured manner, when they allow it. In this sense, Gall agents aren't just "apps"--they play a similar role to databases.

For example, imagine that you want to find out all the groups a user is currently subscribed to. This is stored in every ship inside the `%group-store` Gall agent. That agent, in turn, exposes some of its internal data through `scry` queries using its `on-peek` arm.

In this lesson, in addition to our own `on-peek` arm, we'll examine some that already exist in the Gall agent-space that you can query on your own. By the end, you should be confident that you can grab any info that an agent exposes to your Urbit.

## Example Code
* [/app/iscry.hoon](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/iscry.hoon)
Copy the file to your ship's `app` directory, and install it as usual: `|start %iscry`.

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

### Example Dojo Queries
Since some of these queries are sent to `%group-store`, we need to add a dummy group so that they'll return data:
```
:group-store &group-action [%add-group [~zod %fakegroup] [%invite *(set ship)] %.n]
:group-push-hook &group-update [%add-members [~zod %fakegroup] (sy ~[~zod ~timluc ~dopzod])]
```

#### `%y` Queries
These should use a mold of type `arch`
```
::  all dirs and files in the root path
> .^(arch %cy %)

::  all groups in the `%group-store` agent
> .^(arch %gy /=group-store=/groups)
```

#### `%x` Queries
```
::  paths of all chats we're in
> .^((set path) %gx /=chat-store=/keys/noun)

::  full group info for one group (with noun mold and noun mark)
> .^(noun %gx /=group-store=/groups/ship/~zod/fakegroup/noun)

::  full group info for the same group, but with `(unit group)` mold
::  below line imports the `group.hoon` library
> =g -build-file %/sur/group/hoon
> .^((unit group:g) %gx /=group-store=/groups/ship/~zod/fakegroup/noun)
```

## `on-peek` Mechanics
When Gall receives a scry request with `%gx` or `%gy`, it:
1. translates the request and forwards it to the appropriate agent's `on-peek` arm
2. waits for that arm to produce a result
3. processes the result and, if it's valid, passes it back to the caller

### Translating the Request
Gall scrys have the forms below, where capitalized names are meant to be replaced with values:
```
[%gx /SHIP/GALL-AGENT/TIME/example/path/mark]
::  OR
[%gy /SHIP/GALL-AGENT/TIME/example/path]

```
Gall translates `[%gy /SHIP/GALL-AGENT/TIME/example/path]` into `[%y /example/path]` and passes that value to the `on-peek` of agent `GALL-AGENT`.

Gall translates `[%gx /SHIP/GALL-AGENT/TIME/example/path/mark]` into `[%x /example/path]`, and remembers the mark.

### Inside `on-peek`
Look at the `on-peek` arm in `iscry.hoon`. It matches against the incoming paths, of which we match three:
1. `[%y %result ~]`
2. `[%x %friend ~]`
3. `[%x %no-result ~]`

#### Example Requests
```
> .^(arch %gy /=iscry=/result)

::  returns the ship
> .^(ship %gx /=iscry=/friend/noun)

::  crashes
> .^(noun %gx /=iscry=/no-result/noun)
```

### Processing the Result
When the result is produced by `on-peek`, Gall returns it directly to caller if it was a `%y` scry. If it was an `%x`, Gall runs the mark passed at the end of its path on it, and then returns it to the caller, which runs the mold passed as the first argument to `.^`. 

So `.^(ship %gx /=iscry=/friend/noun)` is passed to `on-peek` as `[%x %friend ~]`, and then it returns `friend.state` inside a `noun` `cage`. Because it is a `ship/@p`, our mold of `ship` succeeds, and it returns `~timluc-miptev`. We could just as easily pass a mold of `noun`: `.^(ship %gx /=iscry=/friend/noun)`, which would produce `3.690.144`.

`on-peek` returns `(unit (unit cage))`. A return of `~` is meant to represent the value maybe existing, and `[~ ~]`. In either case, Gall produces a crash if `~` or `[~ ~]` is returned by `on-peek`.

#### Note on Marks
Generally in Gall agent source, you'll see `%x` queries use a `%noun` mark, the caller will look at their source or documentation to know what type is "really" inside the vase, and will pass that type as the mold to `.^`. In the next section, we'll see how to examine source to see what type is expected inside a given vase.

## Querying Existing Data
Very often, programmers want to make extensions to Urbit that are variations on "query existing data about chats/groups, and then do something." The "query" part of these use cases is done with scry. A bot to monitor chats for invite requests, for example, needs to be able to scry a particular chat's path and check for certain patterns in the messages sent there.

Sometimes these scry paths are documented, but often they're not. No problem! You just need to open up the source of the Gall app that stores the data you want, see what types of scrys its `on-peek` arm takes, what form it produces data in, and build your query accordingly.

Below, we walk through the `on-peek` arms for `%group-store` and `%chat-store` and see how we can extract information from them.

### `%group-store` Walkthrough

### `%chat-store` Walkthrough
- show how `envelopes` parses negative/positive number

## Exercises
* Write successful Gall scry requests to 5 different agents on your main ship. Use both `%x` and `%y`.
