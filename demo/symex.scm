(load "../mk.scm")
(load "../smt.scm")
(load "../z3-driver.scm")
(load "../test-check.scm")

(load "../kanren+/full-interp.scm")

(test "symbolic-execution-2a"
  (run 10 (q)
    (evalo
      `((lambda (n)
          (if (= 137 n)
              'foo
              'bar))
        ,q)
      'bar))
  '(138 0 139 -1 -2 -3 140 141 142 -4)) 
  ;; this is subject to change due to search strategy / z3 heuristics

(test "symbolic-execution-3a"
  (run* (q)
    (evalo
      `((lambda (n)
          (if (= (+ (* n 3) 5) 14359371734)
              'foo
              'bar))
        ',q)
      'foo))
  '(4786457243))

 (test "synthesize-triple-by-example-2c20c"
   (run 3 (f)
     (fresh (op e1 e2)
       (== `(lambda (x) (,op ,e1 ,e2)) f)
       (symbolo op))
     (evalo `(list (,f 1) (,f 2)) '(2 4)))
   '((lambda (x) (+ x x))
     (lambda (x) (* 2 x))
     (lambda (x) (* x 2))))