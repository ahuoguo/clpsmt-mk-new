(load "test-check.scm")
(load "verifyo.scm")

;; NOTE: Nothing here calls out to an SMT solver yet

(test "1[a -> b] ≡ ???"
    (run* (q) (substo/exp 1 'a 'b q))
    (list 1)
)

(test "c[a -> b] ≡ ???"
    (run 1 (q) (substo/exp 'c 'a 'b q))
    '(c)
)

(test "a[a -> b] ≡ ???"
    (run 1 (q) (substo/exp 'a 'a 'b q))
    '(b)
)

(test "(a+b)[a -> c] ≡ ???"
    (run 1 (q) (substo/exp '(a + b) 'a 'c q)) 
    '((c + b))
)

(test "???[a -> c] ≡ (c + b)"
    (run 1 (q) (substo/exp q 'a 'c '(c + b)))
    '((a + b)))

(test "{x = 5}[x -> 5] ≡ ???"
    (run 1 (q) (substo `(x = 5) 'x 5 q))
    '((5 = 5))
)


(test "{(a + b) = (b + c)}[b -> 1] ≡ ???"
    (run 1 (q) (substo '((a + b) = (b + c)) 'b 1 q))
    '(((a + 1) = (1 + c)))
)

(test "???[b -> c] {(a + 1) = (d + c)}"
    (run 1 (q) (substo q 'b 'c `((a + 1) = (d + c))))
    '(((a + 1) = (d + b)))
)

(test "???[b -> c] {(a + c) = (d + c)}"
    (run 1 (q) (substo q 'b 'c '((a + c) = (d + c))))
    '(((a + b) = (d + b)))
)

(test "(wpo `(x := 3) `(x = 3) wp sc)"
    (run 1 (wp sc) (wpo `(x := 3) `(x = 3) wp sc))
    '(((3 = 3) _.0))
)

(test ""
    (run 1 (wp sc)
        (wpo 
            `(seq (x := 2)
                    (y := (x + 1)))
            `[(x = 2) ∧ (y = 3)]
            wp
            sc))
    '((((2 = 2) ∧ ((2 + 1) = 3)) _.0))
)

(test ""
    (run 1 (wp sc)
        (wpo `(seq (x := (x + 1))
                    (y := (x + 1)))
            `[(x = 4) ∧ (y = 5)]
            wp
            sc))
    '(((((x + 1) = 4) ∧ (((x + 1) + 1) = 5)) _.0))
)

(test ""
    (run 1 (wp sc)
        (wpo `(seq (z := (x + 1))
                    (seq (x := (x + 1))
                        (y := (x + 1))))
            `[((x = 4) ∧ (y = 5)) ∧ (z = 4)]
            wp
            sc))
    '((((((x + 1) = 4) ∧ (((x + 1) + 1) = 5)) ∧ ((x + 1) = 4))
        _.0))
)

(test ""
    (run 1 (wp sc)
        (wpo `(if (a = b) (a := 3) (b := 4))
             `[(a = 3) ∨ (b = 4)]
             wp sc))
    '(((((a = b) ⇒ ((3 = 3) ∨ (b = 4))) ∧
        ((¬ (a = b)) ⇒ ((a = 3) ∨ (4 = 4))))
       _.0))
)

;; TODO: debug this
;; (check-equal?
;;  (run 1 (wp sc)
;;       (wpo `(while (x > 0)
;;                    {invariant ((y = (2 * x)) ∧ (x ≥ 0))}
;;                    (seq (x := (x - 1))
;;                         (y := (y - 2))))
;;            `(y = 0)
;;            wp
;;            sc))
;;  '((((y = ((int (0 1)) * x)) ∧ (x ≥ (int ())))
;;     (((((y = ((int (0 1)) * x)) ∧ (x ≥ (int ()))) ∧ (x > (int ())))
;;       ⇒
;;       (((y - (int (0 1))) = ((int (0 1)) * (x - (int (1))))) ∧ ((x - (int (1))) ≥ (int ()))))
;;      ((((y = ((int (0 1)) * x)) ∧ (x ≥ (int ()))) ∧ (¬ (x > (int ())))) ⇒ (y = (int ())))))))

;; A tiny synthesis example
(test "{x + 1 = 2} ??? {x = 2}"
    (run 1 (com)
        (wpo com `[x = 2] `[(x + 1) = 2] '()))
    '((x := (x + 1)))
)
