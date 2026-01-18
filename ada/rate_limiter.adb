-- Token Bucket Rate Limiter
--
-- Transpiled from INTENT.md - Human language is the source code.
--
-- Ada: The language of aerospace and defense.
-- When lives depend on code, they choose Ada.
-- Human intent, mission-critical reliability.

with Ada.Text_IO;           use Ada.Text_IO;
with Ada.Float_Text_IO;     use Ada.Float_Text_IO;
with Ada.Calendar;          use Ada.Calendar;
with Ada.Strings.Fixed;     use Ada.Strings.Fixed;

procedure Rate_Limiter is

   -- A rate limiter using the token bucket algorithm.
   -- Note: Using a simple record instead of protected type for demo simplicity
   type Token_Bucket is record
      Capacity    : Float;
      Refill_Rate : Float;
      Tokens      : Float;
      Last_Refill : Time;
   end record;

   function Create_Bucket (Cap : Float; Rate : Float) return Token_Bucket is
   begin
      return (Capacity => Cap, Refill_Rate => Rate, Tokens => Cap, Last_Refill => Clock);
   end Create_Bucket;

   procedure Refill (Bucket : in out Token_Bucket) is
      Now     : constant Time := Clock;
      Elapsed : constant Duration := Now - Bucket.Last_Refill;
   begin
      if Elapsed > 0.0 then
         declare
            Tokens_To_Add : constant Float := Float (Elapsed) * Bucket.Refill_Rate;
            New_Tokens    : constant Float := Bucket.Tokens + Tokens_To_Add;
         begin
            if New_Tokens > Bucket.Capacity then
               Bucket.Tokens := Bucket.Capacity;
            else
               Bucket.Tokens := New_Tokens;
            end if;
            Bucket.Last_Refill := Now;
         end;
      end if;
   end Refill;

   procedure Consume (Bucket : in out Token_Bucket; Success : out Boolean) is
   begin
      Refill (Bucket);
      if Bucket.Tokens >= 1.0 then
         Bucket.Tokens := Bucket.Tokens - 1.0;
         Success := True;
      else
         Success := False;
      end if;
   end Consume;

   function Available (Bucket : in out Token_Bucket) return Float is
   begin
      Refill (Bucket);
      return Bucket.Tokens;
   end Available;

   -- Demo limiter: 5 tokens capacity, 2 tokens/second refill
   Limiter : Token_Bucket := Create_Bucket (5.0, 2.0);
   
   procedure Print_Attempt (Num : Integer; Success : Boolean; Tokens : Float) is
      Status : constant String := (if Success then "✓ allowed" else "✗ denied");
   begin
      Put ("  Attempt ");
      Put (Num'Image);
      Put (": ");
      Put (Status);
      Put (" (tokens left: ");
      Put (Tokens, Fore => 1, Aft => 2, Exp => 0);
      Put (")");
      New_Line;
   end Print_Attempt;

   Success : Boolean;

begin
   Put_Line ("Token Bucket Rate Limiter - Ada Implementation");
   Put_Line (50 * "=");
   New_Line;
   
   Put_Line ("Created limiter: capacity=5, refill_rate=2/s");
   Put ("Starting tokens: ");
   Put (Available (Limiter), Fore => 1, Aft => 0, Exp => 0);
   New_Line;
   New_Line;
   
   -- Consume all tokens rapidly
   Put_Line ("--- Rapid consumption ---");
   for I in 1 .. 7 loop
      Consume (Limiter, Success);
      Print_Attempt (I, Success, Available (Limiter));
   end loop;
   New_Line;
   
   -- Wait for refill
   Put_Line ("--- Waiting 1 second for refill ---");
   delay 1.0;
   Put ("Tokens after 1s: ");
   Put (Available (Limiter), Fore => 1, Aft => 2, Exp => 0);
   New_Line;
   New_Line;
   
   -- Try again
   Put_Line ("--- Post-refill consumption ---");
   for I in 1 .. 3 loop
      Consume (Limiter, Success);
      Print_Attempt (I, Success, Available (Limiter));
   end loop;
   New_Line;
   
   Put_Line (50 * "=");
   Put_Line ("Human intent → Ada implementation ✓");
   
end Rate_Limiter;
