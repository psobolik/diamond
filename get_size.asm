; Defines a function to get an integer from the command line.
; Value is returned in eax, which is only changed if there's a command line 
; argument. Return value will always be odd.
; Eax is set to 0 if there's an argument but it's invalid.

global get_size

get_size:
        push rbx
        push rcx
        push rdx

        mov rbx, [rbp + 8]      ; argc
        cmp rbx, 1
        je .exit                ; no command line, leave eax as is

        xor eax, eax
        mov rsi, [rbp + 8 + 8 + 8] ; RSI is pointer to argv[1]
        mov rcx, 10             ; multiplier
.loop:
        mov bl, byte [rsi]
        test bl, bl
        jz .done                ; EOS
        sub bl, '0'             ; convert ASCII to decimal
        cmp bl, 0
        jl .oopsie
        cmp bl, 9
        jg .oopsie
        xor edx, edx
        mul rcx                 ; multiply EAX x 10
        add ax, bx              ; add in ones
        inc rsi                 ; look at next byte
        jmp .loop
.oopsie:
        mov eax, 0
        jmp .exit
.done:
        or eax, 1                ; make the result odd
.exit:
        pop rdx
        pop rcx
        pop rbx

        ret
