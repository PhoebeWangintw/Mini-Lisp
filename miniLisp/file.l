%{
    #include "file.tab.h"    
%}
separator  [ \t\n\r]
letter     [a-z]
digit      [0-9]
number     0|[1-9]{digit}*|-[1-9]digit*
ID         {letter}({letter}|{digit}|"-")*
bool-val   #[t|f]
%%
\n           { return(0); }
[]           { // ignore. }
{bool-val}   { yylval.bool = strdup(boolVal);}
{number}     { yylval.num = number; return (number); }
{ID}         { yylval.id = number; return (id); }
"mod"        { return(strdup(yytext)); }
"and"        {}
"or"         {}
"not"        {}
"define"     {}
"fun"        {}
"if"         {}
"print-num"  {}
"print-bool" {}
.            { return(yytext[0]); }
%%