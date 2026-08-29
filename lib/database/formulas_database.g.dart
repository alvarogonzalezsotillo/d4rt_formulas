// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formulas_database.dart';

// ignore_for_file: type=lint
class $FormulaElementsTable extends FormulaElements with TableInfo<$FormulaElementsTable, FormulaElement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormulaElementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _uuidMeta = const VerificationMeta('uuid');
  @override
  late final GeneratedColumn<String> uuid = GeneratedColumn<String>(
    'uuid',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _elementTextMeta = const VerificationMeta('elementText');
  @override
  late final GeneratedColumn<String> elementText = GeneratedColumn<String>(
    'element_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [uuid, elementText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'formula_elements';
  @override
  VerificationContext validateIntegrity(Insertable<FormulaElement> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('uuid')) {
      context.handle(_uuidMeta, uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta));
    } else if (isInserting) {
      context.missing(_uuidMeta);
    }
    if (data.containsKey('element_text')) {
      context.handle(_elementTextMeta, elementText.isAcceptableOrUnknown(data['element_text']!, _elementTextMeta));
    } else if (isInserting) {
      context.missing(_elementTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  FormulaElement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormulaElement(
      uuid: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}uuid'])!,
      elementText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}element_text'])!,
    );
  }

  @override
  $FormulaElementsTable createAlias(String alias) {
    return $FormulaElementsTable(attachedDatabase, alias);
  }
}

class FormulaElement extends DataClass implements Insertable<FormulaElement> {
  final String uuid;
  final String elementText;
  const FormulaElement({required this.uuid, required this.elementText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['uuid'] = Variable<String>(uuid);
    map['element_text'] = Variable<String>(elementText);
    return map;
  }

  FormulaElementsCompanion toCompanion(bool nullToAbsent) {
    return FormulaElementsCompanion(uuid: Value(uuid), elementText: Value(elementText));
  }

  factory FormulaElement.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormulaElement(uuid: serializer.fromJson<String>(json['uuid']), elementText: serializer.fromJson<String>(json['elementText']));
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'uuid': serializer.toJson<String>(uuid), 'elementText': serializer.toJson<String>(elementText)};
  }

  FormulaElement copyWith({String? uuid, String? elementText}) =>
      FormulaElement(uuid: uuid ?? this.uuid, elementText: elementText ?? this.elementText);
  FormulaElement copyWithCompanion(FormulaElementsCompanion data) {
    return FormulaElement(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      elementText: data.elementText.present ? data.elementText.value : this.elementText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FormulaElement(')
          ..write('uuid: $uuid, ')
          ..write('elementText: $elementText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(uuid, elementText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is FormulaElement && other.uuid == this.uuid && other.elementText == this.elementText);
}

class FormulaElementsCompanion extends UpdateCompanion<FormulaElement> {
  final Value<String> uuid;
  final Value<String> elementText;
  final Value<int> rowid;
  const FormulaElementsCompanion({
    this.uuid = const Value.absent(),
    this.elementText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormulaElementsCompanion.insert({required String uuid, required String elementText, this.rowid = const Value.absent()})
    : uuid = Value(uuid),
      elementText = Value(elementText);
  static Insertable<FormulaElement> custom({Expression<String>? uuid, Expression<String>? elementText, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (elementText != null) 'element_text': elementText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormulaElementsCompanion copyWith({Value<String>? uuid, Value<String>? elementText, Value<int>? rowid}) {
    return FormulaElementsCompanion(uuid: uuid ?? this.uuid, elementText: elementText ?? this.elementText, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (uuid.present) {
      map['uuid'] = Variable<String>(uuid.value);
    }
    if (elementText.present) {
      map['element_text'] = Variable<String>(elementText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormulaElementsCompanion(')
          ..write('uuid: $uuid, ')
          ..write('elementText: $elementText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GlobalVariablesTableTable extends GlobalVariablesTable with TableInfo<$GlobalVariablesTableTable, GlobalVariablesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GlobalVariablesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueTextMeta = const VerificationMeta('valueText');
  @override
  late final GeneratedColumn<String> valueText = GeneratedColumn<String>(
    'value_text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [name, valueText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'global_variables_table';
  @override
  VerificationContext validateIntegrity(Insertable<GlobalVariablesTableData> instance, {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(_nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('value_text')) {
      context.handle(_valueTextMeta, valueText.isAcceptableOrUnknown(data['value_text']!, _valueTextMeta));
    } else if (isInserting) {
      context.missing(_valueTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {name};
  @override
  GlobalVariablesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GlobalVariablesTableData(
      name: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      valueText: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value_text'])!,
    );
  }

  @override
  $GlobalVariablesTableTable createAlias(String alias) {
    return $GlobalVariablesTableTable(attachedDatabase, alias);
  }
}

class GlobalVariablesTableData extends DataClass implements Insertable<GlobalVariablesTableData> {
  final String name;
  final String valueText;
  const GlobalVariablesTableData({required this.name, required this.valueText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['value_text'] = Variable<String>(valueText);
    return map;
  }

  GlobalVariablesTableCompanion toCompanion(bool nullToAbsent) {
    return GlobalVariablesTableCompanion(name: Value(name), valueText: Value(valueText));
  }

  factory GlobalVariablesTableData.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GlobalVariablesTableData(
      name: serializer.fromJson<String>(json['name']),
      valueText: serializer.fromJson<String>(json['valueText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{'name': serializer.toJson<String>(name), 'valueText': serializer.toJson<String>(valueText)};
  }

  GlobalVariablesTableData copyWith({String? name, String? valueText}) =>
      GlobalVariablesTableData(name: name ?? this.name, valueText: valueText ?? this.valueText);
  GlobalVariablesTableData copyWithCompanion(GlobalVariablesTableCompanion data) {
    return GlobalVariablesTableData(
      name: data.name.present ? data.name.value : this.name,
      valueText: data.valueText.present ? data.valueText.value : this.valueText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GlobalVariablesTableData(')
          ..write('name: $name, ')
          ..write('valueText: $valueText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(name, valueText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is GlobalVariablesTableData && other.name == this.name && other.valueText == this.valueText);
}

class GlobalVariablesTableCompanion extends UpdateCompanion<GlobalVariablesTableData> {
  final Value<String> name;
  final Value<String> valueText;
  final Value<int> rowid;
  const GlobalVariablesTableCompanion({
    this.name = const Value.absent(),
    this.valueText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GlobalVariablesTableCompanion.insert({required String name, required String valueText, this.rowid = const Value.absent()})
    : name = Value(name),
      valueText = Value(valueText);
  static Insertable<GlobalVariablesTableData> custom({Expression<String>? name, Expression<String>? valueText, Expression<int>? rowid}) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (valueText != null) 'value_text': valueText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GlobalVariablesTableCompanion copyWith({Value<String>? name, Value<String>? valueText, Value<int>? rowid}) {
    return GlobalVariablesTableCompanion(name: name ?? this.name, valueText: valueText ?? this.valueText, rowid: rowid ?? this.rowid);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (valueText.present) {
      map['value_text'] = Variable<String>(valueText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GlobalVariablesTableCompanion(')
          ..write('name: $name, ')
          ..write('valueText: $valueText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$FormulasDatabase extends GeneratedDatabase {
  _$FormulasDatabase(QueryExecutor e) : super(e);
  $FormulasDatabaseManager get managers => $FormulasDatabaseManager(this);
  late final $FormulaElementsTable formulaElements = $FormulaElementsTable(this);
  late final $GlobalVariablesTableTable globalVariablesTable = $GlobalVariablesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [formulaElements, globalVariablesTable];
}

typedef $$FormulaElementsTableCreateCompanionBuilder =
    FormulaElementsCompanion Function({required String uuid, required String elementText, Value<int> rowid});
typedef $$FormulaElementsTableUpdateCompanionBuilder =
    FormulaElementsCompanion Function({Value<String> uuid, Value<String> elementText, Value<int> rowid});

class $$FormulaElementsTableFilterComposer extends Composer<_$FormulasDatabase, $FormulaElementsTable> {
  $$FormulaElementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get elementText => $composableBuilder(column: $table.elementText, builder: (column) => ColumnFilters(column));
}

class $$FormulaElementsTableOrderingComposer extends Composer<_$FormulasDatabase, $FormulaElementsTable> {
  $$FormulaElementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get elementText => $composableBuilder(column: $table.elementText, builder: (column) => ColumnOrderings(column));
}

class $$FormulaElementsTableAnnotationComposer extends Composer<_$FormulasDatabase, $FormulaElementsTable> {
  $$FormulaElementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get uuid => $composableBuilder(column: $table.uuid, builder: (column) => column);

  GeneratedColumn<String> get elementText => $composableBuilder(column: $table.elementText, builder: (column) => column);
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
          (FormulaElement, BaseReferences<_$FormulasDatabase, $FormulaElementsTable, FormulaElement>),
          FormulaElement,
          PrefetchHooks Function()
        > {
  $$FormulaElementsTableTableManager(_$FormulasDatabase db, $FormulaElementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$FormulaElementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$FormulaElementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$FormulaElementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> uuid = const Value.absent(),
                Value<String> elementText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormulaElementsCompanion(uuid: uuid, elementText: elementText, rowid: rowid),
          createCompanionCallback: ({required String uuid, required String elementText, Value<int> rowid = const Value.absent()}) =>
              FormulaElementsCompanion.insert(uuid: uuid, elementText: elementText, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
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
      (FormulaElement, BaseReferences<_$FormulasDatabase, $FormulaElementsTable, FormulaElement>),
      FormulaElement,
      PrefetchHooks Function()
    >;
typedef $$GlobalVariablesTableTableCreateCompanionBuilder =
    GlobalVariablesTableCompanion Function({required String name, required String valueText, Value<int> rowid});
typedef $$GlobalVariablesTableTableUpdateCompanionBuilder =
    GlobalVariablesTableCompanion Function({Value<String> name, Value<String> valueText, Value<int> rowid});

class $$GlobalVariablesTableTableFilterComposer extends Composer<_$FormulasDatabase, $GlobalVariablesTableTable> {
  $$GlobalVariablesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get valueText => $composableBuilder(column: $table.valueText, builder: (column) => ColumnFilters(column));
}

class $$GlobalVariablesTableTableOrderingComposer extends Composer<_$FormulasDatabase, $GlobalVariablesTableTable> {
  $$GlobalVariablesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get valueText => $composableBuilder(column: $table.valueText, builder: (column) => ColumnOrderings(column));
}

class $$GlobalVariablesTableTableAnnotationComposer extends Composer<_$FormulasDatabase, $GlobalVariablesTableTable> {
  $$GlobalVariablesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name => $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get valueText => $composableBuilder(column: $table.valueText, builder: (column) => column);
}

class $$GlobalVariablesTableTableTableManager
    extends
        RootTableManager<
          _$FormulasDatabase,
          $GlobalVariablesTableTable,
          GlobalVariablesTableData,
          $$GlobalVariablesTableTableFilterComposer,
          $$GlobalVariablesTableTableOrderingComposer,
          $$GlobalVariablesTableTableAnnotationComposer,
          $$GlobalVariablesTableTableCreateCompanionBuilder,
          $$GlobalVariablesTableTableUpdateCompanionBuilder,
          (GlobalVariablesTableData, BaseReferences<_$FormulasDatabase, $GlobalVariablesTableTable, GlobalVariablesTableData>),
          GlobalVariablesTableData,
          PrefetchHooks Function()
        > {
  $$GlobalVariablesTableTableTableManager(_$FormulasDatabase db, $GlobalVariablesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () => $$GlobalVariablesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () => $$GlobalVariablesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () => $$GlobalVariablesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> name = const Value.absent(),
                Value<String> valueText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GlobalVariablesTableCompanion(name: name, valueText: valueText, rowid: rowid),
          createCompanionCallback: ({required String name, required String valueText, Value<int> rowid = const Value.absent()}) =>
              GlobalVariablesTableCompanion.insert(name: name, valueText: valueText, rowid: rowid),
          withReferenceMapper: (p0) => p0.map((e) => (e.readTable(table), BaseReferences(db, table, e))).toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GlobalVariablesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$FormulasDatabase,
      $GlobalVariablesTableTable,
      GlobalVariablesTableData,
      $$GlobalVariablesTableTableFilterComposer,
      $$GlobalVariablesTableTableOrderingComposer,
      $$GlobalVariablesTableTableAnnotationComposer,
      $$GlobalVariablesTableTableCreateCompanionBuilder,
      $$GlobalVariablesTableTableUpdateCompanionBuilder,
      (GlobalVariablesTableData, BaseReferences<_$FormulasDatabase, $GlobalVariablesTableTable, GlobalVariablesTableData>),
      GlobalVariablesTableData,
      PrefetchHooks Function()
    >;

class $FormulasDatabaseManager {
  final _$FormulasDatabase _db;
  $FormulasDatabaseManager(this._db);
  $$FormulaElementsTableTableManager get formulaElements => $$FormulaElementsTableTableManager(_db, _db.formulaElements);
  $$GlobalVariablesTableTableTableManager get globalVariablesTable =>
      $$GlobalVariablesTableTableTableManager(_db, _db.globalVariablesTable);
}
