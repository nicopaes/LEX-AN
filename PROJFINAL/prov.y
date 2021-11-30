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
%right EQUAL
%token END

%type <name> id
%union 
{
    char* name;
}
%%


Program: ENTRADA varlist SAIDA varlist cmds END
{
    printf("Compilação sucesso\n");
    char* idvar = $<name>4;
    push_ret(idvar);
};
//------------ TODO AIDA varlist{push_var();}
varlist: id 
{    
    char* idvar = $1;
    printf("----->>>>>>ID %s\n", idvar);
    push_var(idvar);
    //$$ = $1
} COMMA varlist | id 
{    
    char* idvar = $1;
    printf("----->>>>>>ID %s\n", idvar);
    push_var(idvar);
    //$$ = $1
}
;
//------------
cmds: cmd 
{
    printf("KAKAKAKKAKAKA\n\n");
} cmds | cmd

;
//------------
cmd: ENQUANTO id FACA cmds FIM
{
    char* idvar = $2;
    push_enq(idvar);
};
//------------
cmd: id EQUAL id 
{
    char* id1var = $1;
    char* id2var = $3;
    printf("ATTRIB: %s = %s\n", id1var,id2var);
    push_attrib(id1var,id2var);

} | INC LPAR id RPAR
{
    char* idVar = $3;
    push_inc(idVar);

} | ZERA LPAR id RPAR
{
    char* idVar = $3;
    push_inc(idVar);
}
;
%%

int top = 0;
FILE* f1;
char st[50][50];
int bottom = 1;
int needToClose = 0;

int main(int argc, char *argv[])
{
    #ifdef YYDEBUG
        yydebug = 1;
    #endif
    // bison -d prov.y && flex prov.l && gcc -o provolone prov.tab.c lex.yy.c && ./provolone teste.prov
    // bison -t -d prov.y && flex -d prov.l && gcc -w -o provolone prov.tab.c lex.yy.c && ./provolone teste.prov
    // initialize symbol table
	init_hash_table();

    int parse;
    // open input file
    yyin = fopen(argv[1], "r");
    f1 = fopen("output","w");
    push_start();

    // sintax analysis
    if(!yyparse())
    {
        printf("Parsing done\n");
        push_end();
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

push_attrib(char* var1Name, char* var2Name)
{
    fprintf(f1,"    %s = %s;\n",var1Name,var2Name);
}

push_end()
{
    fprintf(f1,"}\n");
}

push_ret(char* varName)
{
    fprintf(f1,"    return %s;\n",varName);
}

push_start()
{
    fprintf(f1,"#include <stdio.h>\n\nint main()\n{\n");
}

push_var(char* varName)
{ 
    printf("VAR NAME : %s\n", varName);
    list_t* l = lookup(varName);
    if(l != NULL)
    {
        if(l->st_dclr == 0)
        {
           fprintf(f1,"    int %s = 0;\n",varName); 
        //    fprintf(f1,"    int %s;\n",varName); 
        //    fprintf(f1,"    printf(\"Entre com o valor de %s\");\n",varName); 
        //    fprintf(f1,"    scanf(\"%d\",&%s);\n",varName); 
        }
        
        if(changeWasDclr(varName))
        {
            printf("Variable declared\n");
        }
    }
    else
    {
        printf("ERROR\n");
    }
}

push_inc(char* varName)
{
    fprintf(f1,"    %s++;\n",varName);
    if(needToClose == 1)
    {
        fprintf(f1,"    }\n");
        needToClose = 0;
    }
}

push_zera(char* varName)
{
    fprintf(f1,"    %s=0;\n",varName);
    if(needToClose == 1)
    {
        fprintf(f1,"    }\n");
        needToClose = 0;
    }
}

push_enq(char* varName)
{
    fprintf(f1,"    for(int i = 0;i < %s;i++)\n    {\n",varName);
    if(needToClose == 1)
    {
        fprintf(f1,"    }\n");
        needToClose = 0;
    }
    needToClose = 1;
}
