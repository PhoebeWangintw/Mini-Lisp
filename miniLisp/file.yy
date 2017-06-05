%{
    #include<iostream>
    #include<cstdlib>
    #include "AST.h"
    #include<map>
    #include<string>
    #include<stack>
    #include<vector>
    
    extern int yylex(void);
    void yyerror(const char *msg);
    typedef std::map<std::string, struct ASTNode *> Map;
    Map* def;
    Map::iterator iter;
    std::stack<ASTType> stack_type;
    struct ASTNode *root;
    int ASTArith(struct ASTNode *, Map *map);
    bool ASTLogical(struct ASTNode *, Map *map);
    struct ASTVal* ASTVisit(struct ASTNode *, Map *map);
    struct ASTNode* ASTIf_stmt(struct ASTNode *node, Map *map);
    void ASTDef_stmt(struct ASTNode *node);
    void print_Result(struct ASTVal *v);
    struct ASTNode *find_def(struct ASTNode *node, Map *map);
    struct ASTVal* ASTFun_call(struct ASTNode *fun_exp, struct ASTNode *par_node);
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
%type<node> num_op logical_op fun_exp fun_call fun_ids fun_body if_exp
%type<node> and_op or_op not_op test_exp then_exp else_exp fun_name
%type<node> variable variables params param

%left BOOL NUM ID
%left '+' '-'
%left '*' '/' MOD
%left AND OR NOT
%left '(' ')'
%nonassoc UMINUS
%%
program: stmt stmts {
            stack_type.push(AST_ROOT);
            $$ = two_Node($1, $2);
            root = $$;
        }
        ;
stmts: stmt stmts {
            stack_type.push(AST_ROOT);
            $$ = two_Node($1, $2);
        }
         | /* lambda */ { 
            stack_type.push(AST_NULL);
            $$ = two_Node(NULL, NULL); 
        }
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
         | /* lambda */ { 
            stack_type.push(AST_NULL);
            $$ = two_Node(NULL, NULL); 
        }
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
        | variable | num_op | logical_op | fun_exp | fun_call | if_exp;
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
def_stmt: '(' DEFINE variable exp ')' { $$ = two_Node($3, $4); }
        ;
        variable: ID {
            struct ASTId *id = (struct ASTId *)malloc(sizeof(struct ASTId));
            id->type = AST_ID;
            id->id = (char *)malloc(sizeof(char) * strlen($1));
            id->id = $1;
            $$ = (struct ASTNode *)id;
        }
        ;
fun_exp: '(' FUN fun_ids fun_body ')' { $$ = two_Node($3, $4); }
        ;
        fun_ids: '(' variables ')' { $$ = $2; }
                ;
        fun_body: exp
                ;
        fun_call: '(' fun_exp params ')'  { 
                    stack_type.push(AST_FUN_CALL);
                    $$ = two_Node($2, $3);
                }
                | '(' fun_name params ')' {
                    stack_type.push(AST_FUN_NAME);
                    $$ = two_Node($2, $3);
                }
                ;
        fun_name:variable;
        params: param params {
                    stack_type.push(AST_FUN_PARAM);
                    $$ = two_Node($1, $2);
                }
                | /* lambda */ {
                    stack_type.push(AST_NULL);
                    $$ = two_Node(NULL, NULL);
                }
                ;
        param: exp
                ;
        variables: variable variables {
                    stack_type.push(AST_ID);
                    $$ = two_Node($1, $2);
                }
                | /* lambda */ { 
                    stack_type.push(AST_NULL);
                    $$ = two_Node(NULL, NULL); 
                }
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

int ASTArith(struct ASTNode *node, Map *map) {
    int val;
    struct ASTNum *num = (struct ASTNum *)node;
    struct ASTId *id = (struct ASTId *)node;
    std::string str;
    switch(node->type) {
        case AST_ADD:
            val = ASTArith(node->lhs, map) + ASTArith(node->rhs, map);
            if (node->rhs->type == AST_NULL) val--;
            break;
        case AST_MINUS:
            val = ASTArith(node->lhs, map) - ASTArith(node->rhs, map);
            break;
        case AST_MUL:
            val = ASTArith(node->lhs, map) * ASTArith(node->rhs, map);
            break;
        case AST_DIV:
            val = ASTArith(node->lhs, map) / ASTArith(node->rhs, map);
            break;
        case AST_MOD:
            val = ASTArith(node->lhs, map) % ASTArith(node->rhs, map);
            break;
        case AST_NUM:
            val = num->num;
            break;
        case AST_GREATER:
            if (ASTArith(node->lhs, map) > ASTArith(node->rhs, map)) val = 1;
            else val = 0;
            break;
        case AST_SMALLER:
            if (ASTArith(node->lhs, map) < ASTArith(node->rhs, map)) val = 1;
            else val = 0;
            break;
        case AST_EQUAL:
            if (node->rhs->type != AST_NULL) {
                if (ASTArith(node->lhs, map) == ASTArith(node->rhs, map)) val = 1;
                else val = 0;
            } else val = 1;
            break;
        case AST_NULL:
            val = 1;
            break;
        case AST_ID:
            str.assign(id->id, strlen(id->id));
            iter = map->find(str);
            if (iter == map->end()) {
                puts("Haven't defined yet! in ASTArith.");
            } else {
                val = ASTVisit(iter->second, map)->num;
            }
            break;
        default:
            puts("to default arithmetic!");
            val = 1;
            break;
    }
    return val;
}

bool ASTLogical(struct ASTNode *node, Map *map) {
    bool b;
    struct ASTBool *b_s = (struct ASTBool *)node;
    struct ASTId *id = (struct ASTId *)node;
    std::string str;
    switch(node->type) {
        case AST_AND:
            b = ASTLogical(node->lhs, map) && ASTLogical(node->rhs, map);
            break;
        case AST_OR:
            b = ASTLogical(node->lhs, map) || ASTLogical(node->rhs, map);
            break;
        case AST_NOT:   
            b = !ASTLogical(node->lhs, map);
            break;
        case AST_GREATER:
        case AST_SMALLER:
        case AST_EQUAL:
            if (ASTArith(node, map) == 1) b = true;
            else b = false;
            break;
        case AST_BOOL:            
            b = b_s->b;
            break;
        case AST_ID:
            str.assign(id->id, strlen(id->id));
            iter = map->find(str);
            if (iter == map->end()) {
                puts("Haven't defined yet! in ASTLogical.");
                exit(0);
            } else {
                b = ASTVisit(iter->second, map)->b;
            }
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

struct ASTNode* ASTIf_stmt(struct ASTNode *node, Map *map) {
    struct ASTIf *if_s = (struct ASTIf *)malloc(sizeof(struct ASTIf));
    if_s = (struct ASTIf *)node;
    if (ASTLogical(if_s->mhs, map)) return if_s->lhs; 
    else return if_s->rhs;
}

void ASTDef_stmt(struct ASTNode *node) {
    struct ASTId *id = (struct ASTId *)node->lhs;
    std::string str(id->id);
    iter = def->find(str);
    if (iter != def->end()) {
        /* if found -> already defined */
        puts("Redefined");
        printf("id->id: %s\n", id->id);
        exit(0);
    } else {
        printf("node->rhs->type: %d\n", node->rhs->type);
        printf("define: %s\n", id->id);
        (*def)[str] = node->rhs;
    }
}


struct ASTVal* ASTFun_call(struct ASTNode *fun_exp, struct ASTNode *par_node) {
    std::vector<std::string> ids;
    std::vector<struct ASTNode *> params;
    struct ASTNode *fun_body = fun_exp->rhs;
    struct ASTNode *id_node = fun_exp->lhs;
    while (par_node->type != AST_NULL) {
        struct ASTNode *n = (struct ASTNode *)ASTVisit(par_node->lhs, def);
        params.push_back(n);
        par_node = par_node->rhs;
    }
    while (id_node->rhs->type != AST_NULL) {
        std::string str(ASTVisit(id_node->lhs, def)->id);
        ids.push_back(str);
        printf("str: %s\n", str.c_str());
        id_node = id_node->rhs;
    }
    std::string str(ASTVisit(id_node->lhs, def)->id);
    ids.push_back(str);
    Map* fun_map = new Map();

    if (params.size() == ids.size()) {
        std::vector<struct ASTNode *>::iterator pa_it;
        std::vector<std::string>::iterator id_it;
        for (pa_it = params.begin(), id_it = ids.begin(); pa_it != params.end(); ++pa_it, ++id_it) {
            (*fun_map)[*id_it] = *pa_it;
        }
    } else {
        puts("size of params and ids do not match");
        exit(0);
    }
    /* fun_body */
    return ASTVisit(fun_body, fun_map);
}

struct ASTNode *find_def(struct ASTNode *node, Map *map) {
    struct ASTId *id = (struct ASTId *)node->lhs;
    std::string str(id->id);
    iter = def->find(str);
    if (iter == def->end()) {
        /* if found -> already defined */
        puts("variable not defined yet.");
        printf("id->id: %s\n", id->id);
        exit(0);
    }
    return iter->second;
}

struct ASTVal* ASTVisit(struct ASTNode *node, Map* map) {
    struct ASTVal *v = (struct ASTVal *)malloc(sizeof(struct ASTVal));
    struct ASTId *id = (struct ASTId *)node;
    switch(node->type) {
        case AST_ROOT:
            ASTVisit(node->lhs, map);
            ASTVisit(node->rhs, map);
            break;
        case AST_ADD:
        case AST_MINUS:
        case AST_MUL:
        case AST_DIV:
        case AST_MOD:
        case AST_NUM:
            v->type = AST_NUM;
            v->num = ASTArith(node, map);
            break;
        case AST_AND:
        case AST_OR:
        case AST_NOT:        
        case AST_GREATER:
        case AST_SMALLER:
        case AST_EQUAL:
        case AST_BOOL:
            v->type = AST_BOOL;
            v->b = ASTLogical(node, map);
            break;
        case AST_ID:
            /* add find id */
            v->type = AST_ID;
            v->id = (char *)malloc(sizeof(char) * strlen(id->id));
            v->id = id->id;
            break;
        case AST_PNUM:
            v->type = AST_NUM;
            v->num = ASTArith(node->lhs, map);
            printf("%d\n", v->num);
            break;
        case AST_PBOOL:
            v->type = AST_BOOL;
            v->b = ASTLogical(node->lhs, map);;
            printf(v->b ? "#t\n" : "#f\n");
            break;
        case AST_IF:
            v = ASTVisit(ASTIf_stmt(node, map), map);
            print_Result(v);
            break;
        case AST_DEF:
            ASTDef_stmt(node);
            break;
        case AST_FUN_NAME:
            print_Result(ASTFun_call(find_def(node, map), node->rhs));
            break;
        case AST_FUN_CALL:
            print_Result(ASTFun_call(node->lhs, node->rhs));
            break;
        case AST_NULL:
            /* do nothing */
            break;
        default:
            printf("ASTType: %d\n", node->type);
            puts("default ASTVisit");
            break;
    }
    return v;
}

void print_Result(struct ASTVal *v) {
    if (v->type == AST_NUM) {
        printf("val: %d\n", v->num);
    } else if (v->type == AST_BOOL){
        printf(v->b ? "val: #t\n" : "val: #f\n");
    } else if (v->type == AST_ID) {
        printf("val: %s\n", v->id);
    }
}

int main(int argc, char *argv[]) {
    yyparse();
    puts("finish parsing");
    def = new Map();
    ASTVisit(root, def);
    return(0);
}
