# HTTP & Static Files
Urbit is Mars. The rest of the computing world is Earth.

We'll touch on this metaphor again later, but it deeply informs how ships communicate with the outside world. They are hermetically sealed, and should only interact with it in specific ways.

That said, your Urbit is meant to be a personal *server*. That means that we need to have ways for it to serve up resources to the outside world (Earth calling Mars).  There are also times when we want to access Earth resources we've heard about, which your Urbit allows you to access through a very narrow interface.

In this lesson, you will learn how to:
* serve static files to Earth (the outside internet)
* handle dynamic inbound requests from Earth on the server-side
* 

## `%file-server`: Serve Static Resources to Earth
In `on-init`, we return a couple cards that open up directories to the world. Those are the `public-filea` and `private-filea` faces. Here are the action types of the `%file-server` agent that we pass them to:
```
$%  [%serve-dir url-base=path clay-base=path public=?]
    [%unserve-dir url-base=path]
    [%toggle-permission url-base=path]
    [%set-landscape-homepage-prefix prefix=(unit term)]
==
```
We use `%serve-dir` here. It takes a URL, a directory to serve, and a flag for whether the file should be served to requesters who are not logged in to this ship. The latter is useful for serving static resources like HTML files or images from an Urbit.

You can run `:file-server +dbug` in the Dojo to see the current bound directories being served.

### Public and Private File Serving
Make sure your ship is not logged in, and then navigate to [http://localhost/~mars-public/index.html](http://localhost/~mars-public/index.html). You should see the contents of `/app/mars/public/index.html` there.

However, if we try to navigate to [http://localhost/~mars-private/index.html](http://localhost/~mars-private/index.html), we get a login screen. If you log in and go back to that link, now you'll see the `/app/mars/private/index.html` file.

### Changing Serving Options
We can directly poke `%file-server` in order to serve and unserve directories or toggle directories between public and private. You can experiment with commands like the below:
```
> :file-server &file-server-action [%toggle-permission /'~mars-public']
> :file-server &file-server-action [%unserve-dir /'~mars-public']
```

## Eyre: HTTP Server to Handle Calls from Earth
`%file-server` lets us handle static resources, but what if you want your Urbit to respond dynamically at a given endpoint?  To do this, we use the Eyre vane to bind our app to a given endpoint and process incoming HTTP requests to that endpoint. `%file-server` uses Eyre internally--after this part of the lesson, you'll probably be able to understand a lot of what's going on in `app/file-server.hoon`.

Back in the [lifecycle lesson](lifecycle.md), we connected to Eyre as part of our `on-init` and `on-load` functions. We'll do the same here, but go into a lot more detail.

### Initial Binding


### Requirements
The binding card does the initial work, but Eyre also requires some other arms in your app to be set up for it.
#### on-poke

#### on-arvo

#### on-watch
- on-poke handler
  - `%handle-http-response` mark
  - type of the vase is `[id=@ta req=inbound-request:eyre]`
- on-arvo handler
  * just confirms the bind with an Eyre `gift`
- on-watch handler
  * why?

### How It Works
`ive-simple-payload` passes cards to Arvo, which passes them to Eyre, which passes back to the caller. This keeps Mars (Urbit, Gall) from knowing about Earth and coupling to it as a dependency.

### Return Types
- return JSON
- return TXT
- return HTML


## Iris: HTTP Client to Call Out to Earth
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
