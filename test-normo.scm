(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")
(load "test-check.scm")
(load "hoare.scm")

(test "x = x ≡ true"
      (run 1 (q) (rewriteo '(= x x) 'true))
      '(_.0))

(test "x ≥ x ≡ true"
      (run 1 (q) (rewriteo '(>= x x) 'true))
      '(_.0))

(test "(∧ true true) ≡ true"
      (run 1 (q) (rewriteo '(∧ true true) 'true))
      '(_.0))

(test "(∧ false true) ≡ true"
      (run 1 (q) (rewriteo '(∧ false true) 'false))
      '(_.0))

(test "(∧ false true) ≡ {q} "
      (run 1 (q) (rewriteo '(∧ false true) q))
      '(false))

(test "(∧ (∧ true true) true) ≡ (∧ true (∧ true true))"
      (run 1 (q) (rewriteo '(∧ (∧ true true) true) '(∧ true (∧ true true))))
      '(_.0))

(test "(> (+ 2 1) 2) ≡ (> 2 1)"
      (run 1 (q) (rewriteo `(> (+ 2 1) 2)
                           `(> 2 1)))
      '(_.0))

;; Alex: the SMT approach sometimes behave like the closure of rewrito
;; more speicifically z/assert (> (+ 2 1) 2) succeeds, resulting in q being
;; unified to true
(test "(> (+ 2 1) 2) ≡ {q}"
      (run 1 (q) (rewriteo `(> (+ 2 1) 2) q))
      '((> 2 1)))

(test "(> 2 1) ≡ {q}"
      (run 1 (q) (rewriteo `(> 2 1) q))
      '(true))

(test "(∧ (>= 1 2) (¬ (> 1 2))) ≡ (= 1 2)"
      (run 1 (q) (rewriteo `(∧ (>= 1 2) (¬ (> 1 2)))
                           `(= 1 2)))
      '(_.0))

(test "(= 1 2) ≡ false"
      (run 1 (q) (rewriteo `(= 1 2) 'false))
      '(_.0))

;; compute 100 valid terms
;; (run 100 (q) (rewriteo q 'true))

(test "(∧ (∧ true true) true) ⇓ true"
      (run 1 (q) (⇓o '(∧ (∧ true true) true) 'true))
      '(_.0))

(test "(> (+ 2 1) 2) ⇓ true"
      (run 1 (q) (⇓o `(> (+ 2 1) 2) 'true))
      '(_.0))

(test "(∧ (>= 1 2) (¬ (> 1 2))) ⇓ false"
      (run 1 (q) (⇓o `(∧ (>= 1 2) (¬ (> 1 2)))
                     'false))
      '(_.0))

(test "(∧ (>= 1 2) (¬ (> 1 2))) ⇓ {q}"
      (run 3 (q) (⇓o `(∧ (>= 1 2) (¬ (> 1 2))) q))
      '(((∧ (>= 1 2) (¬ (> 1 2)))) ;; reflexivity
        ((= 1 2))                  ;; one step
        (false)))                  ;; two steps, we may even ask answers more than 3.

