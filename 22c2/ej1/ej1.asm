global agrupar

%define PTR_SIZE 8
%define MSG_TEXT 0
%define MSG_TEXT_LEN 8
%define MSG_TEXT_TAG 16
%define MSG_STRUCT 24
%define MAX_TAGS 4

;########### SECCION DE DATOS
section .data

;########### SECCION DE TEXTO (PROGRAMA)
section .text

extern calloc
extern malloc
extern realloc
extern strcpy
extern strcat
extern strlen

; [rdi] msgArr , [rsi] msgArr_len 
agrupar:
    push rbp
    push r12
    push r13
    push r14
    push r15

    mov r12, rdi
    mov r13, rsi
    ; msgArr -> [r12] , msgArr_len -> [r13]

    mov rdi, MAX_TAGS
    mov rsi, PTR_SIZE
    call calloc
    mov r15, rax
    ; res -> [r15] 

    xor r14, r14 ; r14 es mi contador

.start:
    xor rax, rax
    cmp r14, r13 ; comparo el contador con el msgArr_len
    je .end ;si es igual termina
    xor r8, r8 ; limpio r8
    mov r8b, byte [r12 + MSG_TEXT_TAG] ;en r8 guardo tag del msgArr 
    imul r8, r8, PTR_SIZE
    mov r9, [r15 + r8] ; Accedo al valor en el res[tag]
    test r9, r9 ;checkeo si esta vacio
    jnz .concat ; si no lo esta lo concateno
    mov rdi, [r12 + MSG_TEXT_LEN] ; en rdi guardo la longitud del texto
    inc rdi ; aumento en uno para el valor nulo
    call malloc ; pido memoria || ERROR :: segundo texto en r14 0x04 me da una addr. ya usada
    xor rcx, rcx
    mov [rax], rcx
    xor r8, r8
    mov r8b, byte [r12 + MSG_TEXT_TAG]
    imul r8, r8, PTR_SIZE
    mov [r15 + r8], rax ;el espacio de memoria creada lo guardo en res[tag]
    mov rdi, rax
    mov rsi, [r12 + MSG_TEXT]
    call strcpy
    jmp .next
    
.concat:
    mov rdi, r9
    call strlen
    mov rsi, [r12 + MSG_TEXT_LEN]
    test rsi, rsi
    jz .next
    inc rsi
    add rsi, rax
    ; ERROR :: en segundo texto en r14 en 0x03 me eliminar el texto guardo en [rdi]
    call realloc ; ERROR ::corrupted size vs. prev_size Progrnam received signal SIGABRT, Aborted. (segundo texto, r13 en 0xd)
    mov rdi, r9
    mov rsi, [r12 + MSG_TEXT]
    call strcat
    jmp .next

.next:
    inc r14
    add r12, MSG_STRUCT
    jmp .start 


.end:
    mov rax, r15
    pop r15
    pop r14
    pop r12
    pop r13
    pop rbp
    ret