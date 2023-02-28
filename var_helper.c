#include <stdio.h>  
#include <stdlib.h>
#include <string.h> 
#include "main.h"
#include "var_helper.h"


extern int linenumber;
extern int v_flag ;
extern int i_flag ;
extern int d_flag ;

tokclosure_t* Program_tokens = NULL;
size_t Program_tokens_len = 0;
size_t current_token =0; 
tokclosure_t new_token;
int lrbrace=0;
int sloop_token;
int eloop_token;
struct symtab{                                      
	char name[20];                                  
	int val;                                  
};

struct arrtab{                                      
	char name[20];                                  
	int  *arr;
  int  size;                                  
};

struct symtab tab[200];

struct arrtab arrtab[200];
int ptr     = 0;   
int ptr_arr = 0; 


int getvalue(int i){
  return tab[i].val;
}


// this function is responsible to check if the the variable is defined before or not
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

// this function is responsible to return the value of the variable if defined , otherwise it will throw an error
int get_variable_value(char name[]){  
    int i = is_defined(name);
    if (i == -1) {
      yyerror("Undeclared identifier");
      exit(1);
    } else {
      return getvalue(i);
    }

}

// this function is responsible to insert a variable

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
    return 0;
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

token_t get_operation(char var_name[]){
   
    if (strcmp(var_name, "+") == 0) {
        return TOK_PLUS;
    } else if (strcmp(var_name, "/") == 0) {
        return TOK_DIV;
    } else if (strcmp(var_name, "*") == 0) {
        return TOK_MUL;
    } else if (strcmp(var_name, "-") == 0) {
        return TOK_MINUS; 
    } else if (strcmp(var_name, "<=") == 0) {
        return TOK_LE;
    } else if (strcmp(var_name, ">=") == 0) {
        return TOK_GE;
    } else if (strcmp(var_name, "<") == 0) {
        return TOK_LT;
    } else if (strcmp(var_name, ">") == 0) {
        return TOK_GT;
    } else if (strcmp(var_name, "==") == 0) {
        return TOK_EEQ;
    } else if (strcmp(var_name, "!=") == 0) {
        return TOK_NE;
    } else if (strcmp(var_name, "&&") == 0) {
        return TOK_AND;
    } else if (strcmp(var_name, "||") == 0) {
        return TOK_OR;}
      else{
        fprintf(stderr, "unexpected operation\n");
        exit(1);
      }
        
    }
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
expr_t* create_expr(exprkind_t kind, expr_t *left, expr_t *right, token_t op) {
    
    expr_t *expr =(expr_t*)malloc(sizeof(expr_t));
    if (!expr) {
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
    }
    expr->kind = kind;
    expr->op_pair[0].operand = (tokclosure_t*)malloc(sizeof(tokclosure_t));
    if (!expr->op_pair[0].operand) {
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
    }
    expr->op_pair[0].operation= op;
    expr->op_pair[0].operand->expr=(void*)left;
    
    if(kind == EXPR_UNARY){        
        expr->op_pair[0].operand->tok=TOK_EXPR;
      }
    

    if (kind == EXPR_BINARY || kind == EXPR_TERNARY) {
        expr->op_pair[1].operand = (tokclosure_t*)malloc(sizeof(tokclosure_t));
        if (!expr->op_pair[0].operand){
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
        }
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// the coming four methods are responsible to add the program tokens into our serialized tokens vector
// as this serialized tokens will be executed later by the interpereter.

void add_token_type(token_t tok){
      tokclosure_t new_token ;
      new_token.tok=tok;
      Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
      if(!Program_tokens){
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
      }
      Program_tokens[Program_tokens_len-1] = new_token; 

}

void add_token_string(token_t tok,char var_name[100]){
      tokclosure_t new_token ;
      new_token.tok=tok;
      strcpy(new_token.var_name, var_name);
      Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
      if(!Program_tokens){
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
      }
      Program_tokens[Program_tokens_len-1] = new_token; 
}

void add_token_number(token_t tok ,int int_val){
      tokclosure_t new_token ;
      new_token.tok=tok;
      new_token.int_val=int_val;
      Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
      if(!Program_tokens){
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
      }
      Program_tokens[Program_tokens_len-1] = new_token; 

}

void add_token_expr(token_t tok ,expr_t *expr){
      tokclosure_t new_token ;
      new_token.tok=tok;
      new_token.expr=(void*)expr;
      Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
      if(!Program_tokens){
        fprintf(stderr, "Error: Out of memory\n");
        exit(1);
      }
      Program_tokens[Program_tokens_len-1] = new_token; 

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// this function is responsible to execute any expression recursively

int execute_expr(expr_t *expr){
    
    tokclosure_t* operand  = expr->op_pair[0].operand;  // first operand
    tokclosure_t* soperand = expr->op_pair[1].operand;  // second operand
    switch(expr->kind) {
      
      case EXPR_UNARY:
      
      switch(operand->tok) {
        
        case TOK_NUMB:
        return operand->int_val;
        break;

        case TOK_VAR:
        return get_variable_value(operand->var_name);
        break;
           
        case TOK_EXPR:
        return execute_expr((expr_t*)operand->expr);
        break;

        default:
        fprintf(stderr, "unexpected operation type\n");
        exit(1);
        return 0;
      }

      break;
 
      case EXPR_BINARY:
         switch (expr->op_pair[0].operation)
         {
         case TOK_PLUS:
          return execute_expr((expr_t*)operand->expr) + execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_MINUS:
          return execute_expr((expr_t*)operand->expr) - execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_DIV:
           return execute_expr((expr_t*)operand->expr) / execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_MUL:
          return execute_expr((expr_t*)operand->expr) * execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_LE:
          return execute_expr((expr_t*)operand->expr) <= execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_GE:
          return execute_expr((expr_t*)operand->expr) >= execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_LT:
          return execute_expr((expr_t*)operand->expr) < execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_GT:
          return execute_expr((expr_t*)operand->expr) >  execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_EEQ:
          return execute_expr((expr_t*)operand->expr) == execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_NE:
          return execute_expr((expr_t*)operand->expr) != execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_AND:
           return execute_expr((expr_t*)operand->expr) && execute_expr((expr_t*)soperand->expr);
         break;

         case TOK_OR:
           return execute_expr((expr_t*)operand->expr) || execute_expr((expr_t*)soperand->expr);
         break;
         
         case TOK_ASSIGNMENT:
           
           insert(execute_expr((expr_t*)soperand->expr),assign((expr_t*)operand->expr));
           return 1;
           break;
         default:
          fprintf(stderr, "unexpected operation\n");
          exit(1); 
          return 0;
          break;
         }  
        break;

      default:
      fprintf(stderr, "unexpected type\n");
      exit(1); 
      return 0;

     }
  
}

char* assign(expr_t *expr){
  
  tokclosure_t* operand = expr->op_pair[0].operand; 
  if(expr->op_pair[0].operation != TOK_VAR || expr->kind != EXPR_UNARY ){
    fprintf(stderr, "wrong assigment\n");
    exit(1); 
  }

  return operand->var_name;
  
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void interpereter(){                      // this function is responsible to interperete the parsed program , it works in a recursive way
 if(current_token >= Program_tokens_len) 
   return;
 token_t tok=Program_tokens[current_token].tok;
 switch (tok)                             // this switch case is responsible to check for the different tok closure in our serilaized vector 
 {
 case TOK_PRINT :                         // case print 
  current_token = current_token+2;        // from the parser structure we know the expected structure so by this it will access the print statement
  printf("%s\n",Program_tokens[current_token].var_name);
  current_token++;
  break;
 case TOK_IF :                            // case if we check for the expression if it is true we procceed with the next token if not we skip the whole block
  current_token = current_token+2;        // we access the expression token to check if it is true or false
  if(execute_expr((expr_t*)Program_tokens[current_token].expr)){
    current_token = current_token+2;      // if true we continue normally
  }
  else {                                  // if false we skip the next block 
    current_token = current_token+2;      // by this our token will point to the correct block
    skip_branch();                        // this one will return back to the else block "one token after else token"
  }
  break;
 
 case TOK_EXPR :
  execute_expr((expr_t*)Program_tokens[current_token].expr);
  current_token++;
  break;
 
 case TOK_ELSE :   // if we reached this token it means we took the if branch so we have to skip this block 
 current_token++;
 skip_branch();    
 break;
 
 default:
  current_token++;
  break;
 }
 interpereter();
}


void skip_branch(){ // this method is responsible to skip either if or else blocks 
 
if(Program_tokens[current_token].tok==TOK_LBRACE){
  lrbrace++;

 }
 else{
  current_token++;
 }

while (lrbrace != 0 && current_token<= Program_tokens_len)
 {
  current_token++;
  if(Program_tokens[current_token].tok==TOK_LBRACE){
  lrbrace++; 
  }

  else if (Program_tokens[current_token].tok==TOK_RBRACE)
  {
    lrbrace--;
  }
  

}
current_token++;
if(Program_tokens[current_token].tok==TOK_ELSE){
  current_token++;
  }
 
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// these two functions are responsible to free the memory

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