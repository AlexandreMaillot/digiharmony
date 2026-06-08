// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'base_de_donnees.dart';

// ignore_for_file: type=lint
class $StatsBienEtreTable extends StatsBienEtre
    with TableInfo<$StatsBienEtreTable, StatsBienEtreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StatsBienEtreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedCountMeta = const VerificationMeta(
    'completedCount',
  );
  @override
  late final GeneratedColumn<int> completedCount = GeneratedColumn<int>(
    'completed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastCompletedAtMeta = const VerificationMeta(
    'lastCompletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastCompletedAt =
      GeneratedColumn<DateTime>(
        'last_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    exerciseId,
    completedCount,
    lastCompletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellbeing_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<StatsBienEtreData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('completed_count')) {
      context.handle(
        _completedCountMeta,
        completedCount.isAcceptableOrUnknown(
          data['completed_count']!,
          _completedCountMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _lastCompletedAtMeta,
        lastCompletedAt.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _lastCompletedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  StatsBienEtreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StatsBienEtreData(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      completedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_count'],
      )!,
      lastCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_at'],
      ),
    );
  }

  @override
  $StatsBienEtreTable createAlias(String alias) {
    return $StatsBienEtreTable(attachedDatabase, alias);
  }
}

class StatsBienEtreData extends DataClass
    implements Insertable<StatsBienEtreData> {
  /// Identifiant d'exercice (ex. 'breathing', 'senses', 'stretch', 'detox').
  final String exerciseId;

  /// Nombre de seances terminees.
  final int completedCount;

  /// Date de la derniere seance terminee.
  final DateTime? lastCompletedAt;
  const StatsBienEtreData({
    required this.exerciseId,
    required this.completedCount,
    this.lastCompletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['completed_count'] = Variable<int>(completedCount);
    if (!nullToAbsent || lastCompletedAt != null) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt);
    }
    return map;
  }

  StatsBienEtreCompanion toCompanion(bool nullToAbsent) {
    return StatsBienEtreCompanion(
      exerciseId: Value(exerciseId),
      completedCount: Value(completedCount),
      lastCompletedAt: lastCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastCompletedAt),
    );
  }

  factory StatsBienEtreData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StatsBienEtreData(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      completedCount: serializer.fromJson<int>(json['completedCount']),
      lastCompletedAt: serializer.fromJson<DateTime?>(json['lastCompletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'completedCount': serializer.toJson<int>(completedCount),
      'lastCompletedAt': serializer.toJson<DateTime?>(lastCompletedAt),
    };
  }

  StatsBienEtreData copyWith({
    String? exerciseId,
    int? completedCount,
    Value<DateTime?> lastCompletedAt = const Value.absent(),
  }) => StatsBienEtreData(
    exerciseId: exerciseId ?? this.exerciseId,
    completedCount: completedCount ?? this.completedCount,
    lastCompletedAt: lastCompletedAt.present
        ? lastCompletedAt.value
        : this.lastCompletedAt,
  );
  StatsBienEtreData copyWithCompanion(StatsBienEtreCompanion data) {
    return StatsBienEtreData(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      completedCount: data.completedCount.present
          ? data.completedCount.value
          : this.completedCount,
      lastCompletedAt: data.lastCompletedAt.present
          ? data.lastCompletedAt.value
          : this.lastCompletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StatsBienEtreData(')
          ..write('exerciseId: $exerciseId, ')
          ..write('completedCount: $completedCount, ')
          ..write('lastCompletedAt: $lastCompletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, completedCount, lastCompletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StatsBienEtreData &&
          other.exerciseId == this.exerciseId &&
          other.completedCount == this.completedCount &&
          other.lastCompletedAt == this.lastCompletedAt);
}

class StatsBienEtreCompanion extends UpdateCompanion<StatsBienEtreData> {
  final Value<String> exerciseId;
  final Value<int> completedCount;
  final Value<DateTime?> lastCompletedAt;
  final Value<int> rowid;
  const StatsBienEtreCompanion({
    this.exerciseId = const Value.absent(),
    this.completedCount = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StatsBienEtreCompanion.insert({
    required String exerciseId,
    this.completedCount = const Value.absent(),
    this.lastCompletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId);
  static Insertable<StatsBienEtreData> custom({
    Expression<String>? exerciseId,
    Expression<int>? completedCount,
    Expression<DateTime>? lastCompletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (completedCount != null) 'completed_count': completedCount,
      if (lastCompletedAt != null) 'last_completed_at': lastCompletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StatsBienEtreCompanion copyWith({
    Value<String>? exerciseId,
    Value<int>? completedCount,
    Value<DateTime?>? lastCompletedAt,
    Value<int>? rowid,
  }) {
    return StatsBienEtreCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      completedCount: completedCount ?? this.completedCount,
      lastCompletedAt: lastCompletedAt ?? this.lastCompletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (completedCount.present) {
      map['completed_count'] = Variable<int>(completedCount.value);
    }
    if (lastCompletedAt.present) {
      map['last_completed_at'] = Variable<DateTime>(lastCompletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StatsBienEtreCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('completedCount: $completedCount, ')
          ..write('lastCompletedAt: $lastCompletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$BaseDeDonnees extends GeneratedDatabase {
  _$BaseDeDonnees(QueryExecutor e) : super(e);
  $BaseDeDonneesManager get managers => $BaseDeDonneesManager(this);
  late final $StatsBienEtreTable statsBienEtre = $StatsBienEtreTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [statsBienEtre];
}

typedef $$StatsBienEtreTableCreateCompanionBuilder =
    StatsBienEtreCompanion Function({
      required String exerciseId,
      Value<int> completedCount,
      Value<DateTime?> lastCompletedAt,
      Value<int> rowid,
    });
typedef $$StatsBienEtreTableUpdateCompanionBuilder =
    StatsBienEtreCompanion Function({
      Value<String> exerciseId,
      Value<int> completedCount,
      Value<DateTime?> lastCompletedAt,
      Value<int> rowid,
    });

class $$StatsBienEtreTableFilterComposer
    extends Composer<_$BaseDeDonnees, $StatsBienEtreTable> {
  $$StatsBienEtreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StatsBienEtreTableOrderingComposer
    extends Composer<_$BaseDeDonnees, $StatsBienEtreTable> {
  $$StatsBienEtreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StatsBienEtreTableAnnotationComposer
    extends Composer<_$BaseDeDonnees, $StatsBienEtreTable> {
  $$StatsBienEtreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get completedCount => $composableBuilder(
    column: $table.completedCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastCompletedAt => $composableBuilder(
    column: $table.lastCompletedAt,
    builder: (column) => column,
  );
}

class $$StatsBienEtreTableTableManager
    extends
        RootTableManager<
          _$BaseDeDonnees,
          $StatsBienEtreTable,
          StatsBienEtreData,
          $$StatsBienEtreTableFilterComposer,
          $$StatsBienEtreTableOrderingComposer,
          $$StatsBienEtreTableAnnotationComposer,
          $$StatsBienEtreTableCreateCompanionBuilder,
          $$StatsBienEtreTableUpdateCompanionBuilder,
          (
            StatsBienEtreData,
            BaseReferences<
              _$BaseDeDonnees,
              $StatsBienEtreTable,
              StatsBienEtreData
            >,
          ),
          StatsBienEtreData,
          PrefetchHooks Function()
        > {
  $$StatsBienEtreTableTableManager(
    _$BaseDeDonnees db,
    $StatsBienEtreTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StatsBienEtreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StatsBienEtreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StatsBienEtreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<int> completedCount = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsBienEtreCompanion(
                exerciseId: exerciseId,
                completedCount: completedCount,
                lastCompletedAt: lastCompletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                Value<int> completedCount = const Value.absent(),
                Value<DateTime?> lastCompletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StatsBienEtreCompanion.insert(
                exerciseId: exerciseId,
                completedCount: completedCount,
                lastCompletedAt: lastCompletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StatsBienEtreTableProcessedTableManager =
    ProcessedTableManager<
      _$BaseDeDonnees,
      $StatsBienEtreTable,
      StatsBienEtreData,
      $$StatsBienEtreTableFilterComposer,
      $$StatsBienEtreTableOrderingComposer,
      $$StatsBienEtreTableAnnotationComposer,
      $$StatsBienEtreTableCreateCompanionBuilder,
      $$StatsBienEtreTableUpdateCompanionBuilder,
      (
        StatsBienEtreData,
        BaseReferences<_$BaseDeDonnees, $StatsBienEtreTable, StatsBienEtreData>,
      ),
      StatsBienEtreData,
      PrefetchHooks Function()
    >;

class $BaseDeDonneesManager {
  final _$BaseDeDonnees _db;
  $BaseDeDonneesManager(this._db);
  $$StatsBienEtreTableTableManager get statsBienEtre =>
      $$StatsBienEtreTableTableManager(_db, _db.statsBienEtre);
}
