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

You can run `:file-server +dbug` in the Dojo to see the current directories being served and the parameters they are served with (like public vs. private).

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
`on-poke` needs to handle a `%handle-http-requuest` mark (line 57). This allows it to 

The type of the vase passed is `[id=@ta =inbound-request:eyre]`. We can process this `inbound-request` in whatever way we want, and return a card to Eyre if we want to pass a response immediately (discussed below in "How It Works").

#### on-arvo
Eyre will send an acknowledgement that our binding worked (or an error if it didn't), and we must process that in `on-arvo`, or else we'll get an error. We do this in line 122. 

`sign-arvo` is documented in the [types appendix](gall_types.md)--its head is the letter of the vane sending the message, and the tail is type `gift:able:$VANE`. If we search for `++  eyre` in `zuse`, we find that the response to a `%connect` or `%serve` will be a boolean saying whether it was accepted as well as the binding site requested.

#### on-watch
This, in line 145, is the strangest requirement: why do we need to handle a subscription request from Eyre?

In fact, all responses to HTTP in Eyre are handled by passing responses to a subscription path.
The answer is that not all HTTP requests are handled synchronously, and we also might want to return streaming data, as with a websocket/`EventSource`. Eyre opens a subscription on path `%http-response` whenever a request is made, and then `leave`s it after the connection is finished. Until that time, we can push data out by `%give`ing `%fact`s to that path. In this app, we simply handle the subscription to avoid errors, but treat it as a no-op.

### How It Works
`give-simple-payload` passes cards to Arvo, which passes them to Eyre, which passes back to the caller. This keeps Mars (Urbit, Gall) from knowing about Earth and coupling to it as a dependency.

Flow:
1. Eyre subscribes on to bound `app` (here, `%mars`) on path `/http-response/$EYRE_ID`
2. Eyre pokes `app` with an incoming request and mark `%handle-http-response`
3. App can respond on the subscribed path with various cages. Examples:
  - `%http-response-header`
  - `%http-response-data`
4. app `%give`s a `%kick` when done to close the connection

#### Manual Example
Navigate to [http://localhost/~mars-manual](http://localhost/~mars-manual).  You'll notice that your browser stays loading, even though some data is displayed in the page.

Let's follow the data flow and see what happens here. If you look in your Dojo, you'll see two messages:
```
>>> "watch request on path: [i=%~.http-response t=/~.eyre_0v4.jolo0.qjl1a.73gr8.40fll.ivird]"
>>  "'/~mars-manual'"
```
The first message is from line 146 and corresponds to (1) above: Eyre subscribes on the `/http-response/...` path. The second is from line 59 in the code, and corresponds to (2) above: Eyre poked our app.

Because our incoming URL matches `'~/mars-manual'`, we call `open-manual-stream` and pass the Eyre id. This will let us respond by passing a message to the subscription.

In line 90, we have `open-manual-stream`. It sets a state variable with the Eyre `id` so that we can close the connection later, and then it `%give`s two `%fact`s: an HTTP header and a response body. Eyre is subscribing on the path here, so it gets these and prints the body in the browser.

Let's inspect our app state, and then close the connection:
```
::  see that we set last-id.state
> :mars +dbug

::  see that there's a subscription from Eyre in sup
> :mars +dbug %bowl

::  poke mars with an action that closes the connection
> :mars &mars-action [%http-stream-close %.y]
```
In that last command, our app matches the `%http-stream-close` action, sets `last-id.state` to `~`, and then passes a `%give %kick` card.  This closes the connection, and you'll see that your browser is no longer "loading".

#### "Managed" Example
Most of the time, however, you just want to return some data upon a request.

Navigate to [http://localhost/~mars-managed](http://localhost/~mars-managed). (Make sure you're logged in). This time, you'll see a JSON response and the page will finish loading.

We handle this starting in line 62. This first uses `give-simple-payload` from `/lib/server.hoon`. Looking at the code below, we see what a `simple-payload` is and how it's used by `server.hoon`:

From `/sys/zuse.hoon`
```
+$  simple-payload
  $:  =response-header
      data=(unit octs)
  ==
```

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
So `give-simple-payload` takes an `eyre-id` (needed to pass data to a subscription) as well as a `simple-payload` (which can be created by the `*-response` arms in `server.hoon`). It then does *exactly* the same process as we did in our manual request handling to `%give` `%fact`s to Eyre, and `%kick`s at the end to close the connection.

Instead of passing a payload directly, in line 65 we use `require-authorization` from `server.hoon`. This takes two parameters: a request and a gate to run on the request. It only runs the gate if the user is currently logged in to the ship. This is a common pattern used to protect private resources and require a login.

### Response Types
You can return many types of responses by using the `*-response` arms in `lib/server.hoon` (eg `html-response`). You simply pass the data you want to return as bytes (`octs` in Urbit-ese) to the appropriate gate. In line 110 we use `json-to-octs`, but we could just as easily generate `html` with `as-octt:mimes:html` from `zuse`:
```
> ^-  octs  (as-octt:mimes:html "<html></html>")
[p=13 q='<html></html>']
```

## Iris: HTTP Client to Call Out to Earth
Calling out to Earth using the Iris (`%i`) vane is very straightforward. Let's do it, and then check how the code works:
```
::  fetch a webpage, example.com
> :mars &mars-action [%http-get 'http://example.com']

::  check that we stored its contents
:mars +dbug [%state 'files']
```

### Call Iris
Above, we used the `%http-get` `mars-action`, which we handle in line 74. We pass a card to Arvo that is a `note-arvo` using `task:able:iris` from `zuse`, which has form for requests: `[%request =request:http =outbound-config]`.

We pass `[%'GET' url ~ ~]` as the `request:http` parameter, and use the bunt value for the `outbound-config`. For the wire to pass on, we use the `url.action` so that we'll have access to it when we receive the response.

### Response Handling in `on-arvo`
The response will come back in `on-arvo`. In line 125 we catch anything coming from Iris, and then only continue if the head of the tail is an `%http-response`. Then we run `handle-response`, passing the head of `wire`, which is our `url`, as well as the response itself.

### Possible Iris Responses (from `zuse.hoon`)
`client-response:iris` in `zuse` can have the following values:
```
::  incremental progress report
[%progress =response-header:http bytes-read=@ud expected-size=(unit @ud) incremental=(unit octs)]

::  success
[%finished =response=header:http full-file=(unit mime-data)]

::  canceled by the runtime system
[%cancel ~]
```

We assume that we'll get a `%finished` response--if we don't, we just print the response and move on.

Once we get `%finished`, we store it in a map keyed by `url`, which is what we saw at the top of this section when we printed the `dbug` state.

## Summary
We covered all of the key ways to communicate with Earth resources over HTTP from Mars.  Now that `%file-server` has been added, you'll be able to handle most web interactions with your server simply by serving static files and using the JSON pokes and subscription pushes you'll learn in the [channels lesson](chanel.md).

However, there are definitely times when you need to access outside resources or serve custom logic from an endpoint, and in those cases, Eyre and Iris are your not-so-hard-to-use friends.

## Exercises
1. Serve your ship's name and the current time from an `/~info` endpoint
2. TODO: `file-server` code analysis


[Prev: Talk to Ships: Poke & Watch](poke.md) | [Home](overview.md) | [Next: JSON & channel.js)](chanel.md)
