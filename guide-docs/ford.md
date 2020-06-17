# Ford: Imports, Files and Marks

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

### Mark File
Put the following in `/mar/fordexample/name.hoon`
```
/-  *fordexample
|_  own=name
++  grab
  |%
  ++  noun
    |=  n=@t
    ^-  name
    [first='NOUN' last=n]
  ++  html
    |=  h=@t
    ^-  name
    [first='HTML' last=h]
  --
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

The syntax `fordex=fordexample` tells Ford to find the file `fordexample.hoon` in `sur` and assign its contents to the face `fordex`. To access its `name` arm in line 30, we need to use the syntax `name:fordex` (evaluate `name` with `fordex` as the subject).

The syntax `*fordexample2*` tells Ford to find the file `fordexample2.hoon` in `sur` and put it into the current subject. Essentially this means that it's not "namespaced": we can access the `age` arm from its core directly, as we do in line 30.

`sur` is used for data structures that are shared between apps.


## `/+` Import Libraries
This works in exactly the same way as `/+`, with the difference that it looks in the `lib` directory. This lets us import existing and user-created libraries.

`*server` is a really common import, because it handles all HTTP response functionality for returning results to requests. It's generally imported with `*` to expose everything, since it's so widely used. It's also sometimes given the face `srv`.

We've seen `default-agent` a lot already. It just gets used once, on line 40.

## Marks
Marks have some similarities to file types, except that they are more explicit and can be directly programmed. They exist only for Ford and processes that use Ford (like Gall), and are defined in the `mar` directory. We use some `/` runes yet that you won't be familiar with--they're explained in "Import and Process Files" below.

Marks have two primary use cases:
1. Importing files with Ford
2. Sending data to Gall apps

We'll work with files in this lesson, and then once we get to [poke](poke.md) and Landscape, we'll see how marks help us for the data-sending use case.

### Example 1: Two Ways to Open an HTML File
Lines 4-10 of `fordexample.hoon`:
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
2. Find the `html` mark in `/mar/html.hoon`. If the mark name has a `-` in it, such as `mymark-name`it looks for a file called `/mar/mymark/name.hoon`.
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
We said above that example was opened as a `noun`, and that we gave an instruction to render it with the `html` mark. So Ford finds the `noun` arm in `grab`, and runs it on the file data. In this case, it's the mold `@t`--so we an `html` mark is just the filedata as one big cord. (Notice that in line 5 we cast the result to a cord. This isn't necessary; I just wanted to show that the result of running the mark is normal Hoon data.)

The same process holds in the code
```
/=  html-as-mime
  /:  /===/app/fordexample/example  /mime/
```
We want to use a `mime` mark, so we check `/mar/mime.hoon`. It does indeed have a `grab` arm for `noun`, which uses the `mime` mold.

#### Converting between Marks
Converting from one mark to another is easy. Ford simply checks whether there is a `grab` arm from the current mark to the new one, and runs it if there is.
```
/=  html-as-mime-as-html
  /:  /===/app/fordexample/example  /html/  /mime/
```
Here we start by rendering a `noun` with `mime`, and then we try to render the `mime` with `html`. If you look in `hhtml`, we see a grab arm for `mime`, which simply drops the `mite` and keeps the `octs` (bytes).

#### Checking the Results of Our Marks
In the Dojo, run `:fordexample %mark-example`. You should see printed:
```
>>  '<html><head><title>Ford HTML Example</title></head></html>\0a'
>>  [[%text %html ~] 59 '<html><head><title>Ford HTML Example</title></head></html>\0a']
>>  '<html><head><title>Ford HTML Example</title></head></html>\0a'
```
The first is the result of our `html` mark, the second is our `mime` mark, and the last is running an `html` mark on our `mime` result (equivalent to the first `html` mark).

### Making a Custom Mark
We have a custom mark in `/mar/fordexample/name.hoon`, and it gets used in lines 12-15:
```
/=  noun-as-name
  /:  /===/app/fordexample/example  /fordexample-name/
/=  html-as-name
  /:  /===/app/fordexample/example  /fordexample-name/  /html/
```
Again, the `-` in the mark means "directory", i.e. `/mar/fordexample/name.hoon`. If we look at that file, we see it has a `grab` from `noun`, and one from `html`. We use those in the first and second examples, respectively.

To test this, run `:fordexample %custom-mark-example` in the Dojo, and you'll see:
```
>>  [first='HTML' last='<html><head><title>Ford HTML Example</title></head></html>\0a']
>>  [first='HTML' last='<html><head><title>Ford HTML Example</title></head></html>\0a']
```
Which confirms that our toy `grab` gates were used to do the proper mark renderings.


## `/= /^ /; /: /_` Import and Process Files
Now we can use our knowledge of marks to process files in any way we want.

### `/:` Set the Current Path
We used this rune in our mark examples in lines 4-15, and now we can explain it. It lets us set a path or file to operate on, and then creates a "horn" from it. A "horn" is just some Hoon created by Ford, usually by rendering marks.

`/:` takes two children:
1. A path/file
2. Either
  * one or more marks
  * `/_` followed by one or more marks

If we look at lines 8 and 10, we'll see how the second child of `/:` can either be one mark, or a series of marks that are rendered in succession.

In lines 21-23, we have `/_`:
```
/=  multiple-files
  /^  (map knot @t)
  /:  /===/app/fordexample  /_  /html/
```
`/_` takes every file in the current directory (here `/app/fordexample`) and applies the given mark to it. It returns a map with keys that are base file names and values that are the file contents with the mark applied.

In the Dojo, run `:fordexample %multiple-files-example`:
```
>>  {~.example2 ~.example}
```
We see both our HTML files' names printed (remember, Urbit ignores the `.html` ending).

### `/=` Assign a Face
This simply assigns a face to the result of a Ford expression, which is Hoon data. We see it used in all our initial lines.

The 2 main ways that you'll form horns are simply by selecting a path and applying a file

### `/^` and `/;` Format the Result
`/^` casts the Ford result, and `/;` runs a gate on it. Line 17 contains a very idiomatic example of this:
```
/=  html-as-octs
  /^  octs
  /;  as-octs:mimes:html
  /:  /===/app/fordexample/example  /html/
```
We first render `example.html` with an `html` mark, then run the `as-octs` gate on it, which converts it to bytes. Finally, we cast it to `octs` (bytes) for later usage. This pattern is very, very often used in Gall apps to include static resources, and we'll see in later lessons how we can return those `octs` resources in HTTP responses.

## Summary
The above should give you everything you need to know to both use Ford, and understand code you encounter in the wild. If you want more examples, the full documentation for Ford runes is [here](https://urbit.org/docs/tutorials/arvo/ford/).

[Prev: App Lifecycle and State](lifecycle.md) | [Home](overview.md) | [Next: Poke and Watch](poke.md)
