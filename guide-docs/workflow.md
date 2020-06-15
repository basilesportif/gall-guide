# Workflow Setup and Basic App Installation
To make Gall apps, it's important to work with your environment, not fight it. Below I outline your main workflow options.

I'll assume throughout this that we are using the `%home` desk in a fake `~zod`. If you want to brush up on using `mount` and `commit` to manage Urbit piers, go [here](https://hooniversity.org/beginning-hoon-introduction-2/what-you-need-to-know-and-do-before-beginning/#).

## Example Code
Below is a completely valid but *very* simple Gall program. You don't need to understand it yet: this lesson is purely about our development workflow.
```
/+  default-agent
^-  agent:gall
=|  state=@
|_  =bowl:gall
+*  this      .
    default   ~(. (default-agent this %|) bowl)
::
++  on-init   
  ~&  >  'on-init'
  on-init:default
++  on-save   on-save:default
++  on-load   
  ~&  >  'on-load'
  on-load:default
++  on-poke
  |=  [=mark =vase]
  ~&  >  state=state
  ~&  got-poked-with-data=mark
  =.  state  +(state)
  `this
::
++  on-watch  on-watch:default
++  on-leave  on-leave:default
++  on-peek   on-peek:default
++  on-agent  on-agent:default
++  on-arvo   on-arvo:default
++  on-fail   on-fail:default
--
```

## Install Your First Gall App
To install a new program in Gall, you simply tell Gall its name with the `|start` command, and Gall will look for a Hoon file with that name in the `/app` directory. 

### Install
To see this, create a Hoon file called `my-gall-program.hoon` in the `/app` directory of your pier (e.g. `home/app/my-gall-program.hoon`) and paste the code above into it. Run the commands:
```
|commit %home
|start %my-gall-program
```
You will see the output:
```
>   'on-init'
> 
>=
activated app home/my-gall-program
[unlinked from [p=~zod q=%my-gall-program]]
```

### Edit
Now let's edit this app. Change the line `~&  >  'on-load'` to 
```
~&  >  'I just loaded'
```
Run `|commit %home`, and you should see:
```
> |commit %home
>=
: /~zod/home/12/app/my-gall-program/hoon
>   'I just loaded'
```

So we see here that once Gall has `start`ed an app, it auto-reloads it whenever a new version of that program is committed. We'll go more into this in the [lifecycle lesson](lifecycle.md)

## Three Workflow Options
The install and editing process shown above will always be the same. However, if we simply develop apps in our pier, we have to take care not to lose them if we start up a new `~zod` for development. 

There are 3 primary workflows we can use to handle this issue.

1. YOLO: edit files directly in your mounted pier
2. Create a separate folder, edit files there, and copy them to your pier
3. Use the `create-landscape-app` scripts to watch your project and sync files to your pier

### Edit Files Directly in Your Pier
This will be familiar to anyone who has written simple Hoon generators. You write the code, commit it, and then run it. Unfortunately, this makes it tricky to put our code in version control and to save it even when we make a new `~zod`. I recommend only using this option for quick throwaway tests and sanity checks.

### Create a Separate Folder/Project
If you are writing a Gall app without a frontend (for example, a web server), you can create a separate folder somewhere in your filesystem, edit files and track changes there, and then copy them to your pier.

This can be done at the command line like so:
```
cp your_code_directory/*.hoon your_pier_directory/app/
```

### Use `create-landscape-app` to Sync Files to Your Pier
Once we begin creating Landscape apps, we will able to use `create-landscape-app` to monitor our JS and Hoon files, and copy them to our ship as they're updated.

## Which Editor to Use?
Any text editor/IDE is fine for Hoon. VSCode has support for Hoon syntax highlighting, if you want that. I generally keep a console with my Dojo open vertically next to my code, so that my editor takes up half the screen, and the console half the screen. This works well with Hoon's vertically-oriented syntax.

## Our Approach
In the introductory documents here, we will use approach (1) (editing files directly in your pier). Once we get to the section on landscape apps, we will use those scripts. If you wish to create a separate directory for your files throughout this and use approach (2), that is totally fine and up to you. Just remember to copy them to your pier and commit each time you save.

## Workflow Summary for Gall
* Have a fake `~zod` running
* Mount it to your Linux/Mac
* get your file with Gall code into `app`, commit, and run `|start %YOURAPPNAME`
* every time you edit, make sure your new file ends up in `app` and that you commit.

[Home](overview.md) | [Next: The 10 Arms of Gaal: App Structure](arms.md)
