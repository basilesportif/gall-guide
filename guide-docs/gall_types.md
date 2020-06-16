# Gall Types
Gall apps are composed of smaller types, and this is a directory of the main pre-defined types you'll encounter in building/reading a Gall app.

Building Gall apps is a matter of building the Gall arms you need. And building Gall arms is about repeatedly answering two "dynamic" questions and one static question:
1. What kind of data is coming in here?
2. What kind of data needs to go back out?
3. (static) What info does every Gall app always have access to?

If you can answer those questions, you'll feel like you always have solid ground under your feet, and can build whatever you need to in Gall.

## How to Use This Document
Whenever you hit a type you don't understand in Gall source, search for it here.

## Note on Finding Source Code
This guide is intended to clearly show what types do, but the source code for them is also quite clear, and I want to empower users to go to that source code. All types indicate the file they come from, and unless stated otherwise, you can find these structures in the files by searching for them as arms:
```
::  any of the below searches will work (without quotes)
"++  quip"
"++  wind"
"++  note-arvo"
```

## Standard Library Types
These are types found in `hoon.hoon`, `arvo.hoon`, and `zuse.hoon`

### Standard Library Organization
* `hoon.hoon`: general Hoon language types and functions
* `arvo.hoon`: 
* `zuse.hoon`: the "public" interface (models and code) for each vane. These can be called by other vanes and user code, and aren't used for internal vane implementation.

### Types Used by Gall

* `quip` (`sys/hoon.hoon`)
  - head is an item (often `cards`), tail is usually a core with data
  - `(quip item state)`
  - `[(list item) state]`

* `vase`
- A `[type noun]`. This "marks" the data as a type so that we can extract it into that type from the `vase`.
- Use this when you don't know at creation time what type of data will be coming into a function. Having vase as the type of a Gall arm forces messages sent to that arm to mark their type.
```
::  Example--q is ~timluc-miptev in atom form
~zod:dojo> !>(~timluc-miptev)
[#t/@p q=3.690.144]
```

* `cage`/`cask` (`sys/arvo.hoon`)
  - `cask` is the general version of `[@tas any-data]`
  -  `cage` is a specific version: `[@tas vase]`

* `wind` (`sys/arvo.hoon`)
  - tagged union
  - `a` is the type for `%pass`, `b` the type for `%give`
  - `(wind a b)`
```
::  wind is a tagged union of:
[%pass p=path q=a]
[%slip p=a]
[%give p=b]
```

* `note-arvo` (`sys/zuse.hoon`)
  - tagged union of the notes that each Arvo vane can create
  - format: `[<vane-letter> task:able:<vane-name>]
  - example: `[%g task:able:gall]`
  
### Eyre
```
::  app is the Gall app to bind to
[%connect =binding app=term]
[%disconnect =binding]
```
```
+$  binding
    $:  ::  site: the site to match.
        ::    A ~ will match the Urbit's identity site (your.urbit.org). Any
        ::    other value will match a domain literal.
        site=(unit @t)
        ::  path: matches this prefix path
        ::    /~myapp will match /~myapp or /~myapp/longer/path
        path=(list @t)
    ==
```

### Wires and Paths
These types often use a shortcut syntax that we can check in the dojo.
EXAMPLE

## Gall Types
These include anything like `...:agent:gall`. They are defined in `sys/zuze.hoon`.
Search for `++  gall` in `zuze.hoon` to find the start of that core definition
* `bowl`

### Gall `agent`
`agent` is an iron core that contains the 10 arms used for the app, which in turn rely on 

* `note`
  - tagged union, can be either a `note-arvo` note (for "calling" arvo vanes)
```
+$  note
      $%  [%arvo =note-arvo]
          [%agent [=ship name=term] =task]
      ==
```
 * `card`
   - used heavily in Gall apps--the return type of most apps is `[(list card) agent]` (or `(quip card agent)`
   - `(wind note gift)`
   - think of a `wind` as an instruction to an Arvo vane or to another Gall agent

* `default-agent`
  - `types` 
