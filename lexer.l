%{
 int line_no=1;
 #include "parser.hpp"
 int in_comment = 0;
%}
alpha [a-zA-Z]+
id ({alpha}+[0-9]*)+
datatype "int"|"float"|"char"
digit [0-9]+(\.[0-9]+)?
string_literal \".*\"
eq "="
%%

(\/\*)(\n|.)*(\*\/) {
    
}

(\/\/).* {
}
"main" {
    if(in_comment==0){
    
    strcpy(yylval.token_data.value,(yytext));return MAIN;
    }}
"(" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return B_OPEN;}
    }
"=" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return EQ;}
    }
">" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return GT;}
    }
"<" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return LT;}
    }
"if" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return IF;}
    }
")" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return B_CLOSE;}
    }
"{" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return C_OPEN;}
    }
"}" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return C_CLOSE;}
    }
"int" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return INT;}}

{digit} {
    if(in_comment==0){
    
    strcpy(yylval.token_data.value,(yytext));return NUMBER;
    }}

{eq} {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return EQ;}
    }

";" {
    if(in_comment==0){
    strcpy(yylval.token_data.value,(yytext));return SEMI;}
    }
"\n" line_no++;
[ \t]+ ;
{id} {strcpy(yylval.token_data.value,(yytext));return ID_;}
%%

