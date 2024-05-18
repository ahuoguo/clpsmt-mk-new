(load "../mk.scm")
(load "../smt.scm")
(load "../z3-driver.scm")
(load "../test-check.scm")

(load "../kanren+/full-interp.scm")

(load "../kanren+/while-abort.scm")

;;; The following example is adapted from:
;;;
;;; https://github.com/webyrd/polyconf-2015/blob/master/talk-code/while-interpreter/while-abort-tests.scm

;;; symbolic execution example from slide 7 of Stephen Chong's slides
;;; on symbolic execution (contains contents from Jeff Foster's
;;; slides)
;;;
;;; http://www.seas.harvard.edu/courses/cs252/2011sp/slides/Lec13-SymExec.pdf

;;;  1. int a = α, b = β, c = γ
;;;  2.             // symbolic
;;;  3. int x = 0, y = 0, z = 0;
;;;  4. if (a) {
;;;  5.   x = -2;
;;;  6. }
;;;  7. if (b < 5) {
;;;  8.   if (!a && c)  { y = 1; }
;;;  9.   z = 2;
;;; 10. }
;;; 11. assert(x+y+z!=3)

;;; we will model the 'assert' using 'if' and 'abort'

;;; Slightly modified version that we are actually modelling:

;;;  1. int a := α, b := β, c := γ
;;;  4. if (a != 0) {
;;;  5.   x := -2;
;;;  6. }
;;;  7. if (b < 5) {
;;;  8.   if ((a = 0) && (c != 0))  { y := 1; }
;;;  9.   z := 2;
;;; 10. }
;;; 11. if (x+(y+z) != 3) {
;;;       abort
;;;     }


(define symbolic-exec-prog
  `(seq
     (if (!= a 0)
         (:= x -2)
         (skip))
     (seq
       (if (< b 5)
           (seq
             (if (and (= a 0) (!= c 0))
                 (:= y 1)
                 (skip))
             (:= z 2))
           (skip))
       (if (!= (+ x (+ y z)) 3)
           (skip)
           (abort)))))

;; in following examples
;; alpha == 0 /\ beta < 5 /\ gamma != 0 will result in an abort

(test "symbolic-exec-prog-c"
  (run 1 (q)
    (fresh (alpha beta gamma s)
      (== (list alpha beta gamma s) q)
      (z/assert `(not (= 0 ,alpha)))
      (z/assert `(<= 0 ,beta))
      (z/assert `(<= 0 ,gamma))
      (->o
       `(,symbolic-exec-prog
         ((a . ,alpha)
          (b . ,beta)
          (c . ,gamma)))
       `(abort ,s))))
  '())

(test "symbolic-exec-prog-d"
  (run 1 (q)
    (fresh (alpha beta gamma s)
      (== (list alpha beta gamma s) q)
      (z/assert `(not (= 0 ,alpha)))
      (->o
       `(,symbolic-exec-prog
         ((a . ,alpha)
          (b . ,beta)
          (c . ,gamma)))
       `(abort ,s))))
  '())

(test "symbolic-exec-prog-e"
  (run 8 (q)
    (fresh (alpha beta gamma s)
      (== (list alpha beta gamma s) q)
      (z/assert `(not (= 0 ,beta)))
      (->o
       `(,symbolic-exec-prog
         ((a . ,alpha)
          (b . ,beta)
          (c . ,gamma)))
       `(abort ,s))))
  '((0 -1 1 ((z . 2) (y . 1) (a . 0) (b . -1) (c . 1))) 
    (0 -2 -1 ((z . 2) (y . 1) (a . 0) (b . -2) (c . -1))) 
    (0 1 -2 ((z . 2) (y . 1) (a . 0) (b . 1) (c . -2))) 
    (0 -3 -3 ((z . 2) (y . 1) (a . 0) (b . -3) (c . -3))) 
    (0 -4 -4 ((z . 2) (y . 1) (a . 0) (b . -4) (c . -4))) 
    (0 -5 -5 ((z . 2) (y . 1) (a . 0) (b . -5) (c . -5))) 
    (0 -6 -6 ((z . 2) (y . 1) (a . 0) (b . -6) (c . -6))) 
    (0 2 -3 ((z . 2) (y . 1) (a . 0) (b . 2) (c . -3)))))

;; old versions (probably older z3 4.8.3) gives this answer
;; '((0 1 1 ((z . 2) (y . 1) (a . 0) (b . 1) (c . 1)))
;;     (0 -1 -1 ((z . 2) (y . 1) (a . 0) (b . -1) (c . -1)))
;;     (0 -2 -2 ((z . 2) (y . 1) (a . 0) (b . -2) (c . -2)))
;;     (0 -3 -3 ((z . 2) (y . 1) (a . 0) (b . -3) (c . -3)))
;;     (0 -4 -4 ((z . 2) (y . 1) (a . 0) (b . -4) (c . -4)))
;;     (0 -5 -5 ((z . 2) (y . 1) (a . 0) (b . -5) (c . -5)))
;;     (0 -6 -6 ((z . 2) (y . 1) (a . 0) (b . -6) (c . -6)))
;;     (0 2 -7 ((z . 2) (y . 1) (a . 0) (b . 2) (c . -7))))
