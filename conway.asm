;Can Ozer 2021

myss        SEGMENT PARA STACK 's'
            DW 200 DUP(?)
myss        ENDS

myds        SEGMENT PARA 'd'
myds        ENDS

mycs        SEGMENT PARA 'c'
            ASSUME CS:mycs, DS:myds, SS:myss

;===============================================================================

main proc    far
; init program
    push    ds
    xor     ax, ax
    push    ax
    mov     ax, myds
    mov     ds, ax

; compute and print a(10)
    mov     ax, 10          ; set input parameter
    push    ax              ; put input parameter on stack
    call    far ptr CONWAY  ; compute a(10) on stack
    pop     ax              ; AX = a(10)
    call    PRINTINT        ; print number in AX

    retf
main endp

;===============================================================================

; CONWAY far subroutine
CONWAY proc far
; store modified registers
    push    ax
    push    bx
    push    cx
    push    bp

; get input parameter n from stack
    mov     bp, sp          ; get stack pointer
    add     bp, 12          ; skip 8 bytes from pushes and 4 bytes of far return address
    mov     ax, [bp]        ; AX = n

; case for n = 0
    cmp     ax, 0           ; check for n = 0
    ja      conway1
    mov     ax, 0           ; return 0
    jmp     conway_done

; case for n = 1 or 2
conway1:
    cmp     ax, 2           ; check for n = 1 or 2
    ja      conway3
    mov     ax, 1           ; return 1
    jmp     conway_done

; case for n >= 3
conway3:
    dec     ax              ; AX = n - 1
    push    ax              ; put n - 1 on stack
    call    far ptr CONWAY  ; compute a(n - 1) on stack
    pop     bx              ; BX = a(n - 1)

    push    bx              ; put a(n - 1) on stack
    call    far ptr CONWAY  ; compute a(a(n - 1)) on stack
    pop     cx              ; CX = a(a(n - 1))

    inc     ax              ; AX = n
    sub     ax, bx          ; AX = n - a(n - 1)
    push    ax              ; put n - a(n - 1) on stack
    call    far ptr CONWAY  ; compute a(n - a(n - 1)) on stack
    pop     ax              ; AX = a(n - a(n - 1))

    add     ax, cx          ; AX = a(a(n - 1)) + a(n - a(n - 1))

conway_done:
    mov     [bp], ax        ; put return value on stack

; restore modified registers
    pop     bp
    pop     cx
    pop     bx
    pop     ax
    retf                    ; far return from subroutine
CONWAY endp

;===============================================================================

; subroutine to print number in AX
PRINTINT proc
    cmp     ax, 0           ; check for zero
    jne     PRINTINT_r      ; use recursive version if not zero
    push    ax              ; store register
    mov     al, '0'         ; print zero
    mov     ah, 0eh         ; teletype output
    int     10h             ; BIOS interrupt
    pop     ax              ; restore register
    ret                     ; return from subroutine

PRINTINT_r:
; store modified registers
    push    ax
    push    bx
    push    dx

    mov     dx, 0           ; convert word in AX to double word in DX:AX
    cmp     ax, 0           ; check for zero
    je      PRINTINT_done   ; printing done
    mov     bx, 10          ; decimal base
    div     bx              ; set AX to quotient and DX to remainder
    call    PRINTINT_r      ; recursively print the quotient
    mov     ax, dx          ; set AX to remainder
    add     al, '0'         ; convert number to symbol
    mov     ah, 0eh         ; teletype output
    int     10h             ; BIOS interrupt

PRINTINT_done:
; restore modified registers
    pop     dx
    pop     bx
    pop     ax
    ret                     ; return from subroutine
PRINTINT endp

;===============================================================================

mycs ENDS
     END main
