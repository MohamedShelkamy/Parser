%{   
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "main.h"
#include "var_helper.h"
int yylex();

tokclosure_t* serialized_tokens = NULL;
size_t serialized_tokens_len = 0;

%}

%token EQ PLUS DIV MUL SUB LPAREN RPAREN 
       LBRACKET RBRACKET DIM PRINT TOK_SEMICOLON 
       TOK_NUM STRING TOK_IDENT ESCAPE LE GE LT 
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

builtin:    print
        ;

statement:  builtin TOK_SEMICOLON
            | 
            expr TOK_SEMICOLON
            ;

code_block: statement
            |
            code_block statement
            |
            LBRACE code_block RBRACE 
            |
            if_stmt 
            ;

prog:       code_block 
            ;







print :    PRINT LPAREN expr RPAREN 
           {
           
           } 
           |
           
           PRINT LPAREN STRING RPAREN
           {
            
           }
           ;


if_stmt : IF LPAREN expr RPAREN LBRACE code_block RBRACE ELSE LBRACE code_block RBRACE
          {

          };   




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


   
          