#include "ej1.h"

list_t* listNew(){
  list_t* l = (list_t*) malloc(sizeof(list_t));
  l->first=NULL;
  l->last=NULL;
  return l;
}

void listAddLast(list_t* pList, pago_t* data){
    listElem_t* new_elem= (listElem_t*) malloc(sizeof(listElem_t));
    new_elem->data=data;
    new_elem->next=NULL;
    new_elem->prev=NULL;
    if(pList->first==NULL){
        pList->first=new_elem;
        pList->last=new_elem;
    } else {
        pList->last->next=new_elem;
        new_elem->prev=pList->last;
        pList->last=new_elem;
    }
}


void listDelete(list_t* pList){
    listElem_t* actual= (pList->first);
    listElem_t* next;
    while(actual != NULL){
        next=actual->next;
        free(actual);
        actual=next;
    }
    free(pList);
}

// usuario(as input) == cobrador
uint8_t contar_pagos_aprobados(list_t* pList, char* usuario){
    uint8_t res = 0;
    listElem_t* actual = pList->first;
    while(actual !=  NULL){
        pago_t* user =  actual->data;
        char* cobrador = user->cobrador;
        if(user->aprobado && strcmp(*cobrador, usuario) == 0){
            res++;
        }
        actual = actual->next;
    }
    return res;
}

uint8_t contar_pagos_rechazados(list_t* pList, char* usuario){
    uint8_t res = 0;
    listElem_t* actual = pList->first;
    while(actual !=  NULL){
        pago_t* user =  actual->data;
        char* cobrador = user->cobrador;
        if(!(user->aprobado) && strcmp(*cobrador, usuario) == 0){
            res++;
        }
        actual = actual->next;
    }
    return res;
}

pagoSplitted_t* split_pagos_usuario(list_t* pList, char* usuario){
    pagoSplitted_t* res = (pagoSplitted_t*) malloc(sizeof(pagoSplitted_t));
    res->cant_aprobados = contar_pagos_aprobados(pList, usuario);
    res->cant_rechazados = contar_pagos_rechazados(pList, usuario);
    pago_t** arrayAprobados = (pago_t**)calloc(res->aprobados, sizeof(pago_t*));
    pago_t** arrayRechazados = (pago_t**)calloc(res->rechazados, sizeof(pago_t*));
    listElem_t* actual = pList->first;
    uint8_t i,j = 0;
    while(actual != NULL){
        pago_t* user =  actual->data;
        char cobrador = user->cobrador;
        if(user->aprobado && strcmp(cobrador, usuario) == 0){
            arrayAprobados[i] = user;
            i++;
        }else if(!(user->aprobado) && strcmp(cobrador, usuario) == 0){
            arrayRechazados[j] = user;
            j++;
        }
        actual = actual->next;
    }
    res->aprobados = arrayAprobados;
    res->rechazados =  arrayRechazados;
    return res;
}