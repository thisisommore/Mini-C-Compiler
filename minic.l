%{
 int line_no=1;
 #include "minic.tab.h"
 int in_comment = 0;
%}
alpha [a-zA-Z]+
id ({alpha}+[0-9]*)+
header #include[ ]<[a-z]+\.h>
datatype "int"|"float"|"char"
digit [0-9]+(\.[0-9]+)?
string_literal \".*\"
comp "=="|"<"|">"|"<="
unary "++"|"--"
%%

(\/\*)(\n|.)*(\*\/) {
    
}

(\/\/).* {
}
{header} { 
    if(in_comment==0){
        strcpy(yylval.token_data.name,(yytext));
        return INCLUDES;
    }
}
"int" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return INT;}}
{datatype} {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return DATATYPE;}}
{digit} {
    if(in_comment==0){
    
    strcpy(yylval.token_data.name,(yytext));return NUMBER;
    }}
"main" {
    if(in_comment==0){
    
    strcpy(yylval.token_data.name,(yytext));return MAIN;
    }}
"(" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return B_OPEN;}
    }
")" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return B_CLOSE;}
    }
"{" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return C_OPEN;}
    }
"}" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return C_CLOSE;}
    }
"=" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return EQL;}
    }
";" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return SEMI;}
    }
{comp} {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return COMP;}
    }
{string_literal} {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return STR_LITERAL;}
    }
{unary} {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return UNARY;} 
    }
"for" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return FOR;}
    }
"while" {
    if(in_comment==0){
    strcpy(yylval.token_data.name,(yytext));return WHILE;}
    }
"\n" line_no++;
[ \t]+ ;
{id} {strcpy(yylval.token_data.name,(yytext));return ID;}
%%

