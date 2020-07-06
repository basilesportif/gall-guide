# HTTP & Static Files
Urbit is Mars. The rest of the computing world is Earth.

We'll touch on this metaphor again later, but it deeply informs how ships communicate with the outside world. They are hermetically sealed, and should only interact with it in specific ways.

That said, your Urbit is meant to be a personal *server*. That means that we need to have ways for it to serve up resources to the outside world (Earth calling Mars).  There are also times when we want to access Earth resources we've heard about, which your Urbit allows you to access through a very narrow interface.

In this lesson, you will learn how to:
* serve static files to Earth (the outside internet)
* handle dynamic inbound requests from Earth on the server-side
* 

## `%file-server`: Serve Static Resources to Earth
In `on-init`, we return a couple cards that open up directories to the world.
```
=/  public-filea   [%file-server-action !>([%serve-dir /'~mars-public' /app/mars/public %.y])]
=/  private-filea  [%file-server-action !>([%serve-dir /'~mars-private' /app/mars/private %.n])]
```
```

> :file-server +dbug
::  the 
```

### Only for Authenticated

## Eyre: Handle Dynamic Calls from Earth
- `%file-server` uses Eyre internally

- return JSON
- return TXT
- return HTML

### How It Works
`ive-simple-payload` passes cards to Arvo, which passes them to Eyre, which passes back to the caller. This keeps Mars (Urbit, Gall) from knowing about Earth and coupling to it as a dependency.

## Iris: Call Out to Earth
```
:mars &mars-action [%http-get 'http://example.com']
```

### Response Handling in `on-arvo`

### Possible Responses (from `zuse.hoon`)
```
::  incremental progress report
[%progress =response-header:http bytes-read=@ud expected-size=(unit @ud) incremental=(unit octs)]

::  success
[%finished =response=header:http full-file=(unit mime-data)]

::  canceled by the runtime system
[%cancel ~]
```
```
+$  mime-data
  [type=@t data=octs]
````

In our `on-init`, we called out to Eyre. Let's see how we can use this call to serve HTTP resources. For more detail on the types used, see the [types appendix](gall_types.md) in the "Eyre" section.
```
[%pass /bind %arvo %e %connect [~ /'~myapp'] %myapp]
```

So now, whenever an HTTP request comes in at `http://localhost:$PORT/~myapp` (where `$PORT` is the port your fakezod is running on), it will produce 


::  print a list of the directories we are serving
> :file-server +dbug


[Prev: Talk to Ships: Poke & Watch](poke.md) | [Home](overview.md) | [Next: JSON & channel.js)](chanel.md)
