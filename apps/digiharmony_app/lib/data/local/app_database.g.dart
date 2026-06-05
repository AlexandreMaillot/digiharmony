// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $EntreesHumeurTable extends EntreesHumeur
    with TableInfo<$EntreesHumeurTable, EntreeHumeur> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntreesHumeurTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeEmotionMeta = const VerificationMeta(
    'codeEmotion',
  );
  @override
  late final GeneratedColumn<String> codeEmotion = GeneratedColumn<String>(
    'code_emotion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valenceMeta = const VerificationMeta(
    'valence',
  );
  @override
  late final GeneratedColumn<int> valence = GeneratedColumn<int>(
    'valence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creeLeMeta = const VerificationMeta('creeLe');
  @override
  late final GeneratedColumn<DateTime> creeLe = GeneratedColumn<DateTime>(
    'cree_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, codeEmotion, valence, creeLe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entrees_humeur';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntreeHumeur> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code_emotion')) {
      context.handle(
        _codeEmotionMeta,
        codeEmotion.isAcceptableOrUnknown(
          data['code_emotion']!,
          _codeEmotionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_codeEmotionMeta);
    }
    if (data.containsKey('valence')) {
      context.handle(
        _valenceMeta,
        valence.isAcceptableOrUnknown(data['valence']!, _valenceMeta),
      );
    } else if (isInserting) {
      context.missing(_valenceMeta);
    }
    if (data.containsKey('cree_le')) {
      context.handle(
        _creeLeMeta,
        creeLe.isAcceptableOrUnknown(data['cree_le']!, _creeLeMeta),
      );
    } else if (isInserting) {
      context.missing(_creeLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntreeHumeur map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntreeHumeur(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codeEmotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_emotion'],
      )!,
      valence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}valence'],
      )!,
      creeLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cree_le'],
      )!,
    );
  }

  @override
  $EntreesHumeurTable createAlias(String alias) {
    return $EntreesHumeurTable(attachedDatabase, alias);
  }
}

class EntreeHumeur extends DataClass implements Insertable<EntreeHumeur> {
  /// Identifiant auto-incrémenté.
  final int id;

  /// Code stable de l'émotion (aligné `MoodColors.byKey`).
  final String codeEmotion;

  /// Valence : >= 0 positive/neutre, < 0 négative.
  ///
  /// Sert au futur compteur « 7 émotions négatives consécutives », dérivé de
  /// Drift (DEC-001), jamais dupliqué dans HydratedBloc.
  final int valence;

  /// Horodatage local de création.
  final DateTime creeLe;
  const EntreeHumeur({
    required this.id,
    required this.codeEmotion,
    required this.valence,
    required this.creeLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code_emotion'] = Variable<String>(codeEmotion);
    map['valence'] = Variable<int>(valence);
    map['cree_le'] = Variable<DateTime>(creeLe);
    return map;
  }

  EntreesHumeurCompanion toCompanion(bool nullToAbsent) {
    return EntreesHumeurCompanion(
      id: Value(id),
      codeEmotion: Value(codeEmotion),
      valence: Value(valence),
      creeLe: Value(creeLe),
    );
  }

  factory EntreeHumeur.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntreeHumeur(
      id: serializer.fromJson<int>(json['id']),
      codeEmotion: serializer.fromJson<String>(json['codeEmotion']),
      valence: serializer.fromJson<int>(json['valence']),
      creeLe: serializer.fromJson<DateTime>(json['creeLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codeEmotion': serializer.toJson<String>(codeEmotion),
      'valence': serializer.toJson<int>(valence),
      'creeLe': serializer.toJson<DateTime>(creeLe),
    };
  }

  EntreeHumeur copyWith({
    int? id,
    String? codeEmotion,
    int? valence,
    DateTime? creeLe,
  }) => EntreeHumeur(
    id: id ?? this.id,
    codeEmotion: codeEmotion ?? this.codeEmotion,
    valence: valence ?? this.valence,
    creeLe: creeLe ?? this.creeLe,
  );
  EntreeHumeur copyWithCompanion(EntreesHumeurCompanion data) {
    return EntreeHumeur(
      id: data.id.present ? data.id.value : this.id,
      codeEmotion: data.codeEmotion.present
          ? data.codeEmotion.value
          : this.codeEmotion,
      valence: data.valence.present ? data.valence.value : this.valence,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntreeHumeur(')
          ..write('id: $id, ')
          ..write('codeEmotion: $codeEmotion, ')
          ..write('valence: $valence, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, codeEmotion, valence, creeLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntreeHumeur &&
          other.id == this.id &&
          other.codeEmotion == this.codeEmotion &&
          other.valence == this.valence &&
          other.creeLe == this.creeLe);
}

class EntreesHumeurCompanion extends UpdateCompanion<EntreeHumeur> {
  final Value<int> id;
  final Value<String> codeEmotion;
  final Value<int> valence;
  final Value<DateTime> creeLe;
  const EntreesHumeurCompanion({
    this.id = const Value.absent(),
    this.codeEmotion = const Value.absent(),
    this.valence = const Value.absent(),
    this.creeLe = const Value.absent(),
  });
  EntreesHumeurCompanion.insert({
    this.id = const Value.absent(),
    required String codeEmotion,
    required int valence,
    required DateTime creeLe,
  }) : codeEmotion = Value(codeEmotion),
       valence = Value(valence),
       creeLe = Value(creeLe);
  static Insertable<EntreeHumeur> custom({
    Expression<int>? id,
    Expression<String>? codeEmotion,
    Expression<int>? valence,
    Expression<DateTime>? creeLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codeEmotion != null) 'code_emotion': codeEmotion,
      if (valence != null) 'valence': valence,
      if (creeLe != null) 'cree_le': creeLe,
    });
  }

  EntreesHumeurCompanion copyWith({
    Value<int>? id,
    Value<String>? codeEmotion,
    Value<int>? valence,
    Value<DateTime>? creeLe,
  }) {
    return EntreesHumeurCompanion(
      id: id ?? this.id,
      codeEmotion: codeEmotion ?? this.codeEmotion,
      valence: valence ?? this.valence,
      creeLe: creeLe ?? this.creeLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codeEmotion.present) {
      map['code_emotion'] = Variable<String>(codeEmotion.value);
    }
    if (valence.present) {
      map['valence'] = Variable<int>(valence.value);
    }
    if (creeLe.present) {
      map['cree_le'] = Variable<DateTime>(creeLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntreesHumeurCompanion(')
          ..write('id: $id, ')
          ..write('codeEmotion: $codeEmotion, ')
          ..write('valence: $valence, ')
          ..write('creeLe: $creeLe')
          ..write(')'))
        .toString();
  }
}

class $ConseilsTable extends Conseils with TableInfo<$ConseilsTable, Conseil> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConseilsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _cleConseilMeta = const VerificationMeta(
    'cleConseil',
  );
  @override
  late final GeneratedColumn<String> cleConseil = GeneratedColumn<String>(
    'cle_conseil',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, cleConseil];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conseils';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conseil> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('cle_conseil')) {
      context.handle(
        _cleConseilMeta,
        cleConseil.isAcceptableOrUnknown(data['cle_conseil']!, _cleConseilMeta),
      );
    } else if (isInserting) {
      context.missing(_cleConseilMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conseil map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conseil(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      cleConseil: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cle_conseil'],
      )!,
    );
  }

  @override
  $ConseilsTable createAlias(String alias) {
    return $ConseilsTable(attachedDatabase, alias);
  }
}

class Conseil extends DataClass implements Insertable<Conseil> {
  /// Identifiant auto-incrémenté.
  final int id;

  /// Clé i18n du conseil (le texte traduit vit dans les ARB).
  final String cleConseil;
  const Conseil({required this.id, required this.cleConseil});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cle_conseil'] = Variable<String>(cleConseil);
    return map;
  }

  ConseilsCompanion toCompanion(bool nullToAbsent) {
    return ConseilsCompanion(id: Value(id), cleConseil: Value(cleConseil));
  }

  factory Conseil.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conseil(
      id: serializer.fromJson<int>(json['id']),
      cleConseil: serializer.fromJson<String>(json['cleConseil']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cleConseil': serializer.toJson<String>(cleConseil),
    };
  }

  Conseil copyWith({int? id, String? cleConseil}) =>
      Conseil(id: id ?? this.id, cleConseil: cleConseil ?? this.cleConseil);
  Conseil copyWithCompanion(ConseilsCompanion data) {
    return Conseil(
      id: data.id.present ? data.id.value : this.id,
      cleConseil: data.cleConseil.present
          ? data.cleConseil.value
          : this.cleConseil,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conseil(')
          ..write('id: $id, ')
          ..write('cleConseil: $cleConseil')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, cleConseil);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conseil &&
          other.id == this.id &&
          other.cleConseil == this.cleConseil);
}

class ConseilsCompanion extends UpdateCompanion<Conseil> {
  final Value<int> id;
  final Value<String> cleConseil;
  const ConseilsCompanion({
    this.id = const Value.absent(),
    this.cleConseil = const Value.absent(),
  });
  ConseilsCompanion.insert({
    this.id = const Value.absent(),
    required String cleConseil,
  }) : cleConseil = Value(cleConseil);
  static Insertable<Conseil> custom({
    Expression<int>? id,
    Expression<String>? cleConseil,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cleConseil != null) 'cle_conseil': cleConseil,
    });
  }

  ConseilsCompanion copyWith({Value<int>? id, Value<String>? cleConseil}) {
    return ConseilsCompanion(
      id: id ?? this.id,
      cleConseil: cleConseil ?? this.cleConseil,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (cleConseil.present) {
      map['cle_conseil'] = Variable<String>(cleConseil.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConseilsCompanion(')
          ..write('id: $id, ')
          ..write('cleConseil: $cleConseil')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EntreesHumeurTable entreesHumeur = $EntreesHumeurTable(this);
  late final $ConseilsTable conseils = $ConseilsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [entreesHumeur, conseils];
}

typedef $$EntreesHumeurTableCreateCompanionBuilder =
    EntreesHumeurCompanion Function({
      Value<int> id,
      required String codeEmotion,
      required int valence,
      required DateTime creeLe,
    });
typedef $$EntreesHumeurTableUpdateCompanionBuilder =
    EntreesHumeurCompanion Function({
      Value<int> id,
      Value<String> codeEmotion,
      Value<int> valence,
      Value<DateTime> creeLe,
    });

class $$EntreesHumeurTableFilterComposer
    extends Composer<_$AppDatabase, $EntreesHumeurTable> {
  $$EntreesHumeurTableFilterComposer({
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

  ColumnFilters<String> get codeEmotion => $composableBuilder(
    column: $table.codeEmotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntreesHumeurTableOrderingComposer
    extends Composer<_$AppDatabase, $EntreesHumeurTable> {
  $$EntreesHumeurTableOrderingComposer({
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

  ColumnOrderings<String> get codeEmotion => $composableBuilder(
    column: $table.codeEmotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get valence => $composableBuilder(
    column: $table.valence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creeLe => $composableBuilder(
    column: $table.creeLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntreesHumeurTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntreesHumeurTable> {
  $$EntreesHumeurTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codeEmotion => $composableBuilder(
    column: $table.codeEmotion,
    builder: (column) => column,
  );

  GeneratedColumn<int> get valence =>
      $composableBuilder(column: $table.valence, builder: (column) => column);

  GeneratedColumn<DateTime> get creeLe =>
      $composableBuilder(column: $table.creeLe, builder: (column) => column);
}

class $$EntreesHumeurTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntreesHumeurTable,
          EntreeHumeur,
          $$EntreesHumeurTableFilterComposer,
          $$EntreesHumeurTableOrderingComposer,
          $$EntreesHumeurTableAnnotationComposer,
          $$EntreesHumeurTableCreateCompanionBuilder,
          $$EntreesHumeurTableUpdateCompanionBuilder,
          (
            EntreeHumeur,
            BaseReferences<_$AppDatabase, $EntreesHumeurTable, EntreeHumeur>,
          ),
          EntreeHumeur,
          PrefetchHooks Function()
        > {
  $$EntreesHumeurTableTableManager(_$AppDatabase db, $EntreesHumeurTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntreesHumeurTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntreesHumeurTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntreesHumeurTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> codeEmotion = const Value.absent(),
                Value<int> valence = const Value.absent(),
                Value<DateTime> creeLe = const Value.absent(),
              }) => EntreesHumeurCompanion(
                id: id,
                codeEmotion: codeEmotion,
                valence: valence,
                creeLe: creeLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codeEmotion,
                required int valence,
                required DateTime creeLe,
              }) => EntreesHumeurCompanion.insert(
                id: id,
                codeEmotion: codeEmotion,
                valence: valence,
                creeLe: creeLe,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntreesHumeurTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntreesHumeurTable,
      EntreeHumeur,
      $$EntreesHumeurTableFilterComposer,
      $$EntreesHumeurTableOrderingComposer,
      $$EntreesHumeurTableAnnotationComposer,
      $$EntreesHumeurTableCreateCompanionBuilder,
      $$EntreesHumeurTableUpdateCompanionBuilder,
      (
        EntreeHumeur,
        BaseReferences<_$AppDatabase, $EntreesHumeurTable, EntreeHumeur>,
      ),
      EntreeHumeur,
      PrefetchHooks Function()
    >;
typedef $$ConseilsTableCreateCompanionBuilder =
    ConseilsCompanion Function({Value<int> id, required String cleConseil});
typedef $$ConseilsTableUpdateCompanionBuilder =
    ConseilsCompanion Function({Value<int> id, Value<String> cleConseil});

class $$ConseilsTableFilterComposer
    extends Composer<_$AppDatabase, $ConseilsTable> {
  $$ConseilsTableFilterComposer({
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

  ColumnFilters<String> get cleConseil => $composableBuilder(
    column: $table.cleConseil,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConseilsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConseilsTable> {
  $$ConseilsTableOrderingComposer({
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

  ColumnOrderings<String> get cleConseil => $composableBuilder(
    column: $table.cleConseil,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConseilsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConseilsTable> {
  $$ConseilsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get cleConseil => $composableBuilder(
    column: $table.cleConseil,
    builder: (column) => column,
  );
}

class $$ConseilsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConseilsTable,
          Conseil,
          $$ConseilsTableFilterComposer,
          $$ConseilsTableOrderingComposer,
          $$ConseilsTableAnnotationComposer,
          $$ConseilsTableCreateCompanionBuilder,
          $$ConseilsTableUpdateCompanionBuilder,
          (Conseil, BaseReferences<_$AppDatabase, $ConseilsTable, Conseil>),
          Conseil,
          PrefetchHooks Function()
        > {
  $$ConseilsTableTableManager(_$AppDatabase db, $ConseilsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConseilsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConseilsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConseilsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> cleConseil = const Value.absent(),
              }) => ConseilsCompanion(id: id, cleConseil: cleConseil),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cleConseil,
              }) => ConseilsCompanion.insert(id: id, cleConseil: cleConseil),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConseilsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConseilsTable,
      Conseil,
      $$ConseilsTableFilterComposer,
      $$ConseilsTableOrderingComposer,
      $$ConseilsTableAnnotationComposer,
      $$ConseilsTableCreateCompanionBuilder,
      $$ConseilsTableUpdateCompanionBuilder,
      (Conseil, BaseReferences<_$AppDatabase, $ConseilsTable, Conseil>),
      Conseil,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EntreesHumeurTableTableManager get entreesHumeur =>
      $$EntreesHumeurTableTableManager(_db, _db.entreesHumeur);
  $$ConseilsTableTableManager get conseils =>
      $$ConseilsTableTableManager(_db, _db.conseils);
}
