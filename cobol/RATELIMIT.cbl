      *> Token Bucket Rate Limiter
      *> 
      *> Transpiled from INTENT.md - Human language is the source code.
      *> 
      *> Yes, even COBOL. The language from 1959 that still processes
      *> trillions of dollars in transactions daily. Human intent
      *> transcends all eras.

       IDENTIFICATION DIVISION.
       PROGRAM-ID. RATELIMIT.
       AUTHOR. HUMAN-INTENT.

       DATA DIVISION.
       WORKING-STORAGE SECTION.
       
      *> Token Bucket Configuration
       01 WS-BUCKET.
          05 WS-CAPACITY        PIC 9(5)V99 VALUE 5.00.
          05 WS-REFILL-RATE     PIC 9(5)V99 VALUE 2.00.
          05 WS-TOKENS          PIC 9(5)V99 VALUE 5.00.
          05 WS-LAST-REFILL     PIC 9(8) VALUE 0.
       
      *> Working Variables
       01 WS-WORK-VARS.
          05 WS-CURRENT-TIME    PIC 9(8).
          05 WS-ELAPSED         PIC 9(5)V99.
          05 WS-TOKENS-TO-ADD   PIC 9(5)V99.
          05 WS-NEW-TOKENS      PIC 9(5)V99.
          05 WS-CONSUME-RESULT  PIC 9 VALUE 0.
             88 CONSUME-SUCCESS VALUE 1.
             88 CONSUME-FAILED  VALUE 0.
          05 WS-ATTEMPT         PIC 9(2).
          05 WS-DISPLAY-TOKENS  PIC Z(4)9.99.
       
       01 WS-SEPARATOR          PIC X(50) VALUE ALL "=".

       PROCEDURE DIVISION.
       MAIN-PROCEDURE.
           DISPLAY "Token Bucket Rate Limiter - COBOL Implementation"
           DISPLAY WS-SEPARATOR
           DISPLAY " "
           DISPLAY "Created limiter: capacity=5, refill_rate=2/s"
           
           ACCEPT WS-LAST-REFILL FROM TIME
           MOVE WS-CAPACITY TO WS-TOKENS
           
           MOVE WS-TOKENS TO WS-DISPLAY-TOKENS
           DISPLAY "Starting tokens: " WS-DISPLAY-TOKENS
           
           DISPLAY " "
           DISPLAY "--- Rapid consumption ---"
           PERFORM VARYING WS-ATTEMPT FROM 1 BY 1 
                   UNTIL WS-ATTEMPT > 7
               PERFORM CONSUME-TOKEN
               MOVE WS-TOKENS TO WS-DISPLAY-TOKENS
               IF CONSUME-SUCCESS
                   DISPLAY "  Attempt " WS-ATTEMPT 
                           ": ALLOWED (tokens: " WS-DISPLAY-TOKENS ")"
               ELSE
                   DISPLAY "  Attempt " WS-ATTEMPT 
                           ": DENIED  (tokens: " WS-DISPLAY-TOKENS ")"
               END-IF
           END-PERFORM
           
           DISPLAY " "
           DISPLAY "--- Simulating refill ---"
           ADD 2.00 TO WS-TOKENS
           IF WS-TOKENS > WS-CAPACITY
               MOVE WS-CAPACITY TO WS-TOKENS
           END-IF
           MOVE WS-TOKENS TO WS-DISPLAY-TOKENS
           DISPLAY "Tokens after refill: " WS-DISPLAY-TOKENS
           
           DISPLAY " "
           DISPLAY "--- Post-refill consumption ---"
           PERFORM VARYING WS-ATTEMPT FROM 1 BY 1 
                   UNTIL WS-ATTEMPT > 3
               PERFORM CONSUME-TOKEN
               MOVE WS-TOKENS TO WS-DISPLAY-TOKENS
               IF CONSUME-SUCCESS
                   DISPLAY "  Attempt " WS-ATTEMPT 
                           ": ALLOWED (tokens: " WS-DISPLAY-TOKENS ")"
               ELSE
                   DISPLAY "  Attempt " WS-ATTEMPT 
                           ": DENIED  (tokens: " WS-DISPLAY-TOKENS ")"
               END-IF
           END-PERFORM
           
           DISPLAY " "
           DISPLAY WS-SEPARATOR
           DISPLAY "Human intent -> COBOL implementation (yes, really)"
           
           STOP RUN.

       CONSUME-TOKEN.
      *>   Attempt to consume one token from the bucket
           IF WS-TOKENS >= 1.00
               SUBTRACT 1.00 FROM WS-TOKENS
               SET CONSUME-SUCCESS TO TRUE
           ELSE
               SET CONSUME-FAILED TO TRUE
           END-IF.
