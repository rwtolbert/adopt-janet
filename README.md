# Janet port of Adopt (https://github.com/sjl/adopt)

In an attempt to learn Janet and make something useful,
this is a port of the Adopt command line argument parser
from CL to Janet.

## Getting started with Janet, jpm, etc.

### janet

```
$ cd ~/dev/github
$ git clone https://github.com/janet-lang/janet.git
$ cd janet
$ git checkout v1.32.1
$ PREFIX=$HOME/dev/janet make
$ PREFIX=$HOME/dev/janet make install
```

### jpm

```
$ cd ~/dev/github
$ git clone https://github.com/janet-lang/jpm.git
$ cd jpm
$ JANET_PREFIX=$HOME/dev/janet janet bootstrap.janet
```

### adopt

```
$ cd ~/dev/github
$ git clone git@github.com:rwtolbert/adopt-janet.git
$ cd adopt-janet
$ jpm deps
$ make test
```
