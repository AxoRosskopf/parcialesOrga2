#include "ej1.h"

char** agrupar_c(msg_t* msgArr, size_t msgArr_len){
    char** res = (char**)calloc(MAX_TAGS, sizeof(char*));
    for (size_t i = 0; i < msgArr_len ; i++){
        size_t msgLenght = msgArr[i].text_len+1;
        size_t tagMsg = msgArr[i].tag;
        char* textMsg = msgArr[i].text;
        if(!res[tagMsg]){
            res[tagMsg] = (char*)malloc(msgLenght);
            strcpy(res[tagMsg], textMsg);
        }else{
            res[msgArr[i].tag] = (char*)realloc(res[tagMsg],strlen(res[tagMsg])+ msgLenght);
            strcat(res[tagMsg], textMsg);
        }
    }
    return res;
}
