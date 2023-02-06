%{
#include <stdio.h>
#include "shello.tab.h"
int linenumber = 1;
%}


digit	([0-9])
alpha     [A-Za-z]

%%
[ \t\r]+ 
"let"           {return (LET);}
"="             {return (EQ);}
"+"             {return (PLUS);}
"/"             {return (DIV);}
"*"             {return (MUL);}
"-"             {return (SUB);}
"("             {return (LPAREN);}
")"             {return (RPAREN);}
"["             {return (LBRACKET);}
"]"             {return (RBRACKET);}
"dim"           {return (DIM);}
"print"         {return (PRINT);}
";"	           {return (TOK_SEMICOLON);}
{digit}+        {
				    yylval.int_val = atoi(yytext); 
				    return TOK_NUM; 
			 } 
\"[^\"]*\"      {   
                   
                   strncpy( yylval.name, yytext + 1, yyleng - 2);
                   return (STRING);
                }
[a-z][A-Za-z0-9]*   {sscanf(yytext, "%s", yylval.name); return(TOK_IDENT);}
[\n] 	          {linenumber++;}

.              {
                   printf("Unrecognized character: %s\n", yytext);
               }
%%

int yywrap(){
     return 1;
}