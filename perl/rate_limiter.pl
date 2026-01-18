#!/usr/bin/env perl
# Token Bucket Rate Limiter
#
# Transpiled from INTENT.md - Human language is the source code.
#
# Perl: The duct tape of the Internet. Still holding things together.

use strict;
use warnings;
use Time::HiRes qw(time sleep);

package TokenBucket;

# A rate limiter using the token bucket algorithm.
#
# Tokens refill at a steady rate up to a maximum capacity.
# Each action consumes one token. If no tokens are available,
# the action is denied.

sub new {
    my ($class, %args) = @_;
    
    my $capacity = $args{capacity} // die "Capacity required";
    my $refill_rate = $args{refill_rate} // die "Refill rate required";
    
    die "Capacity must be positive" unless $capacity > 0;
    die "Refill rate must be positive" unless $refill_rate > 0;
    
    my $self = {
        capacity    => $capacity,
        refill_rate => $refill_rate,
        tokens      => $capacity,  # Start full
        last_refill => time(),
    };
    
    return bless $self, $class;
}

sub _refill {
    my ($self) = @_;
    
    my $now = time();
    my $elapsed = $now - $self->{last_refill};
    
    if ($elapsed > 0) {
        my $tokens_to_add = $elapsed * $self->{refill_rate};
        $self->{tokens} = $self->{tokens} + $tokens_to_add;
        $self->{tokens} = $self->{capacity} if $self->{tokens} > $self->{capacity};
        $self->{last_refill} = $now;
    }
}

sub consume {
    my ($self, $tokens) = @_;
    $tokens //= 1;
    
    $self->_refill();
    
    if ($self->{tokens} >= $tokens) {
        $self->{tokens} -= $tokens;
        return 1;  # true
    }
    return 0;  # false
}

sub available {
    my ($self) = @_;
    $self->_refill();
    return $self->{tokens};
}

sub capacity { shift->{capacity} }
sub refill_rate { shift->{refill_rate} }

package main;

# --- Demonstration ---

print "Token Bucket Rate Limiter - Perl Implementation\n";
print "=" x 50, "\n";
print "\n";

# Create a bucket: 5 tokens capacity, 2 tokens/second refill
my $limiter = TokenBucket->new(capacity => 5, refill_rate => 2);

printf "Created limiter: capacity=%d, refill_rate=%d/s\n",
       $limiter->capacity, $limiter->refill_rate;
printf "Starting tokens: %d\n", $limiter->available;
print "\n";

# Consume all tokens rapidly
print "--- Rapid consumption ---\n";
for my $i (1..7) {
    my $result = $limiter->consume();
    my $status = $result ? "✓ allowed" : "✗ denied";
    printf "  Attempt %d: %s (tokens left: %.2f)\n",
           $i, $status, $limiter->available;
}
print "\n";

# Wait for refill
print "--- Waiting 1 second for refill ---\n";
sleep(1);
printf "Tokens after 1s: %.2f\n", $limiter->available;
print "\n";

# Try again
print "--- Post-refill consumption ---\n";
for my $i (1..3) {
    my $result = $limiter->consume();
    my $status = $result ? "✓ allowed" : "✗ denied";
    printf "  Attempt %d: %s (tokens left: %.2f)\n",
           $i, $status, $limiter->available;
}
print "\n";

print "=" x 50, "\n";
print "Human intent → Perl implementation ✓\n";
