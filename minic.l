%{
 int line_no=1;
 #include "minic.tab.h"
%}
alpha [a-zA-Z]+
header #include[ ]<[a-z]+\.h>
datatype "int"|"float"|"char"
digit [0-9]+(\.[0-9]+)?
string_literal \".*\"
comp "=="|"<"|">"
unary "++"|"--"
%%

{header} {strcpy(yylval.token_data.name,(yytext));return INCLUDES;}
"int" {strcpy(yylval.token_data.name,(yytext));return INT;}
{datatype} {strcpy(yylval.token_data.name,(yytext));return DATATYPE;}
{digit} {strcpy(yylval.token_data.name,(yytext));return NUMBER;}
"main" {strcpy(yylval.token_data.name,(yytext));return MAIN;}
"(" {strcpy(yylval.token_data.name,(yytext));return B_OPEN;}
")" {strcpy(yylval.token_data.name,(yytext));return B_CLOSE;}
"{" {strcpy(yylval.token_data.name,(yytext));return C_OPEN;}
"}" {strcpy(yylval.token_data.name,(yytext));return C_CLOSE;}
"=" {strcpy(yylval.token_data.name,(yytext));return EQL;}
";" {strcpy(yylval.token_data.name,(yytext));return SEMI;}
{comp} {strcpy(yylval.token_data.name,(yytext));return COMP;}
{string_literal} {strcpy(yylval.token_data.name,(yytext));return STR_LITERAL;}
{unary} {strcpy(yylval.token_data.name,(yytext));return UNARY;} 
"for" {strcpy(yylval.token_data.name,(yytext));return FOR;}
"while" {strcpy(yylval.token_data.name,(yytext));return WHILE;}
"\n" line_no++;
[ \t]+ ;
{alpha} {strcpy(yylval.token_data.name,(yytext));return ID;}
%%

