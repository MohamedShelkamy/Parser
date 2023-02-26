%{   
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "main.h"
#include "var_helper.h"
int yylex();

%}

%token EQ LPAREN RPAREN 
       LBRACKET RBRACKET DIM PRINT SEMICOLON 
       TOK_NUM STRING TOK_IDENT LBRACE RBRACE IF ELSE
       DATA_TYPE OPERATION

%union{
	char name[100];
  int int_val;
  expr_t* expr;
}

%type<name>    TOK_IDENT
%type<name>    DATA_TYPE
%type<name>    OPERATION
%type<int_val> TOK_NUM
%type<expr>    expr
%type<name>    STRING
%left          EQ
%left          OPERATION

%start      prog

%%

builtin     : print
            ;

final_expr : expr
            {
            add_token_expr(TOK_EXPR,$1);
            }
            ;

statement:  builtin tok_semicolon
            | 
            final_expr tok_semicolon
            |
            assigment tok_semicolon
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
            add_token_type(TOK_PRINT);
            }
            ;

lparen      : LPAREN
            {
            add_token_type(TOK_LPAREN);           
            }
            ;

rparen      : RPAREN
            {
            add_token_type(TOK_RPAREN);            
            }
            ;

lbrace      : LBRACE
            {
            add_token_type(TOK_LBRACE);       
            }
            ;    

rbrace      : RBRACE
            {
             add_token_type(TOK_RBRACE);           
            }
            ;   

tok_semicolon : SEMICOLON
              {
              add_token_type(TOK_SEMICOLON);            
              }
              ;


print     :   print_symp lparen final_expr rparen 
              |           
              print_symp lparen string rparen 
              ;

If        :   IF
              {
              add_token_type(TOK_IF);             
              }
              ;

Else          : ELSE
              {
              add_token_type(TOK_ELSE);             
              }
              ;

string    :   STRING
              {
              add_token_string(TOK_STRING,$1);              
              }
              ; 

if_stmt : If lparen final_expr rparen lbrace code_block rbrace Else lbrace code_block rbrace
          |
          If lparen final_expr rparen lbrace code_block rbrace
          |
          If lparen final_expr rparen statement
          ;   


assigment :DATA_TYPE expr EQ expr
          {
          add_token_expr(TOK_EXPR,create_expr(EXPR_BINARY,$2,$4,TOK_ASSIGNMENT));  
          }
          | expr EQ expr
          {
          add_token_expr(TOK_EXPR,create_expr(EXPR_BINARY,$1,$3,TOK_ASSIGNMENT));  
          }
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
  | expr OPERATION expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,get_operation($2));
  }
  | LPAREN expr RPAREN
  {
   $$=create_expr(EXPR_UNARY,$2,NULL,TOK_EXPR);
  }
  ;
%%


   
          