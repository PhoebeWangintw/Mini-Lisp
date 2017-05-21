all:
	bison -d -o y.tab.c file.y
	gcc -c -g -I.. y.tab.c
	flex -o lex.yy.c file.l
	gcc -c -g -I.. lex.yy.c
	gcc -o file y.tab.o lex.yy.o -ll

clean:
	rm lex.yy.c lex.yy.o y.tab.c  y.tab.h  y.tab.o
