%{
    #include<iostream>
    #include<cstdlib>
    #include "AST.h"
    #include<map>
    #include<string>
    #include<stack>
    
    extern int yylex(void);
    void yyerror(const char *msg);
    std::map<std::string, struct ASTNode *> def;
    std::map<std::string, struct ASTNode *>::iterator iter;
    std::stack<ASTType> stack_type;
    struct ASTNode *root;
    int ASTArith(struct ASTNode *);
    bool ASTLogical(struct ASTNode *);
    struct ASTVal* ASTVisit(struct ASTNode *);
    struct ASTNode* ASTIf_stmt(struct ASTNode *node);
    void ASTDef_stmt(struct ASTNode *node);
    struct ASTNode* two_Node(struct ASTNode *exp_1, struct ASTNode *exp2);
    struct ASTNode* three_Node(struct ASTNode *exp_1, struct ASTNode *exp_2, struct ASTNode *exp_3);
%}
%error-verbose
%union {
    bool b;
    int num;
    char *id;
    struct ASTNode *node;
}
%token<b> BOOL
%token<num> NUM
%token<id> ID
%token MOD AND OR NOT DEFINE FUN IF PRINT_NUM PRINT_BOOL
%type<node> program stmt stmts print_stmt def_stmt exps exp
%type<node> plus minus multiply divid modulus greater smaller equal
%type<node> num_op logical_op fun_exp fun_call if_exp
%type<node> and_op or_op not_op test_exp then_exp else_exp
%type<node> variable variables

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
            $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
            $$->type = AST_ROOT;
            $$->lhs = $1;
            $$->rhs = $2;
        }
         | /* lambda */ { $$ = (struct ASTNode *)malloc(sizeof(struct ASTNode));
                         $$->type = AST_NULL;
                         $$->lhs = NULL;
                         $$->rhs = NULL; }
        ;
stmt: exp | def_stmt | print_stmt ;
print_stmt: '(' PRINT_NUM exp ')' { $$ = two_Node($3, NULL); }
          | '(' PRINT_BOOL exp ')' { $$ = two_Node($3, NULL); }
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
        plus: '(' '+' exp exp exps ')' { $$ = three_Node($3, $4, $5); }
                ;
        minus: '(' '-' exp exp ')' { $$ = two_Node($3, $4); }
                ;
        multiply: '(' '*' exp exp exps ')' { $$ = three_Node($3, $4, $5); }
                ;
        divid: '(' '/' exp exp ')' { $$ = two_Node($3, $4); }
                ;
        modulus: '(' MOD exp exp ')' { $$ = two_Node($3, $4); }
                ;
        greater: '(' '>' exp exp ')' { $$ = two_Node($3, $4); }
                ;
        smaller: '(' '<' exp exp ')' { $$ = two_Node($3, $4); }
                ;
        equal: '(' '=' exp exp exps ')' { $$ = three_Node($3, $4, $5); }
                ;
logical_op: and_op | or_op | not_op ;
        and_op: '(' AND exp exp exps ')' { $$ = three_Node($3, $4, $5); }
                ;
        or_op: '(' OR exp exp exps ')' { $$ = three_Node($3, $4, $5); }
                ;
        not_op: '(' NOT exp ')' { $$ = two_Node($3, NULL); }
                ;
def_stmt: '(' DEFINE variable exp ')' { 
            $$ = two_Node($3, $4);
        }
        ;
        variable: ID {
            struct ASTId *id = (struct ASTId *)malloc(sizeof(struct ASTId));
            id->type = AST_ID;
            id->id = (char *)malloc(sizeof(char) * strlen($1));
            id->id = $1;
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

struct ASTNode* two_Node(struct ASTNode *exp_1, struct ASTNode *exp_2) {
    struct ASTNode *reduce = (struct ASTNode *)malloc(sizeof(struct ASTNode));
    reduce->type = stack_type.top();
    reduce->lhs = exp_1;
    reduce->rhs = exp_2;
    stack_type.pop();
    return reduce;
}

struct ASTNode* three_Node(struct ASTNode *exp_1, struct ASTNode *exp_2, struct ASTNode *exp_3) {
    struct ASTNode *reduce = (struct ASTNode *)malloc(sizeof(struct ASTNode));
    reduce->type = stack_type.top();
    reduce->lhs = exp_1;
    struct ASTNode *rhs = (struct ASTNode *)malloc(sizeof(struct ASTNode));
    rhs->type = stack_type.top();
    rhs->lhs = exp_2;
    rhs->rhs = exp_3;
    reduce->rhs = rhs;
    stack_type.pop();
    return reduce;
}

int ASTArith(struct ASTNode *node) {
    int val;
    struct ASTNum *num = (struct ASTNum *)node;
    struct ASTId *id = (struct ASTId *)node;
    std::string str;
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
        case AST_ID:
            str.assign(id->id, strlen(id->id));
            iter = def.find(str);
            if (iter == def.end()) {
                puts("Haven't defined yet! in ASTArith.");
            } else {
                val = ASTArith(iter->second);
            }
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

void ASTDef_stmt(struct ASTNode *node) {
    struct ASTId *id = (struct ASTId *)node->lhs;
    std::string str(id->id);
    iter = def.find(str);
    if (iter != def.end()) {
        /* if found -> already defined */
        puts("Redefined");
        printf("id->id: %s\n", id->id);
        exit(0);
    } else {
        printf("define: %s\n", id->id);
        def[str] = node->rhs;
    }
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
        case AST_DEF:
            ASTDef_stmt(node);
            break;
        case AST_NULL:
            /* do nothing */
            break;
        /* case AST_FUN:*/
        default:
            printf("ASTType: %d\n", node->type);
            puts("default ASTVisit");
            break;
    }
    return v;
}

int main(int argc, char *argv[]) {
    yyparse();
    puts("finish parsing");
    ASTVisit(root);
    return(0);
}
