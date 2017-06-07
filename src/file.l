%{
    #include<iostream>
    #include<cstdlib>
    #include<stack>
    #include "AST.h"
    #include "file.tab.hh"
    extern std::stack<ASTType> stack_type;
%}
separator  [ \t\n\r]
letter     [a-z]
digit      [0-9]
number     0|[1-9]{digit}*|-[1-9]{digit}*
ID         {letter}({letter}|{digit}|"-")*
bool-val   #[t|f]
%%
<<EOF>>      { return(0); }
{separator}  { }
"mod"        { stack_type.push(AST_MOD); return(MOD); }
"and"        { stack_type.push(AST_AND); return(AND); }
"or"         { stack_type.push(AST_OR); return(OR); }
"not"        { stack_type.push(AST_NOT); return(NOT); }
"define"     { stack_type.push(AST_DEF); return(DEFINE); }
"fun"        { stack_type.push(AST_FUN_EXP); return(FUN); }
"if"         { stack_type.push(AST_IF); return(IF); }
"print-num"  { stack_type.push(AST_PNUM); return(PRINT_NUM); }
"print-bool" { stack_type.push(AST_PBOOL); return(PRINT_BOOL); }
{bool-val}   { if (yytext[1] == 't') yylval.b = true;
               else yylval.b = false;
               return(BOOL); }
{number}     { yylval.num = atoi(yytext); return(NUM); }
{ID}         { yylval.id = strdup(yytext); return(ID); }
"+"          { stack_type.push(AST_ADD); return(yytext[0]); }
"-"          { stack_type.push(AST_MINUS); return(yytext[0]); }
"*"          { stack_type.push(AST_MUL); return(yytext[0]); }
"/"          { stack_type.push(AST_DIV); return(yytext[0]); }
"="          { stack_type.push(AST_EQUAL); return(yytext[0]); }
">"          { stack_type.push(AST_GREATER); return(yytext[0]); }
"<"          { stack_type.push(AST_SMALLER); return(yytext[0]); }
.            { return(yytext[0]); }
%%