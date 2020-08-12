# Landscape: GUI for Gall
Up until now we've interacted with Gall purely on the command line. However, the work we did in [poke/watch](poke.md) should be giving you some ideas: if we can poke and subscribe from the CLI, wouldn't it be easy to have a frontend app also poke and subscribe?

The answer is...yes!  Landscape is a JS library that allows you to poke and subscribe from a browser that is authenticated to your ship. It has both mandatory and optional components:
* mandatory: a couple functions to do poke/watch
* optional: some JS and CSS defaults for configuring your application.

In this lesson you'll get the rationale for Landscape, and you'll also make your very first app skeleton and see how the workflow goes.

## Why JS? Or, "what's the Point of Urbit if We're Just Gonna JS Anyway?"
Using JS feels like it's cheating or dirtying up the beautiful Urbit experience. But it actually fills an important gap in the current system.

### Urbit Is a Server
At heart, Urbit is a personal *server*, and is agnostic about the types of clients that access it. Up until now, we've been using the Dojo as a client, and it *is* written in Hoon. However, what we really use it for in a Gall context is poking and subscribing.

If we want to display a graphical UI, there's absolutely no reason why we shouldn't leverage the various UX tools and libraries that have been created in Javascript.

### P2P/Rich Computation on Urbit Is the Big Win
Thought experiment: imagine you wanted to implement a P2P chat web app, or a P2P collaborative editing web app. Sure, you'd have to write the interface in JS, but a ton of the work would come when you had to write the serverside. You'd need:
* Authentication
* Database service
* Server software
And then maintain it all on a Unix machine in the cloud.

Urbit gives you all of that stuff for free on your server. Your client app gets access to everything inside the ship with easy pokes from the browser.

### Earth Calls Mars
As explained [here](https://moronlab.blogspot.com/2010/01/urbit-functional-programming-from.html), it's always fine for Earth (the "normal" computing world) to make calls to Mars (Urbit). Mars can never know about Earth. In practice, this means that we can feel totally free to use existing UI tools for React and similar, as long as they only talk to Urbit through a constrained interface (poke and subscribe).

## What Do You Need for a Landscape App?
Every Landscape app has two main components:
1. The Gall app running on a ship
2. A React app (or really any JS framework, but we'll use React) that calls it.

Our React app can push information to the ship with pokes, and listen for information from it with a subscription.

We'll try to give a clear understanding of the pieces of React you need in order to make Landscape apps. Of course, if you want to go further, you can, but you will be able to get all the way to making substantial applications with the information here.

## Workflow: Our First Landscape App
Let's create an
1. Create a clone of `create-landscape-app`
