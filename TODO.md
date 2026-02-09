[ ] Means not done
[x] Means done

- [ ] Unify error reporting. Create class ErrorHandler that get notified of every catched exception. This class prints the exception in stdout.
- Refactor formula and unit loading:
  - [ ] Create method `List<Object?> parseD4rtLiteral(String arrayStringLiteral). It parses a d4rt array literal (containing maps and arrays) to a List<Object?> using d4rt
  - [ ] Remove `fromArrayStringLiteral` from UnitSpec and Formula.
  - [ ] Create function `List<Object> parseCorpusElements(String arrayStringLiteral)`. It uses parseD4rtLiteral and determines if each element of the array is a formula or a unit. Then converts the objects with Formula.fromSet or UnitSpec.fromSet.
  - [ ] Create method loadFormulaElements( List<Object> elements). Tipically receives the list from parseCorpusElements(). It loads the units first, then the formulas, to avoid missing dependencies.
- [ ] Use a single table in database `FORMULAELEMENT` to store formulas and units. The table contains only two columns: autonumeric id and text.
- [ ] Create Formula.toStringLiteral. It is the reverse of Formula.fromSet( Formula.fromArrayStringLiteral(string)[0] )
- [ ] Create UnitSpec.toStringLiteral, like Formula.toStringLiteral
- Database file location:
  - [ ] In linux, the sqlite database file will be located following rules at https://specifications.freedesktop.org/basedir/latest/
  - [ ] In Windows, the sqlite database file will be in %appdata%/Roaming
  - [ ] In Macos, the sqlite database file will be in ~/Library/Application Support
- [ ] Initialize database at startup
  - [ ] If the database is empty, sugest to use a default corpus
  - [ ] If the user choose to use the default corpus, populate de database with the default corpus (load defaultcorpus, and the use toStringLiteral)
  - [ ] From now on, the corpus will be loaded from database instead of assets
- [ ] Create method List<UnitSpec> Corpus.withDependencies(Formula formula). It will return the list of units of the formula, and related units from the corpus.
- [ ] Add a Share button to the formula list. It will export the array string literal of the formula with the units from Corpus.withDependencies().
