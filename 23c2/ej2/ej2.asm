section .rodata
align 16
verify: times 4 db 0, 0, 0, -16

;########### SECCION DE TEXTO (PROGRAMA)
section .text
global mezclarColores
;void mezclarColores( uint8_t *X, uint8_t *Y, uint32_t width, uint32_t height);
; X [rdi]
; Y [rsi]
; width [rdx]
; height [rcx]
mezclarColores:
    push rbp
    mov rbp, rsp
    mov r8, rdx
    movdqa xmm6, [verify]

.for:
    por xmm0, xmm0
    por xmm1, xmm1
    movq xmm0, [rdi]
    shufpd xmm0, xmm0, 0b01
    movq xmm1, [rdi + 64]
    paddd xmm0, xmm1
    

    ; xmm0 = [ 0 : R : G : B | 0 : R : G : B | 0 : R : G : B | 0 : R : G : B ]

    pslld xmm0, 8 ; xmm0 = [ 0 : R : G : B | 0 : R : G : B | 0 : R : G : B | 0 : R : G : B ]
    movdqa xmm7, xmm0 ; xmm1 = xmm0
    pslld xmm7, 24
    psrld xmm7, 8
    movdqa xmm2, xmm0
    psrld xmm2, 8
    paddd xmm7, xmm2 ; xmm7 = [ 0 : B : R : G | 0 : B : R : G | 0 : B : R : G | 0 : B : R : G ]




    movdqa xmm1, xmm0
    ; [ 0 : G : B : 0 | 0 : G : B : 0 | 0 : G : B : 0 | 0 : G : B : 0 ]
    ; Quiero hacer esta mascara para comparar si cae en la primera guarda    
    psrld xmm1, 16 ; xmm1 = ...| G : B : 0 : 0 |...
    pslld xmm1, 8 ; xmm1 = ...| 0 : G : B : 0|... 

    ; [ 0 : R : G : B | 0 : R : G : B | 0 : R : G : B | 0 : R : G : B ]
    ; Quiero hacer esta mascara para comparar si cae en la segunda guarda 
    movdqa xmm2, xmm0 ; xmm2 = ...| 0 : R : G : B |...
    pslld xmm2,8 ; xmm2 = ...| 0 : 0 : R : G |...

    ; Copio xmm0 a xmm3,4,5
    movdqa xmm3, xmm0 ; xmm3 = xmm0
    movdqa xmm4, xmm0 ; xmm4 = xmm0
    movdqa xmm5, xmm0 ; xmm5 = xmm0

    ; En xmm3 comparo los valores de xmm1 ...| 0 < 0 : G < R : B < G : 0 < B |... ?
    pcmpgtb xmm3, xmm1 ; si es greater that en todos los posibles casos en xmm3 quedaria igual ...| 0000 : 1111 : 1111 : 1111 |..
    phaddd xmm3, xmm3 ; al sumarlo por cada double sera ...| 1111 + 1111 + 1111 |...
    phaddd xmm3, xmm3 
    phaddd xmm3, xmm3
    phaddd xmm3, xmm3 
    pslld xmm3, 16
    ; Si existe un  caso que R > G > B su valor por cada double word en xmm3 sera la suma de tres 0xFFFF

    pcmpeqd xmm3, xmm6



    movdqa xmm3, xmm0

    pcmpgtw xmm3, xmm2
    pand xmm5, xmm3





    paddd xmm5, xmm4
    movq [rsi], xmm5
    psrldq xmm5, 8
    movq [rsi + 64], xmm5

    sub rdx, 4
    cmp rdx, 0
    je .next_fila
    jne .next_columna

.next_columna:
    add rdi, 128
    add rsi, 128
    jmp .for

.next_fila:
    sub rcx, 1
    cmp rcx, 0
    je .end
    add rdi, 128
    add rsi, 128
    jmp .for


.end:
    pop rbp
    ret

