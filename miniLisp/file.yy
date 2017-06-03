%{
    #include<iostream>
    #include<cstdlib>
    #include<map>
    #include<string>
    #include "AST.h"
    
    extern int yylex(void);
    void yyerror(const char *msg);
    std::map<std::string, std::string> def;
    // TODO: creating a linked list to store defined variables
    // TODO: creating a linked list to store AST of the defined function.
    struct ASTVal ASTVisit(struct ASTNode* );
    struct ASTNode* root;
%}
%union {
    bool b;
    int num;
    char *id;
    struct ASTNode *node;
}
%token<b> BOOL
%token<num> NUM
%token<id> ID
%token MOD AND OR NOT
%token DEFINE FUN IF PRINT_NUM PRINT_BOOL
%type<node> program stmt stmts print_stmt def_stmt exps exp
%type<node> plus minus multiply divid modulus greater smaller equal
%type<node> num_op logical_op fun_exp fun_call if_exp
%type<node> and_op or_op not_op
%type<node> variable

%left BOOL NUM ID
%left '+' '-'
%left '*' '/' MOD
%left AND OR NOT
%left '(' ')'
%nonassoc UMINUS
%%
program: stmt stmts {
                $$ = (struct ASTNode* )malloc(sizeof(struct ASTNode));
                $$->type = AST_ROOT;
                $$->lhs = $1;
                $$->rhs = $2;
                root = $$;
        }
        ;
stmts: stmt
        | /* lambda */ { $$ = NULL; }
        ;
stmt: exp | def_stmt | print_stmt ;
print_stmt: '(' PRINT_NUM exp ')' { 
                $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                $$->type = AST_PNUM;
                $$->lhs = $3;
                $$->rhs = NULL;
          }
          | '(' PRINT_BOOL exp ')' {
                $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                $$->type = AST_PBOOL;
                $$->lhs = $3;
                $$->rhs = NULL;
          }
          ;
exps: exp
        | /* lambda */ { /* append null */ }
        ;
exp: BOOL {
            struct ASTVal* v = (struct ASTVal *)malloc(sizeof(ASTVal));
            v->type = AST_BOOL;
            v->b = $1;
            $$ = (struct ASTNode *)v;
        }
        | NUM  {
            struct ASTVal* v = (struct ASTVal *)malloc(sizeof(ASTVal));
            v->type = AST_NUM;
            v->num = $1;
            $$ = (struct ASTNode *)v;
        }
        | variable | num_op | logical_op | fun_exp | fun_call | if_exp ;
num_op: plus | minus | multiply | divid | modulus | greater | smaller | equal ;
        plus: '(' '+' exp exp exps ')' { 
                    // (+ 1 2 3 4) 
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_ADD;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
        minus: '(' '-' exp exp ')' { 
                    // (- 2 1) = 1 
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_MINUS;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
        multiply: '(' '*' exp exps ')' { 
                    // (* 1 2 3 4) 
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_MUL;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
        divid: '(' '/' exp exp ')' { 
                    // (/ 3 2) = 1 
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_DIV;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
        modulus: '(' MOD exp exp ')' {
                    // (mod 8 5) = 3 
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_MOD;
                   $$->lhs = $3;
                   $$->rhs = $4;
                 }
                ;
        greater: '(' '>' exp exp ')' { 
                    // (> 1 2)
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_GREATER;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
        smaller: '(' '<' exp exp ')' {
                   $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                   $$->type = AST_SMALLER;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
        equal: '(' '=' exp exps ')' {
                   $$ = (struct ASTNode* )malloc(sizeof(ASTNode));
                   $$->type = AST_EQUAL;
                   $$->lhs = $3;
                   $$->rhs = $4;
                }
                ;
logical_op: and_op | or_op | not_op ;
        and_op: '(' AND exp exps ')' {
                    $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                    $$->type = AST_AND;
                    $$->lhs = $3;
                    $$->rhs = $4;
                }
                ;
        or_op: '(' OR exp exps ')' {
                    $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                    $$->type = AST_OR;
                    $$->lhs = $3;
                    $$->rhs = $4;
                }
                ;
        not_op: '(' NOT exp ')' {
                    $$ = (struct ASTNode *)malloc(sizeof(ASTNode));
                    $$->type = AST_NOT;
                    $$->lhs = $3;
                    $$->rhs = NULL;
                }
                ;
def_stmt: '(' DEFINE variable exp ')' {  }
        ;
        variable: ID {
            struct ASTVal* v = (struct ASTVal *)malloc(sizeof(ASTVal));
            v->type = AST_ID;
            v->val = (char *)malloc(sizeof(strlen($1)));
            v->val = $1;
            $$ = (struct ASTNode *)v;
        }
        ;
fun_exp: '(' FUN fun_ids fun_body ')'
        ;
        fun_ids: '(' variables ')' {  }
                ;
        fun_body: exp
                ;
        fun_call: '(' fun_exp param ')'  {}
                | '(' fun_name param ')' {
                        //ex. (fib 1)
                    }
                ;
        param: exp {
            // $$ = $1;
        }
                ;
        fun_name: ID {
            
        }
        variables: variable
                | /* lambda */
                ;
if_exp: '(' IF test_exp then_exp else_exp ')'
        ;
        test_exp: exp
                ;
        then_exp: exp
                ;
        else_exp: exp
                ;
%%
void yyerror(const char *msg) {
    fprintf(stderr, "%s\n", msg);
    exit(0);
}

struct ASTVal ASTVisit(struct ASTNode *node) {
    struct ASTVal v;
    switch(node->type) {
        case AST_ROOT:
            
            break;
        case AST_ADD:
            v.type = AST_NUM;
            int rhs = node->rhs
            v.num = node->lhs + node->rhs;
            break;
        case AST_MINUS:
            v.type = AST_NUM;
            v.num = node->lhs - node->rhs;
            break;
        case AST_MUL:
            v.type = AST_NUM;
            v.num = node->lhs * node->rhs;
            break;
        case AST_DIV:
            v.type = AST_NUM;
            v.num = node->lhs / node->rhs;
            break;
        case AST_MOD:
            v.type = AST_NUM;
            v.num = node->lhs % node->rhs;
            break;
        case AST_AND:
            v.type = AST_BOOL;
            v.b = node->lhs && node->rhs;
            break;
        case AST_OR:
            v.type = AST_BOOL;
            v.b = node->lhs || node->rhs;
            break;
        case AST_NOT:
            v.type = AST_BOOL;
            v.b = !node->lhs
            break;
        case AST_GREATER:
            v.type = AST_BOOL;
            if (node->lhs > node->rhs) v.b = true;
            else v.b = false;
            break;
        case AST_SMALLER:
            v.type = AST_BOOL;
            if (node->lhs < node->rhs) v.b = true;
            else v.b = false;
            break;
        case AST_EQUAL:
            v.type = AST_BOOL;
            if (node->lhs == node->rhs) v.b = true;
            else v.b = false;
            break;
        case AST_PNUM:
            printf("");
            break;
        case AST_PBOOL:
            break;
        /* case AST_FUN:
        case AST_IF: */
        default:
            break;
    }
    return v;
}

int main(int argc, char *argv[]) {
    yyparse();
    ASTVisit(root);
    return(0);
}
