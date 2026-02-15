# Conventions
[ ] Means not done
[R] Means done by an ai agent, but needs a human review 
[X] Means done


# List of tasks
- [X] Unify error reporting. Create class ErrorHandler that get notified of every catched exception. This class prints the exception in stdout.
- [X] Make formula description collapsable in FormulaScreen. Initialy, the description is visible, but the user can hide it.
- Refactor formula and unit loading:
  - [X] Create method `List<Object?> parseD4rtLiteral(String arrayStringLiteral). It parses a d4rt array literal (containing maps and arrays) to a List<Object?> using d4rt
  - [X] Make `fromArrayStringLiteral` from UnitSpec and Formula to use parseD4rtLiteral
  - [X] Create function `List<Object> parseCorpusElements(String arrayStringLiteral)`. It uses parseD4rtLiteral and determines if each element of the array is a formula or a unit. Then converts the objects with Formula.fromSet or UnitSpec.fromSet.
  - [X] Create method loadFormulaElements( List<Object> elements). Tipically receives the list from parseCorpusElements(). It loads the units first, then the formulas, to avoid missing dependencies.
  - [X] Change createDefaultCorpus to use loadFormulaElements instead of loadUnits and loadFormula. Make loadUnits and loadFormula private.
- [X] Use a single table in database `FORMULAELEMENT` to store formulas and units. The table contains only two columns: autonumeric id and text.
- Drift files have a lot of duplicate code. "web" version is the same as native version, only _openConnection is diferrent. Refactor to not duplicate code.
- [X] Create Formula.toStringLiteral. It is the reverse of Formula.fromSet( Formula.fromArrayStringLiteral(string)[0] )
- [X] Create UnitSpec.toStringLiteral, like Formula.toStringLiteral
- [X] Make Formula and UnitSpec subclasses of FormulaElement. Change return type of functions that return Object to FormulaElement if necessary.
- [X] Define toStringLiteral in FormulaElement.
- [X] Database file location:
  - [X] In linux, the sqlite database file will be located following rules at https://specifications.freedesktop.org/basedir/latest/
  - [X] In Windows, the sqlite database file will be in %appdata%/Roaming
  - [X] In Macos, the sqlite database file will be in ~/Library/Application Support
- [X] Initialize database at startup
  - [X] Try first to load a corpus from database
  - [X] If the database is empty, sugest to use a default corpus
  - [X] If the user choose to use the default corpus, populate de database with the default corpus (load defaultcorpus, and then use toStringLiteral). If not, start with an empty list of formulas.
  - [X] From now on, the corpus will be loaded from database instead of assets
- [X] Create method List<FormulaElement> Corpus.withDependencies(Formula formula). It will return the formula, the units of the formula, and all the units from the corpus with the same base unit.
- [R] Add a Share button to the formula list. It will export the array string literal of the formula with the units from Corpus.withDependencies().
- [ ] Replace flutter-markdown with flutter-markdown-plus
