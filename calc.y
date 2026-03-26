%{
#include <stdio.h>
#include <stdlib.h>
void yyerror(const char *msg);
int yylex(void);
%}
%union {
int ival;
double fval;
}
%token <ival> NUM
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN
%left PLUS MINUS
%left TIMES DIVIDE
%right UMINUS
%type <ival> expr term factor
%%
program:
expr { printf("Result: %d\n", $1); }
;
expr:
expr PLUS term { $$ = $1 + $3; }
| expr MINUS term { $$ = $1 - $3; }
| term { $$ = $1; }
;
term:
term TIMES factor { $$ = $1 * $3; }
| term DIVIDE factor { $$ = $1 / $3; }
| factor { $$ = $1; }
;
factor:
NUM { $$ = $1; }
| LPAREN expr RPAREN { $$ = $2; }
| MINUS factor %prec UMINUS { $$ = -$2; }
;
%%
void yyerror(const char *msg) {
fprintf(stderr, "Parse error: %s\n", msg);
}
int main(void) {
return yyparse();
}