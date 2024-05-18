;; I'm not sure if this is the killer app
;; since z3 with `define-fun-rec` is very fast

(load "../mk.scm")
(load "../smt.scm")
(load "../z3-driver.scm")
(load "../test-check.scm")

(define faco
  (lambda (n out)
    (conde ((z/assert `(= ,n 0))
            (z/assert `(= ,out 1)))
           ((z/assert `(> ,n 0))
            (fresh (n-1 r)
              (z/assert `(= (- ,n 1) ,n-1))
              (z/assert `(= (* ,n ,r) ,out))
              (faco n-1 r))))))

;; equivalent
(define facto
  (lambda (n out)
    (conde ((== n 0)
            (== out 1))
           ((z/assert `(> ,n 0))
            (fresh (n-1 r)
              (z/assert `(= (- ,n 1) ,n-1))
              (z/assert `(= (* ,n ,r) ,out))
              (facto n-1 r))))))

;; Alex: how different is the behavior of the search procedure of the two definitions above?
;; maybe check log file?

(time-test "faco-7"
  (run 7 (q)
    (fresh (n out)
      (faco n out)
      (== q `(,n ,out))))
  '((0 1) (1 1) (2 2) (3 6) (4 24) (5 120) (6 720)))

(time-test "faco-backwards-2"
  (run* (q)
    (faco q 2))
  '(2))

(time-test "faco-backwards-720"
  (run* (q)
    (faco q 720))
  '(6))

;; equivalent
(time-test "facto-7"
  (run 7 (q)
    (fresh (n out)
      (facto n out)
      (== q `(,n ,out))))
  '((0 1) (1 1) (2 2) (3 6) (4 24) (5 120) (6 720)))

(time-test "facto-backwards-2"
  (run* (q)
    (facto q 2))
  '(2))

(time-test "facto-backwards-720"
  (run* (q)
    (facto q 720))
  '(6))

(load "../../clpsmt-miniKanren/full-interp.scm")

(test "evalo-1"
  (run* (q)
    (evalo '(+ 1 2) q))
  '(3))

(time-test "evalo-fac-6"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac 6))
           q))
  '(720))

(time-test "evalo-backwards-fac-6"
  (run 1 (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ,q))
           720))
  '(6))

;; remember the quote!
(time-test "evalo-backwards-fac-quoted-6"
  (run* (q)
    (evalo `(letrec ((fac
                      (lambda (n)
                        (if (< n 0) #f
                            (if (= n 0) 1
                                (* n (fac (- n 1))))))))
              (fac ',q))
           720))
  '(6))
