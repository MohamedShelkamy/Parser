default:
	flex -l shello.l
	bison -dv shello.y 
	gcc -o shello var_helper.c main.c shello.tab.c lex.yy.c -lfl