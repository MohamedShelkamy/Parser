CC=gcc
LD=gcc
LEX=flex
YACC=bison

APP=shello
OBJS=var_helper.o main.o
GENS=shello.tab.c lex.yy.c

CCFLAGS=-Wall -Wextra -std=c99
LDFLAGS=-Wall

all: shello
.PHONY: all

clean:
	rm -vf $(OBJS)
	rm -vf $(GENS)

$(APP): $(GENS) $(OBJS)
	$(LD) $(LDFLAGS) -o $(APP) $(OBJS) $(GENS)

shello.tab.c: shello.y
	$(YACC) -dv shello.y

lex.yy.c: shello.l
	$(LEX) -l shello.l

%.o: %.c
	$(CC) $(CCFLAGS) -c $< -o $@