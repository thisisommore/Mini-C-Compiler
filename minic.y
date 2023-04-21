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

int label_counter=0;
int label_skip_loop=0;
enum VarType { var,func };
void yyerror(const char *s) {
    fprintf(stderr, "Error: %s\n", s);
}
void add_to_symbol_table(enum VarType vt,char * name);

char c_loop_condition[100];
char c_for_action[20];
char c_label[20];
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

int tac = 0;
char * three_address_code[100];
int fltac=0;
%}

%union { 
	struct TokenData { 
		char name[100]; 
		struct token_node* nd;
	} token_data; 
} 

%token <token_data> UNARY COMP FOR DATATYPE MAIN INT NUMBER ID INCLUDES B_OPEN B_CLOSE C_OPEN C_CLOSE EQL SEMI STR_LITERAL WHILE
%type <token_data> LITERAL PROGRAM FUNCTION FUNCTIONS MAIN_FUNC NORMAL_FUNC INCLUDE_STM BODY STATEMENT ASSIGN DATATYPE_ALL

%%


PROGRAM: INCLUDE_STM FUNCTIONS {$$.nd=bootstrap_node($1.nd,$2.nd,"program");head=$$.nd;}
;
FUNCTIONS: MAIN_FUNC NORMAL_FUNC {
    $$.nd=bootstrap_node($1.nd,$2.nd,"functions");
}
;
MAIN_FUNC: INT MAIN {add_to_symbol_table(func,$2.name)} {
    char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"LABEL %s:\n","main");
    three_address_code[tac++] = max;
} B_OPEN B_CLOSE BODY {$$.nd=$6.nd} 
;
NORMAL_FUNC: FUNCTION NORMAL_FUNC {
    $$.nd=bootstrap_node($1.nd,$2.nd,$1.nd->val);
    char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"LABEL %s:\n",$1.nd->val);
    three_address_code[tac++] = max;
} | {}
;
INCLUDE_STM:  INCLUDES {$$.nd=bootstrap_node(NULL,NULL,$1.name);} | INCLUDE_STM INCLUDES {$$.nd=bootstrap_node($1.nd,NULL,$1.name);}
;
BODY: C_OPEN STATEMENT C_CLOSE {$$.nd=bootstrap_node($2.nd,NULL,"body");}
;
STATEMENT:  FOR_LOOP | WHILE_LOOP | ASSIGN SEMI | FUNC_CALL SEMI | STATEMENT STATEMENT  {$$.nd=bootstrap_node($1.nd,$2.nd,"statement");} | {}
;

WHILE_LOOP: WHILE {
    sprintf(c_label,"L%d",label_counter++);
} B_OPEN ID COMP NUMBER {
    char *max=(char *)malloc(sizeof(c_label)+10);
    sprintf(max,"IF %s %s %s GOTO %s\n",$4.name,$5.name,$6.name,c_label);
    three_address_code[tac++] = max;
    
    char * skip_loop=(char *)malloc(sizeof(c_label)+100);
    label_skip_loop=label_counter++;
    sprintf(skip_loop,"GOTO L%d\n",label_skip_loop);
    three_address_code[tac++] = skip_loop;

    char * label_declaration=(char *)malloc(sizeof(c_label)+100);
    sprintf(label_declaration,"%s:\n",c_label);
    three_address_code[tac++] = label_declaration;

    strcpy(c_loop_condition,max);
} B_CLOSE BODY {
     three_address_code[tac++] = strdup(c_loop_condition);
     char *max2=(char *)malloc(sizeof($1.nd->val)+10);
     sprintf(max2,"L%d:\n",label_skip_loop);
     three_address_code[tac++] = max2;
};
FOR_LOOP: FOR {
    sprintf(c_label,"L%d",label_counter++);
} B_OPEN ASSIGN {
} SEMI ID COMP NUMBER {
    char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"IF %s %s %s GOTO %s\n",$7.name,$8.name,$9.name,c_label);
    three_address_code[tac++] = max;
    
    char * skip_loop=(char *)malloc(sizeof(c_label)+100);
    label_skip_loop=label_counter++;
    sprintf(skip_loop,"GOTO L%d\n",label_skip_loop);
    three_address_code[tac++] = skip_loop;

    char * label_declaration=(char *)malloc(sizeof(c_label)+100);
    sprintf(label_declaration,"%s:\n",c_label);
    three_address_code[tac++] = label_declaration;
    
    strcpy(c_loop_condition,max);
} SEMI ID UNARY B_CLOSE BODY {
   	char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"%s%s\n",$12.name,$13.name);
    three_address_code[tac++] = max;
    three_address_code[tac++] = strdup(c_loop_condition);
    char *max2=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max2,"L%d:\n",label_skip_loop);
    three_address_code[tac++] = max2;
    }
FUNC_CALL: ID B_OPEN B_CLOSE {
    char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"GOTO = %s\n","DUNNO");
    three_address_code[tac++] = max;
    }
ASSIGN: DATATYPE_ALL ID {add_to_symbol_table(var,$2.name)} EQL LITERAL {
    $$.nd=bootstrap_node($1.nd,NULL,$2.name);
    char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"%s = %s\n",$2.name,$5.name);
    three_address_code[tac++] = max;
    } | ID EQL LITERAL {
    $$.nd=bootstrap_node(NULL,NULL,$1.name);
    char *max=(char *)malloc(sizeof($1.nd->val)+10);
    sprintf(max,"%s = %s\n",$1.name,$3.name);
    three_address_code[tac++] = max;
    }
;

LITERAL: NUMBER | STR_LITERAL
DATATYPE_ALL: DATATYPE {strcpy(current_data_type,yytext);$$.nd=bootstrap_node(NULL,NULL,$1.name);} | 
              INT {strcpy(current_data_type,yytext)}  {$$.nd=bootstrap_node(NULL,NULL,$1.name);}
;
FUNCTION: DATATYPE_ALL ID {add_to_symbol_table(func,$2.name)} B_OPEN B_CLOSE BODY {$$.nd=bootstrap_node($1.nd,$2.nd,$2.name);}
;

%%

void add_to_symbol_table(enum VarType vt,char * name) {
     for(int j=0;j<symbol_table_counter;j++){
                if(strcmp(symbol_table[j].name,name)==0){
                    char * m = (char *)malloc(10);
                    sprintf(m,"Exist: %s",name);
                    yyerror(m);
                    exit(1);
                };
            }
        if(vt == var) {
			symbol_table[symbol_table_counter].name=strdup(name);
			symbol_table[symbol_table_counter].datatype=strdup(current_data_type);
			symbol_table[symbol_table_counter].line_no=line_no;
			symbol_table[symbol_table_counter].type=strdup("Variable");
		}
		else if(vt == func) {
			symbol_table[symbol_table_counter].name=strdup(name);
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

void print_tac(){
    printf("Three Address Code\n");
    for (int i = 0; i < tac; i++){
        printf("%s",three_address_code[i]);
    }
}

int main(){
    yyparse();
    print_symbol_table();
    printtree(head);
    print_tac();
}