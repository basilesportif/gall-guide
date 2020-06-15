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
Put the following code in the `/sur` directory in a file called `import.hoon`:
```
|%
+$  name  [first=@t  last=@t]
--
```

Put the following code in the `/app` directory in a file called `import.hoon`:
```

```

## `/-` Import Types
Our code starts with:
```
/-  import
```
The `/-` rune looks up files in the `sur` directory with a name and `.hoon` extension, and then binds them in the current subject to the name passed. In that sense, it's similar to defining faces in the dojo.  Here 

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
