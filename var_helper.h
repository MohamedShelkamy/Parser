#ifndef SYMTAB_H
#define SYMTAB_H

typedef enum {
	TOK_IF,
	TOK_ELSE,
	TOK_STRING,
	TOK_SEMICOLON,
	TOK_PRINT,
	TOK_LPAREN, 
	TOK_RPAREN,
	TOK_LBRACE, 
	TOK_RBRACE,
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
} token_t;

typedef struct {
	token_t tok;
	char  var_name[100];
	int   int_val;
	float float_val;
	void* expr;
} tokclosure_t;

typedef enum {
	EXPR_UNARY,
	EXPR_BINARY,
	EXPR_TERNARY
} exprkind_t;

typedef struct {
	exprkind_t kind;
	struct {
		tokclosure_t* operand;
		token_t operation;
	} op_pair[3];
} expr_t;


int is_defined(char name[]);

int yyerror(char *s);

void insert(int value, char name[]);

int getvalue(int i);

int is_defined_arr(char name[]);

void insert_arr(int value, char name[]);

void set_array_value(int value,int pos ,char name[]);

int get_array_value(int pos ,char name[]);

void escape(char* in_word,char* out_word);

void add_token_type(token_t tok);

void add_token_string(token_t tok,char var_name[100]);

void add_token_number(token_t tok ,int int_val);

expr_t* create_expr(exprkind_t kind, expr_t *left, expr_t *right, token_t op);

expr_t* create_expr_const(exprkind_t kind,token_t op,int value);

expr_t* create_expr_var(exprkind_t kind,token_t op, char var_name[100]);

void free_expr(expr_t* expr);

void free_tokclosure(tokclosure_t* tc);

#endif
