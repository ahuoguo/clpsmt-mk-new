;; from https://youtu.be/KsC_9_-NuQg?si=F8lbhIgqhwQkWxlR&t=611

;; (set-option :smt.auto-config false) 
;; (set-option :smt.mbqi true) 

;; (declare-fun fact (Int) Int)
;; (assert (= (fact 0) 1))
;; (assert (forall ((n Int))
;;     (=> (> n 0) (= (fact n) (* n (fact (- n 1)))))))
;; (declare-const r6 Int)
;; (assert (= 720 (fact 6)))
;; (check-sat) ;; unknown, even if changing r6 to result 
;; (get-model) 
;; (eval (fact 6))

;; however, SMT can do recursive reasoning with
(set-logic ALL)
(define-fun-rec 
   fac ((x Int)) Int
   (
    ite (<= x 1) 
        1 
        (* x (fac (- x 1)))
   )
)

(declare-const in Int)
(declare-const out Int)

(assert (= (fac in) out))
(assert (not (= out 0)))
; (assert (not (= out 1)))
; (assert (not (= out 6)))



(check-sat)
; (get-model)
