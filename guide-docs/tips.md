# Tips & Tricks

## Generators

### Poking with Generator Output
`/gen/s3-store/set-endpoint/hoon`
Uses a `%say` generator that takes one argument. You call it with:
```
> :s3-store|set-endpoint 'myendpoint.com'
```
The above expands to "poke `%s3-store` with the output from calling `+_s3-store/set-endpoint 'myendpoint.com'`".

### hood
* |command is just shorthand for :hood|command
