/*
; Fun with x64 assembly!
;
; Writes a diamond pattern of asterisks to stdout.
; Diamond size (number of rows and columns) may be specified on command line; 
; default size is 21.
; Diamond size must be an odd number, and a command line value will be modified 
; if necssary.
*/

.global	main

.extern get_size

.set DEFAULT_SIZE, 21		/* ; this must be odd */
.set SPACE, 0x20

.data
        oopsie_msg: .asciz "Invalid argument"
        oopsie_len: .long .-oopsie_msg
        size: .quad 0
        buffer_ptr: .quad 0
        /*; size resq 1       */      /* ; this is where we'll store the size */
        /*; buffer_ptr resq 1 */      /* ; this is where we'll store the pointer to the buffer */

.text
main:
        push rbp
        mov rbp, rsp            /* ; copy the initial stack pointer */

        mov     eax, DEFAULT_SIZE     
        call    get_size        /* ; get the size from the command line */
        cmp     eax, 0
        je      .oopsie         /* ; there was a command line parameter, but it wasn't a number */
        movq    [size], rax     /* ; store size in variable */

        sub     rbp, [size]     /* ; allocate buffer on the stack */
        dec     rbp             /* ; leave room for LF as well */
        mov     [buffer_ptr], rsp /* ; store pointer to buffer in variable */
        /* ; calculate_star_positions */
        xor     edx, edx
        mov     rax, [size]
	mov	ecx, 2
	div	ecx		/* ; divide the number of colums by two */
	mov	r14d, eax	/* ; save half-height */
	mov	r12, r14	/* ; initial first star column */
	mov	r13, r14	/* ; initial second star column */
	mov	rdx, [buffer_ptr]	/* ; rdx holds index into buffer */
	mov	r8, 1		/* ; initial line number */
	xor	r9, r9		/* ; initial column number  */
.column:
	cmp	r9, r12		/* ; does this column get the first star? */
	jne	.second_star	/* ; no, see if it gets the second star */
	movb	[rdx], '*'	/* ; add line's first star to the buffer */
	jmp	.next_column	/* ; done with this column */
.second_star:
	cmp	r9, r13		/* ; does this column get a star? */
	jne 	.add_space	/* ; no, it gets a space */
	movb	[rdx], '*'	/* ; add line's second star to the buffer */
	jmp	.next_column	/* ; done with this column */
.add_space:
	movb	[rdx], ' '	/* ; add a space to the buffer */
.next_column:
	inc 	rdx		/* ; advance pointer to next cell in the buffer */
	inc 	r9		/* ; increment column number */
	cmp	r9, [size]	/* ; did we put something in every column? */
	jne	.column		/* ; no, keep adding stars */

	call	write_line
	mov	r9, 0		/* ; reset column number */
	cmp	r8, r14		/* ; are the stars getting closer or farther apart? */
	jle	.contract
	inc	r12		/* ; increment first star column */
	dec	r13		/* ; decrement second star column */
	jmp	.reset
.contract:
	dec	r12		/* ; decrement first star column */
	inc	r13		/* ; increment second star column */
.reset:
	mov	rdx, [buffer_ptr]	/* ; reset rdx to the start of the buffer */
	inc 	r8		/* ; increment line number */
	cmp	r8, [size]	/* ; have we done as many lines as we intend to? */
	jng	.column		/* ; no, keep going */
.done:
        add     rbp, [size]
        inc     rbp
        mov     rsp, rbp
        pop     rbp             /* ; restore the stack and RBP */

	mov	rax, 60		/* ; system call for exit */
	xor	rdi, rdi	/* ; exit code 0 */
	syscall
.oopsie:
        /* ; report error */
        mov 	rax, 1		/* ; system call for write */
	mov	rdi, 1		/* ; file handle for stdout */
	mov	rsi, oopsie_msg	/* ; address of string to write */
	mov	rdx, oopsie_len	/* ; number of bytes to write */
	syscall
        jmp .done

write_line:
	push	r13
	movb	[rdx], 10	/* ; add new line to the end of the buffer */
	mov 	rax, 1		/* ; system call for write */
	mov	rdi, 1		/* ; file handle for stdout */
	mov	rsi, [buffer_ptr]	/* ; address of string to write */
	mov	rdx, [size]	/* ; number of bytes to write */
        inc     rdx             /* ; include that new line */
	syscall			/* ; syscall saves rflags in r13  */
	pop	r13
	ret
