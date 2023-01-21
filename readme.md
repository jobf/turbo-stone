lines

born from https://github.com/jobf/haxetta-stone

but we only care about peote-stack here 

## how to run

You need haxe and lime installed

Clone the repo with sub modules

```
git clone --recurse-submodules https://github.com/jobf/turbo-stone.git
```

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


...or native (long initial compile)

```
lime test linux
```

```
lime test windows
```

Other targets? Later.