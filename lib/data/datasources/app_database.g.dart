// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastOpenedAtMeta = const VerificationMeta(
    'lastOpenedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastOpenedAt = GeneratedColumn<DateTime>(
    'last_opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archivedAtMeta = const VerificationMeta(
    'archivedAt',
  );
  @override
  late final GeneratedColumn<DateTime> archivedAt = GeneratedColumn<DateTime>(
    'archived_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultVolumeIdMeta = const VerificationMeta(
    'defaultVolumeId',
  );
  @override
  late final GeneratedColumn<String> defaultVolumeId = GeneratedColumn<String>(
    'default_volume_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVolumeMeta = const VerificationMeta(
    'lastVolume',
  );
  @override
  late final GeneratedColumn<String> lastVolume = GeneratedColumn<String>(
    'last_volume',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastBookApiIdMeta = const VerificationMeta(
    'lastBookApiId',
  );
  @override
  late final GeneratedColumn<String> lastBookApiId = GeneratedColumn<String>(
    'last_book_api_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastBookTitleMeta = const VerificationMeta(
    'lastBookTitle',
  );
  @override
  late final GeneratedColumn<String> lastBookTitle = GeneratedColumn<String>(
    'last_book_title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastChapterMeta = const VerificationMeta(
    'lastChapter',
  );
  @override
  late final GeneratedColumn<int> lastChapter = GeneratedColumn<int>(
    'last_chapter',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastVerseMeta = const VerificationMeta(
    'lastVerse',
  );
  @override
  late final GeneratedColumn<int> lastVerse = GeneratedColumn<int>(
    'last_verse',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    createdAt,
    lastOpenedAt,
    archivedAt,
    defaultVolumeId,
    lastVolume,
    lastBookApiId,
    lastBookTitle,
    lastChapter,
    lastVerse,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('last_opened_at')) {
      context.handle(
        _lastOpenedAtMeta,
        lastOpenedAt.isAcceptableOrUnknown(
          data['last_opened_at']!,
          _lastOpenedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastOpenedAtMeta);
    }
    if (data.containsKey('archived_at')) {
      context.handle(
        _archivedAtMeta,
        archivedAt.isAcceptableOrUnknown(data['archived_at']!, _archivedAtMeta),
      );
    }
    if (data.containsKey('default_volume_id')) {
      context.handle(
        _defaultVolumeIdMeta,
        defaultVolumeId.isAcceptableOrUnknown(
          data['default_volume_id']!,
          _defaultVolumeIdMeta,
        ),
      );
    }
    if (data.containsKey('last_volume')) {
      context.handle(
        _lastVolumeMeta,
        lastVolume.isAcceptableOrUnknown(data['last_volume']!, _lastVolumeMeta),
      );
    }
    if (data.containsKey('last_book_api_id')) {
      context.handle(
        _lastBookApiIdMeta,
        lastBookApiId.isAcceptableOrUnknown(
          data['last_book_api_id']!,
          _lastBookApiIdMeta,
        ),
      );
    }
    if (data.containsKey('last_book_title')) {
      context.handle(
        _lastBookTitleMeta,
        lastBookTitle.isAcceptableOrUnknown(
          data['last_book_title']!,
          _lastBookTitleMeta,
        ),
      );
    }
    if (data.containsKey('last_chapter')) {
      context.handle(
        _lastChapterMeta,
        lastChapter.isAcceptableOrUnknown(
          data['last_chapter']!,
          _lastChapterMeta,
        ),
      );
    }
    if (data.containsKey('last_verse')) {
      context.handle(
        _lastVerseMeta,
        lastVerse.isAcceptableOrUnknown(data['last_verse']!, _lastVerseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      lastOpenedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_opened_at'],
      )!,
      archivedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}archived_at'],
      ),
      defaultVolumeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}default_volume_id'],
      ),
      lastVolume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_volume'],
      ),
      lastBookApiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_book_api_id'],
      ),
      lastBookTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_book_title'],
      ),
      lastChapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_chapter'],
      ),
      lastVerse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_verse'],
      ),
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? description;
  final DateTime createdAt;
  final DateTime lastOpenedAt;
  final DateTime? archivedAt;
  final String? defaultVolumeId;
  final String? lastVolume;
  final String? lastBookApiId;
  final String? lastBookTitle;
  final int? lastChapter;
  final int? lastVerse;
  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    required this.lastOpenedAt,
    this.archivedAt,
    this.defaultVolumeId,
    this.lastVolume,
    this.lastBookApiId,
    this.lastBookTitle,
    this.lastChapter,
    this.lastVerse,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['last_opened_at'] = Variable<DateTime>(lastOpenedAt);
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<DateTime>(archivedAt);
    }
    if (!nullToAbsent || defaultVolumeId != null) {
      map['default_volume_id'] = Variable<String>(defaultVolumeId);
    }
    if (!nullToAbsent || lastVolume != null) {
      map['last_volume'] = Variable<String>(lastVolume);
    }
    if (!nullToAbsent || lastBookApiId != null) {
      map['last_book_api_id'] = Variable<String>(lastBookApiId);
    }
    if (!nullToAbsent || lastBookTitle != null) {
      map['last_book_title'] = Variable<String>(lastBookTitle);
    }
    if (!nullToAbsent || lastChapter != null) {
      map['last_chapter'] = Variable<int>(lastChapter);
    }
    if (!nullToAbsent || lastVerse != null) {
      map['last_verse'] = Variable<int>(lastVerse);
    }
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
      lastOpenedAt: Value(lastOpenedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
      defaultVolumeId: defaultVolumeId == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultVolumeId),
      lastVolume: lastVolume == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVolume),
      lastBookApiId: lastBookApiId == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBookApiId),
      lastBookTitle: lastBookTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBookTitle),
      lastChapter: lastChapter == null && nullToAbsent
          ? const Value.absent()
          : Value(lastChapter),
      lastVerse: lastVerse == null && nullToAbsent
          ? const Value.absent()
          : Value(lastVerse),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      lastOpenedAt: serializer.fromJson<DateTime>(json['lastOpenedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
      defaultVolumeId: serializer.fromJson<String?>(json['defaultVolumeId']),
      lastVolume: serializer.fromJson<String?>(json['lastVolume']),
      lastBookApiId: serializer.fromJson<String?>(json['lastBookApiId']),
      lastBookTitle: serializer.fromJson<String?>(json['lastBookTitle']),
      lastChapter: serializer.fromJson<int?>(json['lastChapter']),
      lastVerse: serializer.fromJson<int?>(json['lastVerse']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'lastOpenedAt': serializer.toJson<DateTime>(lastOpenedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
      'defaultVolumeId': serializer.toJson<String?>(defaultVolumeId),
      'lastVolume': serializer.toJson<String?>(lastVolume),
      'lastBookApiId': serializer.toJson<String?>(lastBookApiId),
      'lastBookTitle': serializer.toJson<String?>(lastBookTitle),
      'lastChapter': serializer.toJson<int?>(lastChapter),
      'lastVerse': serializer.toJson<int?>(lastVerse),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
    DateTime? lastOpenedAt,
    Value<DateTime?> archivedAt = const Value.absent(),
    Value<String?> defaultVolumeId = const Value.absent(),
    Value<String?> lastVolume = const Value.absent(),
    Value<String?> lastBookApiId = const Value.absent(),
    Value<String?> lastBookTitle = const Value.absent(),
    Value<int?> lastChapter = const Value.absent(),
    Value<int?> lastVerse = const Value.absent(),
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
    lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
    defaultVolumeId: defaultVolumeId.present
        ? defaultVolumeId.value
        : this.defaultVolumeId,
    lastVolume: lastVolume.present ? lastVolume.value : this.lastVolume,
    lastBookApiId: lastBookApiId.present
        ? lastBookApiId.value
        : this.lastBookApiId,
    lastBookTitle: lastBookTitle.present
        ? lastBookTitle.value
        : this.lastBookTitle,
    lastChapter: lastChapter.present ? lastChapter.value : this.lastChapter,
    lastVerse: lastVerse.present ? lastVerse.value : this.lastVerse,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
      defaultVolumeId: data.defaultVolumeId.present
          ? data.defaultVolumeId.value
          : this.defaultVolumeId,
      lastVolume: data.lastVolume.present
          ? data.lastVolume.value
          : this.lastVolume,
      lastBookApiId: data.lastBookApiId.present
          ? data.lastBookApiId.value
          : this.lastBookApiId,
      lastBookTitle: data.lastBookTitle.present
          ? data.lastBookTitle.value
          : this.lastBookTitle,
      lastChapter: data.lastChapter.present
          ? data.lastChapter.value
          : this.lastChapter,
      lastVerse: data.lastVerse.present ? data.lastVerse.value : this.lastVerse,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('defaultVolumeId: $defaultVolumeId, ')
          ..write('lastVolume: $lastVolume, ')
          ..write('lastBookApiId: $lastBookApiId, ')
          ..write('lastBookTitle: $lastBookTitle, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('lastVerse: $lastVerse')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    createdAt,
    lastOpenedAt,
    archivedAt,
    defaultVolumeId,
    lastVolume,
    lastBookApiId,
    lastBookTitle,
    lastChapter,
    lastVerse,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.archivedAt == this.archivedAt &&
          other.defaultVolumeId == this.defaultVolumeId &&
          other.lastVolume == this.lastVolume &&
          other.lastBookApiId == this.lastBookApiId &&
          other.lastBookTitle == this.lastBookTitle &&
          other.lastChapter == this.lastChapter &&
          other.lastVerse == this.lastVerse);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<DateTime> lastOpenedAt;
  final Value<DateTime?> archivedAt;
  final Value<String?> defaultVolumeId;
  final Value<String?> lastVolume;
  final Value<String?> lastBookApiId;
  final Value<String?> lastBookTitle;
  final Value<int?> lastChapter;
  final Value<int?> lastVerse;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.defaultVolumeId = const Value.absent(),
    this.lastVolume = const Value.absent(),
    this.lastBookApiId = const Value.absent(),
    this.lastBookTitle = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.lastVerse = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    required DateTime lastOpenedAt,
    this.archivedAt = const Value.absent(),
    this.defaultVolumeId = const Value.absent(),
    this.lastVolume = const Value.absent(),
    this.lastBookApiId = const Value.absent(),
    this.lastBookTitle = const Value.absent(),
    this.lastChapter = const Value.absent(),
    this.lastVerse = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       lastOpenedAt = Value(lastOpenedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? lastOpenedAt,
    Expression<DateTime>? archivedAt,
    Expression<String>? defaultVolumeId,
    Expression<String>? lastVolume,
    Expression<String>? lastBookApiId,
    Expression<String>? lastBookTitle,
    Expression<int>? lastChapter,
    Expression<int>? lastVerse,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (defaultVolumeId != null) 'default_volume_id': defaultVolumeId,
      if (lastVolume != null) 'last_volume': lastVolume,
      if (lastBookApiId != null) 'last_book_api_id': lastBookApiId,
      if (lastBookTitle != null) 'last_book_title': lastBookTitle,
      if (lastChapter != null) 'last_chapter': lastChapter,
      if (lastVerse != null) 'last_verse': lastVerse,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<DateTime>? lastOpenedAt,
    Value<DateTime?>? archivedAt,
    Value<String?>? defaultVolumeId,
    Value<String?>? lastVolume,
    Value<String?>? lastBookApiId,
    Value<String?>? lastBookTitle,
    Value<int?>? lastChapter,
    Value<int?>? lastVerse,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      defaultVolumeId: defaultVolumeId ?? this.defaultVolumeId,
      lastVolume: lastVolume ?? this.lastVolume,
      lastBookApiId: lastBookApiId ?? this.lastBookApiId,
      lastBookTitle: lastBookTitle ?? this.lastBookTitle,
      lastChapter: lastChapter ?? this.lastChapter,
      lastVerse: lastVerse ?? this.lastVerse,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<DateTime>(lastOpenedAt.value);
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<DateTime>(archivedAt.value);
    }
    if (defaultVolumeId.present) {
      map['default_volume_id'] = Variable<String>(defaultVolumeId.value);
    }
    if (lastVolume.present) {
      map['last_volume'] = Variable<String>(lastVolume.value);
    }
    if (lastBookApiId.present) {
      map['last_book_api_id'] = Variable<String>(lastBookApiId.value);
    }
    if (lastBookTitle.present) {
      map['last_book_title'] = Variable<String>(lastBookTitle.value);
    }
    if (lastChapter.present) {
      map['last_chapter'] = Variable<int>(lastChapter.value);
    }
    if (lastVerse.present) {
      map['last_verse'] = Variable<int>(lastVerse.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('defaultVolumeId: $defaultVolumeId, ')
          ..write('lastVolume: $lastVolume, ')
          ..write('lastBookApiId: $lastBookApiId, ')
          ..write('lastBookTitle: $lastBookTitle, ')
          ..write('lastChapter: $lastChapter, ')
          ..write('lastVerse: $lastVerse, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<String> volume = GeneratedColumn<String>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookApiIdMeta = const VerificationMeta(
    'bookApiId',
  );
  @override
  late final GeneratedColumn<String> bookApiId = GeneratedColumn<String>(
    'book_api_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterMeta = const VerificationMeta(
    'chapter',
  );
  @override
  late final GeneratedColumn<int> chapter = GeneratedColumn<int>(
    'chapter',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _verseNumberMeta = const VerificationMeta(
    'verseNumber',
  );
  @override
  late final GeneratedColumn<int> verseNumber = GeneratedColumn<int>(
    'verse_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _highlightColorMeta = const VerificationMeta(
    'highlightColor',
  );
  @override
  late final GeneratedColumn<int> highlightColor = GeneratedColumn<int>(
    'highlight_color',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    volume,
    bookApiId,
    chapter,
    verseNumber,
    type,
    content,
    highlightColor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Note> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    if (data.containsKey('book_api_id')) {
      context.handle(
        _bookApiIdMeta,
        bookApiId.isAcceptableOrUnknown(data['book_api_id']!, _bookApiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookApiIdMeta);
    }
    if (data.containsKey('chapter')) {
      context.handle(
        _chapterMeta,
        chapter.isAcceptableOrUnknown(data['chapter']!, _chapterMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterMeta);
    }
    if (data.containsKey('verse_number')) {
      context.handle(
        _verseNumberMeta,
        verseNumber.isAcceptableOrUnknown(
          data['verse_number']!,
          _verseNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_verseNumberMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('highlight_color')) {
      context.handle(
        _highlightColorMeta,
        highlightColor.isAcceptableOrUnknown(
          data['highlight_color']!,
          _highlightColorMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume'],
      )!,
      bookApiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_api_id'],
      )!,
      chapter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter'],
      )!,
      verseNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}verse_number'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      highlightColor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}highlight_color'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final String id;
  final String projectId;
  final String volume;
  final String bookApiId;
  final int chapter;
  final int verseNumber;
  final String type;
  final String? content;
  final int? highlightColor;
  final DateTime createdAt;
  const Note({
    required this.id,
    required this.projectId,
    required this.volume,
    required this.bookApiId,
    required this.chapter,
    required this.verseNumber,
    required this.type,
    this.content,
    this.highlightColor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['volume'] = Variable<String>(volume);
    map['book_api_id'] = Variable<String>(bookApiId);
    map['chapter'] = Variable<int>(chapter);
    map['verse_number'] = Variable<int>(verseNumber);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || highlightColor != null) {
      map['highlight_color'] = Variable<int>(highlightColor);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      projectId: Value(projectId),
      volume: Value(volume),
      bookApiId: Value(bookApiId),
      chapter: Value(chapter),
      verseNumber: Value(verseNumber),
      type: Value(type),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      highlightColor: highlightColor == null && nullToAbsent
          ? const Value.absent()
          : Value(highlightColor),
      createdAt: Value(createdAt),
    );
  }

  factory Note.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['projectId']),
      volume: serializer.fromJson<String>(json['volume']),
      bookApiId: serializer.fromJson<String>(json['bookApiId']),
      chapter: serializer.fromJson<int>(json['chapter']),
      verseNumber: serializer.fromJson<int>(json['verseNumber']),
      type: serializer.fromJson<String>(json['type']),
      content: serializer.fromJson<String?>(json['content']),
      highlightColor: serializer.fromJson<int?>(json['highlightColor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<String>(projectId),
      'volume': serializer.toJson<String>(volume),
      'bookApiId': serializer.toJson<String>(bookApiId),
      'chapter': serializer.toJson<int>(chapter),
      'verseNumber': serializer.toJson<int>(verseNumber),
      'type': serializer.toJson<String>(type),
      'content': serializer.toJson<String?>(content),
      'highlightColor': serializer.toJson<int?>(highlightColor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Note copyWith({
    String? id,
    String? projectId,
    String? volume,
    String? bookApiId,
    int? chapter,
    int? verseNumber,
    String? type,
    Value<String?> content = const Value.absent(),
    Value<int?> highlightColor = const Value.absent(),
    DateTime? createdAt,
  }) => Note(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    volume: volume ?? this.volume,
    bookApiId: bookApiId ?? this.bookApiId,
    chapter: chapter ?? this.chapter,
    verseNumber: verseNumber ?? this.verseNumber,
    type: type ?? this.type,
    content: content.present ? content.value : this.content,
    highlightColor: highlightColor.present
        ? highlightColor.value
        : this.highlightColor,
    createdAt: createdAt ?? this.createdAt,
  );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      volume: data.volume.present ? data.volume.value : this.volume,
      bookApiId: data.bookApiId.present ? data.bookApiId.value : this.bookApiId,
      chapter: data.chapter.present ? data.chapter.value : this.chapter,
      verseNumber: data.verseNumber.present
          ? data.verseNumber.value
          : this.verseNumber,
      type: data.type.present ? data.type.value : this.type,
      content: data.content.present ? data.content.value : this.content,
      highlightColor: data.highlightColor.present
          ? data.highlightColor.value
          : this.highlightColor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('volume: $volume, ')
          ..write('bookApiId: $bookApiId, ')
          ..write('chapter: $chapter, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('highlightColor: $highlightColor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    volume,
    bookApiId,
    chapter,
    verseNumber,
    type,
    content,
    highlightColor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.volume == this.volume &&
          other.bookApiId == this.bookApiId &&
          other.chapter == this.chapter &&
          other.verseNumber == this.verseNumber &&
          other.type == this.type &&
          other.content == this.content &&
          other.highlightColor == this.highlightColor &&
          other.createdAt == this.createdAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> volume;
  final Value<String> bookApiId;
  final Value<int> chapter;
  final Value<int> verseNumber;
  final Value<String> type;
  final Value<String?> content;
  final Value<int?> highlightColor;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.volume = const Value.absent(),
    this.bookApiId = const Value.absent(),
    this.chapter = const Value.absent(),
    this.verseNumber = const Value.absent(),
    this.type = const Value.absent(),
    this.content = const Value.absent(),
    this.highlightColor = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NotesCompanion.insert({
    required String id,
    required String projectId,
    required String volume,
    required String bookApiId,
    required int chapter,
    required int verseNumber,
    required String type,
    this.content = const Value.absent(),
    this.highlightColor = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       volume = Value(volume),
       bookApiId = Value(bookApiId),
       chapter = Value(chapter),
       verseNumber = Value(verseNumber),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<Note> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? volume,
    Expression<String>? bookApiId,
    Expression<int>? chapter,
    Expression<int>? verseNumber,
    Expression<String>? type,
    Expression<String>? content,
    Expression<int>? highlightColor,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (volume != null) 'volume': volume,
      if (bookApiId != null) 'book_api_id': bookApiId,
      if (chapter != null) 'chapter': chapter,
      if (verseNumber != null) 'verse_number': verseNumber,
      if (type != null) 'type': type,
      if (content != null) 'content': content,
      if (highlightColor != null) 'highlight_color': highlightColor,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NotesCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? volume,
    Value<String>? bookApiId,
    Value<int>? chapter,
    Value<int>? verseNumber,
    Value<String>? type,
    Value<String?>? content,
    Value<int?>? highlightColor,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return NotesCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      volume: volume ?? this.volume,
      bookApiId: bookApiId ?? this.bookApiId,
      chapter: chapter ?? this.chapter,
      verseNumber: verseNumber ?? this.verseNumber,
      type: type ?? this.type,
      content: content ?? this.content,
      highlightColor: highlightColor ?? this.highlightColor,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (volume.present) {
      map['volume'] = Variable<String>(volume.value);
    }
    if (bookApiId.present) {
      map['book_api_id'] = Variable<String>(bookApiId.value);
    }
    if (chapter.present) {
      map['chapter'] = Variable<int>(chapter.value);
    }
    if (verseNumber.present) {
      map['verse_number'] = Variable<int>(verseNumber.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (highlightColor.present) {
      map['highlight_color'] = Variable<int>(highlightColor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('volume: $volume, ')
          ..write('bookApiId: $bookApiId, ')
          ..write('chapter: $chapter, ')
          ..write('verseNumber: $verseNumber, ')
          ..write('type: $type, ')
          ..write('content: $content, ')
          ..write('highlightColor: $highlightColor, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CachedChaptersTable extends CachedChapters
    with TableInfo<$CachedChaptersTable, CachedChapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CachedChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _volumeMeta = const VerificationMeta('volume');
  @override
  late final GeneratedColumn<String> volume = GeneratedColumn<String>(
    'volume',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookApiIdMeta = const VerificationMeta(
    'bookApiId',
  );
  @override
  late final GeneratedColumn<String> bookApiId = GeneratedColumn<String>(
    'book_api_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jsonContentMeta = const VerificationMeta(
    'jsonContent',
  );
  @override
  late final GeneratedColumn<String> jsonContent = GeneratedColumn<String>(
    'json_content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    volume,
    bookApiId,
    chapterNumber,
    jsonContent,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedChapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('volume')) {
      context.handle(
        _volumeMeta,
        volume.isAcceptableOrUnknown(data['volume']!, _volumeMeta),
      );
    } else if (isInserting) {
      context.missing(_volumeMeta);
    }
    if (data.containsKey('book_api_id')) {
      context.handle(
        _bookApiIdMeta,
        bookApiId.isAcceptableOrUnknown(data['book_api_id']!, _bookApiIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookApiIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chapterNumberMeta);
    }
    if (data.containsKey('json_content')) {
      context.handle(
        _jsonContentMeta,
        jsonContent.isAcceptableOrUnknown(
          data['json_content']!,
          _jsonContentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_jsonContentMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {volume, bookApiId, chapterNumber};
  @override
  CachedChapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedChapter(
      volume: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}volume'],
      )!,
      bookApiId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_api_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      jsonContent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}json_content'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $CachedChaptersTable createAlias(String alias) {
    return $CachedChaptersTable(attachedDatabase, alias);
  }
}

class CachedChapter extends DataClass implements Insertable<CachedChapter> {
  final String volume;
  final String bookApiId;
  final int chapterNumber;
  final String jsonContent;
  final DateTime cachedAt;
  const CachedChapter({
    required this.volume,
    required this.bookApiId,
    required this.chapterNumber,
    required this.jsonContent,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['volume'] = Variable<String>(volume);
    map['book_api_id'] = Variable<String>(bookApiId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['json_content'] = Variable<String>(jsonContent);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  CachedChaptersCompanion toCompanion(bool nullToAbsent) {
    return CachedChaptersCompanion(
      volume: Value(volume),
      bookApiId: Value(bookApiId),
      chapterNumber: Value(chapterNumber),
      jsonContent: Value(jsonContent),
      cachedAt: Value(cachedAt),
    );
  }

  factory CachedChapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedChapter(
      volume: serializer.fromJson<String>(json['volume']),
      bookApiId: serializer.fromJson<String>(json['bookApiId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      jsonContent: serializer.fromJson<String>(json['jsonContent']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'volume': serializer.toJson<String>(volume),
      'bookApiId': serializer.toJson<String>(bookApiId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'jsonContent': serializer.toJson<String>(jsonContent),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  CachedChapter copyWith({
    String? volume,
    String? bookApiId,
    int? chapterNumber,
    String? jsonContent,
    DateTime? cachedAt,
  }) => CachedChapter(
    volume: volume ?? this.volume,
    bookApiId: bookApiId ?? this.bookApiId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    jsonContent: jsonContent ?? this.jsonContent,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  CachedChapter copyWithCompanion(CachedChaptersCompanion data) {
    return CachedChapter(
      volume: data.volume.present ? data.volume.value : this.volume,
      bookApiId: data.bookApiId.present ? data.bookApiId.value : this.bookApiId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      jsonContent: data.jsonContent.present
          ? data.jsonContent.value
          : this.jsonContent,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedChapter(')
          ..write('volume: $volume, ')
          ..write('bookApiId: $bookApiId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('jsonContent: $jsonContent, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(volume, bookApiId, chapterNumber, jsonContent, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedChapter &&
          other.volume == this.volume &&
          other.bookApiId == this.bookApiId &&
          other.chapterNumber == this.chapterNumber &&
          other.jsonContent == this.jsonContent &&
          other.cachedAt == this.cachedAt);
}

class CachedChaptersCompanion extends UpdateCompanion<CachedChapter> {
  final Value<String> volume;
  final Value<String> bookApiId;
  final Value<int> chapterNumber;
  final Value<String> jsonContent;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const CachedChaptersCompanion({
    this.volume = const Value.absent(),
    this.bookApiId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.jsonContent = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedChaptersCompanion.insert({
    required String volume,
    required String bookApiId,
    required int chapterNumber,
    required String jsonContent,
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : volume = Value(volume),
       bookApiId = Value(bookApiId),
       chapterNumber = Value(chapterNumber),
       jsonContent = Value(jsonContent),
       cachedAt = Value(cachedAt);
  static Insertable<CachedChapter> custom({
    Expression<String>? volume,
    Expression<String>? bookApiId,
    Expression<int>? chapterNumber,
    Expression<String>? jsonContent,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (volume != null) 'volume': volume,
      if (bookApiId != null) 'book_api_id': bookApiId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (jsonContent != null) 'json_content': jsonContent,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedChaptersCompanion copyWith({
    Value<String>? volume,
    Value<String>? bookApiId,
    Value<int>? chapterNumber,
    Value<String>? jsonContent,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return CachedChaptersCompanion(
      volume: volume ?? this.volume,
      bookApiId: bookApiId ?? this.bookApiId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      jsonContent: jsonContent ?? this.jsonContent,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (volume.present) {
      map['volume'] = Variable<String>(volume.value);
    }
    if (bookApiId.present) {
      map['book_api_id'] = Variable<String>(bookApiId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (jsonContent.present) {
      map['json_content'] = Variable<String>(jsonContent.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedChaptersCompanion(')
          ..write('volume: $volume, ')
          ..write('bookApiId: $bookApiId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('jsonContent: $jsonContent, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $CachedChaptersTable cachedChapters = $CachedChaptersTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    projects,
    notes,
    cachedChapters,
  ];
}

typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      required DateTime lastOpenedAt,
      Value<DateTime?> archivedAt,
      Value<String?> defaultVolumeId,
      Value<String?> lastVolume,
      Value<String?> lastBookApiId,
      Value<String?> lastBookTitle,
      Value<int?> lastChapter,
      Value<int?> lastVerse,
      Value<int> rowid,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<DateTime> lastOpenedAt,
      Value<DateTime?> archivedAt,
      Value<String?> defaultVolumeId,
      Value<String?> lastVolume,
      Value<String?> lastBookApiId,
      Value<String?> lastBookTitle,
      Value<int?> lastChapter,
      Value<int?> lastVerse,
      Value<int> rowid,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$NotesTable, List<Note>> _notesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.notes,
    aliasName: $_aliasNameGenerator(db.projects.id, db.notes.projectId),
  );

  $$NotesTableProcessedTableManager get notesRefs {
    final manager = $$NotesTableTableManager(
      $_db,
      $_db.notes,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_notesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultVolumeId => $composableBuilder(
    column: $table.defaultVolumeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastVolume => $composableBuilder(
    column: $table.lastVolume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBookApiId => $composableBuilder(
    column: $table.lastBookApiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastBookTitle => $composableBuilder(
    column: $table.lastBookTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastChapter => $composableBuilder(
    column: $table.lastChapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastVerse => $composableBuilder(
    column: $table.lastVerse,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> notesRefs(
    Expression<bool> Function($$NotesTableFilterComposer f) f,
  ) {
    final $$NotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableFilterComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultVolumeId => $composableBuilder(
    column: $table.defaultVolumeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastVolume => $composableBuilder(
    column: $table.lastVolume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBookApiId => $composableBuilder(
    column: $table.lastBookApiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastBookTitle => $composableBuilder(
    column: $table.lastBookTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastChapter => $composableBuilder(
    column: $table.lastChapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastVerse => $composableBuilder(
    column: $table.lastVerse,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultVolumeId => $composableBuilder(
    column: $table.defaultVolumeId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastVolume => $composableBuilder(
    column: $table.lastVolume,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastBookApiId => $composableBuilder(
    column: $table.lastBookApiId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastBookTitle => $composableBuilder(
    column: $table.lastBookTitle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastChapter => $composableBuilder(
    column: $table.lastChapter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastVerse =>
      $composableBuilder(column: $table.lastVerse, builder: (column) => column);

  Expression<T> notesRefs<T extends Object>(
    Expression<T> Function($$NotesTableAnnotationComposer a) f,
  ) {
    final $$NotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.notes,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$NotesTableAnnotationComposer(
            $db: $db,
            $table: $db.notes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool notesRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> lastOpenedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String?> defaultVolumeId = const Value.absent(),
                Value<String?> lastVolume = const Value.absent(),
                Value<String?> lastBookApiId = const Value.absent(),
                Value<String?> lastBookTitle = const Value.absent(),
                Value<int?> lastChapter = const Value.absent(),
                Value<int?> lastVerse = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
                archivedAt: archivedAt,
                defaultVolumeId: defaultVolumeId,
                lastVolume: lastVolume,
                lastBookApiId: lastBookApiId,
                lastBookTitle: lastBookTitle,
                lastChapter: lastChapter,
                lastVerse: lastVerse,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                required DateTime lastOpenedAt,
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<String?> defaultVolumeId = const Value.absent(),
                Value<String?> lastVolume = const Value.absent(),
                Value<String?> lastBookApiId = const Value.absent(),
                Value<String?> lastBookTitle = const Value.absent(),
                Value<int?> lastChapter = const Value.absent(),
                Value<int?> lastVerse = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                lastOpenedAt: lastOpenedAt,
                archivedAt: archivedAt,
                defaultVolumeId: defaultVolumeId,
                lastVolume: lastVolume,
                lastBookApiId: lastBookApiId,
                lastBookTitle: lastBookTitle,
                lastChapter: lastChapter,
                lastVerse: lastVerse,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ProjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({notesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (notesRefs) db.notes],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (notesRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable, Note>(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._notesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ProjectsTableReferences(db, table, p0).notesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool notesRefs})
    >;
typedef $$NotesTableCreateCompanionBuilder =
    NotesCompanion Function({
      required String id,
      required String projectId,
      required String volume,
      required String bookApiId,
      required int chapter,
      required int verseNumber,
      required String type,
      Value<String?> content,
      Value<int?> highlightColor,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$NotesTableUpdateCompanionBuilder =
    NotesCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> volume,
      Value<String> bookApiId,
      Value<int> chapter,
      Value<int> verseNumber,
      Value<String> type,
      Value<String?> content,
      Value<int?> highlightColor,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$NotesTableReferences
    extends BaseReferences<_$AppDatabase, $NotesTable, Note> {
  $$NotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.notes.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookApiId => $composableBuilder(
    column: $table.bookApiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get highlightColor => $composableBuilder(
    column: $table.highlightColor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookApiId => $composableBuilder(
    column: $table.bookApiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapter => $composableBuilder(
    column: $table.chapter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get highlightColor => $composableBuilder(
    column: $table.highlightColor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get bookApiId =>
      $composableBuilder(column: $table.bookApiId, builder: (column) => column);

  GeneratedColumn<int> get chapter =>
      $composableBuilder(column: $table.chapter, builder: (column) => column);

  GeneratedColumn<int> get verseNumber => $composableBuilder(
    column: $table.verseNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get highlightColor => $composableBuilder(
    column: $table.highlightColor,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$NotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NotesTable,
          Note,
          $$NotesTableFilterComposer,
          $$NotesTableOrderingComposer,
          $$NotesTableAnnotationComposer,
          $$NotesTableCreateCompanionBuilder,
          $$NotesTableUpdateCompanionBuilder,
          (Note, $$NotesTableReferences),
          Note,
          PrefetchHooks Function({bool projectId})
        > {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> volume = const Value.absent(),
                Value<String> bookApiId = const Value.absent(),
                Value<int> chapter = const Value.absent(),
                Value<int> verseNumber = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int?> highlightColor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion(
                id: id,
                projectId: projectId,
                volume: volume,
                bookApiId: bookApiId,
                chapter: chapter,
                verseNumber: verseNumber,
                type: type,
                content: content,
                highlightColor: highlightColor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String volume,
                required String bookApiId,
                required int chapter,
                required int verseNumber,
                required String type,
                Value<String?> content = const Value.absent(),
                Value<int?> highlightColor = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => NotesCompanion.insert(
                id: id,
                projectId: projectId,
                volume: volume,
                bookApiId: bookApiId,
                chapter: chapter,
                verseNumber: verseNumber,
                type: type,
                content: content,
                highlightColor: highlightColor,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$NotesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $$NotesTableReferences
                                    ._projectIdTable(db),
                                referencedColumn: $$NotesTableReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$NotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NotesTable,
      Note,
      $$NotesTableFilterComposer,
      $$NotesTableOrderingComposer,
      $$NotesTableAnnotationComposer,
      $$NotesTableCreateCompanionBuilder,
      $$NotesTableUpdateCompanionBuilder,
      (Note, $$NotesTableReferences),
      Note,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$CachedChaptersTableCreateCompanionBuilder =
    CachedChaptersCompanion Function({
      required String volume,
      required String bookApiId,
      required int chapterNumber,
      required String jsonContent,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$CachedChaptersTableUpdateCompanionBuilder =
    CachedChaptersCompanion Function({
      Value<String> volume,
      Value<String> bookApiId,
      Value<int> chapterNumber,
      Value<String> jsonContent,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$CachedChaptersTableFilterComposer
    extends Composer<_$AppDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bookApiId => $composableBuilder(
    column: $table.bookApiId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jsonContent => $composableBuilder(
    column: $table.jsonContent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CachedChaptersTableOrderingComposer
    extends Composer<_$AppDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get volume => $composableBuilder(
    column: $table.volume,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bookApiId => $composableBuilder(
    column: $table.bookApiId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jsonContent => $composableBuilder(
    column: $table.jsonContent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CachedChaptersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CachedChaptersTable> {
  $$CachedChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get volume =>
      $composableBuilder(column: $table.volume, builder: (column) => column);

  GeneratedColumn<String> get bookApiId =>
      $composableBuilder(column: $table.bookApiId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get jsonContent => $composableBuilder(
    column: $table.jsonContent,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$CachedChaptersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CachedChaptersTable,
          CachedChapter,
          $$CachedChaptersTableFilterComposer,
          $$CachedChaptersTableOrderingComposer,
          $$CachedChaptersTableAnnotationComposer,
          $$CachedChaptersTableCreateCompanionBuilder,
          $$CachedChaptersTableUpdateCompanionBuilder,
          (
            CachedChapter,
            BaseReferences<_$AppDatabase, $CachedChaptersTable, CachedChapter>,
          ),
          CachedChapter,
          PrefetchHooks Function()
        > {
  $$CachedChaptersTableTableManager(
    _$AppDatabase db,
    $CachedChaptersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CachedChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CachedChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CachedChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> volume = const Value.absent(),
                Value<String> bookApiId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<String> jsonContent = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion(
                volume: volume,
                bookApiId: bookApiId,
                chapterNumber: chapterNumber,
                jsonContent: jsonContent,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String volume,
                required String bookApiId,
                required int chapterNumber,
                required String jsonContent,
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => CachedChaptersCompanion.insert(
                volume: volume,
                bookApiId: bookApiId,
                chapterNumber: chapterNumber,
                jsonContent: jsonContent,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CachedChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CachedChaptersTable,
      CachedChapter,
      $$CachedChaptersTableFilterComposer,
      $$CachedChaptersTableOrderingComposer,
      $$CachedChaptersTableAnnotationComposer,
      $$CachedChaptersTableCreateCompanionBuilder,
      $$CachedChaptersTableUpdateCompanionBuilder,
      (
        CachedChapter,
        BaseReferences<_$AppDatabase, $CachedChaptersTable, CachedChapter>,
      ),
      CachedChapter,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$CachedChaptersTableTableManager get cachedChapters =>
      $$CachedChaptersTableTableManager(_db, _db.cachedChapters);
}
