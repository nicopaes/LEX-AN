%{
  #include <stdio.h>
  #include "hash.c"
  #include "prov.tab.h"
  #include <stdlib.h>
  extern char *yytext;
  extern FILE *yyin;
  extern FILE *yyout;
  extern int yyparse();
  extern int yylex();
  extern int lineno;
  %}
%start Program
%token ENTRADA
%token id
%token SAIDA
%token FIM
%token FACA
%token INC
%token ZERA
%token ENQUANTO
%token COMMA
%token LPAR
%token RPAR
%token EQUAL

%type <name> id
%union 
{
    char* name;
}
%%


Program: ENTRADA varlist  SAIDA varlist cmds FIM
{
    printf("Compilação sucesso\n");
    push();
};
//------------ TODO AIDA varlist{push_var();}
varlist: id COMMA varlist | id 
{    
    char* idvar = $1;
    printf("----->>>>>>ID %s\n", idvar);
}
;
//------------
cmds: cmd cmds | cmd
;
//------------
cmd: ENQUANTO id FACA cmds FIM
{
    printf("cmd1\n");
    push_s("cmd1\n");
};
//------------
cmd: id EQUAL id {push_s("Attrib\n");}| INC LPAR id RPAR | ZERA LPAR id RPAR
;
%%

int top = 0;
FILE* f1;
int main(int argc, char *argv[])
{
    #ifdef YYDEBUG
        yydebug = 1;
    #endif
    // bison -d prov.y && flex prov.l && gcc -o provolone prov.tab.c lex.yy.c && ./provolone teste.prov

    // initialize symbol table
	init_hash_table();

    int parse;
    // open input file
    yyin = fopen(argv[1], "r");
    f1 = fopen("output","w");
    
    // sintax analysis
    if(!yyparse())
    {
        printf("Parsing done\n");
    }
    else
    {
        printf("Parsing error\n");
    }

    fclose(yyin);
    fclose(f1);

    return parse;
}


int yyerror(char *s)
{
  fprintf(stderr, "error: %s\n Line %d\n", s, lineno);
}

push()
{
    fprintf(f1,"%s\n",yytext);
}

push_s(char* s)
{
    fprintf(f1,"%s\n",s);
}

push_var()
{ 
    fprintf(f1,"int %s;\n",yytext);
}

