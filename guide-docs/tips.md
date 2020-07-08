# Tips & Tricks

## Generators
* |command is just shorthand for :hood|command
* and :app|command is just shorthand for "poke app with output from /gen/app/command"
  - see `/gen/s3-store/*` for examples
* just as you could :app +command for /gen/command, etc

### Example
`/gen/s3-store/set-endpoint/hoon`
Uses a `%say` generator that takes one argument. You call it with:
```
> :s3-store|set-endpoint 'myendpoint.com'
```
The above expands to "poke `%s3-store` with the output from calling `+_s3-store/set-endpoint 'myendpoint.com'`".

## Hoon Idioms Used in Gall

`=^` for state updates in helper functions
One frequent pattern with pokes and watches is having a helper function modify the state, and also return some cards as actions. The `=^` is a very convenient rune that we'll use here and that you'll see in a lot of Gall code.

`=^` takes 3 children:
1. a new face (call it `p`)
2. a wing in the subject (call it `q`)
3. some Hoon to run that returns a cell
4. more Hoon

it assigns the head of (3)'s result to `p` and the tail to `q`. Then it runs the Hoon in (4), with `p` and the modified `q` in the subject. 

?+ for handling w default

?- for handling when you know all options (like w state)

~&  for printing
* talk about how it uses `>`, `>>` and `>>>` to change colors.

## irregular forms
* `/` for path
* `+` for mark (e.g. s+'timluc' for `[%s 'timluc']`)
