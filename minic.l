%{
 int line_no=1;
 #include "minic.tab.h"
%}
alpha [a-zA-Z]+
header #include[ ]<[a-z]+\.h>
datatype "int"|"float"|"char"
digit [0-9]+(\.[0-9]+)?
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
"\n" line_no++;
{alpha} {strcpy(yylval.token_data.name,(yytext));return ID;}
%%

