;; (load "mk/mk.scm")
;; (load "arithmetic.scm")
(load "kanren+/membero.scm")
;; (load "mk/test-check.scm")

(define int 
  (lambda (n) n))

(define build-num 
  (lambda (n) n))

(define <o
  (lambda (n m)
    (z/assert `(< ,n ,m))))

(define <=o
  (lambda (n m)
    (z/assert `(<= ,n ,m))))

;; n - m = k
(define minuso 
  (lambda (n m k)
  (z/assert `(= (- ,n ,m) ,k))))

;; n - m = k
(define pluso 
  (lambda (n m k)
  (z/assert `(= (+ ,n ,m) ,k))))

(define maxo
  (lambda (x y z)
    (conde
      [(<o x y) (== z y)]
      [(<=o y x) (== z x)])))

(set! allow-incomplete-search? #t)

#| Grammar:
com := (skip)                   skip
     | (x := aexp)              assignment
     | (if bexp com com)        conditional
     | (seq com com)            sequence
     | (while bexp com)         loop
     | (pre bexp com)           strenthen the pre-condition
     | (post bexp com)          weaken the post-condition

aexp := ℕ | x
      | (+ aexp aexp)
      | (- aexp aexp)
      | (* aexp aexp)

bexp := true | false
      | (∧ bexp bexp)
      | (>= aexp aexp)          greater or equal than
      | (>  aexp aexp)          greater than
|#

(define op1 '(¬))
(define op2 `(+ - * = >= > < <= ∧ ∨))

(define arithop '(+ - *))
(define boolop_num '(= >= > < <=))
(define boolop_bool '(∧ ∨))
(define boolop `(,@op1 ,@boolop_bool ,@boolop_bool))


;; Reflexive, symmetric, transitive closure of rewriteo
(define (⇓o p q)
  (conde
   [(fresh (r)
           (=/= p q)
           (rewriteo p r)
           (⇓o r q))]
   [(== p q)]))

;; TODO: why such rewrite rules are adequate?
;; TODO: consider divide rewrite to rewrite/pred rewrite/exp?
;; Such rewriteo is essentially a partial evaluator on logic terms.

;; Single-step rewrite rules
(define (rewriteo p q)
  (conde
   ;; Reflexivity
   [(fresh (x)
           (== p `(= ,x ,x))
           (== q 'true))]
   [(fresh (x)
           (== p `(>= ,x ,x))
           (== q 'true))]
   #|
   [(fresh (x)
           (== p `(<= ,x ,x))
           (== q 'true))]
   |#
   ;; Congruence of unary operators
   [(fresh (op p^ q^)
           (== p `(,op ,p^))
           (== q `(,op ,q^))
           (membero op op1)
           (rewriteo p^ q^))]
   ;; Congruence of binary operators
   [(fresh (op p1 p2 q1 q2)
           (== p `(,op ,p1 ,p2))
           (== q `(,op ,q1 ,q2))
           (membero op op2)
           (rewriteo p1 q1)
           (rewriteo p2 q2))]
   ;; Prefer right-associativity over left-associativity
   [(fresh (p1 p2 p3)
           (== p `(∧ (∧ ,p1 ,p2) ,p3))
           (== q `(∧ ,p1 (∧ ,p2 ,p3))))]
   [(fresh (p1 p2 p3)
           (== p `(∨ (∨ ,p1 ,p2) ,p3))
           (== q `(∨ ,p1 (∨ ,p2 ,p3))))]
   ;; Unit laws
   [(fresh (p^)
           (conde
            [(== p `(∧ true ,p^))
             (== q p^)]
            [(== p `(∧ ,p^ true))
             (== q p^)]))]
   [(fresh (p^)
           (conde
            [(== p `(∨ false ,p^))
             (== q p^)]
            [(== p `(∨ ,p^ false))
             (== q p^)]))]
   [(fresh (x)
           (conde
            [(== p `(+ 0 ,x))
             (== q `,x)]
            [(== p `(+ ,x 0))
             (== q `,x)]))]
   [(fresh (x)
           (== p `(- ,x 0))
           (== q `,x))]
   [(fresh (x)
           (conde
            [(== p `(* 1 ,x))
             (== q `,x)]
            [(== p `(* ,x 1))
             (== q `,x)]))]
   ;; Zero laws
   [(fresh (p^)
           (conde
            [(== p `(∧ false ,p^))
             (== q 'false)]
            [(== p `(∧ ,p^ false))
             (== q 'false)]))]
   [(fresh (p^)
           (conde
            [(== p `(∨ true ,p^))
             (== q 'true)]
            [(== p `(∨ ,p^ true))
             (== q 'true)]))]
   [(fresh (p^)
           (conde
            [(== p `(* 0 p^))
             (== q 0)]
            [(== p `(* p^ 0))
             (== q 0)]))]
   ;; Prefer greater over geq
   [(fresh (x n1 n2)
           (== p `(>= ,x ,n1))
           (== q `(>  ,x ,n2))
           (minuso n1 1 n2))]
   ;; Simplify conjunctions of comparisons
   ;; TODO: Obviously, there can be more such rules, do we need them?
   ;; TODO: Do we need both >=/> and <=/<?
   ;;       If we enforce that variables must appear on the lhs, then seems yes.
   ;;       But if we relax that (x > 1 or 1 > x are both valid), then we need more rewrite rules to handle the later cases.
   [(fresh (x y)
           (== p `(∧ (>= ,x ,y) (> ,x ,y)))  ;; Note: this assumes > appears before >=!
           (== q `(> ,x ,y)))]
   [(fresh (x y)
           (== p `(∧ (>= ,x ,y) (¬ (> ,x ,y))))
           (== q `(= ,x ,y)))]
   #|
   [(fresh (x y)
           (== p `(∧ (< ,x ,y) (<= ,x ,y)))
           (== q `(< ,x ,y)))]
   [(fresh (x y)
           (== p `(∧ (<= ,x ,y) (¬ (< ,x ,y))))
           (== q `(= ,x ,y)))]
   |#
   ;; Simplification
   [(fresh (x n m k)
           (== p `(= (+ ,x ,n) ,m))
           (== q `(= ,x ,k))
           (symbolo x)
           (minuso m n k))]
   ;; Constant folding
   [(fresh (x y)
           (== p `(= ,x ,y))
           (conde
            [(== `,x `,y) (== q 'true)]
            [(=/= `,x `,y) (== q 'false)]))]
   [(fresh (x y)
           (== p `(> ,x ,y))
           (conde
            [(<o `,y `,x) (== q 'true)]
            [(<=o `,x `,y) (== q 'false)]))]
   [(fresh (x y)
           (== p `(>= ,x ,y))
           (conde
            [(<=o `,y `,x) (== q 'true)]
            [(<o `,x `,y) (== q 'false)]))]
   [(fresh (x n1 n2 n3)
           (== p `(> (- ,x ,n1) ,n2))
           (== q `(> ,x ,n3))
           (pluso n1 n2 n3))]
   [(fresh (x n1 n2)
           (== p `(∧ (> ,x ,n1 (¬ (> ,x ,n2)))))
           (== q `(= ,x ,n2))
           (pluso n1 1 n2))]
   [(fresh (x n1 n2 n3)
           (== p `(∧ (> ,x ,n1) (> ,x ,n2)))
           (== q `(> ,x ,n3))
           (maxo n1 n2 n3))]
   [(fresh (x n1 n2 n3)
           (== p `(> (+ ,x ,n1) ,n2))
           (== q `(> ,x ,n3))
           (minuso n2 n1 n3))]
   [(fresh (x y)
           (== p `(>= (- ,x ,y) 0))
           (== q `(>= ,x ,y)))]
   #| -1 is not expressible
   [(fresh (x y)
           (== p `(> (- ,x ,y) -1))
           (== q `(>= ,x ,y)))]
   |#
   [(fresh (x y z)
           (== p `(+ (* (+ ,x 1) ,y) (- ,z ,y)))
           (== q `(+ (* ,x ,y) ,z)))]))

(define (substo* p x t q)
  (conde
   ;;[(== p q) (numbero p)]
   [(fresh (n)
           (== p `,n)
           (== q p))]
   [(symbolo p)
    (== p x)
    (== t q)]
   [(symbolo p)
    (=/= p x)
    (== p q)]
   [(fresh (op p^ q^)
           (== p `(,op ,p^))
           (== q `(,op ,q^))
           (membero op op1)
           (substo* p^ x t q^))]
   [(fresh (op p1 p2 q1 q2)
           (== p `(,op ,p1 ,p2))
           (== q `(,op ,q1 ,q2))
           (membero op op2)
           (substo* p1 x t q1)
           (substo* p2 x t q2))]))

;; see `test-implieso.scm`
;; Alex: What are the syntactic constraints for p and q?
;;       they should both be bexp?

;; Alex: not need to wrap around int because we assume we support
;; natural numbers by the smt solver
(define (implieso* p q)
  (conde
   [(== p q)]
   ;[(== q 'true)]
   [(== p 'false)]
   ;; TODO: is it sound? under what condition?
   ;; Alex: I think this is not strong enough
   [(fresh (r s w v)
           (== p `(∧ ,r ,s))
           (== q `(∧ ,w ,v))
           (implieso* r w)
           (implieso* s v))]
   [(fresh (r s)
           (== p `(∨ ,r ,s))
           (conde
            [(implieso r q)]
            [(implieso s q)]))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(< ,x ,n))
           (== q `(< ,x ,m))
           (<o n m))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(<= ,x ,n))
           (== q `(<= ,x ,m))
           (<=o n m))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(> ,x ,n))
           (== q `(> ,x ,m))
           (<o m n))]
   [(fresh (x n m)
           (symbolo x)
           (== p `(>= ,x ,n))
           (== q `(>= ,x ,m))
           (<=o m n))]))

(define (implieso p q)
  (fresh (r t)
         (⇓o p r)
         (⇓o q t)
         (implieso* r t)))

;; Equivalent up to normalization
(define (equivo p q) (⇓o p q))

;; p[x -> t] = q
(define (substo p x t q)
  (fresh (r)
         (substo* p x t r)
         (equivo r q)))

(define (listof01o x)
  (conde
   [(== x '())]
   [(fresh (a d)
           (== `(,a . ,d) x)
           (membero a '(0 1))
           (listof01o d))]))

(define (into e)
  (fresh (x)
         (== e x)
         (numbero x)
        ))

(define (aexpo e)
  (conde
   [(into e)]
   [(symbolo e)]
   [(fresh (op e1 e2)
           (== e `(,op ,e1 ,e2))
           (membero op arithop)
           (aexpo e1)
           (aexpo e2))]))

(define (bexpo e)
  (conde
   [(== e 'true)]
   [(== e 'false)]
   [(fresh (op e1)
           (== e `(,op ,e1))
           (membero op op1)
           (bexpo e1))]
   [(fresh (op e1 e2)
           (== e `(,op ,e1 ,e2))
           (membero op boolop_num)
           (aexpo e1)
           (aexpo e2))]
   [(fresh (op e1 e2)
           (== e `(,op ,e1 ,e2))
           (membero op boolop_bool)
           (bexpo e1)
           (bexpo e2))]))

(define (varo x) (symbolo x))

(define (proveo p com q)
  (fresh ()
         (bexpo p)
         (bexpo q)
         (conde
          [(== com `(skip))
           (equivo p q)]
          [(fresh (x e)
                  (== com `(,x := ,e))
                  (varo x)
                  (aexpo e)
                  (substo q x e p)
        )]
          [(fresh (cnd thn els)
                  (== com `(if ,cnd ,thn ,els))
                  (proveo `(∧ ,p ,cnd) thn q)
                  (proveo `(∧ ,p (¬ ,cnd)) els q))]
          [(fresh (cnd body)
                  (== com `(while ,cnd ,body))
                  (equivo `(∧ ,p (¬ ,cnd)) q)
                  (proveo `(∧ ,p ,cnd) body p))]
          [(fresh (c1 r c2)
                  (== com `(seq ,c1 ,c2))
                  (proveo p c1 r)
                  (proveo r c2 q))]
          [(fresh (r com^)
                  (== com `(pre ,r ,com^))
                  (implieso p r)
                  (proveo r com^ q))]
          [(fresh (r com^)
                  (== com `(post ,r ,com^))
                  (implieso r q)
                  (proveo p com^ r))])))
