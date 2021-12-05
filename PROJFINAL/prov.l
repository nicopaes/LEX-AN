%option noyywrap
%{
#include <string.h>
#include "hash.h"
#include "prov.tab.h"

extern void yyerror(const char * message);
#define ECHO fwrite( yytext, yyleng, 1, yyout )
extern FILE *yyin;
extern FILE *yyout;

int lineno = 1; // initialize to 1
%}

%%
%option yylineno;

[ \t]		;
[ \n]   { lineno = lineno + 1;}
ENTRADA { return ENTRADA; }
SAIDA { return SAIDA; }
FIM { return FIM; }
END { return END; }
FACA {return FACA; }
INC { return INC; }
ZERA { return ZERA; }
ENQUANTO {return ENQUANTO; }
, {return COMMA; }
"(" {return LPAR; }
")" {return RPAR;}
"=" {return EQUAL;}
[a-zA-Z]([a-zA-Z]|[0-9])* { 
    yylval.name = strdup(yytext);
    insert(yytext,strlen(yytext),0,lineno);
    return id; }
\/\/.* ;
\/\*(.*\n)*.*\*\/ ;
.           {
                const char* errorStr = malloc(50*sizeof(char));
                sprintf(errorStr,"Unexpected char %s",yytext, lineno);
                yyerror(errorStr);
            }
%%

void ret_print(char *token_type){
    printf("yytext: %s\ttoken: %s\tlineno: %d\n", yytext, token_type, lineno);
}

// int main(int argc, char *argv[]){
//     int ntoken;
 
//     // open input file
//     yyin = fopen(argv[1], "r");
    
//     // lexical analysis
//     //yylex();
//     ntoken = yylex();
//     while(ntoken)
//     {
//         printf("%d -> %s \n", ntoken, yytext);
//         ntoken = yylex();
//     }
//     fclose(yyin);
    
//     // // symbol table dump
//     // yyout = fopen("symtab_dump.out", "w");
//     // symtab_dump(yyout);
//     // fclose(yyout);  
    
//     return 0;
// }