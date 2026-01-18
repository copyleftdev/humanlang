;; Token Bucket Rate Limiter
;;
;; Transpiled from INTENT.md - Human language is the source code.

(ns rate-limiter
  (:import [java.time Instant]))

(defn- now-seconds
  "Get current monotonic time in seconds."
  []
  (/ (System/nanoTime) 1e9))

(defn create-bucket
  "Create a new token bucket rate limiter.
   
   capacity: Maximum number of tokens the bucket can hold
   refill-rate: Number of tokens added per second"
  [capacity refill-rate]
  {:pre [(pos? capacity) (pos? refill-rate)]}
  (atom {:capacity capacity
         :refill-rate refill-rate
         :tokens capacity  ; Start full
         :last-refill (now-seconds)}))

(defn- refill
  "Add tokens based on elapsed time since last refill."
  [{:keys [capacity refill-rate tokens last-refill] :as state}]
  (let [now (now-seconds)
        elapsed (- now last-refill)]
    (if (pos? elapsed)
      (let [tokens-to-add (* elapsed refill-rate)
            new-tokens (min capacity (+ tokens tokens-to-add))]
        (assoc state
               :tokens new-tokens
               :last-refill now))
      state)))

(defn consume!
  "Attempt to consume tokens from the bucket.
   Returns true if tokens were consumed, false if insufficient."
  ([bucket] (consume! bucket 1.0))
  ([bucket tokens]
   (let [result (atom false)]
     (swap! bucket
            (fn [state]
              (let [refilled (refill state)]
                (if (>= (:tokens refilled) tokens)
                  (do
                    (reset! result true)
                    (update refilled :tokens - tokens))
                  (do
                    (reset! result false)
                    refilled)))))
     @result)))

(defn available
  "Get the current number of available tokens."
  [bucket]
  (-> (swap! bucket refill)
      :tokens))

(defn capacity
  "Get the capacity of the bucket."
  [bucket]
  (:capacity @bucket))

(defn refill-rate
  "Get the refill rate of the bucket."
  [bucket]
  (:refill-rate @bucket))

;; --- Demonstration ---

(defn demo []
  (println "Token Bucket Rate Limiter - Clojure Implementation")
  (println (apply str (repeat 50 "=")))
  
  ;; Create a bucket: 5 tokens capacity, 2 tokens/second refill
  (let [limiter (create-bucket 5 2)]
    
    (println)
    (printf "Created limiter: capacity=%.0f, refill_rate=%.0f/s%n"
            (double (capacity limiter)) (double (refill-rate limiter)))
    (printf "Starting tokens: %.0f%n" (double (available limiter)))
    
    ;; Consume all tokens rapidly
    (println)
    (println "--- Rapid consumption ---")
    (doseq [i (range 1 8)]
      (let [result (consume! limiter)
            status (if result "✓ allowed" "✗ denied")]
        (printf "  Attempt %d: %s (tokens left: %.2f)%n"
                i status (available limiter))))
    
    ;; Wait for refill
    (println)
    (println "--- Waiting 1 second for refill ---")
    (Thread/sleep 1000)
    (printf "Tokens after 1s: %.2f%n" (available limiter))
    
    ;; Try again
    (println)
    (println "--- Post-refill consumption ---")
    (doseq [i (range 1 4)]
      (let [result (consume! limiter)
            status (if result "✓ allowed" "✗ denied")]
        (printf "  Attempt %d: %s (tokens left: %.2f)%n"
                i status (available limiter)))))
  
  (println)
  (println (apply str (repeat 50 "=")))
  (println "Human intent → Clojure implementation ✓"))

(demo)
