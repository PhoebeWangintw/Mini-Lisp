%{
    #include<stdio.h>
    #include<stdlib.h>
    extern int yylex(void);
    void yyerror(const char *msg);
    // TODO: creating a linked list to store defined variables
    // TODO: creating a linked list to store AST of the defined function.
    enum ASTType {
        AST_ADD,
        AST_MINUS,
        AST_MUL,
        AST_DIV,
        AST_MOD,
        AST_AND,
        AST_OR,
        AST_NOT,
        AST_FUN,
        AST_IF,
        AST_PNUM,
        AST_PBOOL
    }
    struct ASTNode {
        enum ASTType type;
    };
%}
%union {
    int bool;
    int num;
    char *id;
}
%token<bool> bool-val
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
PROGRAM : STMT STMTS
        ;
STMTS   : STMT
        | /* lambda */
        ;
STMT    : EXP
        | DEF-STMT
        | PRINT-STMT
        | /* lambda */
        ;
PRINT-STMT : '(' print-num EXP ')'
           | '(' print-bool EXP ')'
           ;
EXPS    : EXP
        | /* lambda */
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
        PLUS    : '(' '+' EXP EXPS ')' { //(+ 1 2 3 4) }
                ;
        MINUS   : '(' '-' EXP EXP ')' { //(- 2 1) = 1 }
                ;
        MULTIPLY: '(' '*' EXP EXPS ')' { //(* 1 2 3 4) }
                ;
        DIVID   : '(' '/' EXP EXP ')' { //(/ 3 2) = 1 }
                ;
        MODULUS : '(' mod EXP EXP ')' { //(mod 8 5) = 3 }
                ;
        GREATER : '(' '>' EXP EXP ')' { //(> 1 2)}
                ;
        SMALLER : '(' '<' EXP EXP ')'
                ;
        EQUAL   : '(' '=' EXP EXPS ')'
                ;
LOGICAL-OP: AND-OP
          | OR-OP
          | NOT-OP
          ;
        AND-OP  : '(' and EXP EXPS ')'
                ;
        OR-OP   : '(' or EXP EXPS ')'
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
        FUN-CALL: '(' FUN-EXP PARAM ')'  {}
                | '(' FUN-NAME PARAM ')' {//ex. (fib 1)}
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