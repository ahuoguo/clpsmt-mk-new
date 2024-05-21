# CLP(SMT)

The numerous repos for minikanren with SMT are dazzling. This repo tries to document them and get a minimal running version with annotated examples.

## Requirements

`z3` (I tested this with z3 4.11.0 & 4.13.0), need to add `z3` to PATH. 

I tested with Chez Scheme.

## Running

### Usage

Open Chez Scheme REPL do the following:

```scheme
(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")  ;; or (load "cvc5-driver.scm")
(load "test-check.scm")

(test "basic-1"
  (run* (q)
    (z/assert `(> ,q 0))
    (z/assert `(< ,q 2)))
  '(1))
```

You can also load `talk.scm` to see more tests.

### TODO

- currently I used the `mk-vicare.scm` `mk.scm` `smt.scm` from the faster minikanren `smt` branch, but `mk.scm` in clpsmt-minikanren and others might also just do the work (but slower), might wanna experiment with those (probably also have something uniform to compare run time stats).

- have a racket wrapper? I seems to have better support for timeouts. I commented out some tests in `talk.scm` since cvc5 will timeout on those examples. (commented with "cvc5 too slow")

- include/document more tests. The Rosette repo has some good ones. Barliman also have some use cases for synthesis (see the branches with `smt`)

- For future directions, Nada made [a nice list of future directions](https://github.com/namin/clpsmt-miniKanren/issues/9#issuecomment-893659453)

## Repos

This issue https://github.com/namin/clpsmt-miniKanren/issues/9

### CLP(SMT) miniKanren
- https://github.com/namin/clpsmt-miniKanren

### faster minikanren:

- `smt` branch from Nada https://github.com/namin/faster-miniKanren/tree/smt
- `smt-assumptions` branches mentioned by Siyuan https://github.com/namin/faster-miniKanren/tree/smt-assumptions
- `smt-assumptions` updated by Siyuan https://github.com/namin/faster-miniKanren/tree/smt-assumptions-full-integration

### Rosette experiment 
- https://github.com/chansey97/clprosette-miniKanren

## Talks

- ClojuTRE 2018 https://youtu.be/KsC_9_-NuQg?si=99QwgyuFXxYspUs2
- Minikanren Workshop 2021 Keynote https://youtu.be/owBoKpJ56Fk?si=E5GoevinXsNPWkA3
