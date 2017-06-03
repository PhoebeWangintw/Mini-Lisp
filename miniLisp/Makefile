all:
	bison -d -o file.tab.cc file.yy
	g++ -c -g -I.. file.tab.cc
	flex -o lex.yy.cc file.l
	g++ -c -g -I.. lex.yy.cc
	g++ -o file file.tab.o lex.yy.o -ll
clear:
	rm file file.tab.o lex.yy.o lex.yy.cc file.tab.cc file.tab.hh
