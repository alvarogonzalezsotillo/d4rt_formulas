// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'formulas_database.dart';

// ignore_for_file: type=lint
class $FormulaElementsTable extends FormulaElements
    with TableInfo<$FormulaElementsTable, FormulaElement> {
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
  List<GeneratedColumn> get $columns => [uuid, elementText];
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
    if (data.containsKey('uuid')) {
      context.handle(
        _uuidMeta,
        uuid.isAcceptableOrUnknown(data['uuid']!, _uuidMeta),
      );
    } else if (isInserting) {
      context.missing(_uuidMeta);
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
  Set<GeneratedColumn> get $primaryKey => {uuid};
  @override
  FormulaElement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FormulaElement(
      uuid: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uuid'],
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
    return FormulaElementsCompanion(
      uuid: Value(uuid),
      elementText: Value(elementText),
    );
  }

  factory FormulaElement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FormulaElement(
      uuid: serializer.fromJson<String>(json['uuid']),
      elementText: serializer.fromJson<String>(json['elementText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'uuid': serializer.toJson<String>(uuid),
      'elementText': serializer.toJson<String>(elementText),
    };
  }

  FormulaElement copyWith({String? uuid, String? elementText}) =>
      FormulaElement(
        uuid: uuid ?? this.uuid,
        elementText: elementText ?? this.elementText,
      );
  FormulaElement copyWithCompanion(FormulaElementsCompanion data) {
    return FormulaElement(
      uuid: data.uuid.present ? data.uuid.value : this.uuid,
      elementText: data.elementText.present
          ? data.elementText.value
          : this.elementText,
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
      identical(this, other) ||
      (other is FormulaElement &&
          other.uuid == this.uuid &&
          other.elementText == this.elementText);
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
  FormulaElementsCompanion.insert({
    required String uuid,
    required String elementText,
    this.rowid = const Value.absent(),
  }) : uuid = Value(uuid),
       elementText = Value(elementText);
  static Insertable<FormulaElement> custom({
    Expression<String>? uuid,
    Expression<String>? elementText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (uuid != null) 'uuid': uuid,
      if (elementText != null) 'element_text': elementText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormulaElementsCompanion copyWith({
    Value<String>? uuid,
    Value<String>? elementText,
    Value<int>? rowid,
  }) {
    return FormulaElementsCompanion(
      uuid: uuid ?? this.uuid,
      elementText: elementText ?? this.elementText,
      rowid: rowid ?? this.rowid,
    );
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
      required String uuid,
      required String elementText,
      Value<int> rowid,
    });
typedef $$FormulaElementsTableUpdateCompanionBuilder =
    FormulaElementsCompanion Function({
      Value<String> uuid,
      Value<String> elementText,
      Value<int> rowid,
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
  ColumnFilters<String> get uuid => $composableBuilder(
    column: $table.uuid,
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
  ColumnOrderings<String> get uuid => $composableBuilder(
    column: $table.uuid,
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
  GeneratedColumn<String> get uuid =>
      $composableBuilder(column: $table.uuid, builder: (column) => column);

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
                Value<String> uuid = const Value.absent(),
                Value<String> elementText = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormulaElementsCompanion(
                uuid: uuid,
                elementText: elementText,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String uuid,
                required String elementText,
                Value<int> rowid = const Value.absent(),
              }) => FormulaElementsCompanion.insert(
                uuid: uuid,
                elementText: elementText,
                rowid: rowid,
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
