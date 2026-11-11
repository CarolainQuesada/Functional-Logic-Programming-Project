% Generated knowledge. Do not edit manually.
:- encoding(utf8).
:- dynamic persona/1, curso/1, docente/1, lleva/2, imparte/2.

% Source line 2: persona: Ana
persona('Ana').

% Source line 3: persona: Luis
persona('Luis').

% Source line 4: curso: Paradigmas
curso('Paradigmas').

% Source line 5: docente: Maria
docente('Maria').

% Source line 8: lleva: Ana, Paradigmas
lleva('Ana', 'Paradigmas').

% Source line 9: lleva: Luis, Paradigmas
lleva('Luis', 'Paradigmas').

% Source line 10: imparte: Maria, Paradigmas
imparte('Maria', 'Paradigmas').

% Source line 13: companeros
companero(First, Second) :-
    persona(First),
    persona(Second),
    dif(First, Second),
    once((lleva(First, Course), lleva(Second, Course))).

% Source line 14: curso_con_docente
curso_con_docente(Course) :-
    curso(Course),
    once(imparte(_, Course)).

