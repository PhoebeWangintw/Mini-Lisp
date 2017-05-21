%{
    #include<stdio.h>
    #include<stdlib.h>
    extern int yylex(void);
    void yyerror(const char *msg);
%}
%union {
    int num;
    char *id;
}
%token bool-val
%token<num> number
%token<id> id
%token mod
%token and
%token or
%token not
%token define
%token fun
%token if
%token print-num
%token print-bool

%left '+' '-'
%left '*' '/' mod
%left and or not
%left '(' ')'
%nonassoc UMINUS
%%
PROGRAM : STMT STMT
        ;
STMT    : EXP
        | DEF-STMT
        | PRINT-STMT
        | /* lambda */
        ;
PRINT-STMT : '(' print-num EXP ')'
           | '(' print-bool EXP ')'
           ;
EXP     : bool-val
        | number
        | VARIABLE
        | NUM-OP
        | LOFICAL-OP
        | FUN-EXP
        | FUN-CALL
        | IF-EXP
        ;
NUM-OP  : PLUS
        | MINUS
        | MULTIPLY
        | DIVID
        | MODULUS
        | GREATER
        | SMALLER
        | EQUAL
        ;
        PLUS    : '(' '+' EXP EXP ')'
                ;
        MINUS   : '(' '-' EXP EXP ')'
                ;
        MULTIPLY: '(' '*' EXP EXP ')'
                ;
        DIVID   : '(' '/' EXP EXP ')'
                ;
        MODULUS : '(' mod EXP EXP ')'
                ;
        GREATER : '(' '>' EXP EXP ')'
                ;
        SMALLER : '(' '<' EXP EXP ')'
                ;
        EQUAL   : '(' '=' EXP EXP ')'
                ;
LOGICAL-OP: AND-OP
          | OR-OP
          | NOT-OP
          ;
        AND-OP  : '(' and EXP EXP ')'
                ;
        OR-OP   : '(' or EXP EXP ')'
                ;
        NOT-OP  : '(' not EXP ')'
                ;
DEF-STMT: '(' define VARIABLE EXP ')'
        ;
        VARIABLE: id
                ;
FUN-EXP : '(' fun FUN_IDs FUN-BODY ')'
        ;
        FUN-IDs : '(' id ')'
                ;
        FUN-BODY: EXP
                ;
        FUN-CALL: '(' FUN-EXP PARAM ')'
                | '(' FUN-NAME PARAM ')'
                ;
        PARAM   : EXP
                ;
        LAST-EXP: EXP
                ;
        FUN-NAME: id
                ;
IF-EXP  : '(' if TEST-EXP THAN-EXP ELSE-EXP ')'
        ;
        TEST-EXP: EXP
                ;
        THEN-EXP: EXP
                ;
        ELSE-EXP: EXP
                ;
%%
void yyerror(const char *msg) {
    fprintf(stderr, "%s\n", msg);
}
int main(int argc, char *argv[]) {
    yyparse();
    return (0);
}