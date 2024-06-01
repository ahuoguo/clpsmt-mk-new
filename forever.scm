(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")
(load "test-check.scm")

(load "hoare.scm")


(run 1 (q) (fresh (y) (proveo  `(= ,y 1)
                    `(,y := (+ ,y 1))
                    q)))
