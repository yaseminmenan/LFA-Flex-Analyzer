# Menan Yasemin 336CC

build:
	flex tema.l
	gcc lex.yy.c -o tema

run1:
	./tema < test1.in

run2:
	./tema < test2.in

run3:
	./tema < test3.in

run4:
	./tema < test4.in

clean:
	rm -f tema lex.yy.c