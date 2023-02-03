#ifndef SYMTAB_H
#define SYMTAB_H


int is_defined(char name[]);

int yyerror(char *s);

void insert(int value, char name[]);

int getvalue(int i);

int is_defined_arr(char name[]);

void insert_arr(int value, char name[]);

void set_array_value(int value,int pos ,char name[]);

int get_array_value(int pos ,char name[]);

#endif
