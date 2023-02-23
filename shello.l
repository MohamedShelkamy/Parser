%{
#include <stdio.h>
#include "var_helper.h"
#include "main.h"
#include "shello.tab.h"

int linenumber = 1;
%}


digit	([0-9])
alpha     [A-Za-z]

%%
[ \t\r]+ 
"="             {return (EQ);}
"+"             {return (PLUS);}
"/"             {return (DIV);}
"*"             {return (MUL);}
"-"             {return (SUB);}
"("             {return (LPAREN);}
")"             {return (RPAREN);}
"["             {return (LBRACKET);}
"]"             {return (RBRACKET);}
"{"             {return LBRACE;}
"}"             {return RBRACE;}
"dim"           {return (DIM);}
"print"         {return (PRINT);}
";"	            {return (TOK_SEMICOLON);}
"<="            { return LE; }
">="            { return GE; }
"<"             { return LT; }
">"             { return GT; }
"=="            { return EEQ;}
"!="            { return NE; }
"&&"            { return AND;}
"||"            { return OR; }
"if"            { return IF; }
"else"          { return ELSE;}

{digit}+        {
				    yylval.int_val = atoi(yytext); 
				    return TOK_NUM; 
			    }

\"(\\.|[^\"\\])*\" {
               
               escape(yytext,yylval.name);
               return (STRING);
                
                   }

                              

[a-z][A-Za-z0-9]*   {sscanf(yytext, "%s", yylval.name); return(TOK_IDENT);}
[\n] 	            {linenumber++;}

.              {
                   printf("Unrecognized character: %s\n", yytext);
               }
%%

int yywrap(){
     return 1;
}