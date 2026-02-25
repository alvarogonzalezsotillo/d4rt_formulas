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
- [X] Add a Share button to the formula list. It will export the array string literal of the formula with the units from Corpus.withDependencies().
- [X] Replace flutter-markdown with flutter-markdown-plus
- [X] Heron's formula: investigate why a=3, b=40, c=5 yields NaN. Root cause: input values don't form a valid triangle (violate triangle inequality: 3+5=8 is not > 40). Added documentation note to the formula description.
- [X] Refactor ./assets/formulas d4rt files:
  - [X] Pretty print files as dart literals (like JSON, but allow raw strings r"""like this""")
  - [X] Ensure there is no formula duplicates. If necesary, move or delete the formula in file formulas.d4rt
  - [X] defaultCorpus must load all formula files
- [X] Create a formula in ./assets/formulas/networking.d4art: input is a string with ip address and mask, output is ip subnet of this address and broadcast address.
- [R] Develop a new screen that edits a formula in ./lib/ai directory:
  - [R] FormulaEditor initializes with a Formula
  - [R] A textfield allows editing the "name" of the formula
  - [R] A text area allows editing the "description". A button pops up a preview of the markdown.
  - [R] There is one row per input variable. The "name" is a textfield. A first drop down allows to select the base unit, and a second dropdown is populated with all derived units of the selected base unit, and the base unit. The unit of the input variable is the derived unit.
  - [R] Each input variable can be deleted with a button
  - [R] A button after the inputs variables allows to insert a new input variable
  - [R] There is one row for the ouput variable, similar to the row for the input variable
  - [R] d4rtCode is a text area with dart syntax highligthing
  - [R] At the botton, a button allows to test the edited Formula, launching a FormulaScreen
