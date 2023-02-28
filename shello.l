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
"+"             { sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"/"             { sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"*"             { sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"-"             { sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"("             {return (LPAREN);}
")"             {return (RPAREN);}
"["             {return (LBRACKET);}
"]"             {return (RBRACKET);}
"{"             {return LBRACE;}
"}"             {return RBRACE;}
"dim"           {return (DIM);}
"print"         {return (PRINT);}
";"	            {return (SEMICOLON);}
"<="            {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
">="            {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"<"             {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
">"             {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"=="            {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"!="            {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"&&"            {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"||"            {sscanf(yytext, "%s", yylval.name); 
                  return(OPERATION);}
"if"            { return IF; }
"else"          { return ELSE;}
"while"         { return WHILE;}
"for"           { return FOR;}
","             {return COMMA;}

{digit}+        {
				    yylval.int_val = atoi(yytext); 
				    return TOK_NUM; 
			    }
(int|float|double|char|void|short|long|unsigned|signed|bool|size_t|void) {
 sscanf(yytext, "%s", yylval.name); 
 return(DATA_TYPE);            
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