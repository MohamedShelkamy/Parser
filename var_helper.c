#include <stdio.h>  
#include <stdlib.h>
#include <string.h> 
#include "var_helper.h"
#include "main.h"

extern int linenumber;
extern int v_flag ;
extern int i_flag ;
extern int d_flag ;

struct symtab{                                      
	char name[20];                                  
	int val;                                  
};

struct arrtab{                                      
	char name[20];                                  
	int  *arr;
    int size;                                  
};

struct symtab tab[200];

struct arrtab arrtab[200];
int ptr     = 0;   
int ptr_arr = 0; 


int getvalue(int i){
  return tab[i].val;
}

int is_defined(char name[]){
    
    int i;
	int flag = -1;

	for(i = 0; i < ptr; i++){
		if(strcmp(tab[i].name, name) == 0){
			flag = i;
			break;
		}
	}

	return flag;
}


void insert(int value, char name[]){
    int position;
    position=is_defined(name);
    if(position== -1){     
      if(v_flag==1){
       printf("verbose mode : identifier %s was defined on line %d with value equal to %d\n", name,linenumber ,value);
      }
      tab[ptr].val=value;
      strcpy(tab[ptr].name, name);
      ptr++;
    }
    else {
      tab[position].val=value; 
    }

}


// this part is responsible for the array definitions

int is_defined_arr(char name[]){
    
  int i;
	int flag = -1;

	for(i = 0; i < ptr_arr; i++){
		if(strcmp(arrtab[i].name, name) == 0){
			flag = i;
			break;
		}
	}

	return flag;
}

void insert_arr(int size, char name[]){
    int position;
    position=is_defined_arr(name);
    if(position== -1){
      arrtab[ptr_arr].arr=malloc(size * sizeof(int));
      arrtab[ptr_arr].size=size;
      if(arrtab[ptr_arr].arr== NULL){
        yyerror("failed to initiate the array");
      }
      
      strcpy(arrtab[ptr_arr].name, name);
      if(v_flag==1){
        printf("verbose mode : an %s was defined on line %d with size %d\n", name,linenumber,size);
      }
      
      ptr_arr++;
    }
    else {
      yyerror("already defined array");
    }
}

void set_array_value(int value,int pos ,char name[]){
    int position;
    position=is_defined_arr(name);

    if(position != -1){
      
      if(pos < arrtab[position].size){
        arrtab[position].arr[pos]=value;
        printf("verbose mode : on line %d the array element %d was assigned value equal to %d\n",linenumber,pos,value);
        }
       else{
        yyerror("exceded the size of the array");
       }
    }

    else{
       yyerror("not defined array");
    }
}

int get_array_value(int pos ,char name[]){
    
    int position=is_defined_arr(name);
    
    if(position != -1){
      
      if(pos < arrtab[position].size){
        return arrtab[position].arr[pos];}
       else{
        yyerror("exceded the size of the array");
       }
    }

    else{
       yyerror("not defined array");
    }
}

// the error function
int yyerror(char *s)
{
	printf("%s on line %d\n", s, linenumber);
	return 0;
}

