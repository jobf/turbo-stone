# lines

born from https://github.com/jobf/haxetta-stone

but we only care about peote-stack here 

DEMO HERE >>> http://maitag.de/~half/2023/turbo-stone/alpha/

## how to run

You need haxe and lime installed

Install haxelibs

```
haxelib install json2object
haxelib install format
haxelib install compiletime
haxelib git peote-view https://github.com/maitag/peote-view.git
```


From within the `test-app` directory...

Compile and run web

```
lime test html5
```

...hashlink

```
lime test hashlink
```

...or native (long initial compile)

```
lime test linux
```

```
lime test windows
```

Other targets? Later??