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
       INTEGER STRING TOK_IDENT LBRACE RBRACE IF ELSE
       DATA_TYPE OPERATION WHILE FOR COMMA FLOAT RETURN

%union{
	char name[100];
  float float_val;
  int int_val;
  expr_t* expr;
}

%type<name>    TOK_IDENT
%type<name>    DATA_TYPE
%type<name>    OPERATION
%type<int_val> INTEGER
%type<float_val> FLOAT
%type<expr>    expr
%type<expr>    function_call
%type<expr>    input_list
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
            assigment 
            |
            tok_semicolon
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
            |
            while_stmt
            |
            code_block while_stmt
            |
            function
            |
            code_block function
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
string    :   STRING
              {
              add_token_string(TOK_STRING,$1);              
              }
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

if_stmt : If lparen final_expr rparen lbrace code_block rbrace Else lbrace code_block rbrace
          |
          If lparen final_expr rparen lbrace code_block rbrace
          |
          If lparen final_expr rparen statement
          ;

While   : WHILE 
          {
          add_token_type(TOK_WHILE);             
          }
          ;

while_stmt : While lparen final_expr rparen lbrace code_block rbrace
           
type_name : DATA_TYPE TOK_IDENT
            {
            add_token_string(TOK_DT,$1);
            add_token_string(TOK_NAME,$2);
            }
          ;

comma     : COMMA{add_token_type(TOK_COMMA);}
          ;
 
parameter_list:
               | type_name
               | parameter_list comma type_name

function : type_name lparen parameter_list rparen lbrace code_block rbrace


input_list : {$$=create_expr(EXPR_UNARY,NULL,NULL,TOK_EMPTY);}
             |expr {$$=create_expr(EXPR_UNARY,$1,NULL,TOK_INPUTLIST);}
             |input_list comma expr{$$=create_expr(EXPR_BINARY,$1,$3,TOK_INPUTLIST);}
                
             
function_call : expr LPAREN input_list RPAREN
              {
               $$=create_expr(EXPR_BINARY,$1,$3,TOK_CALL); 
              }
              ;

assigment :DATA_TYPE expr EQ expr tok_semicolon
          { 
          set_data_type($2,$1);
          add_token_expr(TOK_EXPR,create_expr(EXPR_BINARY,$2,$4,TOK_ASSIGNMENT));  
          }
          | expr EQ expr tok_semicolon
          {
          set_data_type($1,"10");  
          add_token_expr(TOK_EXPR,create_expr(EXPR_BINARY,$1,$3,TOK_ASSIGNMENT));  
          }
          |
          expr EQ function_call tok_semicolon
          {
          set_data_type($1,"10");  
          add_token_expr(TOK_EXPR,create_expr(EXPR_BINARY,$1,$3,TOK_ASSIGNMENT));  
          }
          |
          DATA_TYPE expr tok_semicolon  
          {
           set_data_type($2,$1); 
           add_token_expr(TOK_EXPR,create_expr(EXPR_UNARY,$2,NULL,TOK_ASSIGNMENT)); 
          }
          ;
expr:
 
 INTEGER
  {
    $$=create_expr_const(EXPR_UNARY,TOK_NUMB,$1,0,DT_INT);
  }
  | FLOAT
  {
    $$=create_expr_const(EXPR_UNARY,TOK_NUMB,0,$1,DT_FLOAT);
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
