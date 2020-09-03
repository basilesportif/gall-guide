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

TODO: 
* `on-watch`
* `on-poke`

## Views
- coordinate multiple store and hook calls

## Security Considerations
- have to evaluate the code for a new hook (or really any agent) that is installed on your ship, since it can bypass the access controls of a store.

## Exercises
* Outline how you would split `chat-hook` into a `push`/`pull` architecture.
