%{
    #include<iostream>
    #include<cstdlib>
    #include "file.tab.hh"
%}
separator  [ \t\n\r]
letter     [a-z]
digit      [0-9]
number     0|[1-9]{digit}*|-[1-9]digit*
ID         {letter}({letter}|{digit}|"-")*
bool-val   #[t|f]
%%
\n           { return(0); }
[ ]          { }
"mod"        { return(MOD); }
"and"        { return(AND); }
"or"         { return(OR); }
"not"        { return(NOT); }
"define"     { return(DEFINE); }
"fun"        { return(FUN); }
"if"         { return(IF); }
"print-num"  { return(PRINT_NUM); }
"print-bool" { return(PRINT_BOOL); }
{bool-val}   { if (yytext[1] == 't') yylval.b = false;
               else yylval.b = true;
               return(BOOL); }
{number}     { yylval.num = atoi(yytext); return(NUM); }
{ID}         { yylval.id = strdup(yytext); return(ID); }
.            { return(yytext[0]); }
%%