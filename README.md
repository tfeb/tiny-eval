# Two tiny evaluators
Here are two tiny evaluators for a very small Lisp subset: one has dynamic binding and the other lexical.  They exist only to support [an article I wrote about them](https://www.tfeb.org/fragments/2023/02/27/two-tiny-lisp-evaluators/): they are not intended for any other purpose than that.

## Loading the code
There is an ASDF system definition which should load everything.  Alternatively if you have [`require-module`](https://tfeb.github.io/tfeb-lisp-tools/#requiring-modules-with-searching-require-module) then most of the files will simply load their prerequisites for you.

## Examples
There may be some examples in `examples/`.