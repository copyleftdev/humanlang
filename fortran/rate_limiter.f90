! Token Bucket Rate Limiter
!
! Transpiled from INTENT.md - Human language is the source code.
!
! Fortran: The language that sent rockets to the moon.
! Still relevant. Still gets the intent.

module token_bucket_mod
    implicit none
    private
    public :: TokenBucket, create_bucket, consume, available

    type :: TokenBucket
        real(8) :: capacity
        real(8) :: refill_rate
        real(8) :: tokens
        real(8) :: last_refill
    end type TokenBucket

contains

    ! Get current time in seconds
    function get_time() result(t)
        real(8) :: t
        integer :: count, count_rate
        call system_clock(count, count_rate)
        t = real(count, 8) / real(count_rate, 8)
    end function get_time

    ! Create a new token bucket
    function create_bucket(capacity, refill_rate) result(bucket)
        real(8), intent(in) :: capacity, refill_rate
        type(TokenBucket) :: bucket

        if (capacity <= 0.0d0) stop "Capacity must be positive"
        if (refill_rate <= 0.0d0) stop "Refill rate must be positive"

        bucket%capacity = capacity
        bucket%refill_rate = refill_rate
        bucket%tokens = capacity  ! Start full
        bucket%last_refill = get_time()
    end function create_bucket

    ! Refill tokens based on elapsed time
    subroutine refill(bucket)
        type(TokenBucket), intent(inout) :: bucket
        real(8) :: now, elapsed, tokens_to_add

        now = get_time()
        elapsed = now - bucket%last_refill

        if (elapsed > 0.0d0) then
            tokens_to_add = elapsed * bucket%refill_rate
            bucket%tokens = min(bucket%capacity, bucket%tokens + tokens_to_add)
            bucket%last_refill = now
        end if
    end subroutine refill

    ! Attempt to consume tokens
    function consume(bucket, tokens) result(success)
        type(TokenBucket), intent(inout) :: bucket
        real(8), intent(in), optional :: tokens
        logical :: success
        real(8) :: n

        n = 1.0d0
        if (present(tokens)) n = tokens

        call refill(bucket)

        if (bucket%tokens >= n) then
            bucket%tokens = bucket%tokens - n
            success = .true.
        else
            success = .false.
        end if
    end function consume

    ! Get available tokens
    function available(bucket) result(tokens)
        type(TokenBucket), intent(inout) :: bucket
        real(8) :: tokens

        call refill(bucket)
        tokens = bucket%tokens
    end function available

end module token_bucket_mod

! --- Demonstration ---

program rate_limiter
    use token_bucket_mod
    implicit none

    type(TokenBucket) :: limiter
    logical :: result
    integer :: i
    character(len=50) :: separator

    separator = repeat("=", 50)

    print *, "Token Bucket Rate Limiter - Fortran Implementation"
    print *, separator
    print *

    ! Create a bucket: 5 tokens capacity, 2 tokens/second refill
    limiter = create_bucket(5.0d0, 2.0d0)

    print '(A,I0,A,I0,A)', " Created limiter: capacity=", int(limiter%capacity), &
                          ", refill_rate=", int(limiter%refill_rate), "/s"
    print '(A,I0)', " Starting tokens: ", int(available(limiter))
    print *

    ! Consume all tokens rapidly
    print *, "--- Rapid consumption ---"
    do i = 1, 7
        result = consume(limiter)
        if (result) then
            print '(A,I0,A,F5.2,A)', "   Attempt ", i, ": ALLOWED (tokens: ", available(limiter), ")"
        else
            print '(A,I0,A,F5.2,A)', "   Attempt ", i, ": DENIED  (tokens: ", available(limiter), ")"
        end if
    end do
    print *

    ! Wait for refill (simulate with sleep)
    print *, "--- Waiting 1 second for refill ---"
    call sleep(1)
    print '(A,F5.2)', " Tokens after 1s: ", available(limiter)
    print *

    ! Try again
    print *, "--- Post-refill consumption ---"
    do i = 1, 3
        result = consume(limiter)
        if (result) then
            print '(A,I0,A,F5.2,A)', "   Attempt ", i, ": ALLOWED (tokens: ", available(limiter), ")"
        else
            print '(A,I0,A,F5.2,A)', "   Attempt ", i, ": DENIED  (tokens: ", available(limiter), ")"
        end if
    end do

    print *
    print *, separator
    print *, "Human intent -> Fortran implementation ✓"

end program rate_limiter
