% Generated suggested queries. Load this file, then call suggested_query(Query), call(Query).
:- encoding(utf8).
:- ensure_loaded('conocimiento.pl').

suggested_query(persona(_Person)).
suggested_query(curso(_Course)).
suggested_query(docente(_Teacher)).
suggested_query(lleva(_Person, _Course)).
suggested_query(imparte(_Teacher, _Course)).
suggested_query(companero(_First, _Second)).
suggested_query(curso_con_docente(_Course)).
suggested_query(lleva('Ana', _Curso)).
suggested_query(lleva('Luis', _Curso)).
suggested_query(imparte(_Docente, 'Paradigmas')).
suggested_query(imparte('Maria', _Curso)).
