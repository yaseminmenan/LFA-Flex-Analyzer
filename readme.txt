Menan Yasemin 336CC

Tema LEX Limbaje Formale si Automate

Tema a fost realizata intr-o masina virtuala de Linux, folosind FLEX si C. 
Programul primeste ca input un fisier text in care sunt definite obiecte 3D
si le afiseaza, tinand cont sa afiseze obiectele compuse sub forma arborescenta.

Pentru a parsa mai bine fisierul am folosit mai multe stari, pentru a citi
specificatiile obiectului in functie de tipul acestuia (daca face sau nu parte 
dintr-un obiect compus, daca este un obiect simplu sau compus).

---------- VARIABILE ----------

char* object_name 
    - numele obiectului
int nr_vertex;
    - numarul de varfuri ale obiectului
int nr_faces
    - numarul de fete ale obiectului
int nr_texture
    - numarul de coordonate de texturare ale obiectului
char* texture
    - variabila folosita pentru a afisa daca obiectul are sau nu textura
char* img_name
    - numele imaginii
int nr_coords
    - numarul de coordonate ale unui vard sau coordonate de texturare
int composed
    - variabila care indica daca obiectul este sau nu compus
    - daca obiectul curent face parte dintr-un obiect compus, si este
    un obiect simplu, valoarea lui composed este egala cu indent (altfel 
    trebuie sa fie mai mare cu 1 decat indent)
int indent
    - variabila folosita pentru afisarea obiectelor compuse sub forma arborescenta


---------- STARI ----------

INITIAL:
    - Starea initiala, in care se face match pe "Object " pentru a parcurge
    descrierea obiectului. Odata gasit un obiect merge in starea GET_NAME.
    - Obiectul nu face parte dintr-un obiect compus

GET_NAME:
    - Se retine numele obiectului, care poate fi format din litere mari si 
    mici, cifre si _. Dupa ce a dat de "{", merge in starea INSIDE_OBJECT, daca
    obiectul nu este parte dintr-un obiect compus, si INSIDE_COMPOSED daca este.

INSIDE_OBJECT:
    - Se cauta si se retin specificatiile obiectului: varfuri, fete, coordonate de
    texturare, imagine si alte obiecte. Primele cinci pot aparea in orice ordine
    in descrierea obiectului, iar la final se gasesc, daca exista, obiectele.
    - Daca obiectul este compus, adica contine alte obiecte, se afiseaza obiectul
    curent cu specificatiile sale, dar numai o singura data, si se trece in starea
    INSIDE_COMPOSED. 
    - Cand face match pe "}", s-a terminat de citit descrierea obiectului curent.
    Daca este un obiect simplu, acum se afiseaza specificatiile, si se trece la
    starea INITIAL.

INSIDE_COMPOSED:
    - Se cauta si se retin specificatiile obiectului aflat intr-un obiect compus,
    procedandu-se asemanator cu INSIDE_OBJECT.
    - Cand se face match pe "}", se scade indentarea. Daca valoarea a ajuns la 0,
    inseamna ca face parte dintr-un obiect care nu se afla in compozitia altuia,
    si se trece la INSIDE_OBJECT, altfel obiectul face si el parte dintr-un obiect
    compus si se intoarce la INSIDE_COMPOSED.

VERTEX:
    - Stare in care se citeste lista de varfuri
    - Cand face match pe "(", trece in starea INSIDE_VERTEX
    - Cand face match pe " ", "\n" si "\t", ignora
    - Cand face match pe orice altceva, foloseste yyless(0) pentru a introduce 
    inapoi cele yyleng caractere in stream, si se intoarce la starea 
    INSIDE_OBJECT sau INSIDE_COMPOSED

INSIDE_VERTEX:
    - Stare in care se citesc coordonatele unui singur varf
    - Cand face match pe un numar real incrementeaza nr_coords
    - Cand face match pe " ", "\n" si "\t", ignora
    - Cand face match pe ")", s-au terminat de citit coordonatele varfului, si 
    verifica daca acesta are 3 sau 4 coordonate pentru a incrementa nr_vertex
    si se intoarce la VERTEX

FACE:
    - Citeste numarul de fete ale obiectului, delimitate de ";"
    - Cand face match pe orice altceva, procedeaza ca la VERTEX

TEXTURE:
    - Stare in care se citeste lista de coordonate de texturare
    - Este asemanator cu VERTEX
    - Cand face match pe "(", trece in starea INSIDE_TEXTURE
    - Cand face match pe orice altceva, procedeaza ca la VERTEX

INSIDE_TEXTURE:
    - Stare in care se citeste coordonata de texturare
    - Este asemanator cu INSIDE_VERTEX, dar cand face match pe un numar real
    verifica daca este in intervalul [0,1]
    - Cand face match pe ")", s-au terminat de citit coordonatele varfului, si 
    verifica daca acesta are 2 pentru a incrementa nr_texture si se intoarce la
    TEXTURE

IMG:
    - Stare in care se citeste numele imaginii de texturare
    - Cand face match pe orice altceva, concateneaza numele imaginii in variabila
    texture pentru afisare, si apoi procedeaza ca la VERTEX
