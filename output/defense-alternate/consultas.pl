% Generated suggested queries. Load this file, then call suggested_query(Query), call(Query).
:- encoding(utf8).
:- ensure_loaded('conocimiento.pl').

suggested_query(person(_Person)).
suggested_query(course(_Course)).
suggested_query(teacher(_Teacher)).
suggested_query(enrolled(_Person, _Course)).
suggested_query(teaches(_Teacher, _Course)).
suggested_query(classmate(_First, _Second)).
suggested_query(course_with_teacher(_Course)).
