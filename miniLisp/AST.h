#ifndef AST_H
#define AST_H

enum ASTType {
    AST_ROOT, AST_ADD, AST_MINUS, AST_MUL, AST_DIV,
    AST_MOD, AST_AND, AST_OR, AST_NOT, AST_GREATER, 
    AST_SMALLER, AST_EQUAL, AST_FUN_EXP, AST_FUN_CALL, AST_FUN_PARAM,
    AST_DEF, AST_IF, AST_PNUM, AST_PBOOL, AST_BOOL,
    AST_NUM, AST_ID, AST_FUN_NAME, AST_NULL
};

struct ASTNode {
    enum ASTType type;
    struct ASTNode *lhs, *rhs;
};

struct ASTIf {
    enum ASTType type;
    struct ASTNode *lhs, *mhs, *rhs;
};

struct ASTVal {
    enum ASTType type;
    int num;
    bool b;
    char *id;
};

/* for terminal */
struct ASTNum {
    enum ASTType type;
    int num;
};

struct ASTBool {
    enum ASTType type;
    bool b;
};

struct ASTId {
    enum ASTType type;
    char *id;
};

struct fun {
    char *name;
    int paramNum;
};

#endif