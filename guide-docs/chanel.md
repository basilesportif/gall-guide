# Call from Outside: JSON, channel.js, and Static Files

In this lesson, we're going to show how to call into your app from the outside world. We'll do it from a web browser, but this example would be easy to extend to other contexts.

In order to make the calls, we'll use and explain the helper library `channel.js`, which is short (235 lines as of this writing) and provides a minimal interface for poking and subscribing.

You'll also learn how to use the `:file-server` Gall agent to serve static files up to web requests from anywhere on your Urbit.

## Example Code
- very simple
- note: moves to the `|^` style?
- note: uses dbug

## Action Type and JSON Mark

### Action Type

### JSON Mark

### JSON Parsing, Explained
* provide a "mark" (`%increase`)
* function for how to parse that mark's data
* `of` says that it can have many "fronds"
* `ot` says it will have these multiple elements
- `fed:ag` is the ship name parser (`cord` to `ship`). Deal with it.

## Mount the Static Files
```
> :file-server &file-server-action [%serve-dir /'~chanel' /app/chanel %.y]
> :file-server +dbug
```

## channel.js
[May 28 channel.js](https://github.com/urbit/urbit/blob/4fded00005770a84a53ff77a81ba71353f84b4bd/pkg/arvo/app/landscape/js/channel.js)

### EventSource
Simple browser built-in object that opens a connection to a server on a URL, and listens for updates on it from the server. You [attach](https://github.com/urbit/urbit/blob/4fded00005770a84a53ff77a81ba71353f84b4bd/pkg/arvo/app/landscape/js/channel.js#L180) an `onmessage` function to the event source to process messages back.

### flow
1. get a poke or subscribe
2. send their json to `ship/~/channel/$UID`
3. Generate a new `outstandingPoke` or `outstandingSubscription`
4. Open up an `EventSource` if one doesn't exist
5. Poke will generate one response (basicallyy an ack); subscribe will create as many as the server generates. All will be handled in the `onmessage` function.

### poke Response
If the response is to a poke, its data is disregarded, and we just run the poke `onSuccess` function and delete the `outstandingPoke`. This is like a `%poke-ack` in our [prior lesson](poke.md).

### subscribe Response
This can receive a `"quit"` response (for `kick` and `leave`) which causes it to call the subscription's `quitFunc` and deletes the `outstandingSubscription`.

If it receives an `"event"` response, it calls the subscription's `eventFunc` with the the `json` element of the return object.
