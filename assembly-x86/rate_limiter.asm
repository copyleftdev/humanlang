; Token Bucket Rate Limiter
;
; Transpiled from INTENT.md - Human language is the source code.
;
; x86-64 Assembly (Linux, NASM syntax)
; Yes, really. Human intent can even become assembly.
; This is a simplified demonstration using integer tokens.

section .data
    ; Messages
    title_msg:      db "Token Bucket Rate Limiter - x86-64 Assembly", 10, 0
    title_len:      equ $ - title_msg
    
    separator:      db "==================================================", 10, 0
    sep_len:        equ $ - separator
    
    created_msg:    db "Created limiter: capacity=5, refill_rate=2/s", 10, 0
    created_len:    equ $ - created_msg
    
    start_msg:      db "Starting tokens: 5", 10, 10, 0
    start_len:      equ $ - start_msg
    
    rapid_msg:      db "--- Rapid consumption ---", 10, 0
    rapid_len:      equ $ - rapid_msg
    
    allowed_msg:    db "  Attempt: ALLOWED", 10, 0
    allowed_len:    equ $ - allowed_msg
    
    denied_msg:     db "  Attempt: DENIED", 10, 0
    denied_len:     equ $ - denied_msg
    
    done_msg:       db 10, "Human intent -> Assembly (yes, even this)", 10, 0
    done_len:       equ $ - done_msg
    
    newline:        db 10, 0
    
    ; Token bucket state (simplified integer version)
    capacity:       dq 5
    tokens:         dq 5    ; Start full

section .text
    global _start

; Write string to stdout
; rdi = pointer to string
; rsi = length
print:
    push rax
    push rdi
    push rsi
    push rdx
    
    mov rdx, rsi        ; length
    mov rsi, rdi        ; buffer
    mov rdi, 1          ; stdout
    mov rax, 1          ; sys_write
    syscall
    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

; Consume one token
; Returns: rax = 1 if success, 0 if failed
consume:
    mov rax, [tokens]
    cmp rax, 0
    jle .denied
    
    dec rax
    mov [tokens], rax
    mov rax, 1          ; success
    ret
    
.denied:
    xor rax, rax        ; failure
    ret

_start:
    ; Print title
    mov rdi, title_msg
    mov rsi, title_len
    call print
    
    mov rdi, separator
    mov rsi, sep_len
    call print
    
    ; Print created message
    mov rdi, created_msg
    mov rsi, created_len
    call print
    
    mov rdi, start_msg
    mov rsi, start_len
    call print
    
    ; Print rapid consumption header
    mov rdi, rapid_msg
    mov rsi, rapid_len
    call print
    
    ; Try to consume 7 times
    mov r12, 7          ; counter
    
.consume_loop:
    call consume
    test rax, rax
    jz .print_denied
    
    ; Print allowed
    mov rdi, allowed_msg
    mov rsi, allowed_len
    call print
    jmp .continue
    
.print_denied:
    mov rdi, denied_msg
    mov rsi, denied_len
    call print
    
.continue:
    dec r12
    jnz .consume_loop
    
    ; Print separator and done message
    mov rdi, separator
    mov rsi, sep_len
    call print
    
    mov rdi, done_msg
    mov rsi, done_len
    call print
    
    ; Exit
    mov rax, 60         ; sys_exit
    xor rdi, rdi        ; status 0
    syscall
