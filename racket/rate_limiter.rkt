#lang racket

;;; Token Bucket Rate Limiter
;;; Transpiled from INTENT.md - Human language is the source code.

(require racket/class)

(define token-bucket%
  (class object%
    (init-field capacity refill-rate)
    (super-new)
    
    (unless (positive? capacity)
      (error 'token-bucket "Capacity must be positive"))
    (unless (positive? refill-rate)
      (error 'token-bucket "Refill rate must be positive"))
    
    (define tokens capacity)
    (define last-refill (current-inexact-milliseconds))
    (define lock (make-semaphore 1))
    
    (define/private (refill!)
      (define now (current-inexact-milliseconds))
      (define elapsed-ms (- now last-refill))
      (when (> elapsed-ms 0)
        (define elapsed-sec (/ elapsed-ms 1000.0))
        (define tokens-to-add (* elapsed-sec refill-rate))
        (set! tokens (min capacity (+ tokens tokens-to-add)))
        (set! last-refill now)))
    
    (define/public (consume [n 1.0])
      (call-with-semaphore lock
        (λ ()
          (refill!)
          (if (>= tokens n)
              (begin (set! tokens (- tokens n)) #t)
              #f))))
    
    (define/public (available)
      (call-with-semaphore lock
        (λ () (refill!) tokens)))
    
    (define/public (get-capacity) capacity)
    (define/public (get-refill-rate) refill-rate)))

;; Demo
(displayln "Token Bucket Rate Limiter - Racket Implementation")
(displayln (make-string 50 #\=))
(newline)

(define limiter (new token-bucket% [capacity 5] [refill-rate 2]))

(printf "Created limiter: capacity=~a, refill_rate=~a/s~n"
        (send limiter get-capacity) (send limiter get-refill-rate))
(printf "Starting tokens: ~a~n" (inexact->exact (floor (send limiter available))))
(newline)

(displayln "--- Rapid consumption ---")
(for ([i (in-range 1 8)])
  (define result (send limiter consume))
  (define status (if result "✓ allowed" "✗ denied"))
  (printf "  Attempt ~a: ~a (tokens left: ~a)~n" 
          i status (~r (send limiter available) #:precision 2)))
(newline)

(displayln "--- Waiting 1 second for refill ---")
(sleep 1)
(printf "Tokens after 1s: ~a~n" (~r (send limiter available) #:precision 2))
(newline)

(displayln "--- Post-refill consumption ---")
(for ([i (in-range 1 4)])
  (define result (send limiter consume))
  (define status (if result "✓ allowed" "✗ denied"))
  (printf "  Attempt ~a: ~a (tokens left: ~a)~n"
          i status (~r (send limiter available) #:precision 2)))
(newline)

(displayln (make-string 50 #\=))
(displayln "Human intent → Racket implementation ✓")
