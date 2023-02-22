#define yyin stdin  
#include <stdio.h>
#include "var_helper.h"
#include "main.h"
#include "shello.tab.h"


int v_flag = 0;
int i_flag = 0;
int d_flag = 0;


int main(int argc, char *argv[])
{
  token_t* x;

    for (int i = 1; i < argc; i++){
      if (argv[i][0] == '-')
      {
      if (argv[i][1] == 'v')
        v_flag = 1;
      else if (argv[i][1] == 'i')
        i_flag = 1;
      else if (argv[i][1] == 'd')
        d_flag = 1;
      }
      else {
         yyin = fopen(argv[i], "r");
        if (!yyin)
        {
            perror(argv[1]);
            return 1;
        }  
        }
    }
    yyparse();
    fclose(yyin);
    return 0;
}

