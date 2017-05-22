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
        AST_GREATER,
        AST_SMALLER,
        AST_EQUAL,
        AST_FUN,
        AST_IF,
        AST_PNUM,
        AST_PBOOL,
        AST_NUM,
        AST_ID,
        AST_BOOL
    }

    struct ASTNode {
        enum ASTType type;
    };    

    struct ASTArithmatic {
        enum ASTType type;
        struct ASTNode *lhs, *rhs;
    };

    struct ASTVal {
        // for terminal.
        enum ASTType type;
        int num;
        char *val;
    };
    
    struct fun {
        char *name;
        int paramNum;
    };

    struct Defined{
        char *id;
        struct Exp *exp;
        struct Defined *next;
    };
%}
%union {
    char *bool;
    int num;
    char *id;
    struct Defined *defined;
    struct ASTNode *node;
}
%token<bool> bool-val
%token<num> number
%token<id> id
%token mod
%token and
%token or
%token not
%token<defined> define
%token fun
%token if
%token print-num
%token print-bool

%type<node> STMT STMTS EXP EXPS


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
PRINT-STMT: '(' print-num EXP ')'
          | '(' print-bool EXP ')'
          ;
EXPS    : EXP
        | /* lambda */
        ;
EXP     : bool-val {
            struct ASTVal *v = (struct ASTVal *)malloc(sizeof(struct ASTVal));
            v->type = AST_NUM;
            v->val = $1;
            $$ = (struct ASTNode *)v;
        }
        | number  {
            struct ASTVal *v = (struct ASTVal *)malloc(sizeof(struct ASTVal));
            v->type = AST_NUM;
            v->num = $1;
            $$ = (struct ASTNode *)v;
        }
        | VARIABLE {
            $$ = $1;
        }
        | NUM-OP {
            $$ = $1;
        }
        | LOFICAL-OP {
            $$ = $1;
        }
        | FUN-EXP {
            $$ = $1;
        }
        | FUN-CALL {
            $$ = $1;
        }
        | IF-EXP {
            $$ = $1;
        }
        ;
NUM-OP  : PLUS {
            $$ = $1;
        }
        | MINUS {
            $$ = $1;
        }
        | MULTIPLY {
            $$ = $1;
        }
        | DIVID {
            $$ = $1;
        }
        | MODULUS {
            $$ = $1;
        }
        | GREATER {
            $$ = $1;
        }
        | SMALLER {
            $$ = $1;
        }
        | EQUAL {
            $$ = $1;
        }
        ;
        PLUS    : '(' '+' EXP EXPS ')' { 
                    // (+ 1 2 3 4) 
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_ADD;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        MINUS   : '(' '-' EXP EXP ')' { 
                    // (- 2 1) = 1 
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_MINUS;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        MULTIPLY: '(' '*' EXP EXPS ')' { 
                    // (* 1 2 3 4) 
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_MUL;
                    a->lhs = $3;
                    a->rhs = $4;$$ = (struct ASTNode *)a;
                }
                ;
        DIVID   : '(' '/' EXP EXP ')' { 
                    // (/ 3 2) = 1 
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_DIV;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        MODULUS : '(' mod EXP EXP ')' {
                    // (mod 8 5) = 3 
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_MOD;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                 }
                ;
        GREATER : '(' '>' EXP EXP ')' { 
                    // (> 1 2)
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_GREATER;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        SMALLER : '(' '<' EXP EXP ')' {
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_SMALLER;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        EQUAL   : '(' '=' EXP EXPS ')' {
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = EQUAL;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
LOGICAL-OP: AND-OP {
            $$ = $1;
          }
          | OR-OP {
            $$ = $1;
          }
          | NOT-OP {
            $$ = $1;
          }
          ;
        AND-OP  : '(' and EXP EXPS ')' {
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_AND;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        OR-OP   : '(' or EXP EXPS ')' {
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_OR;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
        NOT-OP  : '(' not EXP ')' {
                    struct ASTArithmatic *a = (struct ASTArithmatic *)malloc(sizeof(struct ASTArithmatic));
                    a->type = AST_NOT;
                    a->lhs = $3;
                    a->rhs = $4;
                    $$ = (struct ASTNode *)a;
                }
                ;
DEF-STMT: '(' define VARIABLE EXP ')' { //add to symbol table. }
        ;
        VARIABLE: id {
                    struct ASTVal *v = (struct ASTVal *)malloc(sizeof(struct ASTVal));
                    v->type = AST_VAR;
                    v->val = $1;
                    $$ = (struct ASTNode *)v;
                }
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
        PARAM   : EXP {
            $$ = $1;
        }
                ;
        LAST-EXP: EXP {
            $$ = $1;
        }
                ;
        FUN-NAME: id {
            
        }
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
