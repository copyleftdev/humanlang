;;; Token Bucket Rate Limiter
;;;
;;; Transpiled from INTENT.md - Human language is the source code.
;;;
;;; Common Lisp: The language that was AI before AI was cool.

;;; A rate limiter using the token bucket algorithm.
;;;
;;; Tokens refill at a steady rate up to a maximum capacity.
;;; Each action consumes one token. If no tokens are available,
;;; the action is denied.

(defstruct (token-bucket (:constructor %make-token-bucket))
  (capacity 0.0 :type double-float)
  (refill-rate 0.0 :type double-float)
  (tokens 0.0 :type double-float)
  (last-refill 0.0 :type double-float))

(defun get-time ()
  "Get current time in seconds."
  (/ (get-internal-real-time) internal-time-units-per-second))

(defun make-token-bucket (capacity refill-rate)
  "Create a new token bucket.
   CAPACITY: Maximum number of tokens the bucket can hold.
   REFILL-RATE: Number of tokens added per second."
  (assert (> capacity 0) (capacity) "Capacity must be positive")
  (assert (> refill-rate 0) (refill-rate) "Refill rate must be positive")
  (%make-token-bucket
   :capacity (coerce capacity 'double-float)
   :refill-rate (coerce refill-rate 'double-float)
   :tokens (coerce capacity 'double-float)  ; Start full
   :last-refill (coerce (get-time) 'double-float)))

(defun refill (bucket)
  "Add tokens based on elapsed time since last refill."
  (let* ((now (coerce (get-time) 'double-float))
         (elapsed (- now (token-bucket-last-refill bucket))))
    (when (> elapsed 0)
      (let ((tokens-to-add (* elapsed (token-bucket-refill-rate bucket))))
        (setf (token-bucket-tokens bucket)
              (min (token-bucket-capacity bucket)
                   (+ (token-bucket-tokens bucket) tokens-to-add)))
        (setf (token-bucket-last-refill bucket) now)))))

(defun consume (bucket &optional (tokens 1.0))
  "Attempt to consume tokens from the bucket.
   Returns T if tokens were consumed, NIL if insufficient."
  (refill bucket)
  (if (>= (token-bucket-tokens bucket) tokens)
      (progn
        (decf (token-bucket-tokens bucket) tokens)
        t)
      nil))

(defun available (bucket)
  "Get the current number of available tokens."
  (refill bucket)
  (token-bucket-tokens bucket))

;;; --- Demonstration ---

(defun demo ()
  (format t "Token Bucket Rate Limiter - Common Lisp Implementation~%")
  (format t "~A~%" (make-string 50 :initial-element #\=))
  (terpri)

  ;; Create a bucket: 5 tokens capacity, 2 tokens/second refill
  (let ((limiter (make-token-bucket 5 2)))
    (format t "Created limiter: capacity=~D, refill_rate=~D/s~%"
            (truncate (token-bucket-capacity limiter))
            (truncate (token-bucket-refill-rate limiter)))
    (format t "Starting tokens: ~D~%" (truncate (available limiter)))
    (terpri)

    ;; Consume all tokens rapidly
    (format t "--- Rapid consumption ---~%")
    (dotimes (i 7)
      (let* ((result (consume limiter))
             (status (if result "✓ allowed" "✗ denied")))
        (format t "  Attempt ~D: ~A (tokens left: ~,2F)~%"
                (1+ i) status (available limiter))))
    (terpri)

    ;; Wait for refill
    (format t "--- Waiting 1 second for refill ---~%")
    (sleep 1)
    (format t "Tokens after 1s: ~,2F~%" (available limiter))
    (terpri)

    ;; Try again
    (format t "--- Post-refill consumption ---~%")
    (dotimes (i 3)
      (let* ((result (consume limiter))
             (status (if result "✓ allowed" "✗ denied")))
        (format t "  Attempt ~D: ~A (tokens left: ~,2F)~%"
                (1+ i) status (available limiter)))))

  (terpri)
  (format t "~A~%" (make-string 50 :initial-element #\=))
  (format t "Human intent → Common Lisp implementation ✓~%"))

;; Run the demo
(demo)
