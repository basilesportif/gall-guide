# Call from Outside: JSON & channel.js

In this lesson, we're going to show how to call into your app from the outside world. We'll do it from a web browser, but this example would be easy to extend to other contexts.

In order to make the calls, we'll use and explain the helper library `channel.js`, which is short (235 lines as of this writing) and provides a minimal interface for poking and subscribing.

You'll also learn how to use the `:file-server` Gall agent to serve static files up to web requests from anywhere on your Urbit.

## Example Code
- very simple
- note: moves to the `|^` style?
- note: uses dbug
- note: mounts static files in `on-init`
- `|start %chanel`

## marks and JSON Parsing

### Action Type and JSON mark
In `sur/chanel.hoon` we define our `action` type. It has 4 different elements, to showcase different ways of parsing JSON.

In `mar/chanel/action.hoon`, we define a `%chanel-action` mark. It has a `json` arm in `grab`, so that we can take `json` sent in with a `%chanel-action` mark by the frontend, and properly parse it here. That parsing works by running `=<  (action jon)` on the incoming JSON, where `action` is an arm that produces a JSON parser (a gate). Let's look now at how that works

### JSON Parsing, Explained
In order to parse, we use the `dejs:format` core found in `zuse.hoon`. Its arms let us create gates that will parse a given piece of JSON. There are two basic types of arms: arms that directly produce gates (like `so` and `ni`) and arms that require samples to produce gates (like `of` and `ot`)

#### Simple Parsers
These parsers all take json directly and produce various types like numbers and strings.  You can find all variants by searching for `++  dejs` in `sys/zuse.hoon`.
```
> (so:dejs:format (json [%s 'hello']))
'hello'

> (ni:dejs:format (json [%n ~.99]))
99

> (no:dejs:format (json [%n ~.99]))
~.99

> (bo:dejs:format (json [%b %.y]))
%.y
```

#### Parsers with Samples
These expect a sample in order to produce a gate that can then be used to parse.
```
::  parse string using an aura
> `@da`((se:dejs:format %da) (json [%s '~2020.7.4..08.39.17..541e']))
~2020.7.4..08.39.17..541e

> `@p`((se:dejs:format %p) (json [%s '~timluc-miptev']))`
~timluc-miptev

::  parse string using a rule (useful for going from ship-name to @p)
> `@p`((su:dejs:format fed:ag) (json [%s 'timluc-miptev']))
~timluc-miptev
```

#### Object and Array Parsing
Objects:
```
:: set up example maps
> =m1 (~(put by *(map cord json)) ['key1' [%s 'sample cord']])
> =m2 (~(put by *(map cord json)) ['key2' [%n ~.998]])
> =mboth (~(put by m1) ['key2' [%n ~.998]])

::  of takes a list of [key parser] tuples and makes a parser that creates [key value] keys for ONE key
::  first element of the tuple is a possible key
::  second element of the tuple is the parser to use for that type of key
> =of-parser %-  of:dejs:format
  :~  [%key1 so:dejs:format]
      [%key2 ni:dejs:format]
  ==
> (of-parser (json [%o m1]))
[%'key1' 'sample cord']
> (of-parser (json [%o m2]))
[%'key2' 998]

::  ot takes a list of n tuples, but makes a parser that for an object that has ALL the keys
> =ot-parser %-  ot:dejs:format
  :~  [%key1 so:dejs:format]
      [%key2 ni:dejs:format]
  ==
> (ot-parser (json [%o mboth]))
['sample cord' 998]
```

Arrays:
```
::  ar - array as list. List has one type inside, so one parser passed
> ((ar:dejs:format ni:dejs:format) (json [%a p=~[[%n p=~.9] [%n p=~.10]]]))
~[9 10]

::  at - array as tuple (multiple parsers needed)
> ((at:dejs:format ~[ni:dejs:format so:dejs:format]) (json [%a p=~[[%n p=~.9] [%s 'hello there']]]))
[9 'hello there']

::  as - array as set, all of one type
> `(set @ud)`((as:dejs:format ni:dejs:format) (json [%a p=~[[%n p=~.10] [%n p=~.10] [%n p=~.9] [%n p=~.10]]]))
{10 9}
```

## Simplest Possible Browser/Ship Interaction
In our `on-init`, we started serving the `app/chanel` directory publicly, with no login required. This means that you can navigate directly to [http://localhost/~chanel/index.html](http://localhost/~chanel/index.html) and see a page there.

If you open the JS console, you'll see some messages with your current ship name and some stuff about "Successful Poke".

In `index.html`, you'll see that we include `channel.js` and `index.js`. The latter is our custom logic, so let's start by learning about `channel.js`.

## channel.js
`channel.js` is a library that lives under `/~landscape/js/channel.js` when you are logged in to your ship. We'll use the [May 28th verion](https://github.com/urbit/urbit/blob/4fded00005770a84a53ff77a81ba71353f84b4bd/pkg/arvo/app/landscape/js/channel.js) in this lesson and serve it directly from `app/chanel/channel.js`.

`channel.js` allows you to do pokes and subscribes to a running ship, similar to what we've seen from the Dojo. The only difference is that the data for the pokes will initially be passed as JSON, which is why we learned about parsing above.

### Interface to channel.js
You create a new channel by calling `new Channel()`. This initializes a data structure to track pokes and subscriptions.

You interface with channel.js by calling `poke`, `subscribe` and `unsubscribe`.

#### poke
`poke(ship, app, mark, json, successFunc, failureFunc)`
* ship: ship name, generally the one our frontend is logged in to
* app: name of the Gall app
* mark: name of the mark
* json: data to pass in the poke. We'll see in a bit how custom marks let us parse it on the Gall side
* successFunc: function to call if poke succeeds; takes no parameters
* failureFunc: function to call if poke fails; takes error as parameter

#### subscribe
`subscribe(ship, app, path, connectionErrFunc, eventFunc, quitFunc)`
* ship: ship name, generally the one our frontend is logged in to
* app: name of the Gall app
* path: `on-watch` path to subscribe to
* connectionErrFunc: function to call if subscribing fails
* eventFunc: function to call on success, takes a data parameter
* quitFunc: function to call after unsubscribing or being kicked

#### unsubscribe
`unsubscribe(subscription)`: passes a subscription from `outStandingSubscriptions` to unsubscribe to.

### Basic Logical Flow
1. `poke` or `subscribe`  is called
2. send their json to `ship/~/channel/$UID`
3. Generate a new `outstandingPoke` or `outstandingSubscription`
4. Open up an `EventSource` if one doesn't exist
5. Poke will generate one response (basicallyy an ack); subscribe will create as many as the server generates. All will be handled in the `onmessage` function.

#### poke Response
If the response is to a poke, its data is disregarded, and we just run the poke `onSuccess` function and delete the `outstandingPoke`. This is like a `%poke-ack` in our [prior lesson](poke.md).

#### subscribe Response
This can receive a `"quit"` response (for `kick` and `leave`) which causes it to call the subscription's `quitFunc` and deletes the `outstandingSubscription`.

If it receives an `"event"` response, it calls the subscription's `eventFunc` with the the `json` element of the return object.

### "Under the Hood"
`channel.js` creates a JS `EventSource`, which is just an object that that opens a connection to a server on a URL, and listens for updates on it from the server. You [attach](https://github.com/urbit/urbit/blob/4fded00005770a84a53ff77a81ba71353f84b4bd/pkg/arvo/app/landscape/js/channel.js#L180) an `onmessage` function to the event source to process messages back.

## index.js
Now we can go through this and see how it interacts with our ship's running Gall app.

### Getting Ship Name

### Make Pokes

### Subscribe

### Send Subscription Data

