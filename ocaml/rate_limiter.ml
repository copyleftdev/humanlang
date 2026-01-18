(* Token Bucket Rate Limiter
 *
 * Transpiled from INTENT.md - Human language is the source code.
 *)

(** A rate limiter using the token bucket algorithm. *)
module TokenBucket : sig
  type t
  val create : capacity:float -> refill_rate:float -> t
  val consume : ?tokens:float -> t -> bool
  val available : t -> float
  val capacity : t -> float
  val refill_rate : t -> float
end = struct
  type t = {
    capacity : float;
    refill_rate : float;
    mutable tokens : float;
    mutable last_refill : float;
  }

  let now () = Unix.gettimeofday ()

  let create ~capacity ~refill_rate =
    if capacity <= 0. then invalid_arg "Capacity must be positive";
    if refill_rate <= 0. then invalid_arg "Refill rate must be positive";
    {
      capacity;
      refill_rate;
      tokens = capacity;  (* Start full *)
      last_refill = now ();
    }

  let refill bucket =
    let current = now () in
    let elapsed = current -. bucket.last_refill in
    if elapsed > 0. then begin
      let tokens_to_add = elapsed *. bucket.refill_rate in
      bucket.tokens <- min bucket.capacity (bucket.tokens +. tokens_to_add);
      bucket.last_refill <- current
    end

  let consume ?(tokens = 1.) bucket =
    refill bucket;
    if bucket.tokens >= tokens then begin
      bucket.tokens <- bucket.tokens -. tokens;
      true
    end else
      false

  let available bucket =
    refill bucket;
    bucket.tokens

  let capacity bucket = bucket.capacity
  let refill_rate bucket = bucket.refill_rate
end

(* --- Demonstration --- *)

let () =
  print_endline "Token Bucket Rate Limiter - OCaml Implementation";
  print_endline (String.make 50 '=');
  print_newline ();

  (* Create a bucket: 5 tokens capacity, 2 tokens/second refill *)
  let limiter = TokenBucket.create ~capacity:5. ~refill_rate:2. in

  Printf.printf "Created limiter: capacity=%.0f, refill_rate=%.0f/s\n"
    (TokenBucket.capacity limiter) (TokenBucket.refill_rate limiter);
  Printf.printf "Starting tokens: %.0f\n" (TokenBucket.available limiter);
  print_newline ();

  (* Consume all tokens rapidly *)
  print_endline "--- Rapid consumption ---";
  for i = 1 to 7 do
    let result = TokenBucket.consume limiter in
    let status = if result then "✓ allowed" else "✗ denied" in
    Printf.printf "  Attempt %d: %s (tokens left: %.2f)\n"
      i status (TokenBucket.available limiter)
  done;
  print_newline ();

  (* Wait for refill *)
  print_endline "--- Waiting 1 second for refill ---";
  Unix.sleepf 1.0;
  Printf.printf "Tokens after 1s: %.2f\n" (TokenBucket.available limiter);
  print_newline ();

  (* Try again *)
  print_endline "--- Post-refill consumption ---";
  for i = 1 to 3 do
    let result = TokenBucket.consume limiter in
    let status = if result then "✓ allowed" else "✗ denied" in
    Printf.printf "  Attempt %d: %s (tokens left: %.2f)\n"
      i status (TokenBucket.available limiter)
  done;
  print_newline ();

  print_endline (String.make 50 '=');
  print_endline "Human intent → OCaml implementation ✓"
