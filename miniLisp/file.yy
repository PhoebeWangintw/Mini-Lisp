%{
    #include<iostream>
    #include<cstdlib>
    #include "AST.h"
    #include<map>
    #include<string>
    #include<stack>
    
    extern int yylex(void);
    void yyerror(const char *msg);
    std::map<std::string, std::string> def;
    // TODO: creating a linked list to store defined variables
    // TODO: creating a linked list to store AST of the defined function.
    struct ASTVal* ASTVisit(struct ASTNode *);
    int ASTArith(struct ASTNode *);
    bool ASTLogical(struct ASTNode *);
    struct ASTNode* ASTIf_stmt(struct ASTNode *node);
    struct ASTNode* root;
    std::stack<ASTType> stack_type;
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
%type<node> test_exp then_exp else_exp
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
stmts: stmt stmts {

        }
         | /* lambda */ { $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                         $$->type = AST_NULL;
                         $$->lhs = NULL;
                         $$->rhs = NULL; }
        ;
stmt: exp | def_stmt | print_stmt ;
print_stmt: '(' PRINT_NUM exp ')' { 
                $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                $$->type = AST_PNUM;
                $$->lhs = $3;
                $$->rhs = NULL;
          }
          | '(' PRINT_BOOL exp ')' {
                $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                $$->type = AST_PBOOL;
                $$->lhs = $3;
                $$->rhs = NULL;
          }
          ;
exps: exp exps {
            $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
            $$->type = stack_type.top();
            $$->lhs = $1;
            $$->rhs = $2;
        }
         | /* lambda */ { $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                         $$->type = AST_NULL;
                         $$->lhs = NULL;
                         $$->rhs = NULL; }
        ;
exp: BOOL {
            struct ASTBool *b = (struct ASTBool *)malloc(sizeof(struct ASTBool));
            b->type = AST_BOOL;
            b->b = $1;
            $$ = (struct ASTNode *)b;
        }
        | NUM  {
            struct ASTNum *num = (struct ASTNum *)malloc(sizeof(struct ASTNum));
            num->type = AST_NUM;
            num->num = $1;
            $$ = (struct ASTNode *)num;
        }
        | variable | num_op | logical_op | fun_exp | fun_call | if_exp ;
num_op: plus | minus | multiply | divid | modulus | greater | smaller | equal ;
        plus: '(' '+' exp exp exps ')' { 
                    // (+ 1 2 3 4) 
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   struct ASTNode *rhs = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   rhs->type = stack_type.top();
                   rhs->lhs = $4;
                   rhs->rhs = $5;
                   $$->rhs = rhs;
                   stack_type.pop();
                }
                ;
        minus: '(' '-' exp exp ')' { 
                    // (- 2 1) = 1 
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   $$->rhs = $4;
                   stack_type.pop();
                }
                ;
        multiply: '(' '*' exp exp exps ')' { 
                    // (* 1 2 3 4) 
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   struct ASTNode *rhs = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   rhs->type = stack_type.top();
                   rhs->lhs = $4;
                   rhs->rhs = $5;
                   $$->rhs = rhs;
                   stack_type.pop();
                }
                ;
        divid: '(' '/' exp exp ')' { 
                    // (/ 3 2) = 1 
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   $$->rhs = $4;
                   stack_type.pop();
                }
                ;
        modulus: '(' MOD exp exp ')' {
                    // (mod 8 5) = 3 
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   $$->rhs = $4;
                   stack_type.pop()
                 }
                ;
        greater: '(' '>' exp exp ')' { 
                    // (> 1 2)
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   $$->rhs = $4;
                   stack_type.pop()
                }
                ;
        smaller: '(' '<' exp exp ')' {
                   $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   $$->rhs = $4;
                   stack_type.pop();
                }
                ;
        equal: '(' '=' exp exp exps ')' {
                   $$ = (struct ASTNode* )malloc(sizeof(struct ASTNode));
                   $$->type = stack_type.top();
                   $$->lhs = $3;
                   struct ASTNode *rhs = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                   rhs->type = $4->type;
                   rhs->lhs = $4;
                   rhs->rhs = $5;
                   $$->rhs = rhs;
                   stack_type.pop();
                }
                ;
logical_op: and_op | or_op | not_op ;
        and_op: '(' AND exp exp exps ')' {
                    $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                    $$->type = stack_type.top();
                    $$->lhs = $3;
                    struct ASTNode *rhs = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                    rhs->type = stack_type.top();
                    rhs->lhs = $4;
                    rhs->rhs = $5;
                    $$->rhs = rhs;
                    stack_type.pop();
                }
                ;
        or_op: '(' OR exp exp exps ')' {
                    $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                    $$->type = stack_type.top();
                    $$->lhs = $3;
                    struct ASTNode *rhs = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                    rhs->type = stack_type.top();
                    rhs->lhs = $4;
                    rhs->rhs = $5;
                    $$->rhs = rhs;
                    stack_type.pop();
                }
                ;
        not_op: '(' NOT exp ')' {
                    $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                    $$->type = AST_NOT;
                    $$->lhs = $3;
                    $$->rhs = NULL;
                }
                ;
def_stmt: '(' DEFINE variable exp ')' {  }
        ;
        variable: ID {
            struct ASTId *id = (struct ASTId *)malloc(sizeof(struct ASTId));
            id->type = AST_ID;
            id->id = (char *)malloc(sizeof(strlen($1)));
            $$ = (struct ASTNode *)id;
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
        variables: variable variables
                | /* lambda */
                ;
if_exp: '(' IF test_exp then_exp else_exp ')' {
            struct ASTIf *if_s = (struct ASTIf *)malloc(sizeof(struct ASTIf));
            if_s->type = stack_type.top();
            if_s->mhs = $3;
            if_s->lhs = $4;
            if_s->rhs = $5;
            $$ = (struct ASTNode *)if_s;
            stack_type.pop();
        }
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

int ASTArith(struct ASTNode *node) {
    int val;
    struct ASTNum *num = (struct ASTNum *)node;
    switch(node->type) {
        case AST_ADD:
            val = ASTArith(node->lhs) + ASTArith(node->rhs);
            if (node->rhs->type == AST_NULL) val--;
            break;
        case AST_MINUS:
            val = ASTArith(node->lhs) - ASTArith(node->rhs);
            break;
        case AST_MUL:
            val = ASTArith(node->lhs) * ASTArith(node->rhs);
            break;
        case AST_DIV:
            val = ASTArith(node->lhs) / ASTArith(node->rhs);
            break;
        case AST_MOD:
            val = ASTArith(node->lhs) % ASTArith(node->rhs);
            break;
        case AST_NUM:
            val = num->num;
            break;
        case AST_GREATER:
            if (ASTArith(node->lhs) > ASTArith(node->rhs)) val = 1;
            else val = 0;
            break;
        case AST_SMALLER:
            if (ASTArith(node->lhs) < ASTArith(node->rhs)) val = 1;
            else val = 0;
            break;
        case AST_EQUAL:
            if (node->rhs->type != AST_NULL) {
                if (ASTArith(node->lhs) == ASTArith(node->rhs)) val = 1;
                else val = 0;
            } else val = 1;
            break;
        case AST_NULL:
            val = 1;
            break;
        default:
            puts("to default arithmetic!");
            val = 1;
            break;
    }
    return val;
}

bool ASTLogical(struct ASTNode *node) {
    bool b;
    struct ASTBool *b_s = (struct ASTBool *)node;
    switch(node->type) {
        case AST_AND:
            b = ASTLogical(node->lhs) && ASTLogical(node->rhs);
            break;
        case AST_OR:
            b = ASTLogical(node->lhs) || ASTLogical(node->rhs);
            break;
        case AST_NOT:   
            b = !ASTLogical(node->lhs);
            break;
        case AST_GREATER:
        case AST_SMALLER:
        case AST_EQUAL:
            if (ASTArith(node) == 1) b = true;
            else b = false;
            break;
        case AST_BOOL:            
            b = b_s->b;
            break;
        case AST_NULL:
            b = true;
            break;
        default:
            puts("to default logical!");
            b = true;
            break;
    }
    return b;
}

struct ASTNode* ASTIf_stmt(struct ASTNode *node) {
    struct ASTIf *if_s = (struct ASTIf *)malloc(sizeof(struct ASTIf));
    if_s = (struct ASTIf *)node;
    if (ASTLogical(if_s->mhs)) return if_s->lhs; 
    else return if_s->rhs;
}

struct ASTVal* ASTVisit(struct ASTNode *node) {
    struct ASTVal *v = (struct ASTVal *)malloc(sizeof(struct ASTVal));
    switch(node->type) {
        case AST_ROOT:
            ASTVisit(node->lhs);
            ASTVisit(node->rhs);
            break;
        case AST_ADD:
        case AST_MINUS:
        case AST_MUL:
        case AST_DIV:
        case AST_MOD:
            v->type = AST_NUM;
            v->num = ASTArith(node);
            break;
        case AST_AND:
        case AST_OR:
        case AST_NOT:        
        case AST_GREATER:
        case AST_SMALLER:
        case AST_EQUAL:
            v->type = AST_BOOL;
            v->b = ASTLogical(node);
            break;
        case AST_PNUM:
            v->type = AST_NUM;
            v->num = ASTArith(node->lhs);
            printf("%d\n", v->num);
            break;
        case AST_PBOOL:
            v->type = AST_BOOL;
            v->b = ASTLogical(node->lhs);;
            printf(v->b ? "#t\n" : "#f\n");
            break;
        case AST_IF:
            v = ASTVisit(ASTIf_stmt(node));
            break;
        /* case AST_FUN:*/
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
