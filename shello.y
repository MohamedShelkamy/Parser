%{   
#include <stdio.h>
#include <stdlib.h>
#include <string.h> 
#include "var_helper.h"
#include "main.h"
int yylex();
int global_variable = 1;

%}

%token LET EQ PLUS DIV MUL SUB LPAREN RPAREN 
       LBRACKET RBRACKET DIM PRINT TOK_SEMICOLON 
       TOK_NUM STRING TOK_IDENT ESCAPE LE GE LT 
       GT EEQ NE AND OR LBRACE RBRACE
%token IF ELSE
%union{
	char name[100];
  int int_val;
}

%type<name>    TOK_IDENT
%type<int_val> TOK_NUM
%type<int_val> expr
%type<name>    STRING
%left          PLUS SUB
%left          MUL  DIV
%left          EEQ NE LE GE
%left          LT GT AND OR

%%

prog: prog_lines 
      ;

prog_lines :   | prog_line TOK_SEMICOLON prog_lines
               | if_else_body prog_lines
               | if_body prog_lines
           ;   

prog_line :    | assignment 
               | dim   
               | print
               ;

assignment : LET TOK_IDENT EQ expr 
           {
          if(global_variable){
            insert($4,$2);}
            
           }
           | LET TOK_IDENT LBRACKET expr RBRACKET EQ expr 
           { 
           if(global_variable){
             set_array_value($7,$4 ,$2);}
           }
           ;

dim  :      DIM TOK_IDENT LBRACKET expr RBRACKET 
            {
            if(global_variable){
              insert_arr($4,$2);}
            };

print :    PRINT LPAREN expr RPAREN {if(global_variable){ 
           printf("%d\n",$3);} }
           |
           
           PRINT LPAREN STRING RPAREN{
            if(global_variable){
               printf("%s\n",$3);
            }
           }
           ;

if_else_body : else_stmt prog_lines RBRACE {global_variable = 1;}  
             ;
if_body      : if_stmt prog_lines RBRACE
             ;
else_stmt    : if_stmt prog_lines RBRACE ELSE LBRACE {global_variable = !global_variable;}
          ; 

if_stmt : IF LPAREN expr RPAREN LBRACE{
  
if($3){
  global_variable = 1;
}
else{
  global_variable = 0;
}

};   



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
  | expr AND expr
  {
    $$=$1 && $3;
  }
  | expr OR expr
  {
    $$=$1 || $3;
  }
  | expr GT expr
  {
    $$=$1 > $3; 
  }
   | expr LT expr
  {
    $$=$1 < $3; 
  }
  | expr EEQ expr
  {
    $$=$1 == $3; 
  }
  | expr NE expr
  {
    $$=$1 != $3; 
  }
  | expr GE expr
  {
    $$=$1 >= $3; 
  }
  | expr LE expr
  {
    $$ = $1 <= $3; 
  }
  | LPAREN expr RPAREN
  {
    $$ = $2;
  }
  ;
%%


   
          