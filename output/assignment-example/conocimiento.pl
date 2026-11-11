% Generated knowledge. Do not edit manually.
:- encoding(utf8).
:- dynamic person/1, course/1, teacher/1, enrolled/2, teaches/2.

% Source line 2: persona: Ana
person('Ana').

% Source line 3: persona: Luis
person('Luis').

% Source line 4: curso: Paradigmas
course('Paradigmas').

% Source line 5: docente: Maria
teacher('Maria').

% Source line 8: lleva: Ana, Paradigmas
enrolled('Ana', 'Paradigmas').

% Source line 9: lleva: Luis, Paradigmas
enrolled('Luis', 'Paradigmas').

% Source line 10: imparte: Maria, Paradigmas
teaches('Maria', 'Paradigmas').

% Source line 13: companeros
classmate(First, Second) :-
    person(First),
    person(Second),
    dif(First, Second),
    once((enrolled(First, Course), enrolled(Second, Course))).

% Source line 14: curso_con_docente
course_with_teacher(Course) :-
    course(Course),
    once(teaches(_, Course)).

