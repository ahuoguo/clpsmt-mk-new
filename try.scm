;; files to load `talk.scm`

(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")
(load "test-check.scm")

(load "hoare.scm")

;;  (run 1 (q) (proveo `(= x ,(int 1))
;;                            `(seq (x := 1)
;;                                  (x := ,(int 3)))
;;                            `(= x ,(int 3))))

;; (run 1 (q) (z/assert `(and (=> false true) (=> true false))))

;; (test "(<= x 5) => (<= x 5)"
;;       (run 1 (q) (fresh (x) 
;;             ;; (z/ `(declare-const ,x Int))
;;             (implieso `(<= ,x 5) `(<= ,x 10))))
;;       '(_.0))

;; (run 1 (q) (fresh (x) (implieso `(<= ,x 11) `(<= ,x 10))))

;; (test "{q} => (> ,x 1)"
;;       (run 1 (q) 
;;       (fresh (x) 
;;             (z/ `(declare-const ,q Bool))
;;             (z/assert `(= ,q true))
;;             (z/assert `(= ,q (> ,x 2)))
;;             (implieso q `(> ,x 1))))
;;       '((> x 1)))

;; (test "[x = 1] (seq (x := (+ x 1)) (x := (+ x 1))) [x = 100]"
;;       (run 1 (q) (proveo `(= x 1)
;;                          `(seq (x := (+ x 1))
;;                                (x := (+ x 1)))
;;                          `(= x 100)))
;;       '())

;; (test "[x = 1] (seq (x := (+ {q} 1)) (x := (+ x 1))) [x = 3]"
;;       (run 1 (q) (proveo `(= x ,(int 1))
;;                          `(seq (x := (+ ,q ,(int 1)))
;;                                (x := (+ x ,(int 1))))
;;                          `(= x ,(int 3))))
;;       '((2)))
