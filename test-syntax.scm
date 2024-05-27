(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")
(load "test-check.scm")
(load "hoare.scm")

(test "0 is a valid number"
      (run 1 (q) (into 0))
      '(_.0))

(test "1 is a valid number"
      (run 1 (q) (into 1))
      '(_.0))

(test "2 is a valid number"
      (run 1 (q) (into 2))
      '(_.0))

(test "5 is a valid number"
      (run 1 (q) (into 5))
      '(_.0))

(test "'(int (0 1 2)) is not a valid number"
      (run 1 (q) (into '(int (0 1 2))))
      '())

(test "'(int (0 1 a)) is not a valid number"
      (run 1 (q) (into '(int (0 1 a))))
      '())

(test "(int 100) is an arithmetic expression"
      (run 1 (q) (aexpo (int 100)))
      '(_.0))

(test "(+ 1 x) is an arithmetic expression"
      (run 1 (q) (aexpo `(+ ,1 x)))
      '(_.0))

(test "(* 1 (- x y)) is an arithmetic expression"
      (run 1 (q) (aexpo `(* ,1 (- x y))))
      '(_.0))

(test "(>= 1 (- x y)) is not an arithmetic expression"
      (run 1 (q) (aexpo `(>= ,1 (- x y))))
      '())

(test "(> 1 2) is a boolean expression"
      (run 1 (q) (bexpo `(> ,1 ,2)))
      '(_.0))

(test "(∧ 1 2) is not a boolean expression"
      (run 1 (q) (bexpo `(∧ ,1 ,2)))
      '())

(test "(¬ (∧ (> x y) (∨ (<= x z) (= x y)))) is a boolean expression"
      (run 1 (q) (bexpo '(¬ (∧ (> x y) (∨ (<= x z) (= x y))))))
      '(_.0))
