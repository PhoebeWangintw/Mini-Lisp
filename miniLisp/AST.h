#ifndef AST_H
#define AST_H

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
    AST_BOOL,
    AST_LAMBDA
};

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

#endif