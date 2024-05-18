# CLP(SMT)

The numerous repos for minikanren with SMT are dazzling. This repo tries to document them and get a minimal running version with annotated examples.

## Requirements

`z3` (I tested this with z3 4.11.0), need to add `z3` to PATH. 

I tested with Chez Scheme (9.9.9-pre-release.22)

## Running

### Usage

```scheme
(load "mk.scm")
(load "smt.scm")
(load "test-check.scm")

(test "basic-1"
  (run* (q)
    (z/assert `(> ,q 0))
    (z/assert `(< ,q 2)))
  '(1))
```

You can also load `talk.scm` to see more tests.

### TODO

- currently I used the `mk-vicare.scm` `mk.scm` `smt.scm` from the faster minikanren `smt` branch, but the `mk.scm` in clpsmt-minikanren might also just do the work (but slower), might wanna experiment with that

- Maybe a cvc5 driver?

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
