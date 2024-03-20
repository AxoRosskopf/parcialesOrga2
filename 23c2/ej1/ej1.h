#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <ctype.h>
#include <string.h>
#include <assert.h>
#include <math.h>
#include <stdbool.h>
#include <unistd.h>
#define USE_ASM_IMPL 1

/* Payments */
typedef struct
{
    uint8_t monto; 
    uint8_t aprobado; 
    char *pagador;
    char *cobrador;
} pago_t;
// | start - name(size) |
// struct [ 0 - monto(1) | 1 - aprobado(1) | **padding (6)** | 8 - pagador(8) | 16 - cobrador(8) ]
// size of pago_t =  24 bytes

typedef struct
{
    uint8_t cant_aprobados;
    uint8_t cant_rechazados;
    pago_t **aprobados;
    pago_t **rechazados;
} pagoSplitted_t;
// | start - name(size) |
// struct [ 0 - cant_aprobados(1) | 1 - cant_rechazados(1) | **padding (6)** | 8 - aprovados(8) | 16 - rechazados(8) ]
// size of pagoSplitted_d =  24 bytes

/* List */

typedef struct s_listElem
{
    pago_t *data;
    struct s_listElem *next;
    struct s_listElem *prev;
} listElem_t;
// | start - name(size) |
// struct [ 0 - data(8) | 8 - next(8) | 16 - prev(8) ]
// size of pagoSplitted_d =  24 bytes


typedef struct s_list
{
    struct s_listElem *first;
    struct s_listElem *last;
} list_t;
// | start - name(size) |
// struct [ 0 - first(8) | 8 - last(8) ]
// size of pagoSplitted_d =  16 bytes

/*     FUNTIONS     */

list_t *listNew();
void listAddLast(list_t *pList, pago_t *data);
void listDelete(list_t *pList);

uint8_t contar_pagos_aprobados(list_t *pList, char *usuario);
uint8_t contar_pagos_aprobados_asm(list_t *pList, char *usuario);

uint8_t contar_pagos_rechazados(list_t *pList, char *usuario);
uint8_t contar_pagos_rechazados_asm(list_t *pList, char *usuario);

pagoSplitted_t *split_pagos_usuario(list_t *pList, char *usuario);

pagoSplitted_t *split_pagos_usuario_asm(list_t *pList, char *usuario);
