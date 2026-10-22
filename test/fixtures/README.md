# Input fixture expectations

These are validation expectations. Parser and validation tests load all these fixtures and verify the outcomes below. Physical source lines include blank lines.

| File | Expected outcome |
| --- | --- |
| `../../input/problema.txt` | Valid: four entities, three relations, two rule requests; declarations on lines 2-5, relations on lines 8-10, rules on lines 13-14 |
| `alternate-valid.txt` | Valid: five entities, four relations, two rule requests; Casey and Jordan share Logic; only Logic has a teacher |
| `duplicate-entity.txt` | Duplicate entity error on line 3, referencing the original declaration on line 2 |
| `undeclared-reference.txt` | Undeclared person Taylor in the relation on line 6 |
| `malformed-records.txt` | Malformed entity on line 2, relation on line 7, and rule record on line 10 |
| `missing-section.txt` | File-level missing `[REGLAS_SOLICITADAS]` error, without an invented source line |
| `unsupported-rule.txt` | Unsupported academic rule on line 9 |

The primary valid input also checks that blank lines do not shift source locations. Later automated tests must check the additional lexical and section policies listed in the input specification.
