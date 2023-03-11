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

"++"|"--"|"&" {sscanf(yytext, "%s", yylval.name); 
                return(UNARY_OPEARTION);}

"="             {sscanf(yytext, "%s", yylval.name); 
                return(OPERATION);}
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


{digit}+\.{digit}+ {
                   yylval.float_val = atof(yytext);
                   return FLOAT;  
                   }

{digit}+        {
				   yylval.int_val = atoi(yytext); 
				   return INTEGER; 
			    }
"int" {
 sscanf(yytext, "%s", yylval.name); 
 return(DATA_TYPE);            
} 
"void" {
 sscanf(yytext, "%s", yylval.name); 
 return(DATA_TYPE);            
} 

"float" {
 sscanf(yytext, "%s", yylval.name); 
 return(DATA_TYPE);            
} 
"return" {
    return(RETURN);
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