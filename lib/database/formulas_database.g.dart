// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formulas_database.dart';

// ignore_for_file: type=lint
class $FormulasTable extends Formulas with TableInfo<$FormulasTable, Formula> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormulasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _formulaMeta = const VerificationMeta(
    'formula',
  );
  @override
  late final GeneratedColumn<String> formula = GeneratedColumn<String>(
    'formula',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, formula];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'formulas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Formula> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('formula')) {
      context.handle(
        _formulaMeta,
        formula.isAcceptableOrUnknown(data['formula']!, _formulaMeta),
      );
    } else if (isInserting) {
      context.missing(_formulaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Formula map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Formula(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      formula: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}formula'],
      )!,
    );
  }

  @override
  $FormulasTable createAlias(String alias) {
    return $FormulasTable(attachedDatabase, alias);
  }
}

class Formula extends DataClass implements Insertable<Formula> {
  final int id;
  final String formula;
  const Formula({required this.id, required this.formula});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['formula'] = Variable<String>(formula);
    return map;
  }

  FormulasCompanion toCompanion(bool nullToAbsent) {
    return FormulasCompanion(id: Value(id), formula: Value(formula));
  }

  factory Formula.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Formula(
      id: serializer.fromJson<int>(json['id']),
      formula: serializer.fromJson<String>(json['formula']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'formula': serializer.toJson<String>(formula),
    };
  }

  Formula copyWith({int? id, String? formula}) =>
      Formula(id: id ?? this.id, formula: formula ?? this.formula);
  Formula copyWithCompanion(FormulasCompanion data) {
    return Formula(
      id: data.id.present ? data.id.value : this.id,
      formula: data.formula.present ? data.formula.value : this.formula,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Formula(')
          ..write('id: $id, ')
          ..write('formula: $formula')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, formula);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Formula &&
          other.id == this.id &&
          other.formula == this.formula);
}

class FormulasCompanion extends UpdateCompanion<Formula> {
  final Value<int> id;
  final Value<String> formula;
  const FormulasCompanion({
    this.id = const Value.absent(),
    this.formula = const Value.absent(),
  });
  FormulasCompanion.insert({
    this.id = const Value.absent(),
    required String formula,
  }) : formula = Value(formula);
  static Insertable<Formula> custom({
    Expression<int>? id,
    Expression<String>? formula,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (formula != null) 'formula': formula,
    });
  }

  FormulasCompanion copyWith({Value<int>? id, Value<String>? formula}) {
    return FormulasCompanion(
      id: id ?? this.id,
      formula: formula ?? this.formula,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (formula.present) {
      map['formula'] = Variable<String>(formula.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormulasCompanion(')
          ..write('id: $id, ')
          ..write('formula: $formula')
          ..write(')'))
        .toString();
  }
}

abstract class _$FormulasDatabase extends GeneratedDatabase {
  _$FormulasDatabase(QueryExecutor e) : super(e);
  $FormulasDatabaseManager get managers => $FormulasDatabaseManager(this);
  late final $FormulasTable formulas = $FormulasTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [formulas];
}

typedef $$FormulasTableCreateCompanionBuilder =
    FormulasCompanion Function({Value<int> id, required String formula});
typedef $$FormulasTableUpdateCompanionBuilder =
    FormulasCompanion Function({Value<int> id, Value<String> formula});

class $$FormulasTableFilterComposer
    extends Composer<_$FormulasDatabase, $FormulasTable> {
  $$FormulasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get formula => $composableBuilder(
    column: $table.formula,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormulasTableOrderingComposer
    extends Composer<_$FormulasDatabase, $FormulasTable> {
  $$FormulasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get formula => $composableBuilder(
    column: $table.formula,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormulasTableAnnotationComposer
    extends Composer<_$FormulasDatabase, $FormulasTable> {
  $$FormulasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get formula =>
      $composableBuilder(column: $table.formula, builder: (column) => column);
}

class $$FormulasTableTableManager
    extends
        RootTableManager<
          _$FormulasDatabase,
          $FormulasTable,
          Formula,
          $$FormulasTableFilterComposer,
          $$FormulasTableOrderingComposer,
          $$FormulasTableAnnotationComposer,
          $$FormulasTableCreateCompanionBuilder,
          $$FormulasTableUpdateCompanionBuilder,
          (
            Formula,
            BaseReferences<_$FormulasDatabase, $FormulasTable, Formula>,
          ),
          Formula,
          PrefetchHooks Function()
        > {
  $$FormulasTableTableManager(_$FormulasDatabase db, $FormulasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormulasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormulasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormulasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> formula = const Value.absent(),
              }) => FormulasCompanion(id: id, formula: formula),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String formula,
              }) => FormulasCompanion.insert(id: id, formula: formula),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormulasTableProcessedTableManager =
    ProcessedTableManager<
      _$FormulasDatabase,
      $FormulasTable,
      Formula,
      $$FormulasTableFilterComposer,
      $$FormulasTableOrderingComposer,
      $$FormulasTableAnnotationComposer,
      $$FormulasTableCreateCompanionBuilder,
      $$FormulasTableUpdateCompanionBuilder,
      (Formula, BaseReferences<_$FormulasDatabase, $FormulasTable, Formula>),
      Formula,
      PrefetchHooks Function()
    >;

class $FormulasDatabaseManager {
  final _$FormulasDatabase _db;
  $FormulasDatabaseManager(this._db);
  $$FormulasTableTableManager get formulas =>
      $$FormulasTableTableManager(_db, _db.formulas);
}
