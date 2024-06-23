(load "mk.scm")
(load "smt.scm")
(load "z3-driver.scm")
(load "test-check.scm")
;; (load "hoare.scm")

;; (define int
;;   (lambda (x) `(int ,(build-num x))))

(define build-num (lambda (n) n))

(define int 
  (lambda (n) n))

(define <o
  (lambda (n m)
    (z/assert `(< ,n ,m))))

(define <=o
  (lambda (n m)
    (z/assert `(<= ,n ,m))))


(define ≡ ==)

;; Idea 1: relation verification condition generator
;; TODO: WP vs SP

; Substitution for expressions
; e[x -> t] ≡ res
(define substo/exp
  (lambda (e x t res)
    (conde
     [(fresh (n)
        ;;      (== `(int ,n) e)
             (numbero e)
             (== e res))]
     [(symbolo e)
      (== e x)
      (== t res)]
     [(symbolo e)
      (=/= e x)
      (== e res)]
     [(fresh (e1 e2 s1 s2)
             (== e `(,e1 + ,e2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2)
             (== res `(,s1 + ,s2)))]
     [(fresh (e1 e2 s1 s2)
             (== e `(,e1 - ,e2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2)
             (== res `(,s1 - ,s2)))]
     [(fresh (e1 e2 s1 s2)
             (== e `(,e1 * ,e2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2)
             (== res `(,s1 * ,s2)))]
     [(fresh (e1 e2 s1 s2)
             (== e `(,e1 / ,e2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2)
             (== res `(,s1 / ,s2)))]
     )))

; Substitution for predicates
; p[x -> t] ≡ res
(define substo
  (lambda (p x t res)
    (conde
     [(== p 'true) (== p res)]
     [(== p 'false) (== p res)]
     [(fresh (e1 e2 s1 s2)
             (== p `(,e1 = ,e2))
             (== res `(,s1 = ,s2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2))]
     [(fresh (e1 e2 s1 s2)
             (== p `(,e1 < ,e2))
             (== res `(,s1 < ,s2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2))]
     [(fresh (e1 e2 s1 s2)
             (== p `(,e1 ≤ ,e2))
             (== res `(,s1 ≤ ,s2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2))]
     [(fresh (e1 e2 s1 s2)
             (== p `(,e1 > ,e2))
             (== res `(,s1 > ,s2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2))]
     [(fresh (e1 e2 s1 s2)
             (== p `(,e1 ≥ ,e2))
             (== res `(,s1 ≥ ,s2))
             (substo/exp e1 x t s1)
             (substo/exp e2 x t s2))]
     [(fresh (p1 p2 s1 s2)
             (== p `(,p1 ∧ ,p2))
             (== res `(,s1 ∧ ,s2))
             (substo p1 x t s1)
             (substo p2 x t s2))]
     [(fresh (p1 p2 s1 s2)
             (== p `(,p1 ∨ ,p2))
             (== res `(,s1 ∨ ,s2))
             (substo p1 x t s1)
             (substo p2 x t s2))]
     [(fresh (p1 p2 s1 s2)
             (== p `(,p1 ⇒ ,p2))
             (== res `(,s1 ⇒ ,s2))
             (substo p1 x t s1)
             (substo p2 x t s2))]
     [(fresh (p1 s1)
             (== p `(¬ ,p1))
             (== res `(¬ ,p1))
             (substo p1 x t s1))])))

(define appendo
  (lambda (l s out)
    (conde
     [(== '() l) (== s out)]
     [(fresh (a d res)
             (== `(,a . ,d) l)
             (== `(,a . ,res) out)
             (appendo d s res))])))

(define wpo
  (lambda (com post wp sc)
    (conde
     [(fresh (x e)
             (== com `(,x := ,e))
             (substo post x e wp))] ;; TODO: eval e?
     [(fresh (c1 c2 c2-wp c2-sc c1-sc)
             (== com `(seq ,c1 ,c2))
             (wpo c2 post c2-wp c2-sc)
             (wpo c1 c2-wp wp c1-sc)
             (appendo c1-sc c2-sc sc))]
     [(fresh (c t e t-wp e-wp t-sc e-sc)
             (== com `(if ,c ,t ,e))
             (wpo t post t-wp t-sc)
             (wpo e post e-wp e-sc)
             (== wp `((,c ⇒ ,t-wp) ∧ ((¬ ,c) ⇒ ,e-wp)))
             (appendo t-sc e-sc sc))]
     [(fresh (cnd inv body body-wp body-sc)
             (== com `(while ,cnd (invariant ,inv) ,body))
             (wpo body inv body-wp body-sc)
             ;; you want to use SMT solver to prove they are logically equivalent
        ;      (z/assert `())
             (== wp inv)
             ;; NOTE: post has no constraint!
             (appendo body-sc `(((,inv ∧ ,cnd) ⇒ ,body-wp) ((,inv ∧ (¬ ,cnd)) ⇒ ,post)) sc))]
     [(== com `(skip))
      (== post wp)])))

;; (define equiv
;;  (lambda (p1 p2)
;;        (z/ (list `(assert (not (and (=> ,p1 ,p2) (=> ,p2 ,p1))))))
;;  )
;; )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; TODO
;; this should call out to an SMT solver
(define ==>
  (lambda (p q)
    (== p q)))

(define verifyo
  (lambda (pre com post)
    (conde
     [(fresh (x e pre^)
             (== com `(,x := ,e))
             (substo post x e pre^)
             (==> pre pre^))] ; might be a strengthed precondition
     )))

;; (define reflect/exp
;;   (lambda (e)
;;     (match e
;;       [(? number? n) (int n)]
;;       [(? symbol? x) x])))

;; (define reflect
;;   (lambda (p)
;;     (match p
;;       ['true '(== #t #t)]
;;       ['false '(== #t #f)]
;;       [`(,e1 = ,e2)
;;        `(== ,(reflect/exp e1) ,(reflect/exp e2))])))

;; (reflect/exp 1)
;; (reflect/exp 5)
;; (reflect '(1 = 2))

;; true ⇒ false
;; To check its validity (it is not), we transform it to true ∧ true
(run 1 (q)
     (== #t #t)
     (== #t #t))

;; true ⇒ true
;; To check its validity, we transform it to true ∧ false
(run 1 (q)
     (== #t #t)
     (== #t #f))

;; false ⇒ true
;; To check its validity, we transform it to false ∧ false
(run 1 (q)
     (== #t #f)
     (== #t #f))

;; false ⇒ false
;; To check its validity, we transform it to false ∧ true
(run 1 (q)
     (== #t #f)
     (== #t #t))

;; only this one calls out to a SMT solver
;; ;; 1 < x ⇒ 0 < x
;; ;; To check its validity, we transform it to 1 < x ∧ x <= 0.
;; (run 1 (q)
;;      (fresh (x)
;;             (<o (build-num 1) x)
;;             (<=o x (build-num 0))))

;; x = y ∧ y = z ⇒ x = z
;; To check its validity, we transform it to x = y ∧ y = z ∧ x =/= z
(run 1 (q)
     (fresh (x y z)
            (== x y)
            (== y z)
            (=/= x z)))

