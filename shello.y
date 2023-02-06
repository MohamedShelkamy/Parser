%{   
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "var_helper.h"
#include "main.h"
int yylex();
%}

%token LET EQ PLUS DIV MUL SUB LPAREN RPAREN 
       LBRACKET RBRACKET DIM PRINT TOK_SEMICOLON 
       TOK_NUM STRING TOK_IDENT

%union{
	char name[100];
  int int_val;
}

%type<name>    TOK_IDENT
%type<int_val> TOK_NUM
%type<int_val> expr
%type<name>    STRING

%left PLUS SUB
%left MUL  DIV

%%
prog: prog_lines 
      ;

prog_lines :   | prog_line TOK_SEMICOLON prog_lines
           ;  

prog_line :    | assignment 
               | dim   
               | print 
          ;

assignment : LET TOK_IDENT EQ expr 
           {
            insert($4,$2);
            
           }
           | LET TOK_IDENT LBRACKET expr RBRACKET EQ expr 
           { 
           set_array_value($7,$4 ,$2);
           }
           ;

dim  :      DIM TOK_IDENT LBRACKET expr RBRACKET 
            {
            insert_arr($4,$2);
            };

print :    PRINT LPAREN expr RPAREN {printf("%d\n",$3);}
           |
           PRINT LPAREN STRING RPAREN{printf("%s\n",$3);}
           ;

expr:
  TOK_NUM
  {
    $$ = $1;
  }
  |
  TOK_IDENT LBRACKET expr RBRACKET{
    $$ = get_array_value($3,$1);
  } 
  
  | TOK_IDENT
  {
    int i = is_defined($1);
    if (i == -1) {
      yyerror("Undeclared identifier");
      exit(1);
    } else {
      $$ = getvalue(i);
    }
  }
  | expr PLUS expr
  {
    $$ = $1 + $3;
  }
  | expr DIV expr
  {
    $$ = $1 / $3;
  }
  | expr MUL expr
  {
    $$ = $1 * $3;
  }
  | LPAREN expr RPAREN
  {
    $$ = $2;
  };

%%


  