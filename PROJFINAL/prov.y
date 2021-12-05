%{
  #include <stdio.h>
  #include "hash.c"
  #include "prov.tab.h"
  #include <stdlib.h>
  #define YYERROR_VERBOSE 1
  extern char *yytext;
  extern FILE *yyin;
  extern FILE *yyout;
  extern int yyparse();
  extern int yylex();
  extern int lineno;
  extern int yylineno;
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


Program: ENTRADA {change_isEntrada(1);} varlist SAIDA {change_isEntrada(0);} varlist cmds END
{
    printf("Compilação sucesso\n");
    char* idvar = $<name>6;
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
cmds: cmd cmds | cmd 
;
//------------
cmd: ENQUANTO id FACA 
{
    char* idvar = $2;
    push_enq(idvar);
} cmds FIM {push_fim();}
;
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
    printf("INC: %s++\n", idVar);
    push_inc(idVar);

} | ZERA LPAR id RPAR
{
    char* idVar = $3;
    push_zera(idVar);
}
;
%%

int top = 0;
FILE* f1;
char st[50][50];
int bottom = 1;
int isEntrada = 0;
char* retVar;


int main(int argc, char *argv[])
{
    #ifdef YYDEBUG
        yydebug = 0;
    #endif
    // bison -d prov.y && flex prov.l && gcc -o provolone prov.tab.c lex.yy.c && ./provolone teste.prov
    // bison -t -d prov.y && flex -d prov.l && gcc -w -o provolone prov.tab.c lex.yy.c && ./provolone teste.prov
    // bison prov.y && flex prov.l && gcc -w -o provolone prov.tab.c lex.yy.c && ./provolone teste.prov
    // initialize symbol table
	init_hash_table();

    int parse;
    // open input file
    yyin = fopen(argv[1], "r");
    f1 = fopen("output.c","w");
    push_start();

    // sintax analysis
    if(!yyparse())
    {
        printf("Parsing done\n");
        symtab_print();
        push_end();
    }
    else
    {
        printf("Parsing error\n");
        exit(0);
    }

    fclose(yyin);
    fclose(f1);

    return parse;
}


int yyerror(char *s)
{
  //fprintf(stderr, "ERROR: %s\n Line %d\n", s, lineno);
  printf("ERROR: %s\n", s);
  exit(1);
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
    check_wasDclr(var1Name);
    check_wasDclr(var2Name);
    
    fprintf(f1,"    %s = %s;\n",var1Name,var2Name);
}

push_end()
{
    fprintf(f1,"}\n");
}

push_ret(char* varName)
{
    fprintf(f1,"    printf(\"Resultado final %%d\\n\",%s);\n",varName);
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
           if(isEntrada)
           {
                fprintf(f1,"    int %s;\n",varName); 
                fprintf(f1,"    printf(\"Entre com o valor de %s \\n\");\n",varName); 
                fprintf(f1,"    scanf(\"%%d\",&%s);\n",varName); 
                fprintf(f1,"    printf(\"Valor de %s lido %%d\\n\",%s);\n",varName,varName); 
           }
           else
           {
              fprintf(f1,"    int %s = 0;\n",varName);  
           }           
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
    check_wasDclr(varName);
    fprintf(f1,"    %s++;\n",varName);
}

push_zera(char* varName)
{
    fprintf(f1,"    %s=0;\n",varName);
}

push_enq(char* varName)
{
    check_wasDclr(varName);
    fprintf(f1,"    int i = %s;\n", varName);
    fprintf(f1,"    while(i != 0)\n    {\n\n",varName);
}

push_fim()
{
    fprintf(f1,"    i--;\n    }\n");
}

push_retVar(char* varName)
{
    retVar = varName;
}

change_isEntrada(int value)
{
    isEntrada = value;
}

check_wasDclr(char* varName)
{
    list_t* l = lookup(varName);
    if(l == NULL || !l->st_dclr)
    {        
        const char* errorStr = malloc(50*sizeof(char));
        sprintf(errorStr,"Variable %s not declared on line %d",varName, lineno);
        yyerror(errorStr);
    }
}
