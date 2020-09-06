# Store/Hook/View Architecture
To write an "autistic" Gall agent, one that just processes data and doesn't talk to other agents, you can just write the program and be done with it. However, if you intend your agent's data to be used by other agents, you need to architect them a bit more carefully.

Many Gall agents use a store/hook/view architecture to separate functionality and protect data. In this lesson, you will learn to read programs that use this architecture so that you can call them to access data on your Urbit.

### Overview
* stores are like databases. They generally should only be accessed by agents on your ship.
* hooks act as a permissions layer in front of stores, both for requesting and returning data. They determine what outside ships are allowed to access.
* views join together data from multiple stores, and also process actions from the outside world (e.g. when someone clicks a button in a UI).
  
The focus of this lesson is on reading existing code. By the end of the lesson and its exercises, you will be comfortable understanding and querying Gall agents that use this pattern.

## Example Code

We'll refer to the September 3, 2020 version of the files below:
* [app/chat-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-hook.hoon)
* [app/group-push-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/group-push-hook.hoon)
* [app/group-pull-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/group-pull-hook.hoon)
* [lib/pull-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/pull-hook.hoon)
* [lib/push-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/push-hook.hoon)
* [app/chat-view.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-view.hoon)
* [sur/chat-view.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/sur/chat-view.hoon)
* [lib/chat-view.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/chat-view.hoon)
* [lib/chat-store.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/chat-store.hoon)

## Store
Stores are databases that are intended to 
a. store data for a given application (like chat or groups)
b. make that data available to other agents locally, and selected agents globally

### Access Restrictions
Stores impose read and write access restrictions in three places. 

The first is [on-poke](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-store.hoon#L89), as seen there for `chat-store`. This restricts "write" operations to the store.

Second, the same `team:title` restriction is used in [on-watch](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-store.hoon#L103), which restricts "read" operations.

Finally, `on-peek`'s `scry` reads are only accessible from the calling ship, not from remote. Data access restrictions can be further enforced by limiting what `on-peek` makes available locally.

## Hooks
Urbits get authentication ("who are you?") for free with ship ids, but need a way to handle authorization ("I know who you are, but what are you allowed to access?"). Hooks are the means by which this is achieved.

### Hooks: Mental Model
Hooks can be a bit tricky to grok, so an analogy is helpful. Imagine that every data store is a king, and the king does not want to deal with impositions on his time and attention. So he delegates his evil vizier to handle all interactions with the outside world for him, and refuses to talk to anyone but his vizier.

If King1 wants information from King2, he asks his Vizier1 to get it. Vizier1 contacts his worm-tongued counterpart, Vizier2, with either a poke or subscription request.
* poke: Vizier2 checks whether Vizier1 is allowed to poke King2, and pokes King2 on Vizier1's behalf if he is.
* subscription: Vizier2 checks whether Vizier1 is allowed to subscribe to King2. If he is, Vizier2 listens for any updates from King2, passes them to Vizier1, who in turn informs King1 of these goings-on.

Using this structure, chats and groups can mirror the information held by other chats and groups, while separating data storage from permissions and authorization.

### Examples
Let's look at some concrete examples of hooks requesting and receiving data.

#### Typing a `%message` into Chat
In [line 480 of chat-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-hook.hoon#L480), we see the handling of a `%message` action, for when a new message is entered in chat.

There are 2 cases here, local and foreign:
1. local: we created this `%message` and are poking `%chat-hook` from our own ship. This means that either
  - we own the chat, in which case we want to send the message to our own `chat-store`
  - the chat is on another ship, and we need to poke *that ship's* `chat-hook` to add it to their store
The `?:` that checks whether it's our chat or someone else's is in line 494.

2. foreign: someone else created the `%message` is hitting our `%chat-hook` from another ship's `chat-hook`, and we need to add it to our `%chat-store` iff that ship is in the chat's group, *and** we are the chat owner.

- In line 499 we check that we own the chat (`synced` is a map of chat-path -> chat-owning-ship)
- In line 501 we check that the sender is in the group

**Note**: in the foreign case, we do *not* add the `%message` to our store if we are not the chat's owner. That mirroring is handled via subscriptions, not pokes.

#### Mirroring a Remote Chat
When you're lurking in chat and a message is posted (or if you're super-active but, horror of horrors, you are not the poster), `chat-store` sends that message out to all chat members so that they can mirror it in their local `chat-store`s.

However, we saw in [line 103 of chat-store.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-store.hoon#L103) that only local agents can subsciribe to `chat-store`. So the mirroring flow looks as follows:
1. the chat owner's `chat-store` receives a poke from his `chat-hook` vizier and stores the new message.
2. that `chat-store` sends an update to its local subscribers, one of which is the `chat-hook` vizier (line 111 of `chat-store.hoon`)
3. the vizier forwards it along to all of *its* subscribers: the other `chat-hook`s that are members of that chat.

Step 3 begins in [line 374 of chat-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-hook.hoon#L374), which then calls [fact-check-update](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-hook.hoon#L642) to see whether the `on-agent` call was local or foreign.

- local: our own ship produced the `on-agent` event, which means we need to send out an update to our `chat-hook` vizier peers. In this case, we `%give` the update to subscribers as in [line 663](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-hook.hoon#L663).
- foreign: another `chat-hook` is sending us an update, so we need to mirror it in our `chat-store`. In [line 699](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-hook.hoon#L699) we ensure that the other `chat-hook` is on the chat owner's ship, and then poke our `chat-store` king with the incoming message, so that he can mirror it.

## Deeper on Hooks: `push-hook` & `pull-hook`
In the above examples, a pattern of "check whether this event is from our local king or from a foreign vizier" kept re-occuring. That pattern can be abstracted out into push and pull hooks, as is currently the case for `group-store`'s hooks.

### push vs. pull
* `push` hook 
  - handles all incoming pokes and checks whether they should be passed to the store
  - subscribes to the store and pushes its changes out to its remote hook partners
* `pull` hook
  - subscribes to remote `push` hooks and receives changes they push out
  - pokes its local store as it receives those changes, as seen in [line 191](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/pull-hook.hoon#L191) where it gets a `%fact`, and [line 273](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/pull-hook.hoon#L273) where it puts that fact into its local store

### `push-hook` & `pull-hook` Libraries
We can go even further and make "agent generators" for the push and pull hook pattern.

These libraries are similar to `lib/dbug.hoon`: they are generators that take samples and create full Gall agents from them.

The way to use these is
1. Someone creates a Gall agent, e.g. `app/group-push-hook.hoon`
2. Set the config to pass to the `push-hook` generator
3. Call a gate in the generator, passing it the config *and* a Gall agent with *specific extra arms*. The generator uses those extra arms to return a new Gall agent with custom behavior.

Let's dive right into an example.

#### Push: `app/group-push-hook.hoon`
In [app/group-push-hook.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/group-push-hook.hoon), we see a `config` defined in line 13. This config's form is from [line 6 of `lib/push-hook.hoon`](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/push-hook.hoon#L6), and requires us to define:
```
$:  store-name=term       ::  store agent
    store-path=path       ::  path to watch store-agent on
    update=mold           ::  the mold of updates the store sends
    update-mark=term      ::  the mark of updates the store sends
    pull-hook-name=term   ::  the pull-hook for this store
==
```
In line 19, `push-hook` defines a type: a door with all the Gall arms, plus 4 additional arms:
- `resource-for-update`: figure out from an update which resource it affects (e.g. which group), so that we can send updates to those subscribed to that resource (probably `pull-hook`s).
- `take-update`: handle a subscription update coming from the store. We use the `update` mold for this.
- `should-proxy-update`: takes a vase with an update from the store and returns a true/false as to whether we should pass a poke to the store. The vizier uses this gate to decide whether to pass a poke to his king, the store.
- `initial-watch**: define the initial state that will be passed back when another agent subscribes to us.

When you make a new push-hook agent, **you need to implement those 4 arms**.

From [line 31 on down](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/group-push-hook.hoon#L31), `group-push-hook.hoon` defines an agent with the normal Gall arms, plus those 4. It then passes them as the sample to `agent:push-hook`, which constructs a normal, 10-armed, Gall agent that calls out to them.

#### Pull
`pull-hook` goes in much the same way as `push-hook`, except that it creates an agent that watches a remote `push-hook` for updates, processes those updates, and mirrors them to the appropriate local store.

Its `config` is simpler, since it knows that `push-hook`s use the `[%resource resource]` path to send subscription updates:
```
$:  store-name=term
    update=mold
    update-mark=term
    push-hook-name=term
==
```

The `pull-hook` [agent generator](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/pull-hook.hoon) has 2 additional arms:
- `on-pull-nack`: handle a subscription to a `push-hook` failing
- `on-pull-kick`: handle being kicked from our subscription to a `push-hook`

#### `group-push-hook` and `group-pull-hook`
Analyzing the way in which these define their custom arms will be left as an exercise for the reader.

## A Hook Note
If you want data that's in a store on your ship, you don't need to use a hook--you can just query the store directly with a `poke`, `scry`, or `watch`. Hooks are for intership communication.

## Views
Views are responsible for receiving information from a frontend, translating that into backend calls to other agents, and returning information to the frontend.

### Parse Data
The first responsibility of views is to parse JSON data. [Here we see](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/lib/chat-view.hoon#L9) code to parse JSON into `chat-view` actions. This lets the frontend either poke with JSON or the `chat-view-action` mark, and have it be useable.

To return JSON data, `chat-view` [uses the JSON encoder](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-view.hoon#L106) for `chat-store`.

### Handle Actions and Coordinate Agents
In [sur/chat-view.hoon](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/sur/chat-view.hoon), we see that `chat-view` can create chats, delete them, etc.

The creation case is interesting, because it has to coordinate the `chat-store`, `metadata-store`, and `group-store`.  We see this in [line 224](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-view.hoon#L224), where `create-chat`, `create-group`, and `create-metadata` are all called if the group referenced doesn't exist. These in turn call the relevant stores to add the data, and hooks to monitor the new resources and expose them to others if necessary.

### Pass Data Back to the Frontend
In our [HTTP lesson](http.md), we saw how you can serve data from an HTTP endpoint on your ship. And in the [channels lesson](chanel.md), we saw how you can `%give` data to a subscription path to get it to the frontend.  View agents often use both of these.

In [line 187](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-view.hoon#L187), `chat-view` listens to an HTTP endpoint and returns the contents of a mailbox to it, in JSON form.

In [line 498](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-view.hoon#L498), it passes updates from `chat-store` to the `/primary` subscription path, which is listened for in [line 102](https://github.com/urbit/urbit/blob/3cce0f38300d2e9cae0b47ad1b6901050ba18152/pkg/arvo/app/chat-view.hoon#L102) of `on-watch`.

Either of these methods are acceptable, and applications often use both (preferring HTTP requests for one-time calls, although that's by no means a hard-and-fast rule).

## Security Considerations
- have to evaluate the code for a new hook (or really any agent) that is installed on your ship, since it can bypass the access controls of a store.

## Exercises
* Outline how you would split `chat-hook` into a `push`/`pull` architecture.
* Analyze `should-proxy-update` (and other 3 arms?) of `group-push-hook.hoon`
