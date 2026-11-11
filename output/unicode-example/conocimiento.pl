% Generated knowledge. Do not edit manually.
:- encoding(utf8).
:- dynamic persona/1, curso/1, docente/1, lleva/2, imparte/2.

% Source line 3: persona: José
persona('José').

% Source line 4: persona: Ana
persona('Ana').

% Source line 5: curso: Programación
curso('Programación').

% Source line 6: curso: Sin docente
curso('Sin docente').

% Source line 7: docente: María Pérez
docente('María Pérez').

% Source line 10: lleva: José, Programación
lleva('José', 'Programación').

% Source line 11: lleva: Ana, Programación
lleva('Ana', 'Programación').

% Source line 12: imparte: María Pérez, Programación
imparte('María Pérez', 'Programación').

% Source line 14: companeros
companero(First, Second) :-
    persona(First),
    persona(Second),
    dif(First, Second),
    once((lleva(First, Course), lleva(Second, Course))).

% Source line 15: curso_con_docente
curso_con_docente(Course) :-
    curso(Course),
    once(imparte(_, Course)).

% Source line 16: companeros_en_curso
companero(First, Second, Course) :-
    lleva(First, Course), lleva(Second, Course), dif(First, Second).

% Source line 17: estudiante_de
estudiante_de(Student, Teacher) :-
    lleva(Student, Course), imparte(Teacher, Course).

% Source line 18: curso_sin_docente
curso_sin_docente(Course) :-
    curso(Course), \+ imparte(_, Course).

