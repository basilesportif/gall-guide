# HTTP & Static Files
Doing all this stuff internally is great and all, but your Urbit is meant to be a personal *server*. That means that we need to have ways for it to serve up resources to the outside world (Earth calling Mars).  There are also times when we want to access Earth resources we've heard about, which your Urbit allows you to access through a very narrow interface.

In this lesson, you will learn how to:
* serve static files to Earth (the outside internet)
* 

## `:file-server`: Serve Static Resources
```
> :file-server &file-server-action [%serve-dir /'~chanel' /app/chanel %.y]
> :file-server +dbug
```

### Only for Authenticated

### 

## Iris: Call Out to Earth
```
:mars &mars-action [%http-get 'http://example.com']
```

In our `on-init`, we called out to Eyre. Let's see how we can use this call to serve HTTP resources. For more detail on the types used, see the [types appendix](gall_types.md) in the "Eyre" section.
```
[%pass /bind %arvo %e %connect [~ /'~myapp'] %myapp]
```

So now, whenever an HTTP request comes in at `http://localhost:$PORT/~myapp` (where `$PORT` is the port your fakezod is running on), it will produce 


::  print a list of the directories we are serving
> :file-server +dbug


[Prev: Talk to Ships: Poke & Watch](poke.md) | [Home](overview.md) | [Next: JSON & channel.js)](chanel.md)
