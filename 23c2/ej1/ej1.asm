; pago_t
%define PAGO_T_MONTO 0
%define PAGO_T_APROBADO 1
%define PAGO_T_PAGADOR 8
%define PAGO_T_COBRADOR 16
%define SIZE_PAGO_T 24

; pagoSplitted_d 
%define SPLITTED_T_CANT_APRO 0
%define SPLITTED_T_CANT_RECH 1
%define SPLITTED_T_APROBADOS 8
%define SPLITTED_T_RECHAZADOS 16
%define SIZE_SPLITTED_T 24

; listElem_t
%define LIST_ELEM_DATA 0
%define LIST_ELEM_NEXT 8
%define LIST_ELEM_PREV 16
%define SIZE_LIST_ELEM 24

; list_t
%define LIST_FIRST 0
%define LIST_LAST 8
%define SIZE_LIST 16

; Auxiliar Values
%define NULL 0
%define FALSE 0
%define TRUE 1
%define STRCMP_TRUE 1
%define SIZE_POINTER 8

section .text
global contar_pagos_aprobados_asm
global contar_pagos_rechazados_asm
global split_pagos_usuario_asm

extern malloc
extern free
extern calloc
extern strcmp


;########### SECCION DE TEXTO (PROGRAMA)

; uint8_t contar_pagos_aprobados_asm(list_t* pList, char* usuario);
; pList [rdi], usuario [rsi]
contar_pagos_aprobados_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    xor r13, r13 ; res(r13) = 0
    mov rdx, [rdi + LIST_FIRST] ; asign to rdx(actual) = pList->first; 
    test rdx, rdx;
    jz .end_aprobados

.start_while_aprob:
    mov rcx, [rdx + LIST_ELEM_DATA] ; asign to rcx(user) = actual->data 
    cmp byte [rcx + PAGO_T_APROBADO] , TRUE ; 
    jne .next_iteration_aprob
    mov r8, [rcx +  PAGO_T_COBRADOR]
    mov r9, rdi
    mov rdi, r8
    call strcmp
    mov rdi, r9
    cmp rax, STRCMP_TRUE
    jne .next_iteration_aprob
    inc r13

.next_iteration_aprob:
    mov rdx, [rdx + LIST_ELEM_NEXT]
    test rdx, rdx
    jnz .start_while_aprob


.end_aprobados:
    mov rax, r13
    pop r12
    pop r13
    pop rbp
    ret





; uint8_t contar_pagos_rechazados_asm(list_t* pList, char* usuario);
contar_pagos_rechazados_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    xor r13, r13
    mov rdx, [rdi+ LIST_FIRST]
    test rdx, rdx
    jz .end_rechazados

.start_while_rech:
    mov rcx, [rdx + LIST_ELEM_DATA] ; asign to rcx(user) = actual->data 
    cmp byte [rcx + PAGO_T_APROBADO] , FALSE 
    jne .next_iteration_rech
    mov r8, [rcx +  PAGO_T_COBRADOR]
    mov r9, rdi
    mov rdi, r8
    call strcmp
    mov rdi, r9
    cmp rax, STRCMP_TRUE
    jne .next_iteration_rech
    inc r13

.next_iteration_rech:
    mov rdx, [rdx + LIST_ELEM_NEXT]
    test rdx, rdx
    jnz .start_while_rech

.end_rechazados:
    mov rax, r13
    pop r12
    pop r13
    pop rbp
    ret


; pagoSplitted_t* split_pagos_usuario_asm(list_t* pList, char* usuario);
split_pagos_usuario_asm:
    push rbp
    mov rbp, rsp
    push r12
    push r13
    push r14 ; pointer to struct

    ; Reservo espacio para pagoSplitted_t Struct
    mov r12, rdi
    mov rdi, SIZE_SPLITTED_T
    call malloc
    mov r14, rax ; en R14 va a estar el puntero al struct
    mov rdi, r12 ; restauro lel valor de rdi

    ;    Reservo memoria para los arrays
    ; Array de Aprobado
    call contar_pagos_aprobados_asm ; cuento la cantidad de aprobados
    mov [r14 + SPLITTED_T_CANT_APRO], ax ; guardo el resultado en la struct
    mov r12, rdi
    mov r13, rsi
    mov rdi, rax 
    mov rsi, SIZE_POINTER
    call calloc ; reservo memoria para el array de aprobados
    mov [r14 + SPLITTED_T_APROBADOS], rax ; guardo el puntero en memoria
    mov rdi, r12
    mov rsi, r13

    ; Array de Rechazado (idem a Aprovado)
    call contar_pagos_rechazados_asm
    mov [r14 + SPLITTED_T_CANT_RECH], ax
    mov r12, rdi
    mov r13, rsi
    mov rdi, rax
    mov rsi, SIZE_POINTER
    call calloc
    mov [r14 + SPLITTED_T_APROBADOS], rax
    mov rdi, r12
    mov rsi, r13

    ; Itero por cada listElem para completar las arrays
    mov rdx, [rdi + LIST_FIRST]
    mov r9, [r14 + SPLITTED_T_APROBADOS]
    mov r13, [r14 + SPLITTED_T_RECHAZADOS]
    test rdx, rdx
    jz .end

.start_while:
    mov rcx, [rdx + LIST_ELEM_DATA]
    mov r8, [rcx + PAGO_T_COBRADOR]
    mov r12, rdi
    mov rdi, r8
    call strcmp
    mov rdi, r12
    cmp rax, STRCMP_TRUE
    jne .next_it
    cmp byte [rcx + PAGO_T_APROBADO], TRUE
    jne .es_rechazado
    test r9, r9 
    jz .next_it
    mov [r9], rcx
    add r9, SIZE_POINTER

.next_it:
    mov rdx, [rdx + LIST_ELEM_NEXT]
    test rdx, rdx
    jnz .start_while
    jz .end

.es_rechazado:
    test r13, r13
    jz .next_it
    mov [r13], rcx
    add r13, SIZE_POINTER
    jmp .next_it

.end:
    mov rax, r14
    pop r14
    pop r12
    pop r13
    pop rbp
    ret
