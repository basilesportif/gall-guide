# Importing Code and Static Resources

For nearly all Gall apps, you'll want to use some outside libraries, your own types, and static resources (like HTML and image files). To do this, you need to use Arvo's Ford build system, which Gall automatically calls for you whenever it sees certain runes in your app files.

There are three Ford runes that you need to know:
1. `/-`: import type files from the `/sur` directory
2. `/+`: import code libraries from the `/lib` directory
3. `/=`: import static resources (non-Hoon files)

In this lesson, you'll learn how to use these runes, and we'll also see the basics of returning static resources over HTTP.

Note: these Ford (`/`) runes only work in Gall apps and generators. They will not work in the Dojo.

## Example Code
### Types File
Put the following code in the `/sur` directory in a file called `fordexample.hoon`:
```
|%
+$  name  [first=@t  last=@t]
--
```
Put the following code in the `/sur` directory in a file called `fordexample2.hoon`:
```
|%
++  age  @ud
--
```

Put the following code in the `/app` directory in a file called `fordexample.hoon`:
```
/-  *fordexample2, fe=fordexample
/+  default-agent
|%
+$  versioned-state
  $%  state-zero
  ==
::
+$  state-zero
  $:  [%0 name:fe =age]
  ==
::
+$  card  card:agent:gall
::
--
=|  state=versioned-state
^-  agent:gall
|_  =bowl:gall
+*  this      .
    def   ~(. (default-agent this %|) bowl)
::
++  on-init
  ^-  (quip card _this)
  =.  state  [%0 [first='Hoon' last='Cool Guy'] age=74]
  `this
++  on-save
  ^-  vase
  !>(state) 
++  on-load 
  |=  old-state=vase
  ^-  (quip card _this)
  ~&  >  'on-load'
  =/  prev  !<(versioned-state old-state)
  ?-  -.prev
    %0
    `this(state prev)
  ==
++  on-poke
  |=  [=mark =vase]
  ^-  (quip card _this)
  ?+    mark  (on-poke:def mark vase)
      %noun
    ?>  (team:title our.bowl src.bowl)
    ?+    q.vase  (on-poke:def mark vase)
        %print-state
      ~&  >>  state
      `this
    ==
  ==
::
++  on-watch  on-watch:def
++  on-leave  on-leave:def
++  on-peek   on-peek:def
++  on-agent  on-agent:def
++  on-arvo   on-arvo:def
++  on-fail   on-fail:def
--

```

## `/-` Import Types
Our code starts with:
```
/-   *fordexample2, fe=fordexample
```
The `/-` rune looks up files in the `sur` directory with a name and `.hoon` extension, and then binds them in the current subject to the name passed. In that sense, it's similar to defining faces in the dojo.

The syntax `*fordexample2*` tells Ford to find the file `fordexample2.hoon` in `sur` and put it into the current subject. Essentially this means that it's not "namespaced": we can access the `age` arm from its core directly, as we do in line 9.

The syntax `fe=fordexample` tells Ford to find the file `fordexample.hoon` in `sur` and assign its contents to the face `fe`. To access its `name` arm in line 9, we need to use the syntax `name:fe` (evaluate `name` with `fe` as the subject).


## `/+` Import Libraries

## `/*` Import File Contents & Static Resources

## Marks

### grab

### grow


## Notes/Scratchpad

* serve actual static file 
* explain =,

https://urbit.org/docs/tutorials/arvo/ford/

https://github.com/lukechampine/rote/blob/master/urbit/app/rote.hoon#L588
```

:: Lastly: '%rote-deck' is not an arbitrary symbol; it's a proper Clay mark.
  :: When there's a hyphen in the name, everything before the first hyphen is
  :: interpreted as a directory, so Arvo will look for this mark at
  :: /mar/rote/deck.hoon.
```

### mar
```
/-  *marktest
|_  =marktest
++  grow
  |%
  ++  noun  marktest
  --
::
++  grab
  |%
  ++  noun  ^marktest
  --
--
```

### sur
```
|%
+$  marktest  [name=@t age=@ud]
--
```

### app
```
%marktest
~&  >  !<(marktest vase)
`this
```
