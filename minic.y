%{
#include <stdio.h>
#include <string.h>
#include "lex.yy.c"

struct SymbolTable {
 char * name;
 char * datatype;
 char * type;
 int line_no;
} symbol_table[100];
char current_data_type[10];
int symbol_table_counter = 0;

enum VarType { var,func };
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
void add_to_symbol_table(enum VarType vt);

 struct token_node {
    struct token_node * left;
    struct token_node * right;
    char * val;
 };
struct token_node * head;

struct token_node* bootstrap_node(struct token_node * left, struct token_node * right,char * token){
   struct token_node * base_node =(struct node *) malloc(sizeof(struct token_node));
   base_node->left = left;
   base_node->right = right;
   char *_token = (char *)malloc(strlen(token)+1);
   strcpy(_token, token);
   base_node->val=_token;
   return base_node;
}


%}

%union { 
	struct TokenData { 
		char name[100]; 
		struct token_node* nd;
	} token_data; 
} 

%token <token_data> DATATYPE MAIN INT NUMBER ID INCLUDES B_OPEN B_CLOSE C_OPEN C_CLOSE EQL SEMI
%type <token_data> PROGRAM FUNCTION FUNCTIONS MAIN_FUNC NORMAL_FUNC INCLUDE_STM BODY STATEMENT ASSIGN DATATYPE_ALL

%%


PROGRAM: INCLUDE_STM FUNCTIONS {$$.nd=bootstrap_node($1.nd,$2.nd,"program");head=$$.nd;}
;
FUNCTIONS: MAIN_FUNC NORMAL_FUNC {$$.nd=bootstrap_node($1.nd,$2.nd,$1.name);}
;
MAIN_FUNC: INT MAIN {add_to_symbol_table(func)} B_OPEN B_CLOSE BODY {$$.nd=$6.nd}
;
NORMAL_FUNC: FUNCTION NORMAL_FUNC {$$.nd=bootstrap_node($1.nd,$2.nd,$1.name);} | {}
;
INCLUDE_STM:  INCLUDES {$$.nd=bootstrap_node(NULL,NULL,$1.name);} | INCLUDE_STM INCLUDES {$$.nd=bootstrap_node($1.nd,NULL,$1.name);}
;
BODY: C_OPEN STATEMENT C_CLOSE {$$.nd=bootstrap_node($2.nd,NULL,"body");}
;
STATEMENT:  ASSIGN STATEMENT SEMI {$$.nd=bootstrap_node($1.nd,$2.nd,"statement");} | {}
;
ASSIGN: DATATYPE_ALL ID {add_to_symbol_table(var)} EQL NUMBER {$$.nd=bootstrap_node($1.nd,$2.nd,$2.name);}
;
DATATYPE_ALL: DATATYPE {$$.nd=bootstrap_node(NULL,NULL,$1.name);} | 
              INT {strcpy(current_data_type,yytext)}  {$$.nd=bootstrap_node(NULL,NULL,$1.name);}
;
FUNCTION: DATATYPE_ALL ID {add_to_symbol_table(func)} B_OPEN B_CLOSE BODY {$$.nd=bootstrap_node($1.nd,$2.nd,$2.name);}
;

%%

void add_to_symbol_table(enum VarType vt) {
        if(vt == var) {
			symbol_table[symbol_table_counter].name=strdup(yytext);
			symbol_table[symbol_table_counter].datatype=strdup(current_data_type);
			symbol_table[symbol_table_counter].line_no=line_no;
			symbol_table[symbol_table_counter].type=strdup("Variable");
		}
		else if(vt == func) {
			symbol_table[symbol_table_counter].name=strdup(yytext);
			symbol_table[symbol_table_counter].datatype=strdup(current_data_type);
			symbol_table[symbol_table_counter].line_no=line_no;
			symbol_table[symbol_table_counter].type=strdup("Function");
		}
        symbol_table_counter++;
	}

void print_symbol_table(){
    printf("Symbol table\n");
    for (int i = 0; i < symbol_table_counter; i++){
        struct SymbolTable c_symbol_table = symbol_table[i];
        printf("%s  %s  %s %d\n",c_symbol_table.name,c_symbol_table.datatype,c_symbol_table.type,c_symbol_table.line_no);
    }
}
void printInorder(struct token_node *tree) {
	int i;
	if (tree->left) {
		printInorder(tree->left);
	}
	printf("%s, ", tree->val);
	if (tree->right) {
		printInorder(tree->right);
	}
}
void printtree(struct token_node* tree) {
	printf("\n\n Inorder traversal of the Parse Tree: \n\n");
	printInorder(tree);
	printf("\n\n");
}


int main(){
    yyparse();
    print_symbol_table();
    printtree(head);
}