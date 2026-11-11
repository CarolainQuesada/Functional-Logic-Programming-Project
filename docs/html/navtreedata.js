/*
 @licstart  The following is the entire license notice for the JavaScript code in this file.

 The MIT License (MIT)

 Copyright (C) 1997-2020 by Dimitri van Heesch

 Permission is hereby granted, free of charge, to any person obtaining a copy of this software
 and associated documentation files (the "Software"), to deal in the Software without restriction,
 including without limitation the rights to use, copy, modify, merge, publish, distribute,
 sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all copies or
 substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
 BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
 DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

 @licend  The above is the entire license notice for the JavaScript code in this file
*/
var NAVTREE =
[
  [ "Functional Logic Programming Project", "index.html", [
    [ "Functional-Logic-Programming-Project", "index.html", "index" ],
    [ "src/Diagnostic.hs", "api_src__diagnostic.html", [
      [ "Severity", "api_src__diagnostic.html#api_src_Diagnostic_Severity", null ],
      [ "DiagnosticCode", "api_src__diagnostic.html#api_src_Diagnostic_DiagnosticCode", null ],
      [ "DiagnosticLocation", "api_src__diagnostic.html#api_src_Diagnostic_DiagnosticLocation", null ],
      [ "Diagnostic", "api_src__diagnostic.html#api_src_Diagnostic_Diagnostic", null ],
      [ "hasErrors", "api_src__diagnostic.html#api_src_Diagnostic_hasErrors", null ]
    ] ],
    [ "src/Html.hs", "api_src__html.html", [
      [ "renderHtml", "api_src__html.html#api_src_Html_renderHtml", null ],
      [ "stat", "api_src__html.html#api_src_Html_stat", null ],
      [ "panel", "api_src__html.html#api_src_Html_panel", null ],
      [ "table", "api_src__html.html#api_src_Html_table", null ],
      [ "entityRow", "api_src__html.html#api_src_Html_entityRow", null ],
      [ "relationRow", "api_src__html.html#api_src_Html_relationRow", null ],
      [ "ruleRow", "api_src__html.html#api_src_Html_ruleRow", null ],
      [ "lineNumber", "api_src__html.html#api_src_Html_lineNumber", null ],
      [ "codeBlock", "api_src__html.html#api_src_Html_codeBlock", null ],
      [ "diagnosticHtml", "api_src__html.html#api_src_Html_diagnosticHtml", null ],
      [ "escapeHtml", "api_src__html.html#api_src_Html_escapeHtml", null ],
      [ "sectionNumber", "api_src__html.html#api_src_Html_sectionNumber", null ],
      [ "connectionMap", "api_src__html.html#api_src_Html_connectionMap", null ],
      [ "sectionLabel", "api_src__html.html#api_src_Html_sectionLabel", null ],
      [ "diagnosticMessageEs", "api_src__html.html#api_src_Html_diagnosticMessageEs", null ]
    ] ],
    [ "src/HtmlStyle.hs", "api_src__html_style.html", [
      [ "stylesheet", "api_src__html_style.html#api_src_HtmlStyle_stylesheet", null ]
    ] ],
    [ "src/Input.hs", "api_src__input.html", [
      [ "readProblem", "api_src__input.html#api_src_Input_readProblem", null ]
    ] ],
    [ "src/Model.hs", "api_src__model.html", [
      [ "EntityName", "api_src__model.html#api_src_Model_EntityName", null ],
      [ "EntityKind", "api_src__model.html#api_src_Model_EntityKind", null ],
      [ "Entity", "api_src__model.html#api_src_Model_Entity", null ],
      [ "Relation", "api_src__model.html#api_src_Model_Relation", null ],
      [ "RequestedRule", "api_src__model.html#api_src_Model_RequestedRule", null ],
      [ "Section", "api_src__model.html#api_src_Model_Section", null ],
      [ "Problem", "api_src__model.html#api_src_Model_Problem", null ],
      [ "emptyProblem", "api_src__model.html#api_src_Model_emptyProblem", null ],
      [ "entityName", "api_src__model.html#api_src_Model_entityName", null ],
      [ "entityKind", "api_src__model.html#api_src_Model_entityKind", null ],
      [ "relationReferences", "api_src__model.html#api_src_Model_relationReferences", null ]
    ] ],
    [ "src/Parser.hs", "api_src__parser.html", [
      [ "parseProblem", "api_src__parser.html#api_src_Parser_parseProblem", null ],
      [ "restoreOrder", "api_src__parser.html#api_src_Parser_restoreOrder", null ],
      [ "parseLine", "api_src__parser.html#api_src_Parser_parseLine", null ],
      [ "sectionMarkers", "api_src__parser.html#api_src_Parser_sectionMarkers", null ],
      [ "storeRecord", "api_src__parser.html#api_src_Parser_storeRecord", null ],
      [ "addDiagnostic", "api_src__parser.html#api_src_Parser_addDiagnostic", null ],
      [ "parseEntity", "api_src__parser.html#api_src_Parser_parseEntity", null ],
      [ "parseRelation", "api_src__parser.html#api_src_Parser_parseRelation", null ],
      [ "parseRule", "api_src__parser.html#api_src_Parser_parseRule", null ],
      [ "identifier", "api_src__parser.html#api_src_Parser_identifier", null ],
      [ "fields", "api_src__parser.html#api_src_Parser_fields", null ],
      [ "trim", "api_src__parser.html#api_src_Parser_trim", null ],
      [ "stripBom", "api_src__parser.html#api_src_Parser_stripBom", null ],
      [ "stripCarriageReturn", "api_src__parser.html#api_src_Parser_stripCarriageReturn", null ],
      [ "entityIdentifier", "api_src__parser.html#api_src_Parser_entityIdentifier", null ]
    ] ],
    [ "src/Pipeline.hs", "api_src__pipeline.html", [
      [ "runPipeline", "api_src__pipeline.html#api_src_Pipeline_runPipeline", null ],
      [ "inputFailure", "api_src__pipeline.html#api_src_Pipeline_inputFailure", null ],
      [ "artifacts", "api_src__pipeline.html#api_src_Pipeline_artifacts", null ],
      [ "writeAtomic", "api_src__pipeline.html#api_src_Pipeline_writeAtomic", null ],
      [ "renameWithRetry", "api_src__pipeline.html#api_src_Pipeline_renameWithRetry", null ]
    ] ],
    [ "src/Prolog.hs", "api_src__prolog.html", [
      [ "PrologOutput", "api_src__prolog.html#api_src_Prolog_PrologOutput", null ],
      [ "generateProlog", "api_src__prolog.html#api_src_Prolog_generateProlog", null ],
      [ "unique", "api_src__prolog.html#api_src_Prolog_unique", null ],
      [ "renderLocated", "api_src__prolog.html#api_src_Prolog_renderLocated", null ],
      [ "traceComment", "api_src__prolog.html#api_src_Prolog_traceComment", null ],
      [ "entityFact", "api_src__prolog.html#api_src_Prolog_entityFact", null ],
      [ "relationFact", "api_src__prolog.html#api_src_Prolog_relationFact", null ],
      [ "isTeaching", "api_src__prolog.html#api_src_Prolog_isTeaching", null ],
      [ "term", "api_src__prolog.html#api_src_Prolog_term", null ],
      [ "renderRule", "api_src__prolog.html#api_src_Prolog_renderRule", null ],
      [ "ruleQueries", "api_src__prolog.html#api_src_Prolog_ruleQueries", null ],
      [ "concreteQueries", "api_src__prolog.html#api_src_Prolog_concreteQueries", null ],
      [ "quoteAtom", "api_src__prolog.html#api_src_Prolog_quoteAtom", null ]
    ] ],
    [ "src/PrologFiles.hs", "api_src__prolog_files.html", [
      [ "writePrologFiles", "api_src__prolog_files.html#api_src_PrologFiles_writePrologFiles", null ],
      [ "writeUtf8", "api_src__prolog_files.html#api_src_PrologFiles_writeUtf8", null ]
    ] ],
    [ "src/Source.hs", "api_src__source.html", [
      [ "SourceLine", "api_src__source.html#api_src_Source_SourceLine", null ],
      [ "Located", "api_src__source.html#api_src_Source_Located", null ],
      [ "mapLocated", "api_src__source.html#api_src_Source_mapLocated", null ]
    ] ],
    [ "src/Validation.hs", "api_src__validation.html", [
      [ "validateProblem", "api_src__validation.html#api_src_Validation_validateProblem", null ],
      [ "duplicates", "api_src__validation.html#api_src_Validation_duplicates", null ],
      [ "sectionMarker", "api_src__validation.html#api_src_Validation_sectionMarker", null ]
    ] ],
    [ "src/ValidationReport.hs", "api_src__validation_report.html", [
      [ "renderValidationReport", "api_src__validation_report.html#api_src_ValidationReport_renderValidationReport", null ]
    ] ],
    [ "app/Main.hs", "api_app__main.html", [
      [ "main", "api_app__main.html#api_app_Main_main", null ]
    ] ],
    [ "Architecture and functional/logical boundaries", "md_docs_2architecture.html", [
      [ "Data model", "md_docs_2architecture.html#autotoc_md12", null ],
      [ "Functional core", "md_docs_2architecture.html#autotoc_md13", null ],
      [ "Logical core", "md_docs_2architecture.html#autotoc_md14", null ],
      [ "Output and failure invariants", "md_docs_2architecture.html#autotoc_md15", null ]
    ] ],
    [ "Oral defense guide", "md_docs_2defense-guide.html", [
      [ "Demonstration sequence", "md_docs_2defense-guide.html#autotoc_md17", null ],
      [ "Design questions to prepare together", "md_docs_2defense-guide.html#autotoc_md18", null ],
      [ "Team preparation", "md_docs_2defense-guide.html#autotoc_md19", null ],
      [ "Exact assignment example", "md_docs_2defense-guide.html#autotoc_md20", null ]
    ] ],
    [ "Development environment", "md_docs_2development-environment.html", [
      [ "Windows setup", "md_docs_2development-environment.html#autotoc_md22", null ],
      [ "Verification commands", "md_docs_2development-environment.html#autotoc_md23", null ],
      [ "Verified results", "md_docs_2development-environment.html#autotoc_md24", null ]
    ] ],
    [ "Doxygen documentation", "md_docs_2documentation.html", null ],
    [ "Generated interface", "md_docs_2generated-interface.html", [
      [ "Fieldnotes visual design", "md_docs_2generated-interface.html#autotoc_md27", null ]
    ] ],
    [ "Input format specification", "md_docs_2input-format-analysis.html", [
      [ "Scope and evidence", "md_docs_2input-format-analysis.html#autotoc_md29", null ],
      [ "Required sections", "md_docs_2input-format-analysis.html#autotoc_md30", null ],
      [ "Lexical conventions", "md_docs_2input-format-analysis.html#autotoc_md31", null ],
      [ "Academic vocabulary", "md_docs_2input-format-analysis.html#autotoc_md32", null ],
      [ "Section recognition and traceability", "md_docs_2input-format-analysis.html#autotoc_md33", null ],
      [ "Error and warning policy", "md_docs_2input-format-analysis.html#autotoc_md34", null ],
      [ "Examples and review status", "md_docs_2input-format-analysis.html#autotoc_md35", null ],
      [ "Assignment compatibility", "md_docs_2input-format-analysis.html#autotoc_md36", null ]
    ] ],
    [ "Intermediate model", "md_docs_2intermediate-model.html", [
      [ "Scope", "md_docs_2intermediate-model.html#autotoc_md38", null ],
      [ "Modules", "md_docs_2intermediate-model.html#autotoc_md39", null ],
      [ "Representation decisions", "md_docs_2intermediate-model.html#autotoc_md40", null ],
      [ "Pure operations", "md_docs_2intermediate-model.html#autotoc_md41", null ],
      [ "Verification", "md_docs_2intermediate-model.html#autotoc_md42", null ]
    ] ],
    [ "Functional input parser", "md_docs_2parser.html", [
      [ "API and scope", "md_docs_2parser.html#autotoc_md44", null ],
      [ "Parsing process", "md_docs_2parser.html#autotoc_md45", null ],
      [ "Verification", "md_docs_2parser.html#autotoc_md46", null ]
    ] ],
    [ "Complete pipeline", "md_docs_2pipeline.html", null ],
    [ "Prolog knowledge and queries", "md_docs_2prolog-generation.html", [
      [ "API and output", "md_docs_2prolog-generation.html#autotoc_md49", null ],
      [ "Requested rules", "md_docs_2prolog-generation.html#autotoc_md50", null ],
      [ "Suggested queries", "md_docs_2prolog-generation.html#autotoc_md51", null ],
      [ "Generation command", "md_docs_2prolog-generation.html#autotoc_md52", null ],
      [ "Additional requested rules", "md_docs_2prolog-generation.html#autotoc_md53", null ],
      [ "Verification", "md_docs_2prolog-generation.html#autotoc_md54", null ]
    ] ],
    [ "Assignment requirement checklist", "md_docs_2requirements-checklist.html", null ],
    [ "Semantic validation and reports", "md_docs_2validation.html", [
      [ "API", "md_docs_2validation.html#autotoc_md58", null ],
      [ "Reports and command", "md_docs_2validation.html#autotoc_md59", null ],
      [ "Verification", "md_docs_2validation.html#autotoc_md60", null ],
      [ "Nonblocking coverage warnings", "md_docs_2validation.html#autotoc_md61", null ]
    ] ],
    [ "Verification evidence", "md_docs_2verification.html", [
      [ "Automated results", "md_docs_2verification.html#autotoc_md63", null ],
      [ "Browser execution", "md_docs_2verification.html#autotoc_md64", null ],
      [ "Issues found and resolved", "md_docs_2verification.html#autotoc_md65", null ],
      [ "Reproduction", "md_docs_2verification.html#autotoc_md66", null ],
      [ "Assignment compatibility and delivery improvements", "md_docs_2verification.html#autotoc_md67", null ],
      [ "Defense readiness verification (2026-11-09)", "md_docs_2verification.html#autotoc_md68", null ]
    ] ]
  ] ]
];

var NAVTREEINDEX =
[
"api_app__main.html"
];

const SYNCONMSG = 'click to disable panel synchronization';
const SYNCOFFMSG = 'click to enable panel synchronization';
const LISTOFALLMEMBERS = 'List of all members';