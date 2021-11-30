#define LCURLY 257
#define RCURLY 258
#define LBRAC 259
#define RBRAC 260
#define COMMA 261
#define COLON 262
#define VTRUE 263
#define VFALSE 264
#define VNULL 265
#define STRING 266
#define DECIMAL 267
#ifdef YYSTYPE
#undef  YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
#endif
#ifndef YYSTYPE_IS_DECLARED
#define YYSTYPE_IS_DECLARED 1
typedef union {
  char *string;
  double decimal;
} YYSTYPE;
#endif /* !YYSTYPE_IS_DECLARED */
extern YYSTYPE yylval;
