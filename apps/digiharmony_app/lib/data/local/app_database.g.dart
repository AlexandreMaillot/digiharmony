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
  static const VerificationMeta _jourMeta = const VerificationMeta('jour');
  @override
  late final GeneratedColumn<DateTime> jour = GeneratedColumn<DateTime>(
    'jour',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codeEmotion,
    valence,
    creeLe,
    jour,
  ];
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
    if (data.containsKey('jour')) {
      context.handle(
        _jourMeta,
        jour.isAcceptableOrUnknown(data['jour']!, _jourMeta),
      );
    } else if (isInserting) {
      context.missing(_jourMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {jour},
  ];
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
      jour: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}jour'],
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

  /// Valence : >= 0 positive/neutre, < 0 négative (DEC-SH-002).
  ///
  /// Sert au futur compteur « 7 émotions négatives consécutives », dérivé de
  /// Drift (DEC-001), jamais dupliqué dans HydratedBloc.
  final int valence;

  /// Horodatage local de création.
  final DateTime creeLe;

  /// Jour normalisé (minuit local) — clé d'unicité quotidienne (v2).
  ///
  /// Stocké comme DateTime à 00:00:00 local. Index UNIQUE généré par Drift
  /// via [uniqueKeys]. Permet l'UPSERT par jour (DEC-SH-001).
  final DateTime jour;
  const EntreeHumeur({
    required this.id,
    required this.codeEmotion,
    required this.valence,
    required this.creeLe,
    required this.jour,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code_emotion'] = Variable<String>(codeEmotion);
    map['valence'] = Variable<int>(valence);
    map['cree_le'] = Variable<DateTime>(creeLe);
    map['jour'] = Variable<DateTime>(jour);
    return map;
  }

  EntreesHumeurCompanion toCompanion(bool nullToAbsent) {
    return EntreesHumeurCompanion(
      id: Value(id),
      codeEmotion: Value(codeEmotion),
      valence: Value(valence),
      creeLe: Value(creeLe),
      jour: Value(jour),
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
      jour: serializer.fromJson<DateTime>(json['jour']),
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
      'jour': serializer.toJson<DateTime>(jour),
    };
  }

  EntreeHumeur copyWith({
    int? id,
    String? codeEmotion,
    int? valence,
    DateTime? creeLe,
    DateTime? jour,
  }) => EntreeHumeur(
    id: id ?? this.id,
    codeEmotion: codeEmotion ?? this.codeEmotion,
    valence: valence ?? this.valence,
    creeLe: creeLe ?? this.creeLe,
    jour: jour ?? this.jour,
  );
  EntreeHumeur copyWithCompanion(EntreesHumeurCompanion data) {
    return EntreeHumeur(
      id: data.id.present ? data.id.value : this.id,
      codeEmotion: data.codeEmotion.present
          ? data.codeEmotion.value
          : this.codeEmotion,
      valence: data.valence.present ? data.valence.value : this.valence,
      creeLe: data.creeLe.present ? data.creeLe.value : this.creeLe,
      jour: data.jour.present ? data.jour.value : this.jour,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntreeHumeur(')
          ..write('id: $id, ')
          ..write('codeEmotion: $codeEmotion, ')
          ..write('valence: $valence, ')
          ..write('creeLe: $creeLe, ')
          ..write('jour: $jour')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, codeEmotion, valence, creeLe, jour);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntreeHumeur &&
          other.id == this.id &&
          other.codeEmotion == this.codeEmotion &&
          other.valence == this.valence &&
          other.creeLe == this.creeLe &&
          other.jour == this.jour);
}

class EntreesHumeurCompanion extends UpdateCompanion<EntreeHumeur> {
  final Value<int> id;
  final Value<String> codeEmotion;
  final Value<int> valence;
  final Value<DateTime> creeLe;
  final Value<DateTime> jour;
  const EntreesHumeurCompanion({
    this.id = const Value.absent(),
    this.codeEmotion = const Value.absent(),
    this.valence = const Value.absent(),
    this.creeLe = const Value.absent(),
    this.jour = const Value.absent(),
  });
  EntreesHumeurCompanion.insert({
    this.id = const Value.absent(),
    required String codeEmotion,
    required int valence,
    required DateTime creeLe,
    required DateTime jour,
  }) : codeEmotion = Value(codeEmotion),
       valence = Value(valence),
       creeLe = Value(creeLe),
       jour = Value(jour);
  static Insertable<EntreeHumeur> custom({
    Expression<int>? id,
    Expression<String>? codeEmotion,
    Expression<int>? valence,
    Expression<DateTime>? creeLe,
    Expression<DateTime>? jour,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codeEmotion != null) 'code_emotion': codeEmotion,
      if (valence != null) 'valence': valence,
      if (creeLe != null) 'cree_le': creeLe,
      if (jour != null) 'jour': jour,
    });
  }

  EntreesHumeurCompanion copyWith({
    Value<int>? id,
    Value<String>? codeEmotion,
    Value<int>? valence,
    Value<DateTime>? creeLe,
    Value<DateTime>? jour,
  }) {
    return EntreesHumeurCompanion(
      id: id ?? this.id,
      codeEmotion: codeEmotion ?? this.codeEmotion,
      valence: valence ?? this.valence,
      creeLe: creeLe ?? this.creeLe,
      jour: jour ?? this.jour,
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
    if (jour.present) {
      map['jour'] = Variable<DateTime>(jour.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntreesHumeurCompanion(')
          ..write('id: $id, ')
          ..write('codeEmotion: $codeEmotion, ')
          ..write('valence: $valence, ')
          ..write('creeLe: $creeLe, ')
          ..write('jour: $jour')
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
  static const VerificationMeta _typeCarteMeta = const VerificationMeta(
    'typeCarte',
  );
  @override
  late final GeneratedColumn<String> typeCarte = GeneratedColumn<String>(
    'type_carte',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('conseil'),
  );
  static const VerificationMeta _codeEmotionMeta = const VerificationMeta(
    'codeEmotion',
  );
  @override
  late final GeneratedColumn<String> codeEmotion = GeneratedColumn<String>(
    'code_emotion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accentChromeMeta = const VerificationMeta(
    'accentChrome',
  );
  @override
  late final GeneratedColumn<String> accentChrome = GeneratedColumn<String>(
    'accent_chrome',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('primary'),
  );
  static const VerificationMeta _ordreMeta = const VerificationMeta('ordre');
  @override
  late final GeneratedColumn<int> ordre = GeneratedColumn<int>(
    'ordre',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    cleConseil,
    typeCarte,
    codeEmotion,
    accentChrome,
    ordre,
  ];
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
    if (data.containsKey('type_carte')) {
      context.handle(
        _typeCarteMeta,
        typeCarte.isAcceptableOrUnknown(data['type_carte']!, _typeCarteMeta),
      );
    }
    if (data.containsKey('code_emotion')) {
      context.handle(
        _codeEmotionMeta,
        codeEmotion.isAcceptableOrUnknown(
          data['code_emotion']!,
          _codeEmotionMeta,
        ),
      );
    }
    if (data.containsKey('accent_chrome')) {
      context.handle(
        _accentChromeMeta,
        accentChrome.isAcceptableOrUnknown(
          data['accent_chrome']!,
          _accentChromeMeta,
        ),
      );
    }
    if (data.containsKey('ordre')) {
      context.handle(
        _ordreMeta,
        ordre.isAcceptableOrUnknown(data['ordre']!, _ordreMeta),
      );
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
      typeCarte: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type_carte'],
      )!,
      codeEmotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code_emotion'],
      ),
      accentChrome: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_chrome'],
      )!,
      ordre: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordre'],
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

  /// Type de carte : 'rappel' | 'conseil' | 'emotion'.
  final String typeCarte;

  /// Code émotion canonique si typeCarte == 'emotion' (sinon null).
  ///
  /// ∈ emotionsCanoniques ('happy','calm','dynamic','sad','angry','nervous',
  /// 'tired'). Couleur résolue via MoodColors.byKey à l'affichage.
  final String? codeEmotion;

  /// Jeton d'accent CHROME pour les cartes rappel/conseil.
  ///
  /// Valeurs : 'primary' | 'lime' | 'or'. Ignoré pour 'emotion' (couleur
  /// dérivée de MoodColors). JAMAIS un hex (DEC-CO-07).
  final String accentChrome;

  /// Ordre stable dans le corpus (rotation déterministe). Défaut = id.
  final int ordre;
  const Conseil({
    required this.id,
    required this.cleConseil,
    required this.typeCarte,
    this.codeEmotion,
    required this.accentChrome,
    required this.ordre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['cle_conseil'] = Variable<String>(cleConseil);
    map['type_carte'] = Variable<String>(typeCarte);
    if (!nullToAbsent || codeEmotion != null) {
      map['code_emotion'] = Variable<String>(codeEmotion);
    }
    map['accent_chrome'] = Variable<String>(accentChrome);
    map['ordre'] = Variable<int>(ordre);
    return map;
  }

  ConseilsCompanion toCompanion(bool nullToAbsent) {
    return ConseilsCompanion(
      id: Value(id),
      cleConseil: Value(cleConseil),
      typeCarte: Value(typeCarte),
      codeEmotion: codeEmotion == null && nullToAbsent
          ? const Value.absent()
          : Value(codeEmotion),
      accentChrome: Value(accentChrome),
      ordre: Value(ordre),
    );
  }

  factory Conseil.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conseil(
      id: serializer.fromJson<int>(json['id']),
      cleConseil: serializer.fromJson<String>(json['cleConseil']),
      typeCarte: serializer.fromJson<String>(json['typeCarte']),
      codeEmotion: serializer.fromJson<String?>(json['codeEmotion']),
      accentChrome: serializer.fromJson<String>(json['accentChrome']),
      ordre: serializer.fromJson<int>(json['ordre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'cleConseil': serializer.toJson<String>(cleConseil),
      'typeCarte': serializer.toJson<String>(typeCarte),
      'codeEmotion': serializer.toJson<String?>(codeEmotion),
      'accentChrome': serializer.toJson<String>(accentChrome),
      'ordre': serializer.toJson<int>(ordre),
    };
  }

  Conseil copyWith({
    int? id,
    String? cleConseil,
    String? typeCarte,
    Value<String?> codeEmotion = const Value.absent(),
    String? accentChrome,
    int? ordre,
  }) => Conseil(
    id: id ?? this.id,
    cleConseil: cleConseil ?? this.cleConseil,
    typeCarte: typeCarte ?? this.typeCarte,
    codeEmotion: codeEmotion.present ? codeEmotion.value : this.codeEmotion,
    accentChrome: accentChrome ?? this.accentChrome,
    ordre: ordre ?? this.ordre,
  );
  Conseil copyWithCompanion(ConseilsCompanion data) {
    return Conseil(
      id: data.id.present ? data.id.value : this.id,
      cleConseil: data.cleConseil.present
          ? data.cleConseil.value
          : this.cleConseil,
      typeCarte: data.typeCarte.present ? data.typeCarte.value : this.typeCarte,
      codeEmotion: data.codeEmotion.present
          ? data.codeEmotion.value
          : this.codeEmotion,
      accentChrome: data.accentChrome.present
          ? data.accentChrome.value
          : this.accentChrome,
      ordre: data.ordre.present ? data.ordre.value : this.ordre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conseil(')
          ..write('id: $id, ')
          ..write('cleConseil: $cleConseil, ')
          ..write('typeCarte: $typeCarte, ')
          ..write('codeEmotion: $codeEmotion, ')
          ..write('accentChrome: $accentChrome, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, cleConseil, typeCarte, codeEmotion, accentChrome, ordre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conseil &&
          other.id == this.id &&
          other.cleConseil == this.cleConseil &&
          other.typeCarte == this.typeCarte &&
          other.codeEmotion == this.codeEmotion &&
          other.accentChrome == this.accentChrome &&
          other.ordre == this.ordre);
}

class ConseilsCompanion extends UpdateCompanion<Conseil> {
  final Value<int> id;
  final Value<String> cleConseil;
  final Value<String> typeCarte;
  final Value<String?> codeEmotion;
  final Value<String> accentChrome;
  final Value<int> ordre;
  const ConseilsCompanion({
    this.id = const Value.absent(),
    this.cleConseil = const Value.absent(),
    this.typeCarte = const Value.absent(),
    this.codeEmotion = const Value.absent(),
    this.accentChrome = const Value.absent(),
    this.ordre = const Value.absent(),
  });
  ConseilsCompanion.insert({
    this.id = const Value.absent(),
    required String cleConseil,
    this.typeCarte = const Value.absent(),
    this.codeEmotion = const Value.absent(),
    this.accentChrome = const Value.absent(),
    this.ordre = const Value.absent(),
  }) : cleConseil = Value(cleConseil);
  static Insertable<Conseil> custom({
    Expression<int>? id,
    Expression<String>? cleConseil,
    Expression<String>? typeCarte,
    Expression<String>? codeEmotion,
    Expression<String>? accentChrome,
    Expression<int>? ordre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cleConseil != null) 'cle_conseil': cleConseil,
      if (typeCarte != null) 'type_carte': typeCarte,
      if (codeEmotion != null) 'code_emotion': codeEmotion,
      if (accentChrome != null) 'accent_chrome': accentChrome,
      if (ordre != null) 'ordre': ordre,
    });
  }

  ConseilsCompanion copyWith({
    Value<int>? id,
    Value<String>? cleConseil,
    Value<String>? typeCarte,
    Value<String?>? codeEmotion,
    Value<String>? accentChrome,
    Value<int>? ordre,
  }) {
    return ConseilsCompanion(
      id: id ?? this.id,
      cleConseil: cleConseil ?? this.cleConseil,
      typeCarte: typeCarte ?? this.typeCarte,
      codeEmotion: codeEmotion ?? this.codeEmotion,
      accentChrome: accentChrome ?? this.accentChrome,
      ordre: ordre ?? this.ordre,
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
    if (typeCarte.present) {
      map['type_carte'] = Variable<String>(typeCarte.value);
    }
    if (codeEmotion.present) {
      map['code_emotion'] = Variable<String>(codeEmotion.value);
    }
    if (accentChrome.present) {
      map['accent_chrome'] = Variable<String>(accentChrome.value);
    }
    if (ordre.present) {
      map['ordre'] = Variable<int>(ordre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConseilsCompanion(')
          ..write('id: $id, ')
          ..write('cleConseil: $cleConseil, ')
          ..write('typeCarte: $typeCarte, ')
          ..write('codeEmotion: $codeEmotion, ')
          ..write('accentChrome: $accentChrome, ')
          ..write('ordre: $ordre')
          ..write(')'))
        .toString();
  }
}

class $UsagesEcranJournaliersTable extends UsagesEcranJournaliers
    with TableInfo<$UsagesEcranJournaliersTable, UsageEcranJournalier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsagesEcranJournaliersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _jourMeta = const VerificationMeta('jour');
  @override
  late final GeneratedColumn<DateTime> jour = GeneratedColumn<DateTime>(
    'jour',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalSecondesMeta = const VerificationMeta(
    'totalSecondes',
  );
  @override
  late final GeneratedColumn<int> totalSecondes = GeneratedColumn<int>(
    'total_secondes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _majLeMeta = const VerificationMeta('majLe');
  @override
  late final GeneratedColumn<DateTime> majLe = GeneratedColumn<DateTime>(
    'maj_le',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, jour, totalSecondes, majLe];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'usages_ecran_journaliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<UsageEcranJournalier> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('jour')) {
      context.handle(
        _jourMeta,
        jour.isAcceptableOrUnknown(data['jour']!, _jourMeta),
      );
    } else if (isInserting) {
      context.missing(_jourMeta);
    }
    if (data.containsKey('total_secondes')) {
      context.handle(
        _totalSecondesMeta,
        totalSecondes.isAcceptableOrUnknown(
          data['total_secondes']!,
          _totalSecondesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalSecondesMeta);
    }
    if (data.containsKey('maj_le')) {
      context.handle(
        _majLeMeta,
        majLe.isAcceptableOrUnknown(data['maj_le']!, _majLeMeta),
      );
    } else if (isInserting) {
      context.missing(_majLeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {jour},
  ];
  @override
  UsageEcranJournalier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UsageEcranJournalier(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      jour: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}jour'],
      )!,
      totalSecondes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_secondes'],
      )!,
      majLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}maj_le'],
      )!,
    );
  }

  @override
  $UsagesEcranJournaliersTable createAlias(String alias) {
    return $UsagesEcranJournaliersTable(attachedDatabase, alias);
  }
}

class UsageEcranJournalier extends DataClass
    implements Insertable<UsageEcranJournalier> {
  /// Identifiant auto-incrémenté.
  final int id;

  /// Jour normalisé (minuit local) — clé d'unicité quotidienne.
  ///
  /// Stocké comme DateTime à 00:00:00 local. Index UNIQUE via [uniqueKeys]
  /// pour garantir un agrégat max par jour (UPSERT).
  final DateTime jour;

  /// Total agrégé du jour, en **secondes** (somme des usages des apps).
  final int totalSecondes;

  /// Horodatage local de la dernière mise à jour de l'agrégat.
  final DateTime majLe;
  const UsageEcranJournalier({
    required this.id,
    required this.jour,
    required this.totalSecondes,
    required this.majLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['jour'] = Variable<DateTime>(jour);
    map['total_secondes'] = Variable<int>(totalSecondes);
    map['maj_le'] = Variable<DateTime>(majLe);
    return map;
  }

  UsagesEcranJournaliersCompanion toCompanion(bool nullToAbsent) {
    return UsagesEcranJournaliersCompanion(
      id: Value(id),
      jour: Value(jour),
      totalSecondes: Value(totalSecondes),
      majLe: Value(majLe),
    );
  }

  factory UsageEcranJournalier.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UsageEcranJournalier(
      id: serializer.fromJson<int>(json['id']),
      jour: serializer.fromJson<DateTime>(json['jour']),
      totalSecondes: serializer.fromJson<int>(json['totalSecondes']),
      majLe: serializer.fromJson<DateTime>(json['majLe']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'jour': serializer.toJson<DateTime>(jour),
      'totalSecondes': serializer.toJson<int>(totalSecondes),
      'majLe': serializer.toJson<DateTime>(majLe),
    };
  }

  UsageEcranJournalier copyWith({
    int? id,
    DateTime? jour,
    int? totalSecondes,
    DateTime? majLe,
  }) => UsageEcranJournalier(
    id: id ?? this.id,
    jour: jour ?? this.jour,
    totalSecondes: totalSecondes ?? this.totalSecondes,
    majLe: majLe ?? this.majLe,
  );
  UsageEcranJournalier copyWithCompanion(UsagesEcranJournaliersCompanion data) {
    return UsageEcranJournalier(
      id: data.id.present ? data.id.value : this.id,
      jour: data.jour.present ? data.jour.value : this.jour,
      totalSecondes: data.totalSecondes.present
          ? data.totalSecondes.value
          : this.totalSecondes,
      majLe: data.majLe.present ? data.majLe.value : this.majLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UsageEcranJournalier(')
          ..write('id: $id, ')
          ..write('jour: $jour, ')
          ..write('totalSecondes: $totalSecondes, ')
          ..write('majLe: $majLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, jour, totalSecondes, majLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UsageEcranJournalier &&
          other.id == this.id &&
          other.jour == this.jour &&
          other.totalSecondes == this.totalSecondes &&
          other.majLe == this.majLe);
}

class UsagesEcranJournaliersCompanion
    extends UpdateCompanion<UsageEcranJournalier> {
  final Value<int> id;
  final Value<DateTime> jour;
  final Value<int> totalSecondes;
  final Value<DateTime> majLe;
  const UsagesEcranJournaliersCompanion({
    this.id = const Value.absent(),
    this.jour = const Value.absent(),
    this.totalSecondes = const Value.absent(),
    this.majLe = const Value.absent(),
  });
  UsagesEcranJournaliersCompanion.insert({
    this.id = const Value.absent(),
    required DateTime jour,
    required int totalSecondes,
    required DateTime majLe,
  }) : jour = Value(jour),
       totalSecondes = Value(totalSecondes),
       majLe = Value(majLe);
  static Insertable<UsageEcranJournalier> custom({
    Expression<int>? id,
    Expression<DateTime>? jour,
    Expression<int>? totalSecondes,
    Expression<DateTime>? majLe,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (jour != null) 'jour': jour,
      if (totalSecondes != null) 'total_secondes': totalSecondes,
      if (majLe != null) 'maj_le': majLe,
    });
  }

  UsagesEcranJournaliersCompanion copyWith({
    Value<int>? id,
    Value<DateTime>? jour,
    Value<int>? totalSecondes,
    Value<DateTime>? majLe,
  }) {
    return UsagesEcranJournaliersCompanion(
      id: id ?? this.id,
      jour: jour ?? this.jour,
      totalSecondes: totalSecondes ?? this.totalSecondes,
      majLe: majLe ?? this.majLe,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (jour.present) {
      map['jour'] = Variable<DateTime>(jour.value);
    }
    if (totalSecondes.present) {
      map['total_secondes'] = Variable<int>(totalSecondes.value);
    }
    if (majLe.present) {
      map['maj_le'] = Variable<DateTime>(majLe.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsagesEcranJournaliersCompanion(')
          ..write('id: $id, ')
          ..write('jour: $jour, ')
          ..write('totalSecondes: $totalSecondes, ')
          ..write('majLe: $majLe')
          ..write(')'))
        .toString();
  }
}

class $SeancesBienEtreTable extends SeancesBienEtre
    with TableInfo<$SeancesBienEtreTable, SeanceBienEtre> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SeancesBienEtreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciceIdMeta = const VerificationMeta(
    'exerciceId',
  );
  @override
  late final GeneratedColumn<String> exerciceId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreSeancesMeta = const VerificationMeta(
    'nombreSeances',
  );
  @override
  late final GeneratedColumn<int> nombreSeances = GeneratedColumn<int>(
    'completed_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _derniereSeanceLeMeta = const VerificationMeta(
    'derniereSeanceLe',
  );
  @override
  late final GeneratedColumn<DateTime> derniereSeanceLe =
      GeneratedColumn<DateTime>(
        'last_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    exerciceId,
    nombreSeances,
    derniereSeanceLe,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wellbeing_stats';
  @override
  VerificationContext validateIntegrity(
    Insertable<SeanceBienEtre> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciceIdMeta,
        exerciceId.isAcceptableOrUnknown(data['exercise_id']!, _exerciceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciceIdMeta);
    }
    if (data.containsKey('completed_count')) {
      context.handle(
        _nombreSeancesMeta,
        nombreSeances.isAcceptableOrUnknown(
          data['completed_count']!,
          _nombreSeancesMeta,
        ),
      );
    }
    if (data.containsKey('last_completed_at')) {
      context.handle(
        _derniereSeanceLeMeta,
        derniereSeanceLe.isAcceptableOrUnknown(
          data['last_completed_at']!,
          _derniereSeanceLeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciceId};
  @override
  SeanceBienEtre map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SeanceBienEtre(
      exerciceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      nombreSeances: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_count'],
      )!,
      derniereSeanceLe: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_completed_at'],
      ),
    );
  }

  @override
  $SeancesBienEtreTable createAlias(String alias) {
    return $SeancesBienEtreTable(attachedDatabase, alias);
  }
}

class SeanceBienEtre extends DataClass implements Insertable<SeanceBienEtre> {
  /// Identifiant d'exercice (ex. 'breathing', 'senses', 'stretch', 'detox').
  final String exerciceId;

  /// Nombre de séances terminées.
  final int nombreSeances;

  /// Date de la dernière séance terminée (null si aucune).
  final DateTime? derniereSeanceLe;
  const SeanceBienEtre({
    required this.exerciceId,
    required this.nombreSeances,
    this.derniereSeanceLe,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciceId);
    map['completed_count'] = Variable<int>(nombreSeances);
    if (!nullToAbsent || derniereSeanceLe != null) {
      map['last_completed_at'] = Variable<DateTime>(derniereSeanceLe);
    }
    return map;
  }

  SeancesBienEtreCompanion toCompanion(bool nullToAbsent) {
    return SeancesBienEtreCompanion(
      exerciceId: Value(exerciceId),
      nombreSeances: Value(nombreSeances),
      derniereSeanceLe: derniereSeanceLe == null && nullToAbsent
          ? const Value.absent()
          : Value(derniereSeanceLe),
    );
  }

  factory SeanceBienEtre.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SeanceBienEtre(
      exerciceId: serializer.fromJson<String>(json['exerciceId']),
      nombreSeances: serializer.fromJson<int>(json['nombreSeances']),
      derniereSeanceLe: serializer.fromJson<DateTime?>(
        json['derniereSeanceLe'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciceId': serializer.toJson<String>(exerciceId),
      'nombreSeances': serializer.toJson<int>(nombreSeances),
      'derniereSeanceLe': serializer.toJson<DateTime?>(derniereSeanceLe),
    };
  }

  SeanceBienEtre copyWith({
    String? exerciceId,
    int? nombreSeances,
    Value<DateTime?> derniereSeanceLe = const Value.absent(),
  }) => SeanceBienEtre(
    exerciceId: exerciceId ?? this.exerciceId,
    nombreSeances: nombreSeances ?? this.nombreSeances,
    derniereSeanceLe: derniereSeanceLe.present
        ? derniereSeanceLe.value
        : this.derniereSeanceLe,
  );
  SeanceBienEtre copyWithCompanion(SeancesBienEtreCompanion data) {
    return SeanceBienEtre(
      exerciceId: data.exerciceId.present
          ? data.exerciceId.value
          : this.exerciceId,
      nombreSeances: data.nombreSeances.present
          ? data.nombreSeances.value
          : this.nombreSeances,
      derniereSeanceLe: data.derniereSeanceLe.present
          ? data.derniereSeanceLe.value
          : this.derniereSeanceLe,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SeanceBienEtre(')
          ..write('exerciceId: $exerciceId, ')
          ..write('nombreSeances: $nombreSeances, ')
          ..write('derniereSeanceLe: $derniereSeanceLe')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciceId, nombreSeances, derniereSeanceLe);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SeanceBienEtre &&
          other.exerciceId == this.exerciceId &&
          other.nombreSeances == this.nombreSeances &&
          other.derniereSeanceLe == this.derniereSeanceLe);
}

class SeancesBienEtreCompanion extends UpdateCompanion<SeanceBienEtre> {
  final Value<String> exerciceId;
  final Value<int> nombreSeances;
  final Value<DateTime?> derniereSeanceLe;
  final Value<int> rowid;
  const SeancesBienEtreCompanion({
    this.exerciceId = const Value.absent(),
    this.nombreSeances = const Value.absent(),
    this.derniereSeanceLe = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SeancesBienEtreCompanion.insert({
    required String exerciceId,
    this.nombreSeances = const Value.absent(),
    this.derniereSeanceLe = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : exerciceId = Value(exerciceId);
  static Insertable<SeanceBienEtre> custom({
    Expression<String>? exerciceId,
    Expression<int>? nombreSeances,
    Expression<DateTime>? derniereSeanceLe,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciceId != null) 'exercise_id': exerciceId,
      if (nombreSeances != null) 'completed_count': nombreSeances,
      if (derniereSeanceLe != null) 'last_completed_at': derniereSeanceLe,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SeancesBienEtreCompanion copyWith({
    Value<String>? exerciceId,
    Value<int>? nombreSeances,
    Value<DateTime?>? derniereSeanceLe,
    Value<int>? rowid,
  }) {
    return SeancesBienEtreCompanion(
      exerciceId: exerciceId ?? this.exerciceId,
      nombreSeances: nombreSeances ?? this.nombreSeances,
      derniereSeanceLe: derniereSeanceLe ?? this.derniereSeanceLe,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciceId.present) {
      map['exercise_id'] = Variable<String>(exerciceId.value);
    }
    if (nombreSeances.present) {
      map['completed_count'] = Variable<int>(nombreSeances.value);
    }
    if (derniereSeanceLe.present) {
      map['last_completed_at'] = Variable<DateTime>(derniereSeanceLe.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SeancesBienEtreCompanion(')
          ..write('exerciceId: $exerciceId, ')
          ..write('nombreSeances: $nombreSeances, ')
          ..write('derniereSeanceLe: $derniereSeanceLe, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $EntreesHumeurTable entreesHumeur = $EntreesHumeurTable(this);
  late final $ConseilsTable conseils = $ConseilsTable(this);
  late final $UsagesEcranJournaliersTable usagesEcranJournaliers =
      $UsagesEcranJournaliersTable(this);
  late final $SeancesBienEtreTable seancesBienEtre = $SeancesBienEtreTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    entreesHumeur,
    conseils,
    usagesEcranJournaliers,
    seancesBienEtre,
  ];
}

typedef $$EntreesHumeurTableCreateCompanionBuilder =
    EntreesHumeurCompanion Function({
      Value<int> id,
      required String codeEmotion,
      required int valence,
      required DateTime creeLe,
      required DateTime jour,
    });
typedef $$EntreesHumeurTableUpdateCompanionBuilder =
    EntreesHumeurCompanion Function({
      Value<int> id,
      Value<String> codeEmotion,
      Value<int> valence,
      Value<DateTime> creeLe,
      Value<DateTime> jour,
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

  ColumnFilters<DateTime> get jour => $composableBuilder(
    column: $table.jour,
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

  ColumnOrderings<DateTime> get jour => $composableBuilder(
    column: $table.jour,
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

  GeneratedColumn<DateTime> get jour =>
      $composableBuilder(column: $table.jour, builder: (column) => column);
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
                Value<DateTime> jour = const Value.absent(),
              }) => EntreesHumeurCompanion(
                id: id,
                codeEmotion: codeEmotion,
                valence: valence,
                creeLe: creeLe,
                jour: jour,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String codeEmotion,
                required int valence,
                required DateTime creeLe,
                required DateTime jour,
              }) => EntreesHumeurCompanion.insert(
                id: id,
                codeEmotion: codeEmotion,
                valence: valence,
                creeLe: creeLe,
                jour: jour,
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
    ConseilsCompanion Function({
      Value<int> id,
      required String cleConseil,
      Value<String> typeCarte,
      Value<String?> codeEmotion,
      Value<String> accentChrome,
      Value<int> ordre,
    });
typedef $$ConseilsTableUpdateCompanionBuilder =
    ConseilsCompanion Function({
      Value<int> id,
      Value<String> cleConseil,
      Value<String> typeCarte,
      Value<String?> codeEmotion,
      Value<String> accentChrome,
      Value<int> ordre,
    });

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

  ColumnFilters<String> get typeCarte => $composableBuilder(
    column: $table.typeCarte,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get codeEmotion => $composableBuilder(
    column: $table.codeEmotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accentChrome => $composableBuilder(
    column: $table.accentChrome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordre => $composableBuilder(
    column: $table.ordre,
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

  ColumnOrderings<String> get typeCarte => $composableBuilder(
    column: $table.typeCarte,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get codeEmotion => $composableBuilder(
    column: $table.codeEmotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentChrome => $composableBuilder(
    column: $table.accentChrome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordre => $composableBuilder(
    column: $table.ordre,
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

  GeneratedColumn<String> get typeCarte =>
      $composableBuilder(column: $table.typeCarte, builder: (column) => column);

  GeneratedColumn<String> get codeEmotion => $composableBuilder(
    column: $table.codeEmotion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accentChrome => $composableBuilder(
    column: $table.accentChrome,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordre =>
      $composableBuilder(column: $table.ordre, builder: (column) => column);
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
                Value<String> typeCarte = const Value.absent(),
                Value<String?> codeEmotion = const Value.absent(),
                Value<String> accentChrome = const Value.absent(),
                Value<int> ordre = const Value.absent(),
              }) => ConseilsCompanion(
                id: id,
                cleConseil: cleConseil,
                typeCarte: typeCarte,
                codeEmotion: codeEmotion,
                accentChrome: accentChrome,
                ordre: ordre,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String cleConseil,
                Value<String> typeCarte = const Value.absent(),
                Value<String?> codeEmotion = const Value.absent(),
                Value<String> accentChrome = const Value.absent(),
                Value<int> ordre = const Value.absent(),
              }) => ConseilsCompanion.insert(
                id: id,
                cleConseil: cleConseil,
                typeCarte: typeCarte,
                codeEmotion: codeEmotion,
                accentChrome: accentChrome,
                ordre: ordre,
              ),
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
typedef $$UsagesEcranJournaliersTableCreateCompanionBuilder =
    UsagesEcranJournaliersCompanion Function({
      Value<int> id,
      required DateTime jour,
      required int totalSecondes,
      required DateTime majLe,
    });
typedef $$UsagesEcranJournaliersTableUpdateCompanionBuilder =
    UsagesEcranJournaliersCompanion Function({
      Value<int> id,
      Value<DateTime> jour,
      Value<int> totalSecondes,
      Value<DateTime> majLe,
    });

class $$UsagesEcranJournaliersTableFilterComposer
    extends Composer<_$AppDatabase, $UsagesEcranJournaliersTable> {
  $$UsagesEcranJournaliersTableFilterComposer({
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

  ColumnFilters<DateTime> get jour => $composableBuilder(
    column: $table.jour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSecondes => $composableBuilder(
    column: $table.totalSecondes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$UsagesEcranJournaliersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsagesEcranJournaliersTable> {
  $$UsagesEcranJournaliersTableOrderingComposer({
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

  ColumnOrderings<DateTime> get jour => $composableBuilder(
    column: $table.jour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSecondes => $composableBuilder(
    column: $table.totalSecondes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get majLe => $composableBuilder(
    column: $table.majLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsagesEcranJournaliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsagesEcranJournaliersTable> {
  $$UsagesEcranJournaliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get jour =>
      $composableBuilder(column: $table.jour, builder: (column) => column);

  GeneratedColumn<int> get totalSecondes => $composableBuilder(
    column: $table.totalSecondes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get majLe =>
      $composableBuilder(column: $table.majLe, builder: (column) => column);
}

class $$UsagesEcranJournaliersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsagesEcranJournaliersTable,
          UsageEcranJournalier,
          $$UsagesEcranJournaliersTableFilterComposer,
          $$UsagesEcranJournaliersTableOrderingComposer,
          $$UsagesEcranJournaliersTableAnnotationComposer,
          $$UsagesEcranJournaliersTableCreateCompanionBuilder,
          $$UsagesEcranJournaliersTableUpdateCompanionBuilder,
          (
            UsageEcranJournalier,
            BaseReferences<
              _$AppDatabase,
              $UsagesEcranJournaliersTable,
              UsageEcranJournalier
            >,
          ),
          UsageEcranJournalier,
          PrefetchHooks Function()
        > {
  $$UsagesEcranJournaliersTableTableManager(
    _$AppDatabase db,
    $UsagesEcranJournaliersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UsagesEcranJournaliersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$UsagesEcranJournaliersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$UsagesEcranJournaliersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<DateTime> jour = const Value.absent(),
                Value<int> totalSecondes = const Value.absent(),
                Value<DateTime> majLe = const Value.absent(),
              }) => UsagesEcranJournaliersCompanion(
                id: id,
                jour: jour,
                totalSecondes: totalSecondes,
                majLe: majLe,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required DateTime jour,
                required int totalSecondes,
                required DateTime majLe,
              }) => UsagesEcranJournaliersCompanion.insert(
                id: id,
                jour: jour,
                totalSecondes: totalSecondes,
                majLe: majLe,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$UsagesEcranJournaliersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsagesEcranJournaliersTable,
      UsageEcranJournalier,
      $$UsagesEcranJournaliersTableFilterComposer,
      $$UsagesEcranJournaliersTableOrderingComposer,
      $$UsagesEcranJournaliersTableAnnotationComposer,
      $$UsagesEcranJournaliersTableCreateCompanionBuilder,
      $$UsagesEcranJournaliersTableUpdateCompanionBuilder,
      (
        UsageEcranJournalier,
        BaseReferences<
          _$AppDatabase,
          $UsagesEcranJournaliersTable,
          UsageEcranJournalier
        >,
      ),
      UsageEcranJournalier,
      PrefetchHooks Function()
    >;
typedef $$SeancesBienEtreTableCreateCompanionBuilder =
    SeancesBienEtreCompanion Function({
      required String exerciceId,
      Value<int> nombreSeances,
      Value<DateTime?> derniereSeanceLe,
      Value<int> rowid,
    });
typedef $$SeancesBienEtreTableUpdateCompanionBuilder =
    SeancesBienEtreCompanion Function({
      Value<String> exerciceId,
      Value<int> nombreSeances,
      Value<DateTime?> derniereSeanceLe,
      Value<int> rowid,
    });

class $$SeancesBienEtreTableFilterComposer
    extends Composer<_$AppDatabase, $SeancesBienEtreTable> {
  $$SeancesBienEtreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get exerciceId => $composableBuilder(
    column: $table.exerciceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nombreSeances => $composableBuilder(
    column: $table.nombreSeances,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get derniereSeanceLe => $composableBuilder(
    column: $table.derniereSeanceLe,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SeancesBienEtreTableOrderingComposer
    extends Composer<_$AppDatabase, $SeancesBienEtreTable> {
  $$SeancesBienEtreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get exerciceId => $composableBuilder(
    column: $table.exerciceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nombreSeances => $composableBuilder(
    column: $table.nombreSeances,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get derniereSeanceLe => $composableBuilder(
    column: $table.derniereSeanceLe,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SeancesBienEtreTableAnnotationComposer
    extends Composer<_$AppDatabase, $SeancesBienEtreTable> {
  $$SeancesBienEtreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get exerciceId => $composableBuilder(
    column: $table.exerciceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get nombreSeances => $composableBuilder(
    column: $table.nombreSeances,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get derniereSeanceLe => $composableBuilder(
    column: $table.derniereSeanceLe,
    builder: (column) => column,
  );
}

class $$SeancesBienEtreTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SeancesBienEtreTable,
          SeanceBienEtre,
          $$SeancesBienEtreTableFilterComposer,
          $$SeancesBienEtreTableOrderingComposer,
          $$SeancesBienEtreTableAnnotationComposer,
          $$SeancesBienEtreTableCreateCompanionBuilder,
          $$SeancesBienEtreTableUpdateCompanionBuilder,
          (
            SeanceBienEtre,
            BaseReferences<
              _$AppDatabase,
              $SeancesBienEtreTable,
              SeanceBienEtre
            >,
          ),
          SeanceBienEtre,
          PrefetchHooks Function()
        > {
  $$SeancesBienEtreTableTableManager(
    _$AppDatabase db,
    $SeancesBienEtreTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SeancesBienEtreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SeancesBienEtreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SeancesBienEtreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciceId = const Value.absent(),
                Value<int> nombreSeances = const Value.absent(),
                Value<DateTime?> derniereSeanceLe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeancesBienEtreCompanion(
                exerciceId: exerciceId,
                nombreSeances: nombreSeances,
                derniereSeanceLe: derniereSeanceLe,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciceId,
                Value<int> nombreSeances = const Value.absent(),
                Value<DateTime?> derniereSeanceLe = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SeancesBienEtreCompanion.insert(
                exerciceId: exerciceId,
                nombreSeances: nombreSeances,
                derniereSeanceLe: derniereSeanceLe,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SeancesBienEtreTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SeancesBienEtreTable,
      SeanceBienEtre,
      $$SeancesBienEtreTableFilterComposer,
      $$SeancesBienEtreTableOrderingComposer,
      $$SeancesBienEtreTableAnnotationComposer,
      $$SeancesBienEtreTableCreateCompanionBuilder,
      $$SeancesBienEtreTableUpdateCompanionBuilder,
      (
        SeanceBienEtre,
        BaseReferences<_$AppDatabase, $SeancesBienEtreTable, SeanceBienEtre>,
      ),
      SeanceBienEtre,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$EntreesHumeurTableTableManager get entreesHumeur =>
      $$EntreesHumeurTableTableManager(_db, _db.entreesHumeur);
  $$ConseilsTableTableManager get conseils =>
      $$ConseilsTableTableManager(_db, _db.conseils);
  $$UsagesEcranJournaliersTableTableManager get usagesEcranJournaliers =>
      $$UsagesEcranJournaliersTableTableManager(
        _db,
        _db.usagesEcranJournaliers,
      );
  $$SeancesBienEtreTableTableManager get seancesBienEtre =>
      $$SeancesBienEtreTableTableManager(_db, _db.seancesBienEtre);
}
