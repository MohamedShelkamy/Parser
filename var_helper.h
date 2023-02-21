#ifndef SYMTAB_H
#define SYMTAB_H

typedef enum {
	TOK_NUMB,
	TOK_LET,
	TOK_EXPR,
	TOK_ASSIGNMENT,
	TOK_PLUS,
    TOK_VAR,
    TOK_MINUS,
    TOK_DIV,
    TOK_MUL,
	TOK_LE, 
	TOK_GE,
	TOK_LT,
 	TOK_GT, 
    TOK_EEQ, 
	TOK_NE, 
	TOK_AND, 
	TOK_OR, 
} mytoken_t;

typedef struct {
	mytoken_t tok;
	char var_name[100];
	int int_val;
	float float_val;
	void* expr;
} mytokclosure_t;

typedef enum {
	EXPR_UNARY,
	EXPR_BINARY,
	EXPR_TERNARY
} myexprkind_t;

typedef struct {
	myexprkind_t kind;
	struct {
		mytokclosure_t* operand;
		mytoken_t operation;
	} op_pair[3];
} myexpr_t;


int is_defined(char name[]);

int yyerror(char *s);

void insert(int value, char name[]);

int getvalue(int i);

int is_defined_arr(char name[]);

void insert_arr(int value, char name[]);

void set_array_value(int value,int pos ,char name[]);

int get_array_value(int pos ,char name[]);

void escape(char* in_word,char* out_word);

myexpr_t* create_expr(myexprkind_t kind, myexpr_t *left, myexpr_t *right, mytoken_t op);

myexpr_t* create_expr_const(myexprkind_t kind,mytoken_t op,int value);

myexpr_t* create_expr_var(myexprkind_t kind,mytoken_t op, char var_name[100]);

void free_expr(myexpr_t* expr);

void free_tokclosure(mytokclosure_t* tc);

#endif
