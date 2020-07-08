# HTTP & Static Files
Urbit is Mars. The rest of the computing world is Earth.

We'll touch on this metaphor again later, but it deeply informs how ships communicate with the outside world. They are hermetically sealed, and should only interact with it in specific ways.

That said, your Urbit is meant to be a personal *server*. That means that we need to have ways for it to serve up resources to the outside world (Earth calling Mars).  There are also times when we want to access Earth resources we've heard about, which your Urbit allows you to access through a very narrow interface.

In this lesson, you will learn how to:
* serve static files to Earth (the outside internet)
* handle dynamic inbound requests from Earth on the server-side
* call out to Earth HTTP resources

## Example Code
* to `/app/`
  - [mars.hoon](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/mars.hoon)
* to `/app/mars/public/`
  - [index.html](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/mars/public/index.html)
* to `/app/mars/private/`
  - [index.html](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/app/mars/private/index.html)
* to `/mar/mars/`
  - [action.hoon](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/mar/mars/action.hoon)
* to `/sur/`
  - [mars.hoon](https://github.com/timlucmiptev/gall-guide/blob/master/example-code/sur/mars.hoon)

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
We pass Gall the card `[%pass /bind %arvo %e %connect [~ /'~mars-dynamic'] %mars]`, which is a `note-arvo`, starting with `%e`, which means the rest of the card is of type `task:able:eyre` (defined in `zuse.hoon`).

We pass a `%connect` task:
```
[%connect =binding app=term]
::  app is %mars, the name of our app in Gall
::  binding is:
[site=(unit @t) path=(list @t)]
::  where a ~ value for site matches this ship, or you can pass a domain as a string.
::  generally you'll use ~
```
For the path in `binding`, `/~myapp` will match `/~myapp` or `/~myapp/longer/path`.

### Arm Requirements
The binding card does the initial work, but Eyre also requires some other arms in your app to be set up for it.
#### on-poke
`on-poke` needs to handle a `%handle-http-response` mark (line 56.) This allows it to 

The type of the vase passed is `[id=@ta =inbound-request:eyre]`. We can process this `inbound-request` in whatever way we want, and return a card to Eyre if we want to pass a response immediately (discussed below in "How It Works").

#### on-arvo
Eyre will send an acknowledgement that our binding worked (or an error if it didn't), and we must process that in `on-arvo`, or else we'll get an error. We do this in line 96. 

`sign-arvo` is documented in the [types appendix](gall_types.md)--its head is the letter of the vane sending the message, and the tail is type `gift:able:$VANE`. If we search for `++  eyre` in `zuse`, we find that the response to a `%connect` or `%serve` will be a boolean saying whether it was accepted as well as the binding site requested.

#### on-watch
This, in line 119, is the strangest requirement: why do we need to handle a subscription request from Eyre?

In fact, all responses to HTTP in Eyre are handled by passing responses to a subscription path.
The answer is that not all HTTP requests are handled synchronously, and we also might want to return streaming data, as with a websocket/`EventSource`. Eyre opens a subscription on path `%http-response` whenever a request is made, and then `leave`s it after the connection is finished. Until that time, we can push data out by `%give`ing `%fact`s to that path. In this app, we simply handle the subscription to avoid errors, but treat it as a no-op.

### How It Works
`give-simple-payload` passes cards to Arvo, which passes them to Eyre, which passes back to the caller. This keeps Mars (Urbit, Gall) from knowing about Earth and coupling to it as a dependency.

Flow:
1. Eyre subscribes on to bound `app` (here, `%mars`) on path `/http-response/$EYRE_ID`
2. Eyre pokes `app` with an incoming request and mark `%handle-http-response`
3. App responds on the subscribed path with cages that have marks:
  - `%http-response-header`
  - `%http-response-data`
4. app `%give`s a `%kick` when done to close the connection

#### Manual Example
Navigate to [http://localhost/~mars-manual](http://localhost/~mars-manual).  You'll notice that your browser stays loading, even though some data is displayed in the page.

```
> :mars +dbug
> :mars +dbug %bowl
> :mars &mars-action [%http-stream-close %.y]
```

#### Managed Example
Navigate to [http://localhost/~mars-managed](http://localhost/~mars-managed).  You'll notice that your browser stays loading, even though some data is displayed in the page.

From `/lib/server.hoon`
```
++  give-simple-payload
  |=  [eyre-id=@ta =simple-payload:http]
  ^-  (list card:agent:gall)
  =/  header-cage
    [%http-response-header !>(response-header.simple-payload)]
  =/  data-cage
    [%http-response-data !>(data.simple-payload)]
  :~  [%give %fact ~[/http-response/[eyre-id]] header-cage]
      [%give %fact ~[/http-response/[eyre-id]] data-cage]
      [%give %kick ~[/http-response/[eyre-id]] ~]
  ==
```

### Parsing a Longer URL
- url comes in the request

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
