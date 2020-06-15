# Landscape: GUI for Gall

## Resources Your Urbit Ship Injects
* `window.ship`
* `window.urb`
  - state of frontend's communications with the ship
  - `action` method (funneled to `on-poke`)
  - `subscribe` method (funneled to `on-watch`)

## Resources Your Landscape App Injects
These resources *only* exist while you're on your app's page. They are served from its JS files/

You can define any of these you want and inject them at the time your app loads.
* `window.api`: all api actions you want to define for your app to let it hit the server
* `window.store`
