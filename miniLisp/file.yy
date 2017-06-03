%{
    #include<iostream>
    #include<cstdlib>
    #include<map>
    #include<string>
    #include "AST.h"
    
    extern int yylex(void);
    void yyerror(const char *msg);
    std::map<string, string> def;
    // TODO: creating a linked list to store defined variables
    // TODO: creating a linked list to store AST of the defined function.
%}
%union {
    bool b;
    int num;
    char *id;
    struct Defined *defined;
    struct ASTNode *node;
}
%token<b> BOOL
%token<num> NUM
%token<id> ID
%token MOD AND OR NOT
%token DEFINE FUN IF PRINT_NUM PRINT_BOOL

%left BOOL NUM ID
%left '+' '-'
%left '*' '/' MOD
%left AND OR NOT
%left '(' ')'
%nonassoc UMINUS
%%
program : stmt stmts
        ;
stmts   : stmt
        | /* lambda */ { }
        ;
stmt    : exp | def_stmt | print_stmt ;
print_stmt: '(' PRINT_NUM exp ')' {  }
          | '(' PRINT_BOOL exp ')'
          ;
exps    : exp
        | /* lambda */ {  }
        ;
exp     : BOOL {
            
        }
        | NUM  {
            
        }
        | variable | num_op | logical_op | fun_exp | fun_call | if_exp ;
num_op  : plus | minus | multiply | divid | modulus | greater | smaller | equal ;
        plus    : '(' '+' exp exps ')' { 
                    // (+ 1 2 3 4) 
                    $$ = $3 + $4;
                }
                ;
        minus   : '(' '-' exp exp ')' { 
                    // (- 2 1) = 1 
                    
                }
                ;
        multiply: '(' '*' exp exps ')' { 
                    // (* 1 2 3 4) 
                    $$ = (struct ASTArithmatic)malloc();
                }
                ;
        divid   : '(' '/' exp exp ')' { 
                    // (/ 3 2) = 1 
                    
                }
                ;
        modulus : '(' MOD exp exp ')' {
                    // (mod 8 5) = 3 
                    
                 }
                ;
        greater : '(' '>' exp exp ')' { 
                    // (> 1 2)
                    
                }
                ;
        smaller : '(' '<' exp exp ')' {
                    
                }
                ;
        equal   : '(' '=' exp exps ')' {
                    
                }
                ;
logical_op: and_op | or_op | not_op ;
        and_op  : '(' AND exp exps ')' {
                    $$ = $3 && $4;
                }
                ;
        or_op   : '(' OR exp exps ')' {
                    $$ = $3 || $4;
                }
                ;
        not_op  : '(' NOT exp ')' {
                    $$ = !$3;
                }
                ;
def_stmt: '(' DEFINE variable exp ')' { def.insert(std::pair<string, string>($3, $4)); }
        ;
        variable: ID ;
fun_exp : '(' FUN fun_ids fun_body ')'
        ;
        fun_ids : '(' ID ')' { $$ = $2; }
                ;
        fun_body: exp
                ;
        fun_call: '(' fun_exp param ')'  {}
                | '(' fun_name param ')' {
                        //ex. (fib 1)
                    }
                ;
        param   : exp {
            // $$ = $1;
        }
                ;
        fun_name: ID {
            
        }
                ;
if_exp  : '(' IF test_exp then_exp else_exp ')'
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
int main(int argc, char *argv[]) {
    yyparse();
    return(0);
}
