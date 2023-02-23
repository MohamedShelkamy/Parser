%{   
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "main.h"
#include "var_helper.h"
int yylex();

tokclosure_t* Program_tokens = NULL;
size_t Program_tokens_len = 0;
tokclosure_t new_token;

%}

%token EQ PLUS DIV MUL SUB LPAREN RPAREN 
       LBRACKET RBRACKET DIM PRINT SEMICOLON 
       TOK_NUM STRING TOK_IDENT LE GE LT 
       GT EEQ NE AND OR LBRACE RBRACE IF ELSE


%union{
	char name[100];
  int int_val;
  expr_t* expr;
}

%type<name>    TOK_IDENT
%type<int_val> TOK_NUM
%type<expr>    expr
%type<name>    STRING
%left          PLUS SUB
%left          MUL  DIV
%left          EEQ NE LE GE
%left          LT GT AND OR EQ

%start      prog

%%

builtin     : print
            ;

final_expr : expr
            ;

statement:  builtin tok_semicolon
            | 
            final_expr tok_semicolon
            ;

code_block: statement
            |
            code_block statement
            |
            LBRACE code_block RBRACE 
            |
            if_stmt 
            |
            code_block if_stmt
            ;

prog:       code_block 
            ;


print_symp  : PRINT
            {
            new_token = create_token_type(TOK_PRINT);
            Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
            Program_tokens[Program_tokens_len-1] = new_token;  
            }
            ;

lparen      : LPAREN
            {
            new_token = create_token_type(TOK_LPAREN);
            Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
            Program_tokens[Program_tokens_len-1] = new_token;            
            }
            ;

rparen      : RPAREN
            {
            new_token = create_token_type(TOK_RPAREN);
            Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
            Program_tokens[Program_tokens_len-1] = new_token;            
            }
            ;

lbrace      : LBRACE
            {
            new_token = create_token_type(TOK_LBRACE);
            Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
            Program_tokens[Program_tokens_len-1] = new_token;            
            }
            ;    

rbrace      : RBRACE
            {
            new_token = create_token_type(TOK_RBRACE);
            Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
            Program_tokens[Program_tokens_len-1] = new_token;            
            }
            ;   

tok_semicolon : SEMICOLON
              {
              new_token = create_token_type(TOK_SEMICOLON);
              Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
              Program_tokens[Program_tokens_len-1] = new_token;              
              }
              ;


print     :   print_symp lparen final_expr rparen 
              |           
              print_symp lparen string rparen 
              ;

If        :   IF
              {
              new_token = create_token_type(TOK_IF);
              Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
              Program_tokens[Program_tokens_len-1] = new_token;              
              }
              ;

Else          : ELSE
              {
              new_token = create_token_type(TOK_ELSE);
              Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
              Program_tokens[Program_tokens_len-1] = new_token;              
              }
              ;

string    :   STRING
              {
              new_token = create_token_string(TOK_STRING,$1);
              Program_tokens = (tokclosure_t*)realloc(Program_tokens, sizeof(tokclosure_t) * (++Program_tokens_len));
              Program_tokens[Program_tokens_len-1] = new_token;              
              }
              ; 

if_stmt : If lparen final_expr rparen lbrace code_block rbrace Else lbrace code_block rbrace
          |
          If lparen final_expr rparen lbrace code_block rbrace
          ;   


expr:
 
 TOK_NUM
  {
    $$=create_expr_const(EXPR_UNARY,TOK_NUMB,$1);
  }  
  | TOK_IDENT
  {
    $$=create_expr_var(EXPR_UNARY,TOK_VAR,$1);
  }
  | expr EQ expr  
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_ASSIGNMENT);                 
  }
  | expr PLUS expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_PLUS);
  }
  | expr DIV expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_DIV);
  }
  | expr MUL expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_MUL);
  }
  | expr AND expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_AND);
  }
  | expr OR expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_OR);
  }
  | expr GT expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_GT); 
  }
  | expr LT expr
  {     
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_LT); 
  }
  | expr EEQ expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_EEQ); 
  }
  | expr NE expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_NE); 
  }
  | expr GE expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_GE);
  }
  | expr LE expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_LE); 
  }
  | LPAREN expr RPAREN
  {
   $$=create_expr(EXPR_UNARY,$2,NULL,TOK_EXPR);
  }
  ;
%%


   
          