#ifndef SYMTAB_H
#define SYMTAB_H

typedef enum
{
	TOK_WHILE,
	TOK_FOR,
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
	TOK_COMMA,
	TOK_DT,
	TOK_NAME,
	TOK_INPUTLIST,
	TOK_CALL,
	TOK_EMPTY,
	TOK_PREPLUS, 
	TOK_POSTPLUS,
	TOK_PREMINUS, 
	TOK_POSTMINUS,
	TOK_ADRESS
} token_t;

typedef enum
{
	DT_INT,
	DT_FLOAT
} data_type;

typedef struct
{
	token_t tok;
	data_type kind;
	char var_name[100];
	int int_val;
	float float_val;
	void *expr;
} tokclosure_t;

typedef enum
{
	EXPR_UNARY,
	EXPR_BINARY,
	EXPR_TERNARY
} exprkind_t;

typedef struct
{
	exprkind_t kind;
	struct
	{
		tokclosure_t *operand;
		token_t operation;
	} op_pair[3];
} expr_t;

typedef struct 
{
  char name[20];
  int val;
  float float_val;
  data_type kind;	
}parameters_t;


struct symtab
{
  char name[20];
  int val;
  float float_val;
  data_type kind;
};

struct arrtab
{
  char name[20];
  int *arr;
  int size;
};

struct funtab
{
char name[200];
size_t start_token;
size_t end_token;
data_type return_type;
int    par_num;
int    par_set;
parameters_t* function_parameters;
};

int is_defined(char name[]);

int is_defined_fun(char name[]);

int yyerror(char *s);

void ins_fun_par(float value, char name[]);

void insert(float value, char name[], data_type dt);

float getvalue(int i);

float get_variable_value(char name[]);

int is_defined_arr(char name[]);

void insert_arr(int value, char name[]);

void set_array_value(int value, int pos, char name[]);

int get_array_value(int pos, char name[]);

void escape(char *in_word, char *out_word);

void add_token_type(token_t tok);

void add_token_string(token_t tok, char var_name[100]);

void add_token_number(token_t tok, int int_val);

void add_token_expr(token_t tok, expr_t *expr);

expr_t *create_expr(exprkind_t kind, expr_t *left, expr_t *right, token_t op);

expr_t *create_expr_const(exprkind_t kind, token_t op, int value, float float_value, data_type dt);

expr_t *create_expr_var(exprkind_t kind, token_t op, char var_name[100]);

void set_data_type(expr_t *expr, char name[]);

void interpereter();

void take_branch();

void skip_branch();

char *assign(expr_t *expr);

expr_t * precedence_expr_tree(expr_t *current , expr_t *parent,expr_t *root);

float execute_expr(expr_t *expr);

token_t get_operation(char var_name[],char post_pre_fix[]);

data_type get_type(expr_t *expr);

void display(tokclosure_t token);

void while_handler();

void free_expr(expr_t *expr);

void free_tokclosure(tokclosure_t *tc);

void define_function();

int get_func_parameters();

data_type get_par_type(char type[]);

void function_boundary();

float call_function(expr_t *fun ,expr_t *par);

void set_function_parameter(expr_t *expr);

float execute_function(char name[]);

#endif
