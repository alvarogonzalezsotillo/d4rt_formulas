// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formulas_database_web.dart';

// ignore_for_file: type=lint
class $FormulaElementsTable extends FormulaElements
    with TableInfo<$FormulaElementsTable, FormulaElement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormulaElementsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _elementTextMeta = const VerificationMeta(
    'elementText',
  );
  @override
  late final GeneratedColumn<String> elementText = GeneratedColumn<String>(
    'element_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, elementText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'formula_elements';
  @override
  VerificationContext validateIntegrity(
    Insertable<FormulaElement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('element_text')) {
      context.handle(
        _elementTextMeta,
        elementText.isAcceptableOrUnknown(
          data['element_text']!,
          _elementTextMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_elementTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FormulaElement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormulaElement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      elementText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}element_text'],
      )!,
    );
  }

  @override
  $FormulaElementsTable createAlias(String alias) {
    return $FormulaElementsTable(attachedDatabase, alias);
  }
}

class FormulaElement extends DataClass implements Insertable<FormulaElement> {
  final int id;
  final String elementText;
  const FormulaElement({required this.id, required this.elementText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['element_text'] = Variable<String>(elementText);
    return map;
  }

  FormulaElementsCompanion toCompanion(bool nullToAbsent) {
    return FormulaElementsCompanion(
      id: Value(id),
      elementText: Value(elementText),
    );
  }

  factory FormulaElement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormulaElement(
      id: serializer.fromJson<int>(json['id']),
      elementText: serializer.fromJson<String>(json['elementText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'elementText': serializer.toJson<String>(elementText),
    };
  }

  FormulaElement copyWith({int? id, String? elementText}) => FormulaElement(
    id: id ?? this.id,
    elementText: elementText ?? this.elementText,
  );
  FormulaElement copyWithCompanion(FormulaElementsCompanion data) {
    return FormulaElement(
      id: data.id.present ? data.id.value : this.id,
      elementText: data.elementText.present
          ? data.elementText.value
          : this.elementText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormulaElement(')
          ..write('id: $id, ')
          ..write('elementText: $elementText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, elementText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FormulaElement &&
          other.id == this.id &&
          other.elementText == this.elementText);
}

class FormulaElementsCompanion extends UpdateCompanion<FormulaElement> {
  final Value<int> id;
  final Value<String> elementText;
  const FormulaElementsCompanion({
    this.id = const Value.absent(),
    this.elementText = const Value.absent(),
  });
  FormulaElementsCompanion.insert({
    this.id = const Value.absent(),
    required String elementText,
  }) : elementText = Value(elementText);
  static Insertable<FormulaElement> custom({
    Expression<int>? id,
    Expression<String>? elementText,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (elementText != null) 'element_text': elementText,
    });
  }

  FormulaElementsCompanion copyWith({
    Value<int>? id,
    Value<String>? elementText,
  }) {
    return FormulaElementsCompanion(
      id: id ?? this.id,
      elementText: elementText ?? this.elementText,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (elementText.present) {
      map['element_text'] = Variable<String>(elementText.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormulaElementsCompanion(')
          ..write('id: $id, ')
          ..write('elementText: $elementText')
          ..write(')'))
        .toString();
  }
}

abstract class _$FormulasDatabase extends GeneratedDatabase {
  _$FormulasDatabase(QueryExecutor e) : super(e);
  $FormulasDatabaseManager get managers => $FormulasDatabaseManager(this);
  late final $FormulaElementsTable formulaElements = $FormulaElementsTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [formulaElements];
}

typedef $$FormulaElementsTableCreateCompanionBuilder =
    FormulaElementsCompanion Function({
      Value<int> id,
      required String elementText,
    });
typedef $$FormulaElementsTableUpdateCompanionBuilder =
    FormulaElementsCompanion Function({
      Value<int> id,
      Value<String> elementText,
    });

class $$FormulaElementsTableFilterComposer
    extends Composer<_$FormulasDatabase, $FormulaElementsTable> {
  $$FormulaElementsTableFilterComposer({
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

  ColumnFilters<String> get elementText => $composableBuilder(
    column: $table.elementText,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FormulaElementsTableOrderingComposer
    extends Composer<_$FormulasDatabase, $FormulaElementsTable> {
  $$FormulaElementsTableOrderingComposer({
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

  ColumnOrderings<String> get elementText => $composableBuilder(
    column: $table.elementText,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FormulaElementsTableAnnotationComposer
    extends Composer<_$FormulasDatabase, $FormulaElementsTable> {
  $$FormulaElementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get elementText => $composableBuilder(
    column: $table.elementText,
    builder: (column) => column,
  );
}

class $$FormulaElementsTableTableManager
    extends
        RootTableManager<
          _$FormulasDatabase,
          $FormulaElementsTable,
          FormulaElement,
          $$FormulaElementsTableFilterComposer,
          $$FormulaElementsTableOrderingComposer,
          $$FormulaElementsTableAnnotationComposer,
          $$FormulaElementsTableCreateCompanionBuilder,
          $$FormulaElementsTableUpdateCompanionBuilder,
          (
            FormulaElement,
            BaseReferences<
              _$FormulasDatabase,
              $FormulaElementsTable,
              FormulaElement
            >,
          ),
          FormulaElement,
          PrefetchHooks Function()
        > {
  $$FormulaElementsTableTableManager(
    _$FormulasDatabase db,
    $FormulaElementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormulaElementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormulaElementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormulaElementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> elementText = const Value.absent(),
              }) => FormulaElementsCompanion(id: id, elementText: elementText),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String elementText,
              }) => FormulaElementsCompanion.insert(
                id: id,
                elementText: elementText,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FormulaElementsTableProcessedTableManager =
    ProcessedTableManager<
      _$FormulasDatabase,
      $FormulaElementsTable,
      FormulaElement,
      $$FormulaElementsTableFilterComposer,
      $$FormulaElementsTableOrderingComposer,
      $$FormulaElementsTableAnnotationComposer,
      $$FormulaElementsTableCreateCompanionBuilder,
      $$FormulaElementsTableUpdateCompanionBuilder,
      (
        FormulaElement,
        BaseReferences<
          _$FormulasDatabase,
          $FormulaElementsTable,
          FormulaElement
        >,
      ),
      FormulaElement,
      PrefetchHooks Function()
    >;

class $FormulasDatabaseManager {
  final _$FormulasDatabase _db;
  $FormulasDatabaseManager(this._db);
  $$FormulaElementsTableTableManager get formulaElements =>
      $$FormulaElementsTableTableManager(_db, _db.formulaElements);
}
