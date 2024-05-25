;; (load "mk/test-check.scm")

(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")
(load "test-check.scm")
(load "hoare.scm")

(test "true => true"
      (run 1 (q) (implieso* 'true 'true))
      '(_.0))

(test "true => false"
      (run 1 (q) (implieso* 'true 'false))
      '())

(test "false => true"
      (run 1 (q) (implieso* 'false 'true))
      '(_.0))

(test "false => false"
      (run 1 (q) (implieso* 'false 'false))
      '(_.0))

(test "(<= x 5) => (<= x 5)"
      (run 1 (q) (implieso* `(<= x ,(int 5)) `(<= x ,(int 10))))
      '(_.0))

(test "(<= x 5) => (<= x 10)"
      (run 1 (q) (implieso* `(<= x ,(int 5)) `(<= x ,(int 10))))
      '(_.0))

(test "(<= x 11) =/=> (<= x 10)"
      (run 1 (q) (implieso* `(<= x ,(int 11)) `(<= x ,(int 10))))
      '())

(test "(> x 1) => (> x 0)"
      (run 1 (q) (implieso* `(> x ,(int 1)) `(> x ,(int 0))))
      '(_.0))

(test "(> x 0) =/=> (> x 1)"
      (run 1 (q) (implieso* `(> x ,(int 0)) `(> x ,(int 1))))
      '())

(test "{q} => (> x 1)"
      (run 1 (q) (implieso* q `(> x ,(int 1))))
      '((> x 1)))

(test "{q} => (> x 1), {q} =/= (> x 1)"
      (run 1 (q)
           (implieso* q `(> x ,(int 1)))
           (=/= q `(> x ,(int 1))))
      '(false))

(test "{q} => (> x 1), {q} =/= (> x 1), {q} =/= false"
      (run 1 (q)
           (implieso* q `(> x ,(int 1)))
           (=/= q `(> x ,(int 1)))
           (=/= q 'false))
      '((> x 2)))

(test "(> x 1) => {q}, {q} =/= (> x 1), {q} =/= true"
      (run 1 (q)
           (implieso* `(> x ,(int 1)) q)
           (=/= q `(> x ,(int 1)))
           (=/= q 'true))
      '((> x 0)))

(test "(> x 2) => {q}, {q} =/= (> x 2), {q} =/= true"
      (run 1 (q)
           (implieso* `(> x ,(int 2)) q)
           (=/= q `(> x ,(int 2)))
           (=/= q 'true))
      '((> x 1)))

(test "(> x 2) => {q}, {q} =/= (> x 2), {q} =/= true, {q} =/= (> x 0)"
      (run 1 (q)
           (implieso* `(> x ,(int 2)) q)
           (=/= q `(> x ,(int 2)))
           (=/= q `(> x ,(int 0)))
           (=/= q 'true))
      '((> x 1)))

;; I embeded to i32, so it's not natural numbers...
;; (test "(> x 2) => {q}, {q} =/= (> x 2), {q} =/= true, {q} =/= (> x 1), {q} =/= (> x 0)"
;;       (run 1 (q)
;;            (implieso* `(> x ,(int 2)) q)
;;            (=/= q `(> x ,(int 2)))
;;            (=/= q `(> x ,(int 1)))
;;            (=/= q `(> x ,(int 0)))
;;            (=/= q 'true))
;;       '())

(test "(> x 2) => {q}, {q} =/= (> x 2), {q} =/= true, {q} =/= (> x 1), {q} => (< x 0)"
      (run 1 (q)
           (implieso* `(> x ,(int 2)) q)
           (=/= q `(> x ,(int 2)))
           (=/= q `(> x ,(int 1)))
           (implieso* q `(< x ,(int 0)))
           (=/= q 'true))
      '())
