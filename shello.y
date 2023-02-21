%{   
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "main.h"
#include "var_helper.h"
int yylex();
%}

%token LET EQ PLUS DIV MUL SUB LPAREN RPAREN 
       LBRACKET RBRACKET DIM PRINT TOK_SEMICOLON 
       TOK_NUM STRING TOK_IDENT ESCAPE LE GE LT 
       GT EEQ NE AND OR LBRACE RBRACE IF ELSE


%union{
	char name[100];
  int int_val;
  myexpr_t* expr;
}

%type<name>    TOK_IDENT
%type<int_val> TOK_NUM
%type<expr>    expr
%type<name>    STRING
%left          PLUS SUB
%left          MUL  DIV
%left          EEQ NE LE GE
%left          LT GT AND OR

%%

prog: prog_lines 
      ;

prog_lines :   | prog_line TOK_SEMICOLON prog_lines
               | if_stmt prog_lines
           ;   

prog_line :    | assignment 
               | dim   
               | print
               ;

assignment : LET TOK_IDENT EQ expr 
           {
                    
           }
           | LET TOK_IDENT LBRACKET expr RBRACKET EQ expr 
           { 
 
           }
           ;

dim  :      DIM TOK_IDENT LBRACKET expr RBRACKET 
            {
              
            };

print :    PRINT LPAREN expr RPAREN { 
           } 
           |
           
           PRINT LPAREN STRING RPAREN{
            
           }
           ;

if_stmt : IF LPAREN expr RPAREN LBRACE prog_lines RBRACE ELSE LBRACE prog_lines RBRACE{};   



expr:
 TOK_NUM
  {
    mytokclosure_t* operand =(mytokclosure_t*)malloc(sizeof(mytokclosure_t));
    operand->int_val=$1;
    operand->tok=TOK_NUMB;
    $$=create_expr(EXPR_UNARY,NULL,NULL,TOK_NUMB,operand);
  }
  
  /*|
  TOK_IDENT LBRACKET expr RBRACKET{
    $$ = get_array_value($3,$1);
  } 
  
  | TOK_IDENT
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_PLUS,NULL);
  }*/
  | expr PLUS expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_PLUS,NULL);
  }
  | expr DIV expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_DIV,NULL);
  }
  | expr MUL expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_MUL,NULL);
  }
  | expr AND expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_AND,NULL);
  }
  | expr OR expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_OR,NULL);
  }
  | expr GT expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_GT,NULL); 
  }
  | expr LT expr
  {     
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_LT,NULL); 
  }
  | expr EEQ expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_EEQ,NULL); 
  }
  | expr NE expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_NE,NULL); 
  }
  | expr GE expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_GE,NULL);
  }
  | expr LE expr
  {
    $$=create_expr(EXPR_BINARY,$1,$3,TOK_LE,NULL); 
  }
  | LPAREN expr RPAREN
  {
   $$=create_expr(EXPR_UNARY,$2,NULL,TOK_EXPR,NULL);
  }
  ;
%%


   
          