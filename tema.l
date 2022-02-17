Menan Yasemin 336CC

%{
#include<stdio.h>
#include <stdlib.h>

char* object_name;
int nr_vertex;
int nr_faces;
int nr_texture;
int indent;
int composed;
char* texture;
char* img_name;
int nr_coords;
%}

letter [A-Za-z]
letter_lower [a-z]
digit [0-9]
sign [+-]?
nr_natural {digit}+
nr_real {sign}{nr_natural}\.{nr_natural}?
letter_digit [a-zA-Z0-9_]
name {letter}{letter_digit}+
newline [\n]
ignore [ \t\n]
img {letter_digit}+\.{letter_lower}+

%s GET_NAME
%s VERTEX
%s FACE
%s TEXTURE
%s IMG
%s COMPOSED_NAME
%s INSIDE_COMPOSED
%s INSIDE_OBJECT
%s INSIDE_VERTEX
%s INSIDE_TEXTURE

%%

    /* Stare initiala in care se cauta un obiect care nu face parte din compozitia altui obiect */
<INITIAL>"Object" { 
                    BEGIN(GET_NAME); 
                    nr_vertex = 0; 
                    nr_faces = 0;
                    nr_texture = 0;
                    texture = "fara textura";
                    composed = 0;
                    indent = 0;
                  }

    /* Stare pentru citirea si retinerea numeului obiectului */
<GET_NAME>{name}+  { 
                             object_name = malloc(yyleng+1);
                             strcpy(object_name, yytext); 
                           }

<GET_NAME>"{" { 
                if (composed == 0) {
                    BEGIN(INSIDE_OBJECT);
                } else {
                    BEGIN(INSIDE_COMPOSED);
                }
              }

<GET_NAME>{ignore}* ;

    /* Stare in care se citeste descrierea obiectului */
<INSIDE_OBJECT>"vertexes" { BEGIN(VERTEX); }

<INSIDE_OBJECT>"faces" { BEGIN(FACE); }

<INSIDE_OBJECT>"texture" {BEGIN(TEXTURE); }

<INSIDE_OBJECT>"img" { BEGIN(IMG); }

    /* Obiectul curent este un obiect compus, care contine alte obiecte */
<INSIDE_OBJECT>"Object" { 
                          /* Daca este primul obiect gasit in descrierea obiectului curent,
                           * afisez obiectul curent si incep sa citesc descrierea noului
                           * obiect gasit
                           */
                          if(composed == 0) {
                              printf("Object %s: varfuri: %d, fete: %d, %s\n", object_name, nr_vertex, nr_faces, texture);
                              composed++;
                          }

                          /* Resetez variabilele cu specificatiile obiectului si incep citirea
                           * noului obiect gasit, incrementand indentarea pentru afisare
                           */
                          BEGIN(GET_NAME);
                          nr_vertex = 0; 
                          nr_faces = 0;
                          nr_texture = 0;
                          texture = "fara textura";
                          indent++;
                        } 

    /* S-a terminat de citit descrierea obiectului curent */
<INSIDE_OBJECT>"}" {
                     /* Daca obiectul este unul simplu, nu este compus, il afisez */
                     if (composed == 0) {
                        printf("Object %s: varfuri: %d, fete: %d, %s\n", object_name, nr_vertex, nr_faces, texture); 
                     }

                     /* Caut urmatorul obiect din fisier */
                     BEGIN(INITIAL);
                    }

<INSIDE_OBJECT>{ignore}* ;

    /* Stare in care se citeste descrierea obiectului aflat intr-un obiect compus */
<INSIDE_COMPOSED>"vertexes" { BEGIN(VERTEX); }

<INSIDE_COMPOSED>"faces" { BEGIN(FACE); }

<INSIDE_COMPOSED>"texture" {BEGIN(TEXTURE); }

<INSIDE_COMPOSED>"img" { BEGIN(IMG); }

    /* Daca obiectul este la randul lui obiet compus, afiseaza descrierea si trece la urmatorul obiect */
<INSIDE_COMPOSED>"Object" { 
                            if(composed == indent) {
                                for (int i = 0; i < indent; i++) {
                                    printf("\t");
                                }
                                printf("Object %s: varfuri: %d, fete: %d, %s\n", object_name, nr_vertex, nr_faces, texture);
                                composed++;
                            }

                            BEGIN(GET_NAME);
                            nr_vertex = 0; 
                            nr_faces = 0;
                            nr_texture = 0;
                            texture = "fara textura";
                            indent++;
                            } 

    /* S-a terminat de parcurs obiectul aflat intr-un obiect compus */
<INSIDE_COMPOSED>"}" {
                        /* Daca nu este un obiect compus afiseaza */
                        if (composed == indent) {
                            for (int i = 0; i < indent; i++) {
                                    printf("\t");
                            }
                            printf("Object %s: varfuri: %d, fete: %d, %s\n", object_name, nr_vertex, nr_faces, texture);
                        } 
                        /* Altfel trebuie decrementata variabila compus 
                        *  pentru intoarcerea la obiectul anterior
                        */
                        else {
                            composed--;
                        }

                        indent--;
                        
                        if (indent == 0) {
                            BEGIN(INSIDE_OBJECT);
                        }
                        else {
                            BEGIN(INSIDE_COMPOSED);
                        }
                    } 



    /* Stare pentru citirea descrierii listei de varfuri */
<VERTEX>"(" { BEGIN(INSIDE_VERTEX); nr_coords = 0;}

<VERTEX>{ignore}* ;

<VERTEX>. { 
            yyless(0); 
            if (composed == 0) { 
                BEGIN(INSIDE_OBJECT); 
            } else {
                BEGIN(INSIDE_COMPOSED);
            }
          }

    /* Stare pentru citirea coordonatelor unui varf */
<INSIDE_VERTEX>{nr_real}+ {nr_coords++;}

<INSIDE_VERTEX>")"  {
                        /* Daca are coordonate 3D carteziene
                        *  sau omogene este un varf acceptat
                        */
                        if (nr_coords == 3 || nr_coords == 4) {
                            nr_vertex++;
                        }
                    }

<INSIDE_VERTEX>{ignore}* ;

<INSIDE_VERTEX>. {yyless(0); BEGIN(VERTEX);}


     /* Stare pentru citirea descrierii listei de fete */
<FACE>";" {nr_faces++;}

<FACE>{nr_natural}*{ignore}* ;

<FACE>. { 
          yyless(0); 
          if (composed == 0) { 
                BEGIN(INSIDE_OBJECT); 
          } else {
                BEGIN(INSIDE_COMPOSED);
          } 
        }

     /* Stare pentru citirea descrierii listei coordonatelor de texturare */
<TEXTURE>"(" { BEGIN(INSIDE_TEXTURE); nr_coords = 0;}

<TEXTURE>{ignore}* ;

<TEXTURE>. { 
             yyless(0); 
             if (composed == 0) { 
                BEGIN(INSIDE_OBJECT); 
             } else {
                BEGIN(INSIDE_COMPOSED);
             }
            }

    /* Stare pentru citirea coordonatelor de texturare */
<INSIDE_TEXTURE>{nr_real}+ {
                                float number = atof(yytext);
                                if (0.0 <= number && number <= 1.0) {
                                    nr_coords++;
                                }
                           }

<INSIDE_TEXTURE>")" {
                        if (nr_coords == 2) {
                            nr_texture++;
                        }
                    }

<INSIDE_TEXTURE>{ignore}* ;

<INSIDE_TEXTURE>. {yyless(0); BEGIN(TEXTURE);}


    /* Stare pentru citirea numelui imaginii */
<IMG>{img}  {
                img_name = malloc(yyleng+1);
                strcpy(img_name, yytext);
            }

<IMG>{ignore}* ;            

<IMG>. {
          texture = malloc(17 + strlen(img_name));
          strcpy(texture, "imagine textura ");
          strcat(texture, img_name);

          yyless(0); 
          if (composed == 0) { 
                BEGIN(INSIDE_OBJECT); 
          } else {
               BEGIN(INSIDE_COMPOSED);
          }
        }

.|\n ;

%%

int main(int argc, char **argv){
	yyin = fopen(argv[1],"r");
	yylex();
	fclose(yyin);
} 

int yywrap(){
        return(1);
}
