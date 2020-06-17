# Importing Code and Static Resources
**TODO: check all line numbers***

For nearly all Gall apps, you'll want to use some outside libraries, your own types, and static resources (like HTML and image files). To do this, you need to use Arvo's Ford build system, which Gall automatically calls for you whenever it sees certain runes in your app files.

There are three classes of Ford runes that you'll see at the top of almost all Gall apps:
1. `/-`: import type files from the `/sur` directory
2. `/+`: import code libraries from the `/lib` directory
3. `/= /^ /; /: /_`: convert files to Hoon data types so they can be used in your program

In addition to those runes, Ford has the concept of a `mark`, which is like a filetype that you can control and extend yourself to both work with existing data and create your own filetypes.

In this lesson, you'll learn how to include types and libraries, work with and create marks, and import files for use in your program.

Note: these Ford (`/`) runes only work in Hoon files evaluated in Gall apps and generators. They will not work in the Dojo.

## Example Code
Start by creating a directory, `/app/fordexample`

### HTML Files
Create two files, `/app/fordexample/example.html` and `/app/fordexample/example2.html`. Put the following code in each of them:
```
<html><head><title>Ford HTML Example</title></head></html>
```

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

### Gall File
Put the following code in the `/app` directory in a file called `fordexample.hoon`:
```

```

Now go ahead and run `|commit %home`. You should see a message that `app initialized successfully`.

## `/-` Import Types
Our code starts with:
```
/-   *fordexample2, fordex=fordexample
```
The `/-` rune looks up files in the `sur` directory with a name and `.hoon` extension, and then binds them in the current subject to the name passed. In that sense, it's similar to defining faces in the dojo.

The syntax `fordex=fordexample` tells Ford to find the file `fordexample.hoon` in `sur` and assign its contents to the face `fordex`. To access its `name` arm in line 9, we need to use the syntax `name:fordex` (evaluate `name` with `fordex` as the subject).

The syntax `*fordexample2*` tells Ford to find the file `fordexample2.hoon` in `sur` and put it into the current subject. Essentially this means that it's not "namespaced": we can access the `age` arm from its core directly, as we do in line 9.

`sur` is used for data structures that are shared between apps.


## `/+` Import Libraries
This works in exactly the same way as `/+`, with the difference that it looks in the `lib` directory. This lets us import existing and user-created libraries.

`*server` is a really common import, because it handles all HTTP response functionality for returning results to requests. It's generally imported with `*` to expose everything, since it's so widely used. It's also sometimes given the face `srv`.

We've seen `default-agent` a lot already. It just gets used once, on line 19.

## Marks
Marks have some similarities to file types, except that they are more explicit and can be directly programmed. They exist only for Ford and processes that use Ford (like Gall), and are defined in the `mar` directory. We use some `/` runes yet that you won't be familiar with--they're explained in "Import and Process Files" below.

Marks have two primary use cases:
1. Importing files with Ford
2. Sending data to Gall apps

We'll work with files in this lesson, and then once we get to [poke](poke.md) and Landscape, we'll see how marks help us for the data-sending use case.

### Example 1: Two Ways to Open an HTML File
Lines 3-9 of `fordexample.hoon`:
```
/=  html-as-html
  /^  cord
  /:  /===/app/fordexample/example  /html/
/=  html-as-mime
  /:  /===/app/fordexample/example  /mime/
/=  html-as-mime-as-html
  /:  /===/app/fordexample/example  /html/  /mime/
```
We'll learn exactly how this syntax works later in this lesson. For now, focus on the `/html/` and `/mime/` parts. These are marks, and they are both run on the file `example.html` (Ford essentially ignores the Unix `.html` file ending, although it remains as a suggestion for the mark to use in opening). 

So the first 3 lines here say:
1. Get the file `/app/fordexample/example` and convert it to a Hoon noun
2. Find the `html` mark in `/mar/html.hoon`
3. See if it has a way to convert from `noun`

#### How the Mark Works
To convert from one mark to another, Ford looks for the appropriate arm in the `grab` core of the mark.

Open the file `/mar/html.hoon`, and you'll see that it has the code:
```
++  grab  |%::  convert from
          ++  noun  @t                                  ::clam from %noun
          ++  mime  |=({p/mite q/octs} q.q)             ::retrieve form $mime
          --
```
We said above that example was opened as a `noun`, and that we gave an instruction to render it with the `html` mark. So Ford finds the `noun` arm in `grab`, and runs it on the file data. In this case, it's the mold `@t`--so we an `html` mark is just the filedata as one big cord. (Notice that in line 4 we cast the result to a cord. This isn't necessary; I just wanted to show that the result of running the mark is normal Hoon data.)

### `grab` and `grow`

### Making a Custom Mark
TODO: do a custom mark for the `name` type



## `/= /^ /; /: /_` Import and Process Files
These runes are used in combination.

### `/:` Set the Current Path


* `/:` - it accesses a Ford resource and applies a mark to it (marks are explained below in the "Marks" section)
* `/_` - similar to a wildcard in Unix. Returns a map of knots (filenames) to filedata
* `/=` - assigns a face to a horn
* `/^` - casts a horn
* `/;` - run a gate on a horn


### Examples
Let's look now at the code starting in line 3 of `fordexample.hoon`:
```
/=  html-as-html
  /^  cord
  /:  /===/app/fordexample/example  /html/
/=  html-as-mime
  /:  /===/app/fordexample/example  /mime/
/=  html-as-octs
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/fordexample/example  /html/
/=  multiple-files
  /^  (map knot tape)
  /:  /===/app/fordexample  /_  /html/
```

In all cases, we do something, and then apply a face to it with `/=`.

Notice that the second child of each
### TODO: example of converting to bytes right away

### TODO: show example of importing wildcard -- we still apply a mark

### What Type Will My File Be?
* use `multiple-files` example


## Summary



## Notes/Scratchpad
* show how `-` works in filenames

* explain =,

The full documentation for Ford runes is [here](https://urbit.org/docs/tutorials/arvo/ford/), and it's pretty good, with examples. 

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
