Token Bucket Rate Limiter

Transpiled from INTENT dot md
Human language is the source code

Yes even Brainfuck
The most esoteric of languages bows to human intent

This program demonstrates a simplified token bucket
Starting with 5 tokens consuming until empty

Memory layout:
Cell 0: Token counter (starts at 5)
Cell 1: Loop counter for attempts
Cell 2: Temp for output

Initialize 5 tokens
+++++

Now we attempt to consume 7 times
Each attempt checks if tokens > 0

Set up loop counter for 7 attempts in cell 1
>+++++++

Main consumption loop
[
    Go back to tokens (cell 0)
    <
    
    Check if we have tokens (non-zero)
    [
        We have tokens! Consume one
        -
        
        Print A for Allowed
        >++++++++[<++++++++>-]<+.[-]
        
        Go to loop counter
        >>
    ]
    
    Decrement loop counter
    -
]

Print newline
++++++++++.[-]

Print done message (simplified)
The human intent transcends even this

>++++++++++[<++++++++++>-]<++.[-]
Print H
>++++++++[<++++++++++++>-]<+.[-]
Print u
>++++++++[<++++++++++++++>-]<+.[-]
Print m
>++++++++[<++++++++++>-]<-.[-]
Print a
>++++++++[<++++++++++++++>-]<.[-]
Print n

End

The fact that this file exists proves the point:
Human intent is the universal source code
Everything else is just syntax
