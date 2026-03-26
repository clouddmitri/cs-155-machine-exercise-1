%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>                                                           /* For Power Function */

void yyerror(const char *msg);
int yylex(void);
%}

%union {
int ival;
double fval;
}

%token <ival> NUM
%token <fval> FNUM                                                          /* FNUM Token */
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN POWER                          /* Add POWER Token */
%left PLUS MINUS
%left TIMES DIVIDE
%right POWER                                                                /* Set associativity for POWER */
%right UMINUS
%type <fval> expr term factor                                               /* Use double instead of int */
%%

program:
program expr '\n'                   { printf("Result: %lf\n", $2); }        /* Prints float */
| program '\n'                      { /* ignore empty line */ }
| /* empty */
;

expr:
expr PLUS term                      { $$ = $1 + $3; }
| expr MINUS term                   { $$ = $1 - $3; }
| term                              { $$ = $1; }
;

term:
term TIMES factor                   { $$ = $1 * $3; }
| term DIVIDE factor                { $$ = $1 / $3; }
| factor                            { $$ = $1; }
;

factor:
NUM                                 { $$ = $1; }
| FNUM                              { $$ = $1; }                                    /* FNUM rule for Factor */
| LPAREN expr RPAREN                { $$ = $2; }
| MINUS factor %prec UMINUS         { $$ = -$2; }
| factor POWER factor               { $$ = (int)pow((double)$1, (double)$3); }      /* Production Rule for POWER */
%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

int main(void) {
    return yyparse();
}