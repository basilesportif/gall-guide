## Serve Static Resources from HTTP
In our `on-init`, we called out to Eyre. Let's see how we can use this call to serve HTTP resources. For more detail on the types used, see the [types appendix](gall_types.md) in the "Eyre" section.
```
[%pass /bind %arvo %e %connect [~ /'~myapp'] %myapp]
```

So now, whenever an HTTP request comes in at `http://localhost:$PORT/~myapp` (where `$PORT` is the port your fakezod is running on), it will produce 
