% Generated knowledge. Do not edit manually.
:- encoding(utf8).
:- dynamic person/1, course/1, teacher/1, enrolled/2, teaches/2.

% Source line 2: person: Casey
person('Casey').

% Source line 3: person: Jordan
person('Jordan').

% Source line 4: course: Logic
course('Logic').

% Source line 5: course: Algebra
course('Algebra').

% Source line 6: teacher: Riley
teacher('Riley').

% Source line 9: enrolled: Casey, Logic
enrolled('Casey', 'Logic').

% Source line 10: enrolled: Jordan, Logic
enrolled('Jordan', 'Logic').

% Source line 11: enrolled: Jordan, Algebra
enrolled('Jordan', 'Algebra').

% Source line 12: teaches: Riley, Logic
teaches('Riley', 'Logic').

% Source line 15: classmates
classmate(First, Second) :-
    person(First),
    person(Second),
    dif(First, Second),
    once((enrolled(First, Course), enrolled(Second, Course))).

% Source line 16: course_with_teacher
course_with_teacher(Course) :-
    course(Course),
    once(teaches(_, Course)).

