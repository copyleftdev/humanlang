{
  Token Bucket Rate Limiter
  
  Transpiled from INTENT.md - Human language is the source code.
  
  Pascal: The language that taught a generation to program.
  Niklaus Wirth would be proud.
}

{$mode objfpc}
program RateLimiter;

uses
  SysUtils, DateUtils;

type
  TTokenBucket = record
    Capacity: Double;
    RefillRate: Double;
    Tokens: Double;
    LastRefill: TDateTime;
  end;

function CreateBucket(ACapacity, ARefillRate: Double): TTokenBucket;
begin
  if ACapacity <= 0 then
    raise Exception.Create('Capacity must be positive');
  if ARefillRate <= 0 then
    raise Exception.Create('Refill rate must be positive');
    
  Result.Capacity := ACapacity;
  Result.RefillRate := ARefillRate;
  Result.Tokens := ACapacity;  { Start full }
  Result.LastRefill := Now;
end;

procedure Refill(var Bucket: TTokenBucket);
var
  CurrentTime: TDateTime;
  ElapsedSeconds: Double;
  TokensToAdd: Double;
begin
  CurrentTime := Now;
  ElapsedSeconds := SecondSpan(Bucket.LastRefill, CurrentTime);
  
  if ElapsedSeconds > 0 then
  begin
    TokensToAdd := ElapsedSeconds * Bucket.RefillRate;
    Bucket.Tokens := Bucket.Tokens + TokensToAdd;
    if Bucket.Tokens > Bucket.Capacity then
      Bucket.Tokens := Bucket.Capacity;
    Bucket.LastRefill := CurrentTime;
  end;
end;

function Consume(var Bucket: TTokenBucket; Tokens: Double = 1.0): Boolean;
begin
  Refill(Bucket);
  
  if Bucket.Tokens >= Tokens then
  begin
    Bucket.Tokens := Bucket.Tokens - Tokens;
    Result := True;
  end
  else
    Result := False;
end;

function Available(var Bucket: TTokenBucket): Double;
begin
  Refill(Bucket);
  Result := Bucket.Tokens;
end;

{ --- Demonstration --- }

var
  Limiter: TTokenBucket;
  I: Integer;
  Success: Boolean;
  Status: String;

begin
  WriteLn('Token Bucket Rate Limiter - Pascal Implementation');
  WriteLn(StringOfChar('=', 50));
  WriteLn;
  
  { Create a bucket: 5 tokens capacity, 2 tokens/second refill }
  Limiter := CreateBucket(5, 2);
  
  WriteLn(Format('Created limiter: capacity=%.0f, refill_rate=%.0f/s',
                 [Limiter.Capacity, Limiter.RefillRate]));
  WriteLn(Format('Starting tokens: %.0f', [Available(Limiter)]));
  WriteLn;
  
  { Consume all tokens rapidly }
  WriteLn('--- Rapid consumption ---');
  for I := 1 to 7 do
  begin
    Success := Consume(Limiter);
    if Success then
      Status := 'ALLOWED'
    else
      Status := 'DENIED';
    WriteLn(Format('  Attempt %d: %s (tokens left: %.2f)',
                   [I, Status, Available(Limiter)]));
  end;
  WriteLn;
  
  { Wait for refill }
  WriteLn('--- Waiting 1 second for refill ---');
  Sleep(1000);
  WriteLn(Format('Tokens after 1s: %.2f', [Available(Limiter)]));
  WriteLn;
  
  { Try again }
  WriteLn('--- Post-refill consumption ---');
  for I := 1 to 3 do
  begin
    Success := Consume(Limiter);
    if Success then
      Status := 'ALLOWED'
    else
      Status := 'DENIED';
    WriteLn(Format('  Attempt %d: %s (tokens left: %.2f)',
                   [I, Status, Available(Limiter)]));
  end;
  WriteLn;
  
  WriteLn(StringOfChar('=', 50));
  WriteLn('Human intent -> Pascal implementation');
end.
