# Connecting Gall to a Frontend
Now that we have a backend working, it's time to hook it up to a frontend. Urbit is *very* flexible in this regard: while many apps are built with React, that is *not* a requirement. To demonstrate that, we're going to build a quick frontend for our `%picky` app using the [Svelte library](https://svelte.dev).

We also will layer a "view" Gall agent on top of our backend agent. Our backend agent is responsible for querying the various data stores; the view agent receives commands from the frontend to proxy to the backend, and also serves backend responses to appropriate destinations.

## Frontend Workflow
The code for our JS frontend lives in [picky/frontend]().
  * watches the js files and compiles them, then copies to your ship

