%{
#include <stdio.h>
#include <stdlib.h>
#include <math.h>                                                           /* For Power Function */
#include <string.h>                                                         /* For String Functions */

int depth = 0;                                                              /* Current Depth of Tree */

/* Write d*2 spaces into dst, return pointer to end */
char *indent(char *dst, int d) {
    for (int i = 0; i < d; i++) { 
        *dst++ = ' '; 
        *dst++ = ' '; 
    }
    return dst;
}

/*
 * Each rule builds its subtree as a string and passes it up to its parent via $$. 
 * The parent then indents the children and places its own label above them.
 */

/* Indent every line of s by depth*2 spaces using indent(), then free s */
char *indent_str(char *s) {
    int lines = 1;
    for (char *p = s; *p; p++) 
        if (*p == '\n') 
            lines++;
    char *out = malloc(strlen(s) + lines * depth * 2 + 1);
    char *dst = indent(out, depth);                                         /* indent first line */
    for (char *p = s; *p; p++) {
        *dst++ = *p;
        if (*p == '\n' && *(p+1))                                           /* indent each next line */
            dst = indent(dst, depth);
    }
    *dst = '\0';
    free(s);
    return out;
}

/* Place label on top, children indented one level below */
char *prepend(const char *label, char *child) {
    depth++;
    child = indent_str(child);
    depth--;
    char *out = malloc(strlen(label) + 1 + strlen(child) + 1);
    sprintf(out, "%s\n%s", label, child);
    free(child);
    return out;
}

/* Concatenate two sibling subtree strings */
char *join(char *a, char *b) {
    char *out = malloc(strlen(a) + strlen(b) + 1);
    sprintf(out, "%s%s", a, b);
    free(a); 
    free(b);
    return out;
}

void yyerror(const char *msg);
int yylex(void);
%}

%union {
int ival;
double fval;
char *sval;                                                                 /* Carry tree text upward */
}

%token <ival> NUM
%token <fval> FNUM                                                          /* FNUM Token */
%token PLUS MINUS TIMES DIVIDE LPAREN RPAREN POWER                          /* Add POWER Token */
%left PLUS MINUS
%left TIMES DIVIDE
%right POWER                                                                /* Set associativity for POWER */
%right UMINUS
%type <sval> expr term factor                                               /* Tree text passed upward */
%%

program:
  program expr '\n'                 { printf("%s\n", $2); free($2); }       /* Print finished tree */
| program '\n'                      { /* ignore empty line */ }
| /* empty */
;

expr:
  expr PLUS term                    { $$ = prepend("expr", join(join($1, strdup("+\n")), $3)); }
| expr MINUS term                   { $$ = prepend("expr", join(join($1, strdup("-\n")), $3)); }
| term                              { $$ = prepend("expr", $1); }
;

term:
  term TIMES factor                 { $$ = prepend("term", join(join($1, strdup("*\n")), $3)); }
| term DIVIDE factor                { $$ = prepend("term", join(join($1, strdup("/\n")), $3)); }
| factor                            { $$ = prepend("term", $1); }
;

factor:
  NUM                               { char b[32]; 
                                      sprintf(b, "%d\n", $1);
                                      $$ = prepend("factor", strdup(b)); }
| FNUM                              { char b[32]; 
                                      sprintf(b, "%g\n", $1);
                                      $$ = prepend("factor", strdup(b)); }
| LPAREN expr RPAREN                { $$ = prepend("factor", $2); }
| MINUS factor %prec UMINUS         { $$ = prepend("factor", join(strdup("-\n"), $2)); }
| factor POWER factor               { $$ = prepend("factor", join(join($1, strdup("^\n")), $3)); }
;
%%

void yyerror(const char *msg) {
    fprintf(stderr, "Parse error: %s\n", msg);
}

int main(void) {
    return yyparse();
}