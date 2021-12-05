#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "hash.h"
 
void init_hash_table(){
    int i; 
    hash_table = malloc(SIZE * sizeof(list_t*));
    for(i = 0; i < SIZE; i++) hash_table[i] = NULL;
}
 
unsigned int hash(char *key){
    unsigned int hashval = 0;
    for(;*key!='\0';key++) hashval += *key;
    hashval += key[0] % 11 + (key[0] << 3) - key[0];
    return hashval % SIZE;
}
 
void insert(char *name, int len, int type, int lineno){
    unsigned int hashval = hash(name);
    list_t *l = hash_table[hashval];
    
    while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;
    
    /* variable not yet in table */
    if (l == NULL){
        l = (list_t*) malloc(sizeof(list_t));
        strncpy(l->st_name, name, len);  
        /* add to hashtable */
        l->st_type = type;
        l->lines = (RefList*) malloc(sizeof(RefList));
        l->lines->lineno = lineno;
        l->lines->next = NULL;
        l->next = hash_table[hashval];
        l->st_dclr = 0;
        hash_table[hashval] = l; 
        //printf("Inserted %s for the first time at line %d\n", name, lineno); // error checking
    }
    /* found in table, so just add line number */
    else{
        RefList *t = l->lines;
        while (t->next != NULL) t = t->next;
        /* add linenumber to reference list */
        t->next = (RefList*) malloc(sizeof(RefList));
        t->next->lineno = lineno;
        t->next->next = NULL;
        //printf("Found %s again at line %d\n", name,lineno);
    }
}
 
list_t *lookup(char *name){ /* return symbol if found or NULL if not found */
    unsigned int hashval = hash(name);
    list_t *l = hash_table[hashval];
    while ((l != NULL) && (strcmp(name,l->st_name) != 0)) l = l->next;
    return l; // NULL is not found
}

int changeType(char* name, int newType)
{
    list_t* l = lookup(name);
    if(l == NULL) return 0;

    l->st_type = newType;
    return 1;
}

int changeWasDclr(char* name)
{
    list_t* l = lookup(name);
    if(l == NULL) return 0;

    l->st_dclr = 1;
    return 1;
}

/* print to stdout by default */ 
void symtab_dump(FILE * of){  
  int i;
  fprintf(of,"------------ ------ ------------\n");
  fprintf(of,"Name         Type   Line Numbers\n");
  fprintf(of,"------------ ------ -------------\n");
  for (i=0; i < SIZE; ++i){ 
    if (hash_table[i] != NULL){ 
        list_t *l = hash_table[i];
        while (l != NULL){ 
            RefList *t = l->lines;
            fprintf(of,"%-12s ",l->st_name);
            //if (l->st_type == INTEGER) 
            fprintf(of,"%-7s","INT");
            // else if (l->st_type == FLOAT) fprintf(of,"%-7s","FLOAT");
            // else if (l->st_type == STRING) fprintf(of,"%-7s","STRING");
            // else if (l->st_type == ARRAY_TYPE){
            //     fprintf(of,"array of ");
            //     if (l->inf_type == INT_TYPE)           fprintf(of,"%-7s","int");
            //     else if (l->inf_type  == REAL_TYPE)    fprintf(of,"%-7s","real");
            //     else if (l->inf_type  == STR_TYPE)     fprintf(of,"%-7s","string");
            //     else fprintf(of,"%-7s","undef");
            // }
            // else if (l->st_type == FUNCTION_TYPE){
            //     fprintf(of,"%-7s %s","function returns ");
            //     if (l->inf_type == INT_TYPE)           fprintf(of,"%-7s","int");
            //     else if (l->inf_type  == REAL_TYPE)    fprintf(of,"%-7s","real");
            //     else if (l->inf_type  == STR_TYPE)     fprintf(of,"%-7s","string");
            //     else fprintf(of,"%-7s","undef");
            // }
            //else fprintf(of,"%-7s","undef"); // if UNDEF or 0
            while (t != NULL){
                fprintf(of,"%4d ",t->lineno);
            t = t->next;
            }
            fprintf(of,"\n");
            l = l->next;
        }
    }
  }
}

/* print to stdout by default */ 
void symtab_print(){  
  int i;
  printf("------------ ----- ----------  ----------\n");
  printf("Name         Type  WasDclr      Lines\n");
  printf("------------ ----- ----------  ----------\n");
  for (i=0; i < SIZE; ++i){ 
    if (hash_table[i] != NULL){ 
        list_t *l = hash_table[i];
        while (l != NULL){ 
            RefList *t = l->lines;
            printf("%-12s ",l->st_name);
            //if (l->st_type == INTEGER) 
            printf("%-7s","INT");
            // else if (l->st_type == FLOAT) printf("%-7s","FLOAT");
            // else if (l->st_type == STRING) printf("%-7s","STRING");
            // else if (l->st_type == CHAR) printf("%-7s","CHAR");
            // else if (l->st_type == ARRAY_TYPE){
            //     printf("array of ");
            //     if (l->inf_type == INT_TYPE)           printf("%-7s","int");
            //     else if (l->inf_type  == REAL_TYPE)    printf("%-7s","real");
            //     else if (l->inf_type  == STR_TYPE)     printf("%-7s","string");
            //     else printf("%-7s","undef");
            // }
            // else if (l->st_type == FUNCTION_TYPE){
            //     printf("%-7s %s","function returns ");
            //     if (l->inf_type == INT_TYPE)           printf("%-7s","int");
            //     else if (l->inf_type  == REAL_TYPE)    printf("%-7s","real");
            //     else if (l->inf_type  == STR_TYPE)     printf("%-7s","string");
            //     else printf("%-7s","undef");
            // }
            //else printf("%-7s","undef"); // if UNDEF or 0
            if(l->st_dclr)
            {
                printf("TRUE    ");
            }
            else 
            {
                printf("FALSE   ");
            }
            while (t != NULL){
                printf("%4d ",t->lineno);
            t = t->next;
            }
            printf("\n");
            l = l->next;
        }
    }
  }
}