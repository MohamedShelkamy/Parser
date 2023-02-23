#include <stdio.h>  
#include <stdlib.h>
#include <string.h> 
#include "main.h"
#include "var_helper.h"


extern int linenumber;
extern int v_flag ;
extern int i_flag ;
extern int d_flag ;

struct symtab{                                      
	char name[20];                                  
	int val;                                  
};

struct arrtab{                                      
	char name[20];                                  
	int  *arr;
    int size;                                  
};

struct symtab tab[200];

struct arrtab arrtab[200];
int ptr     = 0;   
int ptr_arr = 0; 


int getvalue(int i){
  return tab[i].val;
}

int is_defined(char name[]){
    
    int i;
	int flag = -1;

	for(i = 0; i < ptr; i++){
		if(strcmp(tab[i].name, name) == 0){
			flag = i;
			break;
		}
	}

	return flag;
}


void insert(int value, char name[]){
    int position;
    position=is_defined(name);
    if(position== -1){     
      if(v_flag==1){
       printf("verbose mode : identifier %s was defined on line %d with value equal to %d\n", name,linenumber ,value);
      }
      tab[ptr].val=value;
      strcpy(tab[ptr].name, name);
      ptr++;
    }
    else {
      tab[position].val=value; 
    }

}


// this part is responsible for the array definitions

int is_defined_arr(char name[]){
    
  int i;
	int flag = -1;

	for(i = 0; i < ptr_arr; i++){
		if(strcmp(arrtab[i].name, name) == 0){
			flag = i;
			break;
		}
	}

	return flag;
}

void insert_arr(int size, char name[]){
    int position;
    position=is_defined_arr(name);
    if(position== -1){
      arrtab[ptr_arr].arr=malloc(size * sizeof(int));
      arrtab[ptr_arr].size=size;
      if(arrtab[ptr_arr].arr== NULL){
        yyerror("failed to initiate the array");
      }
      
      strcpy(arrtab[ptr_arr].name, name);
      if(v_flag==1){
        printf("verbose mode : an %s was defined on line %d with size %d\n", name,linenumber,size);
      }
      
      ptr_arr++;
    }
    else {
      yyerror("already defined array");
    }
}

void set_array_value(int value,int pos ,char name[]){
    int position;
    position=is_defined_arr(name);

    if(position != -1){
      
      if(pos < arrtab[position].size){
        arrtab[position].arr[pos]=value;
        if(v_flag==1){
        printf("verbose mode : on line %d the array element %d was assigned value equal to %d\n",linenumber,pos,value);
        }
        }
       else{
        yyerror("exceded the size of the array");
       }
    }

    else{
      yyerror("not defined array");
    }
}

int get_array_value(int pos ,char name[]){
    
    int position=is_defined_arr(name);
    
    if(position != -1){
      
      if(pos < arrtab[position].size){
        return arrtab[position].arr[pos];}
       else{
        yyerror("exceded the size of the array");
       }
    }

    else{
       yyerror("not defined array");
    }
}

void escape(char* in_word,char* out_word){
  int length = strlen(in_word);
  int j = 0;
  for (int i = 1; i < length-1; i++) {
    if (in_word[i] != '\\') {
      out_word[j++] = in_word[i];
    }
  }
  out_word[j] = '\0';
}

// the error function
int yyerror(char *s)
{
	printf("%s on line %d\n", s, linenumber);
	return 0;
}

expr_t* create_expr(exprkind_t kind, expr_t *left, expr_t *right, token_t op) {
    
    expr_t *expr =(expr_t*)malloc(sizeof(expr_t));
    if (!expr) {
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
    }
    expr->kind = kind;

    if(kind == EXPR_UNARY){
        expr->op_pair[0].operand = (tokclosure_t*)malloc(sizeof(tokclosure_t));
        expr->op_pair[0].operand->expr=(void*)left;
        expr->op_pair[0].operation= op; 
      }
    

    if (kind == EXPR_BINARY || kind == EXPR_TERNARY) {
        expr->op_pair[0].operand = (tokclosure_t*)malloc(sizeof(tokclosure_t));
        expr->op_pair[0].operand->expr=(void*)left;
        expr->op_pair[0].operation= op;
        expr->op_pair[1].operand = (tokclosure_t*)malloc(sizeof(tokclosure_t));
        expr->op_pair[1].operand->expr = (void*)right;
        expr->op_pair[1].operation = op;
    }

    return expr;
}
expr_t* create_expr_const(exprkind_t kind,token_t op,int value){
      
      expr_t *expr =(expr_t*)malloc(sizeof(expr_t));
      if (!expr) {
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
      } 
      expr->kind = kind;
      tokclosure_t* operand =(tokclosure_t*)malloc(sizeof(tokclosure_t));
      operand->int_val=value;
      operand->tok=TOK_NUMB;
      expr->op_pair[0].operand = operand;
      expr->op_pair[0].operation = op;
      return expr;
}

expr_t* create_expr_var(exprkind_t kind,token_t op,char var_name[100]){

      expr_t *expr =(expr_t*)malloc(sizeof(expr_t));
      if (!expr) {
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
      }
      expr->kind = kind;
      tokclosure_t* operand =(tokclosure_t*)malloc(sizeof(tokclosure_t));
      operand->tok=TOK_VAR;
      strncpy(operand->var_name, var_name, sizeof(operand->var_name) - 1);
      expr->op_pair[0].operand = operand;
      expr->op_pair[0].operation = op;
      return expr;
}

tokclosure_t create_token(token_t tok,char  var_name[100] ,int int_val ,float float_val ,void* expr){

      tokclosure_t new_token ;
      new_token.tok=tok;
      strcpy(new_token.var_name, var_name);
      new_token.int_val=int_val;
      new_token.expr=expr;

      return new_token;

}







void free_expr(expr_t* expr) {
    if (expr) {
        for (int i = 0; i < 3; i++) {
            if (expr->op_pair[i].operand) {
                free_tokclosure(expr->op_pair[i].operand);
            }
        }
        free(expr);
    }
}

void free_tokclosure(tokclosure_t* tc) {
    if (tc->tok == TOK_EXPR) {
        free_expr((expr_t*)tc->expr);
    }
    free(tc);
}
