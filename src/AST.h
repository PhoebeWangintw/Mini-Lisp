#ifndef AST_H
#define AST_H

enum ASTType {
    AST_ROOT, AST_ADD, AST_MINUS, AST_MUL, AST_DIV,
    AST_MOD, AST_AND, AST_OR, AST_NOT, AST_GREATER, 
    AST_SMALLER, AST_EQUAL, AST_FUN_EXP, AST_FUN_CALL, AST_DEF,
    AST_IF, AST_PNUM, AST_PBOOL, AST_BOOL, AST_NUM,
    AST_ID, AST_FUN_NAME, AST_NULL
};

struct _ASTNode {
    enum ASTType type;
    struct _ASTNode *lhs, *rhs;
};

typedef struct _ASTNode ASTNode;

struct _ASTIf {
    enum ASTType type;
    ASTNode *lhs, *mhs, *rhs;
};

typedef struct _ASTIf ASTIf;

struct _ASTVal {
    enum ASTType type;
    int num;
    bool b;
    char *id;
};

typedef struct _ASTVal ASTVal;

/* for terminal */
struct _ASTNum {
    enum ASTType type;
    int num;
};

typedef struct _ASTNum ASTNum;

struct _ASTBool {
    enum ASTType type;
    bool b;
};

typedef struct _ASTBool ASTBool;

struct _ASTId {
    enum ASTType type;
    char *id;
};

typedef struct _ASTId ASTId;

#endif