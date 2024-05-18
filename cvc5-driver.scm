(define cvc5-counter-check-sat 0)
(define cvc5-counter-get-model 0)

(define log-all-calls #f)

(define read-sat
  (lambda (fn)
    (let ([p (open-input-file fn)])
      (let ([r (read p)])
        (close-input-port p)
        (eq? r 'sat)))))

;; TODO: try  QF_UFDTLIAFS and maybe it can solve more problems?
(define call-cvc5
  (lambda (xs)
    (let ([p (open-output-file "out.smt" 'replace)])
      (for-each (lambda (x) (fprintf p "~a\n" x))
                (cons '(set-logic ALL) xs))
      (close-output-port p)
      
      (system "perl -i -pe 's/#t/true/g' out.smt")
      (system "perl -i -pe 's/#f/false/g' out.smt")
      (system "perl -i -pe 's/bitvec-/#b/g' out.smt")
      ;; cvc5 cannot recognize negative numbers like -1, it must be (- 1)
      ;; (z3 recognizes both)
      (system "perl -i -pe 's/-(\\d+)/(- \\1)/g' out.smt")
      (let ((r (system "cvc5 -m --lang smt out.smt > out.txt")))
        (when log-all-calls
          (system (format "cp out.smt out~d.smt" (+ cvc5-counter-check-sat cvc5-counter-get-model)))
          (system (format "cp out.txt out~d.txt" (+ cvc5-counter-check-sat cvc5-counter-get-model))))
        (system "perl -i -pe 's/#b/bitvec-/g' out.txt")
        (when (not (= r 0))
            (error 'call-cvc5 "error in cvc5 out.smt > out.txt"))))))

(define check-sat
  (lambda (xs)
    (call-cvc5 (append xs '((check-sat) (exit))))
    (set! cvc5-counter-check-sat (+ cvc5-counter-check-sat 1))
    (read-sat "out.txt")))

;; copied from z3-driver.scm
(define read-model
  (lambda (fn)
    (let ([p (open-input-file fn)])
      (let ([r (read p)])
        (if (eq? r 'sat)
            (let ([m (read p)])
              (close-input-port p)
              (map (lambda (x)
                     (cons (cadr x)
                           (if (null? (caddr x))
                               (let ([r (cadddr (cdr x))])
                                 (cond
                                   ((eq? r 'false) #f)
                                   ((eq? r 'true) #t)
                                   ((and (pair? (cadddr x)) (eq? (cadr (cadddr x)) 'BitVec)) r)
                                   (else (eval r))))
                               `(lambda ,(map car (caddr x)) ,(cadddr (cdr x))))))
                   m))
            (begin
              (close-input-port p)
              #f))))))

(define get-model
  (lambda (xs)
    (call-cvc5 (append xs '((check-sat) (get-model) (exit))))
    (set! cvc5-counter-get-model (+ cvc5-counter-get-model 1))
    (read-model "out.txt")))

(define neg-model
  (lambda (model)
    (cons
     'assert
     (list
      (cons
       'or
       (map
        (lambda (xv)
          `(not (= ,(car xv) ,(cdr xv))))
        model))))))

(define check-model-unique
  (lambda (xs model)
    (let ([r
           (check-sat
            (append xs (list (neg-model model))))])
      (not r))))

(define get-all-models
  (lambda (xs ms)
    (let* ([ys (append xs (map neg-model ms))])
      (if (not (check-sat ys))
          (reverse ms)
          (get-all-models xs (cons (get-model ys) ms))))))

;; copied from z3-driver.scm
(define get-next-model
  (lambda (xs ms)
    (let* ([ms (map (lambda (m)
                      (filter (lambda (x) ; ignoring functions
                                (or (number? (cdr x))
                                    (symbol? (cdr x)) ; for bitvectors
                                    (boolean? (cdr x)) ; for booleans
                                    )) m))
                    ms)])
      (if (member '() ms) #f  ; if we're skipping a model, let us stop
          (let ([ys (append xs (map neg-model ms))])
            (and (check-sat ys)
                 (get-model ys)))))))
