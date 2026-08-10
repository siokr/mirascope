// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaTypeMeta = const VerificationMeta(
    'mediaType',
  );
  @override
  late final GeneratedColumn<String> mediaType = GeneratedColumn<String>(
    'media_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _creatorMeta = const VerificationMeta(
    'creator',
  );
  @override
  late final GeneratedColumn<String> creator = GeneratedColumn<String>(
    'creator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _coverRefMeta = const VerificationMeta(
    'coverRef',
  );
  @override
  late final GeneratedColumn<String> coverRef = GeneratedColumn<String>(
    'cover_ref',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MediaItemsTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($MediaItemsTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaType,
    title,
    subtitle,
    creator,
    description,
    coverRef,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_type')) {
      context.handle(
        _mediaTypeMeta,
        mediaType.isAcceptableOrUnknown(data['media_type']!, _mediaTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mediaTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('creator')) {
      context.handle(
        _creatorMeta,
        creator.isAcceptableOrUnknown(data['creator']!, _creatorMeta),
      );
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
    if (data.containsKey('cover_ref')) {
      context.handle(
        _coverRefMeta,
        coverRef.isAcceptableOrUnknown(data['cover_ref']!, _coverRefMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      creator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}creator'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      coverRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_ref'],
      ),
      createdAt: $MediaItemsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      updatedAt: $MediaItemsTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime, int> $converterupdatedAt =
      const DateTimeMillisConverter();
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final String id;
  final String mediaType;
  final String title;
  final String? subtitle;
  final String? creator;
  final String? description;
  final String? coverRef;
  final DateTime createdAt;
  final DateTime updatedAt;
  const MediaItem({
    required this.id,
    required this.mediaType,
    required this.title,
    this.subtitle,
    this.creator,
    this.description,
    this.coverRef,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_type'] = Variable<String>(mediaType);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    if (!nullToAbsent || creator != null) {
      map['creator'] = Variable<String>(creator);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || coverRef != null) {
      map['cover_ref'] = Variable<String>(coverRef);
    }
    {
      map['created_at'] = Variable<int>(
        $MediaItemsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    {
      map['updated_at'] = Variable<int>(
        $MediaItemsTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      mediaType: Value(mediaType),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      creator: creator == null && nullToAbsent
          ? const Value.absent()
          : Value(creator),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      coverRef: coverRef == null && nullToAbsent
          ? const Value.absent()
          : Value(coverRef),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<String>(json['id']),
      mediaType: serializer.fromJson<String>(json['mediaType']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      creator: serializer.fromJson<String?>(json['creator']),
      description: serializer.fromJson<String?>(json['description']),
      coverRef: serializer.fromJson<String?>(json['coverRef']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaType': serializer.toJson<String>(mediaType),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'creator': serializer.toJson<String?>(creator),
      'description': serializer.toJson<String?>(description),
      'coverRef': serializer.toJson<String?>(coverRef),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MediaItem copyWith({
    String? id,
    String? mediaType,
    String? title,
    Value<String?> subtitle = const Value.absent(),
    Value<String?> creator = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> coverRef = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => MediaItem(
    id: id ?? this.id,
    mediaType: mediaType ?? this.mediaType,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    creator: creator.present ? creator.value : this.creator,
    description: description.present ? description.value : this.description,
    coverRef: coverRef.present ? coverRef.value : this.coverRef,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      mediaType: data.mediaType.present ? data.mediaType.value : this.mediaType,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      creator: data.creator.present ? data.creator.value : this.creator,
      description: data.description.present
          ? data.description.value
          : this.description,
      coverRef: data.coverRef.present ? data.coverRef.value : this.coverRef,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('creator: $creator, ')
          ..write('description: $description, ')
          ..write('coverRef: $coverRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaType,
    title,
    subtitle,
    creator,
    description,
    coverRef,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.mediaType == this.mediaType &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.creator == this.creator &&
          other.description == this.description &&
          other.coverRef == this.coverRef &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<String> id;
  final Value<String> mediaType;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String?> creator;
  final Value<String?> description;
  final Value<String?> coverRef;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.mediaType = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.creator = const Value.absent(),
    this.description = const Value.absent(),
    this.coverRef = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    required String id,
    required String mediaType,
    required String title,
    this.subtitle = const Value.absent(),
    this.creator = const Value.absent(),
    this.description = const Value.absent(),
    this.coverRef = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaType = Value(mediaType),
       title = Value(title),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<MediaItem> custom({
    Expression<String>? id,
    Expression<String>? mediaType,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? creator,
    Expression<String>? description,
    Expression<String>? coverRef,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaType != null) 'media_type': mediaType,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (creator != null) 'creator': creator,
      if (description != null) 'description': description,
      if (coverRef != null) 'cover_ref': coverRef,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaType,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<String?>? creator,
    Value<String?>? description,
    Value<String?>? coverRef,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      mediaType: mediaType ?? this.mediaType,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      creator: creator ?? this.creator,
      description: description ?? this.description,
      coverRef: coverRef ?? this.coverRef,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaType.present) {
      map['media_type'] = Variable<String>(mediaType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (creator.present) {
      map['creator'] = Variable<String>(creator.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (coverRef.present) {
      map['cover_ref'] = Variable<String>(coverRef.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $MediaItemsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $MediaItemsTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('mediaType: $mediaType, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('creator: $creator, ')
          ..write('description: $description, ')
          ..write('coverRef: $coverRef, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ContentUnitsTable extends ContentUnits
    with TableInfo<$ContentUnitsTable, ContentUnit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ContentUnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _unitTypeMeta = const VerificationMeta(
    'unitType',
  );
  @override
  late final GeneratedColumn<String> unitType = GeneratedColumn<String>(
    'unit_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentRefMeta = const VerificationMeta(
    'contentRef',
  );
  @override
  late final GeneratedColumn<String> contentRef = GeneratedColumn<String>(
    'content_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLocatorMeta = const VerificationMeta(
    'sourceLocator',
  );
  @override
  late final GeneratedColumn<String> sourceLocator = GeneratedColumn<String>(
    'source_locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    unitType,
    title,
    orderIndex,
    contentRef,
    sourceLocator,
    contentHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'content_units';
  @override
  VerificationContext validateIntegrity(
    Insertable<ContentUnit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('unit_type')) {
      context.handle(
        _unitTypeMeta,
        unitType.isAcceptableOrUnknown(data['unit_type']!, _unitTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_unitTypeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('content_ref')) {
      context.handle(
        _contentRefMeta,
        contentRef.isAcceptableOrUnknown(data['content_ref']!, _contentRefMeta),
      );
    } else if (isInserting) {
      context.missing(_contentRefMeta);
    }
    if (data.containsKey('source_locator')) {
      context.handle(
        _sourceLocatorMeta,
        sourceLocator.isAcceptableOrUnknown(
          data['source_locator']!,
          _sourceLocatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLocatorMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {mediaItemId, orderIndex},
  ];
  @override
  ContentUnit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ContentUnit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      unitType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit_type'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      contentRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_ref'],
      )!,
      sourceLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_locator'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
    );
  }

  @override
  $ContentUnitsTable createAlias(String alias) {
    return $ContentUnitsTable(attachedDatabase, alias);
  }
}

class ContentUnit extends DataClass implements Insertable<ContentUnit> {
  final String id;
  final String mediaItemId;
  final String unitType;
  final String title;
  final int orderIndex;
  final String contentRef;
  final String sourceLocator;
  final String contentHash;
  const ContentUnit({
    required this.id,
    required this.mediaItemId,
    required this.unitType,
    required this.title,
    required this.orderIndex,
    required this.contentRef,
    required this.sourceLocator,
    required this.contentHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['unit_type'] = Variable<String>(unitType);
    map['title'] = Variable<String>(title);
    map['order_index'] = Variable<int>(orderIndex);
    map['content_ref'] = Variable<String>(contentRef);
    map['source_locator'] = Variable<String>(sourceLocator);
    map['content_hash'] = Variable<String>(contentHash);
    return map;
  }

  ContentUnitsCompanion toCompanion(bool nullToAbsent) {
    return ContentUnitsCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      unitType: Value(unitType),
      title: Value(title),
      orderIndex: Value(orderIndex),
      contentRef: Value(contentRef),
      sourceLocator: Value(sourceLocator),
      contentHash: Value(contentHash),
    );
  }

  factory ContentUnit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ContentUnit(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      unitType: serializer.fromJson<String>(json['unitType']),
      title: serializer.fromJson<String>(json['title']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      contentRef: serializer.fromJson<String>(json['contentRef']),
      sourceLocator: serializer.fromJson<String>(json['sourceLocator']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'unitType': serializer.toJson<String>(unitType),
      'title': serializer.toJson<String>(title),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'contentRef': serializer.toJson<String>(contentRef),
      'sourceLocator': serializer.toJson<String>(sourceLocator),
      'contentHash': serializer.toJson<String>(contentHash),
    };
  }

  ContentUnit copyWith({
    String? id,
    String? mediaItemId,
    String? unitType,
    String? title,
    int? orderIndex,
    String? contentRef,
    String? sourceLocator,
    String? contentHash,
  }) => ContentUnit(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    unitType: unitType ?? this.unitType,
    title: title ?? this.title,
    orderIndex: orderIndex ?? this.orderIndex,
    contentRef: contentRef ?? this.contentRef,
    sourceLocator: sourceLocator ?? this.sourceLocator,
    contentHash: contentHash ?? this.contentHash,
  );
  ContentUnit copyWithCompanion(ContentUnitsCompanion data) {
    return ContentUnit(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      unitType: data.unitType.present ? data.unitType.value : this.unitType,
      title: data.title.present ? data.title.value : this.title,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      contentRef: data.contentRef.present
          ? data.contentRef.value
          : this.contentRef,
      sourceLocator: data.sourceLocator.present
          ? data.sourceLocator.value
          : this.sourceLocator,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ContentUnit(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('unitType: $unitType, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('contentRef: $contentRef, ')
          ..write('sourceLocator: $sourceLocator, ')
          ..write('contentHash: $contentHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    unitType,
    title,
    orderIndex,
    contentRef,
    sourceLocator,
    contentHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ContentUnit &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.unitType == this.unitType &&
          other.title == this.title &&
          other.orderIndex == this.orderIndex &&
          other.contentRef == this.contentRef &&
          other.sourceLocator == this.sourceLocator &&
          other.contentHash == this.contentHash);
}

class ContentUnitsCompanion extends UpdateCompanion<ContentUnit> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<String> unitType;
  final Value<String> title;
  final Value<int> orderIndex;
  final Value<String> contentRef;
  final Value<String> sourceLocator;
  final Value<String> contentHash;
  final Value<int> rowid;
  const ContentUnitsCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.unitType = const Value.absent(),
    this.title = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.contentRef = const Value.absent(),
    this.sourceLocator = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ContentUnitsCompanion.insert({
    required String id,
    required String mediaItemId,
    required String unitType,
    required String title,
    required int orderIndex,
    required String contentRef,
    required String sourceLocator,
    required String contentHash,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaItemId = Value(mediaItemId),
       unitType = Value(unitType),
       title = Value(title),
       orderIndex = Value(orderIndex),
       contentRef = Value(contentRef),
       sourceLocator = Value(sourceLocator),
       contentHash = Value(contentHash);
  static Insertable<ContentUnit> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? unitType,
    Expression<String>? title,
    Expression<int>? orderIndex,
    Expression<String>? contentRef,
    Expression<String>? sourceLocator,
    Expression<String>? contentHash,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (unitType != null) 'unit_type': unitType,
      if (title != null) 'title': title,
      if (orderIndex != null) 'order_index': orderIndex,
      if (contentRef != null) 'content_ref': contentRef,
      if (sourceLocator != null) 'source_locator': sourceLocator,
      if (contentHash != null) 'content_hash': contentHash,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ContentUnitsCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaItemId,
    Value<String>? unitType,
    Value<String>? title,
    Value<int>? orderIndex,
    Value<String>? contentRef,
    Value<String>? sourceLocator,
    Value<String>? contentHash,
    Value<int>? rowid,
  }) {
    return ContentUnitsCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      unitType: unitType ?? this.unitType,
      title: title ?? this.title,
      orderIndex: orderIndex ?? this.orderIndex,
      contentRef: contentRef ?? this.contentRef,
      sourceLocator: sourceLocator ?? this.sourceLocator,
      contentHash: contentHash ?? this.contentHash,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (unitType.present) {
      map['unit_type'] = Variable<String>(unitType.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (contentRef.present) {
      map['content_ref'] = Variable<String>(contentRef.value);
    }
    if (sourceLocator.present) {
      map['source_locator'] = Variable<String>(sourceLocator.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ContentUnitsCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('unitType: $unitType, ')
          ..write('title: $title, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('contentRef: $contentRef, ')
          ..write('sourceLocator: $sourceLocator, ')
          ..write('contentHash: $contentHash, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookmarksTable extends Bookmarks
    with TableInfo<$BookmarksTable, Bookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentUnitIdMeta = const VerificationMeta(
    'contentUnitId',
  );
  @override
  late final GeneratedColumn<String> contentUnitId = GeneratedColumn<String>(
    'content_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES content_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  @override
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($BookmarksTable.$convertercreatedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> deletedAt =
      GeneratedColumn<int>(
        'deleted_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BookmarksTable.$converterdeletedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    contentUnitId,
    locator,
    label,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Bookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('content_unit_id')) {
      context.handle(
        _contentUnitIdMeta,
        contentUnitId.isAcceptableOrUnknown(
          data['content_unit_id']!,
          _contentUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentUnitIdMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Bookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Bookmark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      contentUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_unit_id'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      createdAt: $BookmarksTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
      deletedAt: $BookmarksTable.$converterdeletedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}deleted_at'],
        ),
      ),
    );
  }

  @override
  $BookmarksTable createAlias(String alias) {
    return $BookmarksTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime, int> $converterdeletedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime?, int?> $converterdeletedAtn =
      NullAwareTypeConverter.wrap($converterdeletedAt);
}

class Bookmark extends DataClass implements Insertable<Bookmark> {
  final String id;
  final String mediaItemId;
  final String contentUnitId;
  final String locator;
  final String label;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const Bookmark({
    required this.id,
    required this.mediaItemId,
    required this.contentUnitId,
    required this.locator,
    required this.label,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['content_unit_id'] = Variable<String>(contentUnitId);
    map['locator'] = Variable<String>(locator);
    map['label'] = Variable<String>(label);
    {
      map['created_at'] = Variable<int>(
        $BookmarksTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<int>(
        $BookmarksTable.$converterdeletedAtn.toSql(deletedAt),
      );
    }
    return map;
  }

  BookmarksCompanion toCompanion(bool nullToAbsent) {
    return BookmarksCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      contentUnitId: Value(contentUnitId),
      locator: Value(locator),
      label: Value(label),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Bookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Bookmark(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      contentUnitId: serializer.fromJson<String>(json['contentUnitId']),
      locator: serializer.fromJson<String>(json['locator']),
      label: serializer.fromJson<String>(json['label']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'contentUnitId': serializer.toJson<String>(contentUnitId),
      'locator': serializer.toJson<String>(locator),
      'label': serializer.toJson<String>(label),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Bookmark copyWith({
    String? id,
    String? mediaItemId,
    String? contentUnitId,
    String? locator,
    String? label,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Bookmark(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    contentUnitId: contentUnitId ?? this.contentUnitId,
    locator: locator ?? this.locator,
    label: label ?? this.label,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Bookmark copyWithCompanion(BookmarksCompanion data) {
    return Bookmark(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      contentUnitId: data.contentUnitId.present
          ? data.contentUnitId.value
          : this.contentUnitId,
      locator: data.locator.present ? data.locator.value : this.locator,
      label: data.label.present ? data.label.value : this.label,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Bookmark(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('contentUnitId: $contentUnitId, ')
          ..write('locator: $locator, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    contentUnitId,
    locator,
    label,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Bookmark &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.contentUnitId == this.contentUnitId &&
          other.locator == this.locator &&
          other.label == this.label &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class BookmarksCompanion extends UpdateCompanion<Bookmark> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<String> contentUnitId;
  final Value<String> locator;
  final Value<String> label;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const BookmarksCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.contentUnitId = const Value.absent(),
    this.locator = const Value.absent(),
    this.label = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookmarksCompanion.insert({
    required String id,
    required String mediaItemId,
    required String contentUnitId,
    required String locator,
    required String label,
    required DateTime createdAt,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaItemId = Value(mediaItemId),
       contentUnitId = Value(contentUnitId),
       locator = Value(locator),
       label = Value(label),
       createdAt = Value(createdAt);
  static Insertable<Bookmark> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? contentUnitId,
    Expression<String>? locator,
    Expression<String>? label,
    Expression<int>? createdAt,
    Expression<int>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (contentUnitId != null) 'content_unit_id': contentUnitId,
      if (locator != null) 'locator': locator,
      if (label != null) 'label': label,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookmarksCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaItemId,
    Value<String>? contentUnitId,
    Value<String>? locator,
    Value<String>? label,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return BookmarksCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      contentUnitId: contentUnitId ?? this.contentUnitId,
      locator: locator ?? this.locator,
      label: label ?? this.label,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (contentUnitId.present) {
      map['content_unit_id'] = Variable<String>(contentUnitId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $BookmarksTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<int>(
        $BookmarksTable.$converterdeletedAtn.toSql(deletedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookmarksCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('contentUnitId: $contentUnitId, ')
          ..write('locator: $locator, ')
          ..write('label: $label, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LibraryEntriesTable extends LibraryEntries
    with TableInfo<$LibraryEntriesTable, LibraryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LibraryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> addedAt =
      GeneratedColumn<int>(
        'added_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($LibraryEntriesTable.$converteraddedAt);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> lastOpenedAt =
      GeneratedColumn<int>(
        'last_opened_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($LibraryEntriesTable.$converterlastOpenedAtn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> archivedAt =
      GeneratedColumn<int>(
        'archived_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($LibraryEntriesTable.$converterarchivedAtn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    favorite,
    addedAt,
    lastOpenedAt,
    archivedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'library_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<LibraryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    } else if (isInserting) {
      context.missing(_favoriteMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {mediaItemId},
  ];
  @override
  LibraryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LibraryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      addedAt: $LibraryEntriesTable.$converteraddedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}added_at'],
        )!,
      ),
      lastOpenedAt: $LibraryEntriesTable.$converterlastOpenedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}last_opened_at'],
        ),
      ),
      archivedAt: $LibraryEntriesTable.$converterarchivedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}archived_at'],
        ),
      ),
    );
  }

  @override
  $LibraryEntriesTable createAlias(String alias) {
    return $LibraryEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converteraddedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime, int> $converterlastOpenedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime?, int?> $converterlastOpenedAtn =
      NullAwareTypeConverter.wrap($converterlastOpenedAt);
  static TypeConverter<DateTime, int> $converterarchivedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime?, int?> $converterarchivedAtn =
      NullAwareTypeConverter.wrap($converterarchivedAt);
}

class LibraryEntry extends DataClass implements Insertable<LibraryEntry> {
  final String id;
  final String mediaItemId;
  final bool favorite;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;
  final DateTime? archivedAt;
  const LibraryEntry({
    required this.id,
    required this.mediaItemId,
    required this.favorite,
    required this.addedAt,
    this.lastOpenedAt,
    this.archivedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['favorite'] = Variable<bool>(favorite);
    {
      map['added_at'] = Variable<int>(
        $LibraryEntriesTable.$converteraddedAt.toSql(addedAt),
      );
    }
    if (!nullToAbsent || lastOpenedAt != null) {
      map['last_opened_at'] = Variable<int>(
        $LibraryEntriesTable.$converterlastOpenedAtn.toSql(lastOpenedAt),
      );
    }
    if (!nullToAbsent || archivedAt != null) {
      map['archived_at'] = Variable<int>(
        $LibraryEntriesTable.$converterarchivedAtn.toSql(archivedAt),
      );
    }
    return map;
  }

  LibraryEntriesCompanion toCompanion(bool nullToAbsent) {
    return LibraryEntriesCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      favorite: Value(favorite),
      addedAt: Value(addedAt),
      lastOpenedAt: lastOpenedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastOpenedAt),
      archivedAt: archivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(archivedAt),
    );
  }

  factory LibraryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LibraryEntry(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastOpenedAt: serializer.fromJson<DateTime?>(json['lastOpenedAt']),
      archivedAt: serializer.fromJson<DateTime?>(json['archivedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'favorite': serializer.toJson<bool>(favorite),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastOpenedAt': serializer.toJson<DateTime?>(lastOpenedAt),
      'archivedAt': serializer.toJson<DateTime?>(archivedAt),
    };
  }

  LibraryEntry copyWith({
    String? id,
    String? mediaItemId,
    bool? favorite,
    DateTime? addedAt,
    Value<DateTime?> lastOpenedAt = const Value.absent(),
    Value<DateTime?> archivedAt = const Value.absent(),
  }) => LibraryEntry(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    favorite: favorite ?? this.favorite,
    addedAt: addedAt ?? this.addedAt,
    lastOpenedAt: lastOpenedAt.present ? lastOpenedAt.value : this.lastOpenedAt,
    archivedAt: archivedAt.present ? archivedAt.value : this.archivedAt,
  );
  LibraryEntry copyWithCompanion(LibraryEntriesCompanion data) {
    return LibraryEntry(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastOpenedAt: data.lastOpenedAt.present
          ? data.lastOpenedAt.value
          : this.lastOpenedAt,
      archivedAt: data.archivedAt.present
          ? data.archivedAt.value
          : this.archivedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntry(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('favorite: $favorite, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('archivedAt: $archivedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mediaItemId, favorite, addedAt, lastOpenedAt, archivedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LibraryEntry &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.favorite == this.favorite &&
          other.addedAt == this.addedAt &&
          other.lastOpenedAt == this.lastOpenedAt &&
          other.archivedAt == this.archivedAt);
}

class LibraryEntriesCompanion extends UpdateCompanion<LibraryEntry> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<bool> favorite;
  final Value<DateTime> addedAt;
  final Value<DateTime?> lastOpenedAt;
  final Value<DateTime?> archivedAt;
  final Value<int> rowid;
  const LibraryEntriesCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.favorite = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastOpenedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LibraryEntriesCompanion.insert({
    required String id,
    required String mediaItemId,
    required bool favorite,
    required DateTime addedAt,
    this.lastOpenedAt = const Value.absent(),
    this.archivedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaItemId = Value(mediaItemId),
       favorite = Value(favorite),
       addedAt = Value(addedAt);
  static Insertable<LibraryEntry> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<bool>? favorite,
    Expression<int>? addedAt,
    Expression<int>? lastOpenedAt,
    Expression<int>? archivedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (favorite != null) 'favorite': favorite,
      if (addedAt != null) 'added_at': addedAt,
      if (lastOpenedAt != null) 'last_opened_at': lastOpenedAt,
      if (archivedAt != null) 'archived_at': archivedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LibraryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaItemId,
    Value<bool>? favorite,
    Value<DateTime>? addedAt,
    Value<DateTime?>? lastOpenedAt,
    Value<DateTime?>? archivedAt,
    Value<int>? rowid,
  }) {
    return LibraryEntriesCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      favorite: favorite ?? this.favorite,
      addedAt: addedAt ?? this.addedAt,
      lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      archivedAt: archivedAt ?? this.archivedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<int>(
        $LibraryEntriesTable.$converteraddedAt.toSql(addedAt.value),
      );
    }
    if (lastOpenedAt.present) {
      map['last_opened_at'] = Variable<int>(
        $LibraryEntriesTable.$converterlastOpenedAtn.toSql(lastOpenedAt.value),
      );
    }
    if (archivedAt.present) {
      map['archived_at'] = Variable<int>(
        $LibraryEntriesTable.$converterarchivedAtn.toSql(archivedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LibraryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('favorite: $favorite, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastOpenedAt: $lastOpenedAt, ')
          ..write('archivedAt: $archivedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaPagesTable extends MangaPages
    with TableInfo<$MangaPagesTable, MangaPage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaPagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentUnitIdMeta = const VerificationMeta(
    'contentUnitId',
  );
  @override
  late final GeneratedColumn<String> contentUnitId = GeneratedColumn<String>(
    'content_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES content_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentRefMeta = const VerificationMeta(
    'contentRef',
  );
  @override
  late final GeneratedColumn<String> contentRef = GeneratedColumn<String>(
    'content_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceLocatorMeta = const VerificationMeta(
    'sourceLocator',
  );
  @override
  late final GeneratedColumn<String> sourceLocator = GeneratedColumn<String>(
    'source_locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mimeTypeMeta = const VerificationMeta(
    'mimeType',
  );
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
    'mime_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _byteLengthMeta = const VerificationMeta(
    'byteLength',
  );
  @override
  late final GeneratedColumn<int> byteLength = GeneratedColumn<int>(
    'byte_length',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pixelWidthMeta = const VerificationMeta(
    'pixelWidth',
  );
  @override
  late final GeneratedColumn<int> pixelWidth = GeneratedColumn<int>(
    'pixel_width',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pixelHeightMeta = const VerificationMeta(
    'pixelHeight',
  );
  @override
  late final GeneratedColumn<int> pixelHeight = GeneratedColumn<int>(
    'pixel_height',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    contentUnitId,
    orderIndex,
    contentRef,
    sourceLocator,
    contentHash,
    mimeType,
    byteLength,
    pixelWidth,
    pixelHeight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_pages';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaPage> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('content_unit_id')) {
      context.handle(
        _contentUnitIdMeta,
        contentUnitId.isAcceptableOrUnknown(
          data['content_unit_id']!,
          _contentUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentUnitIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('content_ref')) {
      context.handle(
        _contentRefMeta,
        contentRef.isAcceptableOrUnknown(data['content_ref']!, _contentRefMeta),
      );
    } else if (isInserting) {
      context.missing(_contentRefMeta);
    }
    if (data.containsKey('source_locator')) {
      context.handle(
        _sourceLocatorMeta,
        sourceLocator.isAcceptableOrUnknown(
          data['source_locator']!,
          _sourceLocatorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_sourceLocatorMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(
        _mimeTypeMeta,
        mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeTypeMeta);
    }
    if (data.containsKey('byte_length')) {
      context.handle(
        _byteLengthMeta,
        byteLength.isAcceptableOrUnknown(data['byte_length']!, _byteLengthMeta),
      );
    } else if (isInserting) {
      context.missing(_byteLengthMeta);
    }
    if (data.containsKey('pixel_width')) {
      context.handle(
        _pixelWidthMeta,
        pixelWidth.isAcceptableOrUnknown(data['pixel_width']!, _pixelWidthMeta),
      );
    }
    if (data.containsKey('pixel_height')) {
      context.handle(
        _pixelHeightMeta,
        pixelHeight.isAcceptableOrUnknown(
          data['pixel_height']!,
          _pixelHeightMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {contentUnitId, orderIndex},
  ];
  @override
  MangaPage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaPage(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      contentUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_unit_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      contentRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_ref'],
      )!,
      sourceLocator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_locator'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
      mimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime_type'],
      )!,
      byteLength: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_length'],
      )!,
      pixelWidth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pixel_width'],
      ),
      pixelHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pixel_height'],
      ),
    );
  }

  @override
  $MangaPagesTable createAlias(String alias) {
    return $MangaPagesTable(attachedDatabase, alias);
  }
}

class MangaPage extends DataClass implements Insertable<MangaPage> {
  final String id;
  final String contentUnitId;
  final int orderIndex;
  final String contentRef;
  final String sourceLocator;
  final String contentHash;
  final String mimeType;
  final int byteLength;
  final int? pixelWidth;
  final int? pixelHeight;
  const MangaPage({
    required this.id,
    required this.contentUnitId,
    required this.orderIndex,
    required this.contentRef,
    required this.sourceLocator,
    required this.contentHash,
    required this.mimeType,
    required this.byteLength,
    this.pixelWidth,
    this.pixelHeight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['content_unit_id'] = Variable<String>(contentUnitId);
    map['order_index'] = Variable<int>(orderIndex);
    map['content_ref'] = Variable<String>(contentRef);
    map['source_locator'] = Variable<String>(sourceLocator);
    map['content_hash'] = Variable<String>(contentHash);
    map['mime_type'] = Variable<String>(mimeType);
    map['byte_length'] = Variable<int>(byteLength);
    if (!nullToAbsent || pixelWidth != null) {
      map['pixel_width'] = Variable<int>(pixelWidth);
    }
    if (!nullToAbsent || pixelHeight != null) {
      map['pixel_height'] = Variable<int>(pixelHeight);
    }
    return map;
  }

  MangaPagesCompanion toCompanion(bool nullToAbsent) {
    return MangaPagesCompanion(
      id: Value(id),
      contentUnitId: Value(contentUnitId),
      orderIndex: Value(orderIndex),
      contentRef: Value(contentRef),
      sourceLocator: Value(sourceLocator),
      contentHash: Value(contentHash),
      mimeType: Value(mimeType),
      byteLength: Value(byteLength),
      pixelWidth: pixelWidth == null && nullToAbsent
          ? const Value.absent()
          : Value(pixelWidth),
      pixelHeight: pixelHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(pixelHeight),
    );
  }

  factory MangaPage.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaPage(
      id: serializer.fromJson<String>(json['id']),
      contentUnitId: serializer.fromJson<String>(json['contentUnitId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      contentRef: serializer.fromJson<String>(json['contentRef']),
      sourceLocator: serializer.fromJson<String>(json['sourceLocator']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
      mimeType: serializer.fromJson<String>(json['mimeType']),
      byteLength: serializer.fromJson<int>(json['byteLength']),
      pixelWidth: serializer.fromJson<int?>(json['pixelWidth']),
      pixelHeight: serializer.fromJson<int?>(json['pixelHeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'contentUnitId': serializer.toJson<String>(contentUnitId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'contentRef': serializer.toJson<String>(contentRef),
      'sourceLocator': serializer.toJson<String>(sourceLocator),
      'contentHash': serializer.toJson<String>(contentHash),
      'mimeType': serializer.toJson<String>(mimeType),
      'byteLength': serializer.toJson<int>(byteLength),
      'pixelWidth': serializer.toJson<int?>(pixelWidth),
      'pixelHeight': serializer.toJson<int?>(pixelHeight),
    };
  }

  MangaPage copyWith({
    String? id,
    String? contentUnitId,
    int? orderIndex,
    String? contentRef,
    String? sourceLocator,
    String? contentHash,
    String? mimeType,
    int? byteLength,
    Value<int?> pixelWidth = const Value.absent(),
    Value<int?> pixelHeight = const Value.absent(),
  }) => MangaPage(
    id: id ?? this.id,
    contentUnitId: contentUnitId ?? this.contentUnitId,
    orderIndex: orderIndex ?? this.orderIndex,
    contentRef: contentRef ?? this.contentRef,
    sourceLocator: sourceLocator ?? this.sourceLocator,
    contentHash: contentHash ?? this.contentHash,
    mimeType: mimeType ?? this.mimeType,
    byteLength: byteLength ?? this.byteLength,
    pixelWidth: pixelWidth.present ? pixelWidth.value : this.pixelWidth,
    pixelHeight: pixelHeight.present ? pixelHeight.value : this.pixelHeight,
  );
  MangaPage copyWithCompanion(MangaPagesCompanion data) {
    return MangaPage(
      id: data.id.present ? data.id.value : this.id,
      contentUnitId: data.contentUnitId.present
          ? data.contentUnitId.value
          : this.contentUnitId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      contentRef: data.contentRef.present
          ? data.contentRef.value
          : this.contentRef,
      sourceLocator: data.sourceLocator.present
          ? data.sourceLocator.value
          : this.sourceLocator,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      byteLength: data.byteLength.present
          ? data.byteLength.value
          : this.byteLength,
      pixelWidth: data.pixelWidth.present
          ? data.pixelWidth.value
          : this.pixelWidth,
      pixelHeight: data.pixelHeight.present
          ? data.pixelHeight.value
          : this.pixelHeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaPage(')
          ..write('id: $id, ')
          ..write('contentUnitId: $contentUnitId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('contentRef: $contentRef, ')
          ..write('sourceLocator: $sourceLocator, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteLength: $byteLength, ')
          ..write('pixelWidth: $pixelWidth, ')
          ..write('pixelHeight: $pixelHeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    contentUnitId,
    orderIndex,
    contentRef,
    sourceLocator,
    contentHash,
    mimeType,
    byteLength,
    pixelWidth,
    pixelHeight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaPage &&
          other.id == this.id &&
          other.contentUnitId == this.contentUnitId &&
          other.orderIndex == this.orderIndex &&
          other.contentRef == this.contentRef &&
          other.sourceLocator == this.sourceLocator &&
          other.contentHash == this.contentHash &&
          other.mimeType == this.mimeType &&
          other.byteLength == this.byteLength &&
          other.pixelWidth == this.pixelWidth &&
          other.pixelHeight == this.pixelHeight);
}

class MangaPagesCompanion extends UpdateCompanion<MangaPage> {
  final Value<String> id;
  final Value<String> contentUnitId;
  final Value<int> orderIndex;
  final Value<String> contentRef;
  final Value<String> sourceLocator;
  final Value<String> contentHash;
  final Value<String> mimeType;
  final Value<int> byteLength;
  final Value<int?> pixelWidth;
  final Value<int?> pixelHeight;
  final Value<int> rowid;
  const MangaPagesCompanion({
    this.id = const Value.absent(),
    this.contentUnitId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.contentRef = const Value.absent(),
    this.sourceLocator = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.byteLength = const Value.absent(),
    this.pixelWidth = const Value.absent(),
    this.pixelHeight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaPagesCompanion.insert({
    required String id,
    required String contentUnitId,
    required int orderIndex,
    required String contentRef,
    required String sourceLocator,
    required String contentHash,
    required String mimeType,
    required int byteLength,
    this.pixelWidth = const Value.absent(),
    this.pixelHeight = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       contentUnitId = Value(contentUnitId),
       orderIndex = Value(orderIndex),
       contentRef = Value(contentRef),
       sourceLocator = Value(sourceLocator),
       contentHash = Value(contentHash),
       mimeType = Value(mimeType),
       byteLength = Value(byteLength);
  static Insertable<MangaPage> custom({
    Expression<String>? id,
    Expression<String>? contentUnitId,
    Expression<int>? orderIndex,
    Expression<String>? contentRef,
    Expression<String>? sourceLocator,
    Expression<String>? contentHash,
    Expression<String>? mimeType,
    Expression<int>? byteLength,
    Expression<int>? pixelWidth,
    Expression<int>? pixelHeight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (contentUnitId != null) 'content_unit_id': contentUnitId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (contentRef != null) 'content_ref': contentRef,
      if (sourceLocator != null) 'source_locator': sourceLocator,
      if (contentHash != null) 'content_hash': contentHash,
      if (mimeType != null) 'mime_type': mimeType,
      if (byteLength != null) 'byte_length': byteLength,
      if (pixelWidth != null) 'pixel_width': pixelWidth,
      if (pixelHeight != null) 'pixel_height': pixelHeight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaPagesCompanion copyWith({
    Value<String>? id,
    Value<String>? contentUnitId,
    Value<int>? orderIndex,
    Value<String>? contentRef,
    Value<String>? sourceLocator,
    Value<String>? contentHash,
    Value<String>? mimeType,
    Value<int>? byteLength,
    Value<int?>? pixelWidth,
    Value<int?>? pixelHeight,
    Value<int>? rowid,
  }) {
    return MangaPagesCompanion(
      id: id ?? this.id,
      contentUnitId: contentUnitId ?? this.contentUnitId,
      orderIndex: orderIndex ?? this.orderIndex,
      contentRef: contentRef ?? this.contentRef,
      sourceLocator: sourceLocator ?? this.sourceLocator,
      contentHash: contentHash ?? this.contentHash,
      mimeType: mimeType ?? this.mimeType,
      byteLength: byteLength ?? this.byteLength,
      pixelWidth: pixelWidth ?? this.pixelWidth,
      pixelHeight: pixelHeight ?? this.pixelHeight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (contentUnitId.present) {
      map['content_unit_id'] = Variable<String>(contentUnitId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (contentRef.present) {
      map['content_ref'] = Variable<String>(contentRef.value);
    }
    if (sourceLocator.present) {
      map['source_locator'] = Variable<String>(sourceLocator.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (byteLength.present) {
      map['byte_length'] = Variable<int>(byteLength.value);
    }
    if (pixelWidth.present) {
      map['pixel_width'] = Variable<int>(pixelWidth.value);
    }
    if (pixelHeight.present) {
      map['pixel_height'] = Variable<int>(pixelHeight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaPagesCompanion(')
          ..write('id: $id, ')
          ..write('contentUnitId: $contentUnitId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('contentRef: $contentRef, ')
          ..write('sourceLocator: $sourceLocator, ')
          ..write('contentHash: $contentHash, ')
          ..write('mimeType: $mimeType, ')
          ..write('byteLength: $byteLength, ')
          ..write('pixelWidth: $pixelWidth, ')
          ..write('pixelHeight: $pixelHeight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressEntriesTable extends ReadingProgressEntries
    with TableInfo<$ReadingProgressEntriesTable, ReadingProgressEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _contentUnitIdMeta = const VerificationMeta(
    'contentUnitId',
  );
  @override
  late final GeneratedColumn<String> contentUnitId = GeneratedColumn<String>(
    'content_unit_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES content_units (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _locatorMeta = const VerificationMeta(
    'locator',
  );
  @override
  late final GeneratedColumn<String> locator = GeneratedColumn<String>(
    'locator',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fractionMeta = const VerificationMeta(
    'fraction',
  );
  @override
  late final GeneratedColumn<double> fraction = GeneratedColumn<double>(
    'fraction',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $ReadingProgressEntriesTable.$converterupdatedAt,
      );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<int> revision = GeneratedColumn<int>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    contentUnitId,
    locator,
    fraction,
    updatedAt,
    revision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('content_unit_id')) {
      context.handle(
        _contentUnitIdMeta,
        contentUnitId.isAcceptableOrUnknown(
          data['content_unit_id']!,
          _contentUnitIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentUnitIdMeta);
    }
    if (data.containsKey('locator')) {
      context.handle(
        _locatorMeta,
        locator.isAcceptableOrUnknown(data['locator']!, _locatorMeta),
      );
    } else if (isInserting) {
      context.missing(_locatorMeta);
    }
    if (data.containsKey('fraction')) {
      context.handle(
        _fractionMeta,
        fraction.isAcceptableOrUnknown(data['fraction']!, _fractionMeta),
      );
    } else if (isInserting) {
      context.missing(_fractionMeta);
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {mediaItemId},
  ];
  @override
  ReadingProgressEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      contentUnitId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_unit_id'],
      )!,
      locator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}locator'],
      )!,
      fraction: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fraction'],
      )!,
      updatedAt: $ReadingProgressEntriesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision'],
      )!,
    );
  }

  @override
  $ReadingProgressEntriesTable createAlias(String alias) {
    return $ReadingProgressEntriesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const DateTimeMillisConverter();
}

class ReadingProgressEntry extends DataClass
    implements Insertable<ReadingProgressEntry> {
  final String id;
  final String mediaItemId;
  final String contentUnitId;
  final String locator;
  final double fraction;
  final DateTime updatedAt;
  final int revision;
  const ReadingProgressEntry({
    required this.id,
    required this.mediaItemId,
    required this.contentUnitId,
    required this.locator,
    required this.fraction,
    required this.updatedAt,
    required this.revision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['content_unit_id'] = Variable<String>(contentUnitId);
    map['locator'] = Variable<String>(locator);
    map['fraction'] = Variable<double>(fraction);
    {
      map['updated_at'] = Variable<int>(
        $ReadingProgressEntriesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    map['revision'] = Variable<int>(revision);
    return map;
  }

  ReadingProgressEntriesCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressEntriesCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      contentUnitId: Value(contentUnitId),
      locator: Value(locator),
      fraction: Value(fraction),
      updatedAt: Value(updatedAt),
      revision: Value(revision),
    );
  }

  factory ReadingProgressEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressEntry(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      contentUnitId: serializer.fromJson<String>(json['contentUnitId']),
      locator: serializer.fromJson<String>(json['locator']),
      fraction: serializer.fromJson<double>(json['fraction']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      revision: serializer.fromJson<int>(json['revision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'contentUnitId': serializer.toJson<String>(contentUnitId),
      'locator': serializer.toJson<String>(locator),
      'fraction': serializer.toJson<double>(fraction),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'revision': serializer.toJson<int>(revision),
    };
  }

  ReadingProgressEntry copyWith({
    String? id,
    String? mediaItemId,
    String? contentUnitId,
    String? locator,
    double? fraction,
    DateTime? updatedAt,
    int? revision,
  }) => ReadingProgressEntry(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    contentUnitId: contentUnitId ?? this.contentUnitId,
    locator: locator ?? this.locator,
    fraction: fraction ?? this.fraction,
    updatedAt: updatedAt ?? this.updatedAt,
    revision: revision ?? this.revision,
  );
  ReadingProgressEntry copyWithCompanion(ReadingProgressEntriesCompanion data) {
    return ReadingProgressEntry(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      contentUnitId: data.contentUnitId.present
          ? data.contentUnitId.value
          : this.contentUnitId,
      locator: data.locator.present ? data.locator.value : this.locator,
      fraction: data.fraction.present ? data.fraction.value : this.fraction,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      revision: data.revision.present ? data.revision.value : this.revision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressEntry(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('contentUnitId: $contentUnitId, ')
          ..write('locator: $locator, ')
          ..write('fraction: $fraction, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    contentUnitId,
    locator,
    fraction,
    updatedAt,
    revision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressEntry &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.contentUnitId == this.contentUnitId &&
          other.locator == this.locator &&
          other.fraction == this.fraction &&
          other.updatedAt == this.updatedAt &&
          other.revision == this.revision);
}

class ReadingProgressEntriesCompanion
    extends UpdateCompanion<ReadingProgressEntry> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<String> contentUnitId;
  final Value<String> locator;
  final Value<double> fraction;
  final Value<DateTime> updatedAt;
  final Value<int> revision;
  final Value<int> rowid;
  const ReadingProgressEntriesCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.contentUnitId = const Value.absent(),
    this.locator = const Value.absent(),
    this.fraction = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.revision = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressEntriesCompanion.insert({
    required String id,
    required String mediaItemId,
    required String contentUnitId,
    required String locator,
    required double fraction,
    required DateTime updatedAt,
    required int revision,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaItemId = Value(mediaItemId),
       contentUnitId = Value(contentUnitId),
       locator = Value(locator),
       fraction = Value(fraction),
       updatedAt = Value(updatedAt),
       revision = Value(revision);
  static Insertable<ReadingProgressEntry> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? contentUnitId,
    Expression<String>? locator,
    Expression<double>? fraction,
    Expression<int>? updatedAt,
    Expression<int>? revision,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (contentUnitId != null) 'content_unit_id': contentUnitId,
      if (locator != null) 'locator': locator,
      if (fraction != null) 'fraction': fraction,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (revision != null) 'revision': revision,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaItemId,
    Value<String>? contentUnitId,
    Value<String>? locator,
    Value<double>? fraction,
    Value<DateTime>? updatedAt,
    Value<int>? revision,
    Value<int>? rowid,
  }) {
    return ReadingProgressEntriesCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      contentUnitId: contentUnitId ?? this.contentUnitId,
      locator: locator ?? this.locator,
      fraction: fraction ?? this.fraction,
      updatedAt: updatedAt ?? this.updatedAt,
      revision: revision ?? this.revision,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (contentUnitId.present) {
      map['content_unit_id'] = Variable<String>(contentUnitId.value);
    }
    if (locator.present) {
      map['locator'] = Variable<String>(locator.value);
    }
    if (fraction.present) {
      map['fraction'] = Variable<double>(fraction.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ReadingProgressEntriesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (revision.present) {
      map['revision'] = Variable<int>(revision.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressEntriesCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('contentUnitId: $contentUnitId, ')
          ..write('locator: $locator, ')
          ..write('fraction: $fraction, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('revision: $revision, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReaderPreferencesTable extends ReaderPreferences
    with TableInfo<$ReaderPreferencesTable, ReaderPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReaderPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scopeMeta = const VerificationMeta('scope');
  @override
  late final GeneratedColumn<String> scope = GeneratedColumn<String>(
    'scope',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _fontSizeMeta = const VerificationMeta(
    'fontSize',
  );
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
    'font_size',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lineHeightMeta = const VerificationMeta(
    'lineHeight',
  );
  @override
  late final GeneratedColumn<double> lineHeight = GeneratedColumn<double>(
    'line_height',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _themeKeyMeta = const VerificationMeta(
    'themeKey',
  );
  @override
  late final GeneratedColumn<String> themeKey = GeneratedColumn<String>(
    'theme_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readingModeMeta = const VerificationMeta(
    'readingMode',
  );
  @override
  late final GeneratedColumn<String> readingMode = GeneratedColumn<String>(
    'reading_mode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReaderPreferencesTable.$converterupdatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    scope,
    mediaItemId,
    fontSize,
    lineHeight,
    themeKey,
    readingMode,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reader_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReaderPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('scope')) {
      context.handle(
        _scopeMeta,
        scope.isAcceptableOrUnknown(data['scope']!, _scopeMeta),
      );
    } else if (isInserting) {
      context.missing(_scopeMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    }
    if (data.containsKey('font_size')) {
      context.handle(
        _fontSizeMeta,
        fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta),
      );
    }
    if (data.containsKey('line_height')) {
      context.handle(
        _lineHeightMeta,
        lineHeight.isAcceptableOrUnknown(data['line_height']!, _lineHeightMeta),
      );
    }
    if (data.containsKey('theme_key')) {
      context.handle(
        _themeKeyMeta,
        themeKey.isAcceptableOrUnknown(data['theme_key']!, _themeKeyMeta),
      );
    }
    if (data.containsKey('reading_mode')) {
      context.handle(
        _readingModeMeta,
        readingMode.isAcceptableOrUnknown(
          data['reading_mode']!,
          _readingModeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReaderPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReaderPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      scope: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      ),
      fontSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}font_size'],
      ),
      lineHeight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}line_height'],
      ),
      themeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}theme_key'],
      ),
      readingMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_mode'],
      ),
      updatedAt: $ReaderPreferencesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $ReaderPreferencesTable createAlias(String alias) {
    return $ReaderPreferencesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const DateTimeMillisConverter();
}

class ReaderPreference extends DataClass
    implements Insertable<ReaderPreference> {
  final String id;
  final String scope;
  final String? mediaItemId;
  final double? fontSize;
  final double? lineHeight;
  final String? themeKey;
  final String? readingMode;
  final DateTime updatedAt;
  const ReaderPreference({
    required this.id,
    required this.scope,
    this.mediaItemId,
    this.fontSize,
    this.lineHeight,
    this.themeKey,
    this.readingMode,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['scope'] = Variable<String>(scope);
    if (!nullToAbsent || mediaItemId != null) {
      map['media_item_id'] = Variable<String>(mediaItemId);
    }
    if (!nullToAbsent || fontSize != null) {
      map['font_size'] = Variable<double>(fontSize);
    }
    if (!nullToAbsent || lineHeight != null) {
      map['line_height'] = Variable<double>(lineHeight);
    }
    if (!nullToAbsent || themeKey != null) {
      map['theme_key'] = Variable<String>(themeKey);
    }
    if (!nullToAbsent || readingMode != null) {
      map['reading_mode'] = Variable<String>(readingMode);
    }
    {
      map['updated_at'] = Variable<int>(
        $ReaderPreferencesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  ReaderPreferencesCompanion toCompanion(bool nullToAbsent) {
    return ReaderPreferencesCompanion(
      id: Value(id),
      scope: Value(scope),
      mediaItemId: mediaItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaItemId),
      fontSize: fontSize == null && nullToAbsent
          ? const Value.absent()
          : Value(fontSize),
      lineHeight: lineHeight == null && nullToAbsent
          ? const Value.absent()
          : Value(lineHeight),
      themeKey: themeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(themeKey),
      readingMode: readingMode == null && nullToAbsent
          ? const Value.absent()
          : Value(readingMode),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReaderPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReaderPreference(
      id: serializer.fromJson<String>(json['id']),
      scope: serializer.fromJson<String>(json['scope']),
      mediaItemId: serializer.fromJson<String?>(json['mediaItemId']),
      fontSize: serializer.fromJson<double?>(json['fontSize']),
      lineHeight: serializer.fromJson<double?>(json['lineHeight']),
      themeKey: serializer.fromJson<String?>(json['themeKey']),
      readingMode: serializer.fromJson<String?>(json['readingMode']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'scope': serializer.toJson<String>(scope),
      'mediaItemId': serializer.toJson<String?>(mediaItemId),
      'fontSize': serializer.toJson<double?>(fontSize),
      'lineHeight': serializer.toJson<double?>(lineHeight),
      'themeKey': serializer.toJson<String?>(themeKey),
      'readingMode': serializer.toJson<String?>(readingMode),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReaderPreference copyWith({
    String? id,
    String? scope,
    Value<String?> mediaItemId = const Value.absent(),
    Value<double?> fontSize = const Value.absent(),
    Value<double?> lineHeight = const Value.absent(),
    Value<String?> themeKey = const Value.absent(),
    Value<String?> readingMode = const Value.absent(),
    DateTime? updatedAt,
  }) => ReaderPreference(
    id: id ?? this.id,
    scope: scope ?? this.scope,
    mediaItemId: mediaItemId.present ? mediaItemId.value : this.mediaItemId,
    fontSize: fontSize.present ? fontSize.value : this.fontSize,
    lineHeight: lineHeight.present ? lineHeight.value : this.lineHeight,
    themeKey: themeKey.present ? themeKey.value : this.themeKey,
    readingMode: readingMode.present ? readingMode.value : this.readingMode,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReaderPreference copyWithCompanion(ReaderPreferencesCompanion data) {
    return ReaderPreference(
      id: data.id.present ? data.id.value : this.id,
      scope: data.scope.present ? data.scope.value : this.scope,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      lineHeight: data.lineHeight.present
          ? data.lineHeight.value
          : this.lineHeight,
      themeKey: data.themeKey.present ? data.themeKey.value : this.themeKey,
      readingMode: data.readingMode.present
          ? data.readingMode.value
          : this.readingMode,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReaderPreference(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('fontSize: $fontSize, ')
          ..write('lineHeight: $lineHeight, ')
          ..write('themeKey: $themeKey, ')
          ..write('readingMode: $readingMode, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    scope,
    mediaItemId,
    fontSize,
    lineHeight,
    themeKey,
    readingMode,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReaderPreference &&
          other.id == this.id &&
          other.scope == this.scope &&
          other.mediaItemId == this.mediaItemId &&
          other.fontSize == this.fontSize &&
          other.lineHeight == this.lineHeight &&
          other.themeKey == this.themeKey &&
          other.readingMode == this.readingMode &&
          other.updatedAt == this.updatedAt);
}

class ReaderPreferencesCompanion extends UpdateCompanion<ReaderPreference> {
  final Value<String> id;
  final Value<String> scope;
  final Value<String?> mediaItemId;
  final Value<double?> fontSize;
  final Value<double?> lineHeight;
  final Value<String?> themeKey;
  final Value<String?> readingMode;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReaderPreferencesCompanion({
    this.id = const Value.absent(),
    this.scope = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.lineHeight = const Value.absent(),
    this.themeKey = const Value.absent(),
    this.readingMode = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReaderPreferencesCompanion.insert({
    required String id,
    required String scope,
    this.mediaItemId = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.lineHeight = const Value.absent(),
    this.themeKey = const Value.absent(),
    this.readingMode = const Value.absent(),
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       scope = Value(scope),
       updatedAt = Value(updatedAt);
  static Insertable<ReaderPreference> custom({
    Expression<String>? id,
    Expression<String>? scope,
    Expression<String>? mediaItemId,
    Expression<double>? fontSize,
    Expression<double>? lineHeight,
    Expression<String>? themeKey,
    Expression<String>? readingMode,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (scope != null) 'scope': scope,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (fontSize != null) 'font_size': fontSize,
      if (lineHeight != null) 'line_height': lineHeight,
      if (themeKey != null) 'theme_key': themeKey,
      if (readingMode != null) 'reading_mode': readingMode,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReaderPreferencesCompanion copyWith({
    Value<String>? id,
    Value<String>? scope,
    Value<String?>? mediaItemId,
    Value<double?>? fontSize,
    Value<double?>? lineHeight,
    Value<String?>? themeKey,
    Value<String?>? readingMode,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReaderPreferencesCompanion(
      id: id ?? this.id,
      scope: scope ?? this.scope,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      fontSize: fontSize ?? this.fontSize,
      lineHeight: lineHeight ?? this.lineHeight,
      themeKey: themeKey ?? this.themeKey,
      readingMode: readingMode ?? this.readingMode,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (scope.present) {
      map['scope'] = Variable<String>(scope.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (lineHeight.present) {
      map['line_height'] = Variable<double>(lineHeight.value);
    }
    if (themeKey.present) {
      map['theme_key'] = Variable<String>(themeKey.value);
    }
    if (readingMode.present) {
      map['reading_mode'] = Variable<String>(readingMode.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $ReaderPreferencesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReaderPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('scope: $scope, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('fontSize: $fontSize, ')
          ..write('lineHeight: $lineHeight, ')
          ..write('themeKey: $themeKey, ')
          ..write('readingMode: $readingMode, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MangaReaderPreferencesTable extends MangaReaderPreferences
    with TableInfo<$MangaReaderPreferencesTable, MangaReaderPreference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MangaReaderPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'UNIQUE REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _readingModeMeta = const VerificationMeta(
    'readingMode',
  );
  @override
  late final GeneratedColumn<String> readingMode = GeneratedColumn<String>(
    'reading_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageTurnDirectionMeta = const VerificationMeta(
    'pageTurnDirection',
  );
  @override
  late final GeneratedColumn<String> pageTurnDirection =
      GeneratedColumn<String>(
        'page_turn_direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> updatedAt =
      GeneratedColumn<int>(
        'updated_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>(
        $MangaReaderPreferencesTable.$converterupdatedAt,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    readingMode,
    pageTurnDirection,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manga_reader_preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<MangaReaderPreference> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_mediaItemIdMeta);
    }
    if (data.containsKey('reading_mode')) {
      context.handle(
        _readingModeMeta,
        readingMode.isAcceptableOrUnknown(
          data['reading_mode']!,
          _readingModeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_readingModeMeta);
    }
    if (data.containsKey('page_turn_direction')) {
      context.handle(
        _pageTurnDirectionMeta,
        pageTurnDirection.isAcceptableOrUnknown(
          data['page_turn_direction']!,
          _pageTurnDirectionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pageTurnDirectionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MangaReaderPreference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MangaReaderPreference(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      )!,
      readingMode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading_mode'],
      )!,
      pageTurnDirection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}page_turn_direction'],
      )!,
      updatedAt: $MangaReaderPreferencesTable.$converterupdatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}updated_at'],
        )!,
      ),
    );
  }

  @override
  $MangaReaderPreferencesTable createAlias(String alias) {
    return $MangaReaderPreferencesTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $converterupdatedAt =
      const DateTimeMillisConverter();
}

class MangaReaderPreference extends DataClass
    implements Insertable<MangaReaderPreference> {
  final String id;
  final String mediaItemId;
  final String readingMode;
  final String pageTurnDirection;
  final DateTime updatedAt;
  const MangaReaderPreference({
    required this.id,
    required this.mediaItemId,
    required this.readingMode,
    required this.pageTurnDirection,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['media_item_id'] = Variable<String>(mediaItemId);
    map['reading_mode'] = Variable<String>(readingMode);
    map['page_turn_direction'] = Variable<String>(pageTurnDirection);
    {
      map['updated_at'] = Variable<int>(
        $MangaReaderPreferencesTable.$converterupdatedAt.toSql(updatedAt),
      );
    }
    return map;
  }

  MangaReaderPreferencesCompanion toCompanion(bool nullToAbsent) {
    return MangaReaderPreferencesCompanion(
      id: Value(id),
      mediaItemId: Value(mediaItemId),
      readingMode: Value(readingMode),
      pageTurnDirection: Value(pageTurnDirection),
      updatedAt: Value(updatedAt),
    );
  }

  factory MangaReaderPreference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MangaReaderPreference(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String>(json['mediaItemId']),
      readingMode: serializer.fromJson<String>(json['readingMode']),
      pageTurnDirection: serializer.fromJson<String>(json['pageTurnDirection']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String>(mediaItemId),
      'readingMode': serializer.toJson<String>(readingMode),
      'pageTurnDirection': serializer.toJson<String>(pageTurnDirection),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MangaReaderPreference copyWith({
    String? id,
    String? mediaItemId,
    String? readingMode,
    String? pageTurnDirection,
    DateTime? updatedAt,
  }) => MangaReaderPreference(
    id: id ?? this.id,
    mediaItemId: mediaItemId ?? this.mediaItemId,
    readingMode: readingMode ?? this.readingMode,
    pageTurnDirection: pageTurnDirection ?? this.pageTurnDirection,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MangaReaderPreference copyWithCompanion(
    MangaReaderPreferencesCompanion data,
  ) {
    return MangaReaderPreference(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      readingMode: data.readingMode.present
          ? data.readingMode.value
          : this.readingMode,
      pageTurnDirection: data.pageTurnDirection.present
          ? data.pageTurnDirection.value
          : this.pageTurnDirection,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MangaReaderPreference(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('readingMode: $readingMode, ')
          ..write('pageTurnDirection: $pageTurnDirection, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, mediaItemId, readingMode, pageTurnDirection, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MangaReaderPreference &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.readingMode == this.readingMode &&
          other.pageTurnDirection == this.pageTurnDirection &&
          other.updatedAt == this.updatedAt);
}

class MangaReaderPreferencesCompanion
    extends UpdateCompanion<MangaReaderPreference> {
  final Value<String> id;
  final Value<String> mediaItemId;
  final Value<String> readingMode;
  final Value<String> pageTurnDirection;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MangaReaderPreferencesCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.readingMode = const Value.absent(),
    this.pageTurnDirection = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MangaReaderPreferencesCompanion.insert({
    required String id,
    required String mediaItemId,
    required String readingMode,
    required String pageTurnDirection,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       mediaItemId = Value(mediaItemId),
       readingMode = Value(readingMode),
       pageTurnDirection = Value(pageTurnDirection),
       updatedAt = Value(updatedAt);
  static Insertable<MangaReaderPreference> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? readingMode,
    Expression<String>? pageTurnDirection,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (readingMode != null) 'reading_mode': readingMode,
      if (pageTurnDirection != null) 'page_turn_direction': pageTurnDirection,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MangaReaderPreferencesCompanion copyWith({
    Value<String>? id,
    Value<String>? mediaItemId,
    Value<String>? readingMode,
    Value<String>? pageTurnDirection,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MangaReaderPreferencesCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      readingMode: readingMode ?? this.readingMode,
      pageTurnDirection: pageTurnDirection ?? this.pageTurnDirection,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (readingMode.present) {
      map['reading_mode'] = Variable<String>(readingMode.value);
    }
    if (pageTurnDirection.present) {
      map['page_turn_direction'] = Variable<String>(pageTurnDirection.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(
        $MangaReaderPreferencesTable.$converterupdatedAt.toSql(updatedAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MangaReaderPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('readingMode: $readingMode, ')
          ..write('pageTurnDirection: $pageTurnDirection, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ImportRecordsTable extends ImportRecords
    with TableInfo<$ImportRecordsTable, ImportRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ImportRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaItemIdMeta = const VerificationMeta(
    'mediaItemId',
  );
  @override
  late final GeneratedColumn<String> mediaItemId = GeneratedColumn<String>(
    'media_item_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _sourcePathMeta = const VerificationMeta(
    'sourcePath',
  );
  @override
  late final GeneratedColumn<String> sourcePath = GeneratedColumn<String>(
    'source_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceKindMeta = const VerificationMeta(
    'sourceKind',
  );
  @override
  late final GeneratedColumn<String> sourceKind = GeneratedColumn<String>(
    'source_kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileSizeMeta = const VerificationMeta(
    'fileSize',
  );
  @override
  late final GeneratedColumn<int> fileSize = GeneratedColumn<int>(
    'file_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, int> modifiedAt =
      GeneratedColumn<int>(
        'modified_at',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($ImportRecordsTable.$convertermodifiedAtn);
  static const VerificationMeta _fingerprintMeta = const VerificationMeta(
    'fingerprint',
  );
  @override
  late final GeneratedColumn<String> fingerprint = GeneratedColumn<String>(
    'fingerprint',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _textEncodingMeta = const VerificationMeta(
    'textEncoding',
  );
  @override
  late final GeneratedColumn<String> textEncoding = GeneratedColumn<String>(
    'text_encoding',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _errorCodeMeta = const VerificationMeta(
    'errorCode',
  );
  @override
  late final GeneratedColumn<String> errorCode = GeneratedColumn<String>(
    'error_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, int> createdAt =
      GeneratedColumn<int>(
        'created_at',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ImportRecordsTable.$convertercreatedAt);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    mediaItemId,
    sourcePath,
    sourceKind,
    fileSize,
    modifiedAt,
    fingerprint,
    textEncoding,
    status,
    errorCode,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'import_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ImportRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('media_item_id')) {
      context.handle(
        _mediaItemIdMeta,
        mediaItemId.isAcceptableOrUnknown(
          data['media_item_id']!,
          _mediaItemIdMeta,
        ),
      );
    }
    if (data.containsKey('source_path')) {
      context.handle(
        _sourcePathMeta,
        sourcePath.isAcceptableOrUnknown(data['source_path']!, _sourcePathMeta),
      );
    } else if (isInserting) {
      context.missing(_sourcePathMeta);
    }
    if (data.containsKey('source_kind')) {
      context.handle(
        _sourceKindMeta,
        sourceKind.isAcceptableOrUnknown(data['source_kind']!, _sourceKindMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceKindMeta);
    }
    if (data.containsKey('file_size')) {
      context.handle(
        _fileSizeMeta,
        fileSize.isAcceptableOrUnknown(data['file_size']!, _fileSizeMeta),
      );
    } else if (isInserting) {
      context.missing(_fileSizeMeta);
    }
    if (data.containsKey('fingerprint')) {
      context.handle(
        _fingerprintMeta,
        fingerprint.isAcceptableOrUnknown(
          data['fingerprint']!,
          _fingerprintMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fingerprintMeta);
    }
    if (data.containsKey('text_encoding')) {
      context.handle(
        _textEncodingMeta,
        textEncoding.isAcceptableOrUnknown(
          data['text_encoding']!,
          _textEncodingMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('error_code')) {
      context.handle(
        _errorCodeMeta,
        errorCode.isAcceptableOrUnknown(data['error_code']!, _errorCodeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ImportRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ImportRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      mediaItemId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_item_id'],
      ),
      sourcePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_path'],
      )!,
      sourceKind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_kind'],
      )!,
      fileSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_size'],
      )!,
      modifiedAt: $ImportRecordsTable.$convertermodifiedAtn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}modified_at'],
        ),
      ),
      fingerprint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fingerprint'],
      )!,
      textEncoding: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text_encoding'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      errorCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_code'],
      ),
      createdAt: $ImportRecordsTable.$convertercreatedAt.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}created_at'],
        )!,
      ),
    );
  }

  @override
  $ImportRecordsTable createAlias(String alias) {
    return $ImportRecordsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, int> $convertermodifiedAt =
      const DateTimeMillisConverter();
  static TypeConverter<DateTime?, int?> $convertermodifiedAtn =
      NullAwareTypeConverter.wrap($convertermodifiedAt);
  static TypeConverter<DateTime, int> $convertercreatedAt =
      const DateTimeMillisConverter();
}

class ImportRecord extends DataClass implements Insertable<ImportRecord> {
  final String id;
  final String? mediaItemId;
  final String sourcePath;
  final String sourceKind;
  final int fileSize;
  final DateTime? modifiedAt;
  final String fingerprint;
  final String? textEncoding;
  final String status;
  final String? errorCode;
  final DateTime createdAt;
  const ImportRecord({
    required this.id,
    this.mediaItemId,
    required this.sourcePath,
    required this.sourceKind,
    required this.fileSize,
    this.modifiedAt,
    required this.fingerprint,
    this.textEncoding,
    required this.status,
    this.errorCode,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || mediaItemId != null) {
      map['media_item_id'] = Variable<String>(mediaItemId);
    }
    map['source_path'] = Variable<String>(sourcePath);
    map['source_kind'] = Variable<String>(sourceKind);
    map['file_size'] = Variable<int>(fileSize);
    if (!nullToAbsent || modifiedAt != null) {
      map['modified_at'] = Variable<int>(
        $ImportRecordsTable.$convertermodifiedAtn.toSql(modifiedAt),
      );
    }
    map['fingerprint'] = Variable<String>(fingerprint);
    if (!nullToAbsent || textEncoding != null) {
      map['text_encoding'] = Variable<String>(textEncoding);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || errorCode != null) {
      map['error_code'] = Variable<String>(errorCode);
    }
    {
      map['created_at'] = Variable<int>(
        $ImportRecordsTable.$convertercreatedAt.toSql(createdAt),
      );
    }
    return map;
  }

  ImportRecordsCompanion toCompanion(bool nullToAbsent) {
    return ImportRecordsCompanion(
      id: Value(id),
      mediaItemId: mediaItemId == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaItemId),
      sourcePath: Value(sourcePath),
      sourceKind: Value(sourceKind),
      fileSize: Value(fileSize),
      modifiedAt: modifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(modifiedAt),
      fingerprint: Value(fingerprint),
      textEncoding: textEncoding == null && nullToAbsent
          ? const Value.absent()
          : Value(textEncoding),
      status: Value(status),
      errorCode: errorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(errorCode),
      createdAt: Value(createdAt),
    );
  }

  factory ImportRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ImportRecord(
      id: serializer.fromJson<String>(json['id']),
      mediaItemId: serializer.fromJson<String?>(json['mediaItemId']),
      sourcePath: serializer.fromJson<String>(json['sourcePath']),
      sourceKind: serializer.fromJson<String>(json['sourceKind']),
      fileSize: serializer.fromJson<int>(json['fileSize']),
      modifiedAt: serializer.fromJson<DateTime?>(json['modifiedAt']),
      fingerprint: serializer.fromJson<String>(json['fingerprint']),
      textEncoding: serializer.fromJson<String?>(json['textEncoding']),
      status: serializer.fromJson<String>(json['status']),
      errorCode: serializer.fromJson<String?>(json['errorCode']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'mediaItemId': serializer.toJson<String?>(mediaItemId),
      'sourcePath': serializer.toJson<String>(sourcePath),
      'sourceKind': serializer.toJson<String>(sourceKind),
      'fileSize': serializer.toJson<int>(fileSize),
      'modifiedAt': serializer.toJson<DateTime?>(modifiedAt),
      'fingerprint': serializer.toJson<String>(fingerprint),
      'textEncoding': serializer.toJson<String?>(textEncoding),
      'status': serializer.toJson<String>(status),
      'errorCode': serializer.toJson<String?>(errorCode),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ImportRecord copyWith({
    String? id,
    Value<String?> mediaItemId = const Value.absent(),
    String? sourcePath,
    String? sourceKind,
    int? fileSize,
    Value<DateTime?> modifiedAt = const Value.absent(),
    String? fingerprint,
    Value<String?> textEncoding = const Value.absent(),
    String? status,
    Value<String?> errorCode = const Value.absent(),
    DateTime? createdAt,
  }) => ImportRecord(
    id: id ?? this.id,
    mediaItemId: mediaItemId.present ? mediaItemId.value : this.mediaItemId,
    sourcePath: sourcePath ?? this.sourcePath,
    sourceKind: sourceKind ?? this.sourceKind,
    fileSize: fileSize ?? this.fileSize,
    modifiedAt: modifiedAt.present ? modifiedAt.value : this.modifiedAt,
    fingerprint: fingerprint ?? this.fingerprint,
    textEncoding: textEncoding.present ? textEncoding.value : this.textEncoding,
    status: status ?? this.status,
    errorCode: errorCode.present ? errorCode.value : this.errorCode,
    createdAt: createdAt ?? this.createdAt,
  );
  ImportRecord copyWithCompanion(ImportRecordsCompanion data) {
    return ImportRecord(
      id: data.id.present ? data.id.value : this.id,
      mediaItemId: data.mediaItemId.present
          ? data.mediaItemId.value
          : this.mediaItemId,
      sourcePath: data.sourcePath.present
          ? data.sourcePath.value
          : this.sourcePath,
      sourceKind: data.sourceKind.present
          ? data.sourceKind.value
          : this.sourceKind,
      fileSize: data.fileSize.present ? data.fileSize.value : this.fileSize,
      modifiedAt: data.modifiedAt.present
          ? data.modifiedAt.value
          : this.modifiedAt,
      fingerprint: data.fingerprint.present
          ? data.fingerprint.value
          : this.fingerprint,
      textEncoding: data.textEncoding.present
          ? data.textEncoding.value
          : this.textEncoding,
      status: data.status.present ? data.status.value : this.status,
      errorCode: data.errorCode.present ? data.errorCode.value : this.errorCode,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ImportRecord(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('sourcePath: $sourcePath, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('fileSize: $fileSize, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('textEncoding: $textEncoding, ')
          ..write('status: $status, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    mediaItemId,
    sourcePath,
    sourceKind,
    fileSize,
    modifiedAt,
    fingerprint,
    textEncoding,
    status,
    errorCode,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ImportRecord &&
          other.id == this.id &&
          other.mediaItemId == this.mediaItemId &&
          other.sourcePath == this.sourcePath &&
          other.sourceKind == this.sourceKind &&
          other.fileSize == this.fileSize &&
          other.modifiedAt == this.modifiedAt &&
          other.fingerprint == this.fingerprint &&
          other.textEncoding == this.textEncoding &&
          other.status == this.status &&
          other.errorCode == this.errorCode &&
          other.createdAt == this.createdAt);
}

class ImportRecordsCompanion extends UpdateCompanion<ImportRecord> {
  final Value<String> id;
  final Value<String?> mediaItemId;
  final Value<String> sourcePath;
  final Value<String> sourceKind;
  final Value<int> fileSize;
  final Value<DateTime?> modifiedAt;
  final Value<String> fingerprint;
  final Value<String?> textEncoding;
  final Value<String> status;
  final Value<String?> errorCode;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ImportRecordsCompanion({
    this.id = const Value.absent(),
    this.mediaItemId = const Value.absent(),
    this.sourcePath = const Value.absent(),
    this.sourceKind = const Value.absent(),
    this.fileSize = const Value.absent(),
    this.modifiedAt = const Value.absent(),
    this.fingerprint = const Value.absent(),
    this.textEncoding = const Value.absent(),
    this.status = const Value.absent(),
    this.errorCode = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ImportRecordsCompanion.insert({
    required String id,
    this.mediaItemId = const Value.absent(),
    required String sourcePath,
    required String sourceKind,
    required int fileSize,
    this.modifiedAt = const Value.absent(),
    required String fingerprint,
    this.textEncoding = const Value.absent(),
    required String status,
    this.errorCode = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sourcePath = Value(sourcePath),
       sourceKind = Value(sourceKind),
       fileSize = Value(fileSize),
       fingerprint = Value(fingerprint),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<ImportRecord> custom({
    Expression<String>? id,
    Expression<String>? mediaItemId,
    Expression<String>? sourcePath,
    Expression<String>? sourceKind,
    Expression<int>? fileSize,
    Expression<int>? modifiedAt,
    Expression<String>? fingerprint,
    Expression<String>? textEncoding,
    Expression<String>? status,
    Expression<String>? errorCode,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (mediaItemId != null) 'media_item_id': mediaItemId,
      if (sourcePath != null) 'source_path': sourcePath,
      if (sourceKind != null) 'source_kind': sourceKind,
      if (fileSize != null) 'file_size': fileSize,
      if (modifiedAt != null) 'modified_at': modifiedAt,
      if (fingerprint != null) 'fingerprint': fingerprint,
      if (textEncoding != null) 'text_encoding': textEncoding,
      if (status != null) 'status': status,
      if (errorCode != null) 'error_code': errorCode,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ImportRecordsCompanion copyWith({
    Value<String>? id,
    Value<String?>? mediaItemId,
    Value<String>? sourcePath,
    Value<String>? sourceKind,
    Value<int>? fileSize,
    Value<DateTime?>? modifiedAt,
    Value<String>? fingerprint,
    Value<String?>? textEncoding,
    Value<String>? status,
    Value<String?>? errorCode,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ImportRecordsCompanion(
      id: id ?? this.id,
      mediaItemId: mediaItemId ?? this.mediaItemId,
      sourcePath: sourcePath ?? this.sourcePath,
      sourceKind: sourceKind ?? this.sourceKind,
      fileSize: fileSize ?? this.fileSize,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      fingerprint: fingerprint ?? this.fingerprint,
      textEncoding: textEncoding ?? this.textEncoding,
      status: status ?? this.status,
      errorCode: errorCode ?? this.errorCode,
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
    if (mediaItemId.present) {
      map['media_item_id'] = Variable<String>(mediaItemId.value);
    }
    if (sourcePath.present) {
      map['source_path'] = Variable<String>(sourcePath.value);
    }
    if (sourceKind.present) {
      map['source_kind'] = Variable<String>(sourceKind.value);
    }
    if (fileSize.present) {
      map['file_size'] = Variable<int>(fileSize.value);
    }
    if (modifiedAt.present) {
      map['modified_at'] = Variable<int>(
        $ImportRecordsTable.$convertermodifiedAtn.toSql(modifiedAt.value),
      );
    }
    if (fingerprint.present) {
      map['fingerprint'] = Variable<String>(fingerprint.value);
    }
    if (textEncoding.present) {
      map['text_encoding'] = Variable<String>(textEncoding.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (errorCode.present) {
      map['error_code'] = Variable<String>(errorCode.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(
        $ImportRecordsTable.$convertercreatedAt.toSql(createdAt.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ImportRecordsCompanion(')
          ..write('id: $id, ')
          ..write('mediaItemId: $mediaItemId, ')
          ..write('sourcePath: $sourcePath, ')
          ..write('sourceKind: $sourceKind, ')
          ..write('fileSize: $fileSize, ')
          ..write('modifiedAt: $modifiedAt, ')
          ..write('fingerprint: $fingerprint, ')
          ..write('textEncoding: $textEncoding, ')
          ..write('status: $status, ')
          ..write('errorCode: $errorCode, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $ContentUnitsTable contentUnits = $ContentUnitsTable(this);
  late final $BookmarksTable bookmarks = $BookmarksTable(this);
  late final $LibraryEntriesTable libraryEntries = $LibraryEntriesTable(this);
  late final $MangaPagesTable mangaPages = $MangaPagesTable(this);
  late final $ReadingProgressEntriesTable readingProgressEntries =
      $ReadingProgressEntriesTable(this);
  late final $ReaderPreferencesTable readerPreferences =
      $ReaderPreferencesTable(this);
  late final $MangaReaderPreferencesTable mangaReaderPreferences =
      $MangaReaderPreferencesTable(this);
  late final $ImportRecordsTable importRecords = $ImportRecordsTable(this);
  late final Index bookmarksMediaCreatedIdx = Index(
    'bookmarks_media_created_idx',
    'CREATE INDEX bookmarks_media_created_idx ON bookmarks (media_item_id, created_at)',
  );
  late final Index mediaItemsTypeUpdatedIdx = Index(
    'media_items_type_updated_idx',
    'CREATE INDEX media_items_type_updated_idx ON media_items (media_type, updated_at)',
  );
  late final Index readerPreferencesGlobalIdx = Index(
    'reader_preferences_global_idx',
    'CREATE UNIQUE INDEX reader_preferences_global_idx ON reader_preferences (scope) WHERE scope = \'global\'',
  );
  late final Index readerPreferencesMediaIdx = Index(
    'reader_preferences_media_idx',
    'CREATE UNIQUE INDEX reader_preferences_media_idx ON reader_preferences (media_item_id) WHERE scope = \'mediaItem\'',
  );
  late final Index importRecordsFingerprintIdx = Index(
    'import_records_fingerprint_idx',
    'CREATE INDEX import_records_fingerprint_idx ON import_records (fingerprint)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mediaItems,
    contentUnits,
    bookmarks,
    libraryEntries,
    mangaPages,
    readingProgressEntries,
    readerPreferences,
    mangaReaderPreferences,
    importRecords,
    bookmarksMediaCreatedIdx,
    mediaItemsTypeUpdatedIdx,
    readerPreferencesGlobalIdx,
    readerPreferencesMediaIdx,
    importRecordsFingerprintIdx,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('content_units', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'content_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('bookmarks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('library_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'content_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('manga_pages', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'content_units',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reading_progress', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('reader_preferences', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [
        TableUpdate('manga_reader_preferences', kind: UpdateKind.delete),
      ],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('import_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MediaItemsTableCreateCompanionBuilder =
    MediaItemsCompanion Function({
      required String id,
      required String mediaType,
      required String title,
      Value<String?> subtitle,
      Value<String?> creator,
      Value<String?> description,
      Value<String?> coverRef,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MediaItemsTableUpdateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<String> id,
      Value<String> mediaType,
      Value<String> title,
      Value<String?> subtitle,
      Value<String?> creator,
      Value<String?> description,
      Value<String?> coverRef,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MediaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem> {
  $$MediaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ContentUnitsTable, List<ContentUnit>>
  _contentUnitsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.contentUnits,
    aliasName: 'media_items__id__content_units__media_item_id',
  );

  $$ContentUnitsTableProcessedTableManager get contentUnitsRefs {
    final manager = $$ContentUnitsTableTableManager(
      $_db,
      $_db.contentUnits,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_contentUnitsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'media_items__id__bookmarks__media_item_id',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LibraryEntriesTable, List<LibraryEntry>>
  _libraryEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.libraryEntries,
    aliasName: 'media_items__id__library_entries__media_item_id',
  );

  $$LibraryEntriesTableProcessedTableManager get libraryEntriesRefs {
    final manager = $$LibraryEntriesTableTableManager(
      $_db,
      $_db.libraryEntries,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_libraryEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReadingProgressEntriesTable,
    List<ReadingProgressEntry>
  >
  _readingProgressEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readingProgressEntries,
        aliasName: 'media_items__id__reading_progress__media_item_id',
      );

  $$ReadingProgressEntriesTableProcessedTableManager
  get readingProgressEntriesRefs {
    final manager = $$ReadingProgressEntriesTableTableManager(
      $_db,
      $_db.readingProgressEntries,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingProgressEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ReaderPreferencesTable, List<ReaderPreference>>
  _readerPreferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readerPreferences,
        aliasName: 'media_items__id__reader_preferences__media_item_id',
      );

  $$ReaderPreferencesTableProcessedTableManager get readerPreferencesRefs {
    final manager = $$ReaderPreferencesTableTableManager(
      $_db,
      $_db.readerPreferences,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readerPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $MangaReaderPreferencesTable,
    List<MangaReaderPreference>
  >
  _mangaReaderPreferencesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.mangaReaderPreferences,
        aliasName: 'media_items__id__manga_reader_preferences__media_item_id',
      );

  $$MangaReaderPreferencesTableProcessedTableManager
  get mangaReaderPreferencesRefs {
    final manager = $$MangaReaderPreferencesTableTableManager(
      $_db,
      $_db.mangaReaderPreferences,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _mangaReaderPreferencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ImportRecordsTable, List<ImportRecord>>
  _importRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.importRecords,
    aliasName: 'media_items__id__import_records__media_item_id',
  );

  $$ImportRecordsTableProcessedTableManager get importRecordsRefs {
    final manager = $$ImportRecordsTableTableManager(
      $_db,
      $_db.importRecords,
    ).filter((f) => f.mediaItemId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_importRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
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

  ColumnFilters<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverRef => $composableBuilder(
    column: $table.coverRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  Expression<bool> contentUnitsRefs(
    Expression<bool> Function($$ContentUnitsTableFilterComposer f) f,
  ) {
    final $$ContentUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableFilterComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> libraryEntriesRefs(
    Expression<bool> Function($$LibraryEntriesTableFilterComposer f) f,
  ) {
    final $$LibraryEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableFilterComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingProgressEntriesRefs(
    Expression<bool> Function($$ReadingProgressEntriesTableFilterComposer f) f,
  ) {
    final $$ReadingProgressEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readingProgressEntries,
          getReferencedColumn: (t) => t.mediaItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingProgressEntriesTableFilterComposer(
                $db: $db,
                $table: $db.readingProgressEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> readerPreferencesRefs(
    Expression<bool> Function($$ReaderPreferencesTableFilterComposer f) f,
  ) {
    final $$ReaderPreferencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readerPreferences,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReaderPreferencesTableFilterComposer(
            $db: $db,
            $table: $db.readerPreferences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mangaReaderPreferencesRefs(
    Expression<bool> Function($$MangaReaderPreferencesTableFilterComposer f) f,
  ) {
    final $$MangaReaderPreferencesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mangaReaderPreferences,
          getReferencedColumn: (t) => t.mediaItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MangaReaderPreferencesTableFilterComposer(
                $db: $db,
                $table: $db.mangaReaderPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> importRecordsRefs(
    Expression<bool> Function($$ImportRecordsTableFilterComposer f) f,
  ) {
    final $$ImportRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableFilterComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
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

  ColumnOrderings<String> get mediaType => $composableBuilder(
    column: $table.mediaType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get creator => $composableBuilder(
    column: $table.creator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverRef => $composableBuilder(
    column: $table.coverRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get mediaType =>
      $composableBuilder(column: $table.mediaType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get creator =>
      $composableBuilder(column: $table.creator, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get coverRef =>
      $composableBuilder(column: $table.coverRef, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> contentUnitsRefs<T extends Object>(
    Expression<T> Function($$ContentUnitsTableAnnotationComposer a) f,
  ) {
    final $$ContentUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> libraryEntriesRefs<T extends Object>(
    Expression<T> Function($$LibraryEntriesTableAnnotationComposer a) f,
  ) {
    final $$LibraryEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.libraryEntries,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LibraryEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.libraryEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingProgressEntriesRefs<T extends Object>(
    Expression<T> Function($$ReadingProgressEntriesTableAnnotationComposer a) f,
  ) {
    final $$ReadingProgressEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readingProgressEntries,
          getReferencedColumn: (t) => t.mediaItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingProgressEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.readingProgressEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> readerPreferencesRefs<T extends Object>(
    Expression<T> Function($$ReaderPreferencesTableAnnotationComposer a) f,
  ) {
    final $$ReaderPreferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readerPreferences,
          getReferencedColumn: (t) => t.mediaItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReaderPreferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.readerPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> mangaReaderPreferencesRefs<T extends Object>(
    Expression<T> Function($$MangaReaderPreferencesTableAnnotationComposer a) f,
  ) {
    final $$MangaReaderPreferencesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.mangaReaderPreferences,
          getReferencedColumn: (t) => t.mediaItemId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MangaReaderPreferencesTableAnnotationComposer(
                $db: $db,
                $table: $db.mangaReaderPreferences,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> importRecordsRefs<T extends Object>(
    Expression<T> Function($$ImportRecordsTableAnnotationComposer a) f,
  ) {
    final $$ImportRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.importRecords,
      getReferencedColumn: (t) => t.mediaItemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ImportRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.importRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (MediaItem, $$MediaItemsTableReferences),
          MediaItem,
          PrefetchHooks Function({
            bool contentUnitsRefs,
            bool bookmarksRefs,
            bool libraryEntriesRefs,
            bool readingProgressEntriesRefs,
            bool readerPreferencesRefs,
            bool mangaReaderPreferencesRefs,
            bool importRecordsRefs,
          })
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String?> creator = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverRef = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                mediaType: mediaType,
                title: title,
                subtitle: subtitle,
                creator: creator,
                description: description,
                coverRef: coverRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaType,
                required String title,
                Value<String?> subtitle = const Value.absent(),
                Value<String?> creator = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> coverRef = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                id: id,
                mediaType: mediaType,
                title: title,
                subtitle: subtitle,
                creator: creator,
                description: description,
                coverRef: coverRef,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MediaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                contentUnitsRefs = false,
                bookmarksRefs = false,
                libraryEntriesRefs = false,
                readingProgressEntriesRefs = false,
                readerPreferencesRefs = false,
                mangaReaderPreferencesRefs = false,
                importRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (contentUnitsRefs) db.contentUnits,
                    if (bookmarksRefs) db.bookmarks,
                    if (libraryEntriesRefs) db.libraryEntries,
                    if (readingProgressEntriesRefs) db.readingProgressEntries,
                    if (readerPreferencesRefs) db.readerPreferences,
                    if (mangaReaderPreferencesRefs) db.mangaReaderPreferences,
                    if (importRecordsRefs) db.importRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (contentUnitsRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ContentUnit
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._contentUnitsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).contentUnitsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          Bookmark
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (libraryEntriesRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          LibraryEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._libraryEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).libraryEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingProgressEntriesRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ReadingProgressEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._readingProgressEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).readingProgressEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readerPreferencesRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ReaderPreference
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._readerPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).readerPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mangaReaderPreferencesRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          MangaReaderPreference
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._mangaReaderPreferencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).mangaReaderPreferencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (importRecordsRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ImportRecord
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._importRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).importRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.mediaItemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, $$MediaItemsTableReferences),
      MediaItem,
      PrefetchHooks Function({
        bool contentUnitsRefs,
        bool bookmarksRefs,
        bool libraryEntriesRefs,
        bool readingProgressEntriesRefs,
        bool readerPreferencesRefs,
        bool mangaReaderPreferencesRefs,
        bool importRecordsRefs,
      })
    >;
typedef $$ContentUnitsTableCreateCompanionBuilder =
    ContentUnitsCompanion Function({
      required String id,
      required String mediaItemId,
      required String unitType,
      required String title,
      required int orderIndex,
      required String contentRef,
      required String sourceLocator,
      required String contentHash,
      Value<int> rowid,
    });
typedef $$ContentUnitsTableUpdateCompanionBuilder =
    ContentUnitsCompanion Function({
      Value<String> id,
      Value<String> mediaItemId,
      Value<String> unitType,
      Value<String> title,
      Value<int> orderIndex,
      Value<String> contentRef,
      Value<String> sourceLocator,
      Value<String> contentHash,
      Value<int> rowid,
    });

final class $$ContentUnitsTableReferences
    extends BaseReferences<_$AppDatabase, $ContentUnitsTable, ContentUnit> {
  $$ContentUnitsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias('content_units__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BookmarksTable, List<Bookmark>>
  _bookmarksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookmarks,
    aliasName: 'content_units__id__bookmarks__content_unit_id',
  );

  $$BookmarksTableProcessedTableManager get bookmarksRefs {
    final manager = $$BookmarksTableTableManager(
      $_db,
      $_db.bookmarks,
    ).filter((f) => f.contentUnitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookmarksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MangaPagesTable, List<MangaPage>>
  _mangaPagesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.mangaPages,
    aliasName: 'content_units__id__manga_pages__content_unit_id',
  );

  $$MangaPagesTableProcessedTableManager get mangaPagesRefs {
    final manager = $$MangaPagesTableTableManager(
      $_db,
      $_db.mangaPages,
    ).filter((f) => f.contentUnitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_mangaPagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ReadingProgressEntriesTable,
    List<ReadingProgressEntry>
  >
  _readingProgressEntriesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.readingProgressEntries,
        aliasName: 'content_units__id__reading_progress__content_unit_id',
      );

  $$ReadingProgressEntriesTableProcessedTableManager
  get readingProgressEntriesRefs {
    final manager = $$ReadingProgressEntriesTableTableManager(
      $_db,
      $_db.readingProgressEntries,
    ).filter((f) => f.contentUnitId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _readingProgressEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ContentUnitsTableFilterComposer
    extends Composer<_$AppDatabase, $ContentUnitsTable> {
  $$ContentUnitsTableFilterComposer({
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

  ColumnFilters<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentRef => $composableBuilder(
    column: $table.contentRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLocator => $composableBuilder(
    column: $table.sourceLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> bookmarksRefs(
    Expression<bool> Function($$BookmarksTableFilterComposer f) f,
  ) {
    final $$BookmarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.contentUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableFilterComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> mangaPagesRefs(
    Expression<bool> Function($$MangaPagesTableFilterComposer f) f,
  ) {
    final $$MangaPagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangaPages,
      getReferencedColumn: (t) => t.contentUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangaPagesTableFilterComposer(
            $db: $db,
            $table: $db.mangaPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> readingProgressEntriesRefs(
    Expression<bool> Function($$ReadingProgressEntriesTableFilterComposer f) f,
  ) {
    final $$ReadingProgressEntriesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readingProgressEntries,
          getReferencedColumn: (t) => t.contentUnitId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingProgressEntriesTableFilterComposer(
                $db: $db,
                $table: $db.readingProgressEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContentUnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $ContentUnitsTable> {
  $$ContentUnitsTableOrderingComposer({
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

  ColumnOrderings<String> get unitType => $composableBuilder(
    column: $table.unitType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentRef => $composableBuilder(
    column: $table.contentRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLocator => $composableBuilder(
    column: $table.sourceLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ContentUnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ContentUnitsTable> {
  $$ContentUnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unitType =>
      $composableBuilder(column: $table.unitType, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentRef => $composableBuilder(
    column: $table.contentRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLocator => $composableBuilder(
    column: $table.sourceLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> bookmarksRefs<T extends Object>(
    Expression<T> Function($$BookmarksTableAnnotationComposer a) f,
  ) {
    final $$BookmarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookmarks,
      getReferencedColumn: (t) => t.contentUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookmarksTableAnnotationComposer(
            $db: $db,
            $table: $db.bookmarks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> mangaPagesRefs<T extends Object>(
    Expression<T> Function($$MangaPagesTableAnnotationComposer a) f,
  ) {
    final $$MangaPagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.mangaPages,
      getReferencedColumn: (t) => t.contentUnitId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MangaPagesTableAnnotationComposer(
            $db: $db,
            $table: $db.mangaPages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> readingProgressEntriesRefs<T extends Object>(
    Expression<T> Function($$ReadingProgressEntriesTableAnnotationComposer a) f,
  ) {
    final $$ReadingProgressEntriesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.readingProgressEntries,
          getReferencedColumn: (t) => t.contentUnitId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ReadingProgressEntriesTableAnnotationComposer(
                $db: $db,
                $table: $db.readingProgressEntries,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ContentUnitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ContentUnitsTable,
          ContentUnit,
          $$ContentUnitsTableFilterComposer,
          $$ContentUnitsTableOrderingComposer,
          $$ContentUnitsTableAnnotationComposer,
          $$ContentUnitsTableCreateCompanionBuilder,
          $$ContentUnitsTableUpdateCompanionBuilder,
          (ContentUnit, $$ContentUnitsTableReferences),
          ContentUnit,
          PrefetchHooks Function({
            bool mediaItemId,
            bool bookmarksRefs,
            bool mangaPagesRefs,
            bool readingProgressEntriesRefs,
          })
        > {
  $$ContentUnitsTableTableManager(_$AppDatabase db, $ContentUnitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ContentUnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ContentUnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ContentUnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> unitType = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> contentRef = const Value.absent(),
                Value<String> sourceLocator = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ContentUnitsCompanion(
                id: id,
                mediaItemId: mediaItemId,
                unitType: unitType,
                title: title,
                orderIndex: orderIndex,
                contentRef: contentRef,
                sourceLocator: sourceLocator,
                contentHash: contentHash,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaItemId,
                required String unitType,
                required String title,
                required int orderIndex,
                required String contentRef,
                required String sourceLocator,
                required String contentHash,
                Value<int> rowid = const Value.absent(),
              }) => ContentUnitsCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                unitType: unitType,
                title: title,
                orderIndex: orderIndex,
                contentRef: contentRef,
                sourceLocator: sourceLocator,
                contentHash: contentHash,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ContentUnitsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                mediaItemId = false,
                bookmarksRefs = false,
                mangaPagesRefs = false,
                readingProgressEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (bookmarksRefs) db.bookmarks,
                    if (mangaPagesRefs) db.mangaPages,
                    if (readingProgressEntriesRefs) db.readingProgressEntries,
                  ],
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
                        if (mediaItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mediaItemId,
                                    referencedTable:
                                        $$ContentUnitsTableReferences
                                            ._mediaItemIdTable(db),
                                    referencedColumn:
                                        $$ContentUnitsTableReferences
                                            ._mediaItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (bookmarksRefs)
                        await $_getPrefetchedData<
                          ContentUnit,
                          $ContentUnitsTable,
                          Bookmark
                        >(
                          currentTable: table,
                          referencedTable: $$ContentUnitsTableReferences
                              ._bookmarksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContentUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).bookmarksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contentUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (mangaPagesRefs)
                        await $_getPrefetchedData<
                          ContentUnit,
                          $ContentUnitsTable,
                          MangaPage
                        >(
                          currentTable: table,
                          referencedTable: $$ContentUnitsTableReferences
                              ._mangaPagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContentUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).mangaPagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contentUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (readingProgressEntriesRefs)
                        await $_getPrefetchedData<
                          ContentUnit,
                          $ContentUnitsTable,
                          ReadingProgressEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ContentUnitsTableReferences
                              ._readingProgressEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ContentUnitsTableReferences(
                                db,
                                table,
                                p0,
                              ).readingProgressEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.contentUnitId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ContentUnitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ContentUnitsTable,
      ContentUnit,
      $$ContentUnitsTableFilterComposer,
      $$ContentUnitsTableOrderingComposer,
      $$ContentUnitsTableAnnotationComposer,
      $$ContentUnitsTableCreateCompanionBuilder,
      $$ContentUnitsTableUpdateCompanionBuilder,
      (ContentUnit, $$ContentUnitsTableReferences),
      ContentUnit,
      PrefetchHooks Function({
        bool mediaItemId,
        bool bookmarksRefs,
        bool mangaPagesRefs,
        bool readingProgressEntriesRefs,
      })
    >;
typedef $$BookmarksTableCreateCompanionBuilder =
    BookmarksCompanion Function({
      required String id,
      required String mediaItemId,
      required String contentUnitId,
      required String locator,
      required String label,
      required DateTime createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$BookmarksTableUpdateCompanionBuilder =
    BookmarksCompanion Function({
      Value<String> id,
      Value<String> mediaItemId,
      Value<String> contentUnitId,
      Value<String> locator,
      Value<String> label,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

final class $$BookmarksTableReferences
    extends BaseReferences<_$AppDatabase, $BookmarksTable, Bookmark> {
  $$BookmarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) =>
      db.mediaItems.createAlias('bookmarks__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContentUnitsTable _contentUnitIdTable(_$AppDatabase db) => db
      .contentUnits
      .createAlias('bookmarks__content_unit_id__content_units__id');

  $$ContentUnitsTableProcessedTableManager get contentUnitId {
    final $_column = $_itemColumn<String>('content_unit_id')!;

    final manager = $$ContentUnitsTableTableManager(
      $_db,
      $_db.contentUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contentUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableFilterComposer({
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

  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get deletedAt =>
      $composableBuilder(
        column: $table.deletedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContentUnitsTableFilterComposer get contentUnitId {
    final $$ContentUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableFilterComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableOrderingComposer({
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

  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContentUnitsTableOrderingComposer get contentUnitId {
    final $$ContentUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookmarksTable> {
  $$BookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContentUnitsTableAnnotationComposer get contentUnitId {
    final $$ContentUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookmarksTable,
          Bookmark,
          $$BookmarksTableFilterComposer,
          $$BookmarksTableOrderingComposer,
          $$BookmarksTableAnnotationComposer,
          $$BookmarksTableCreateCompanionBuilder,
          $$BookmarksTableUpdateCompanionBuilder,
          (Bookmark, $$BookmarksTableReferences),
          Bookmark,
          PrefetchHooks Function({bool mediaItemId, bool contentUnitId})
        > {
  $$BookmarksTableTableManager(_$AppDatabase db, $BookmarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> contentUnitId = const Value.absent(),
                Value<String> locator = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion(
                id: id,
                mediaItemId: mediaItemId,
                contentUnitId: contentUnitId,
                locator: locator,
                label: label,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaItemId,
                required String contentUnitId,
                required String locator,
                required String label,
                required DateTime createdAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookmarksCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                contentUnitId: contentUnitId,
                locator: locator,
                label: label,
                createdAt: createdAt,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$BookmarksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mediaItemId = false, contentUnitId = false}) {
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
                        if (mediaItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mediaItemId,
                                    referencedTable: $$BookmarksTableReferences
                                        ._mediaItemIdTable(db),
                                    referencedColumn: $$BookmarksTableReferences
                                        ._mediaItemIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (contentUnitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contentUnitId,
                                    referencedTable: $$BookmarksTableReferences
                                        ._contentUnitIdTable(db),
                                    referencedColumn: $$BookmarksTableReferences
                                        ._contentUnitIdTable(db)
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

typedef $$BookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookmarksTable,
      Bookmark,
      $$BookmarksTableFilterComposer,
      $$BookmarksTableOrderingComposer,
      $$BookmarksTableAnnotationComposer,
      $$BookmarksTableCreateCompanionBuilder,
      $$BookmarksTableUpdateCompanionBuilder,
      (Bookmark, $$BookmarksTableReferences),
      Bookmark,
      PrefetchHooks Function({bool mediaItemId, bool contentUnitId})
    >;
typedef $$LibraryEntriesTableCreateCompanionBuilder =
    LibraryEntriesCompanion Function({
      required String id,
      required String mediaItemId,
      required bool favorite,
      required DateTime addedAt,
      Value<DateTime?> lastOpenedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });
typedef $$LibraryEntriesTableUpdateCompanionBuilder =
    LibraryEntriesCompanion Function({
      Value<String> id,
      Value<String> mediaItemId,
      Value<bool> favorite,
      Value<DateTime> addedAt,
      Value<DateTime?> lastOpenedAt,
      Value<DateTime?> archivedAt,
      Value<int> rowid,
    });

final class $$LibraryEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $LibraryEntriesTable, LibraryEntry> {
  $$LibraryEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias('library_entries__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LibraryEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableFilterComposer({
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

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get addedAt =>
      $composableBuilder(
        column: $table.addedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get lastOpenedAt =>
      $composableBuilder(
        column: $table.lastOpenedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableOrderingComposer({
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

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastOpenedAt => $composableBuilder(
    column: $table.lastOpenedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get archivedAt => $composableBuilder(
    column: $table.archivedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LibraryEntriesTable> {
  $$LibraryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get lastOpenedAt =>
      $composableBuilder(
        column: $table.lastOpenedAt,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<DateTime?, int> get archivedAt =>
      $composableBuilder(
        column: $table.archivedAt,
        builder: (column) => column,
      );

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LibraryEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LibraryEntriesTable,
          LibraryEntry,
          $$LibraryEntriesTableFilterComposer,
          $$LibraryEntriesTableOrderingComposer,
          $$LibraryEntriesTableAnnotationComposer,
          $$LibraryEntriesTableCreateCompanionBuilder,
          $$LibraryEntriesTableUpdateCompanionBuilder,
          (LibraryEntry, $$LibraryEntriesTableReferences),
          LibraryEntry,
          PrefetchHooks Function({bool mediaItemId})
        > {
  $$LibraryEntriesTableTableManager(
    _$AppDatabase db,
    $LibraryEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LibraryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LibraryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LibraryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion(
                id: id,
                mediaItemId: mediaItemId,
                favorite: favorite,
                addedAt: addedAt,
                lastOpenedAt: lastOpenedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaItemId,
                required bool favorite,
                required DateTime addedAt,
                Value<DateTime?> lastOpenedAt = const Value.absent(),
                Value<DateTime?> archivedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LibraryEntriesCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                favorite: favorite,
                addedAt: addedAt,
                lastOpenedAt: lastOpenedAt,
                archivedAt: archivedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LibraryEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemId = false}) {
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
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable: $$LibraryEntriesTableReferences
                                    ._mediaItemIdTable(db),
                                referencedColumn:
                                    $$LibraryEntriesTableReferences
                                        ._mediaItemIdTable(db)
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

typedef $$LibraryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LibraryEntriesTable,
      LibraryEntry,
      $$LibraryEntriesTableFilterComposer,
      $$LibraryEntriesTableOrderingComposer,
      $$LibraryEntriesTableAnnotationComposer,
      $$LibraryEntriesTableCreateCompanionBuilder,
      $$LibraryEntriesTableUpdateCompanionBuilder,
      (LibraryEntry, $$LibraryEntriesTableReferences),
      LibraryEntry,
      PrefetchHooks Function({bool mediaItemId})
    >;
typedef $$MangaPagesTableCreateCompanionBuilder =
    MangaPagesCompanion Function({
      required String id,
      required String contentUnitId,
      required int orderIndex,
      required String contentRef,
      required String sourceLocator,
      required String contentHash,
      required String mimeType,
      required int byteLength,
      Value<int?> pixelWidth,
      Value<int?> pixelHeight,
      Value<int> rowid,
    });
typedef $$MangaPagesTableUpdateCompanionBuilder =
    MangaPagesCompanion Function({
      Value<String> id,
      Value<String> contentUnitId,
      Value<int> orderIndex,
      Value<String> contentRef,
      Value<String> sourceLocator,
      Value<String> contentHash,
      Value<String> mimeType,
      Value<int> byteLength,
      Value<int?> pixelWidth,
      Value<int?> pixelHeight,
      Value<int> rowid,
    });

final class $$MangaPagesTableReferences
    extends BaseReferences<_$AppDatabase, $MangaPagesTable, MangaPage> {
  $$MangaPagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ContentUnitsTable _contentUnitIdTable(_$AppDatabase db) => db
      .contentUnits
      .createAlias('manga_pages__content_unit_id__content_units__id');

  $$ContentUnitsTableProcessedTableManager get contentUnitId {
    final $_column = $_itemColumn<String>('content_unit_id')!;

    final manager = $$ContentUnitsTableTableManager(
      $_db,
      $_db.contentUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contentUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MangaPagesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaPagesTable> {
  $$MangaPagesTableFilterComposer({
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

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentRef => $composableBuilder(
    column: $table.contentRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceLocator => $composableBuilder(
    column: $table.sourceLocator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pixelWidth => $composableBuilder(
    column: $table.pixelWidth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pixelHeight => $composableBuilder(
    column: $table.pixelHeight,
    builder: (column) => ColumnFilters(column),
  );

  $$ContentUnitsTableFilterComposer get contentUnitId {
    final $$ContentUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableFilterComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaPagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaPagesTable> {
  $$MangaPagesTableOrderingComposer({
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

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentRef => $composableBuilder(
    column: $table.contentRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceLocator => $composableBuilder(
    column: $table.sourceLocator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mimeType => $composableBuilder(
    column: $table.mimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pixelWidth => $composableBuilder(
    column: $table.pixelWidth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pixelHeight => $composableBuilder(
    column: $table.pixelHeight,
    builder: (column) => ColumnOrderings(column),
  );

  $$ContentUnitsTableOrderingComposer get contentUnitId {
    final $$ContentUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaPagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaPagesTable> {
  $$MangaPagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentRef => $composableBuilder(
    column: $table.contentRef,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceLocator => $composableBuilder(
    column: $table.sourceLocator,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<int> get byteLength => $composableBuilder(
    column: $table.byteLength,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pixelWidth => $composableBuilder(
    column: $table.pixelWidth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pixelHeight => $composableBuilder(
    column: $table.pixelHeight,
    builder: (column) => column,
  );

  $$ContentUnitsTableAnnotationComposer get contentUnitId {
    final $$ContentUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaPagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangaPagesTable,
          MangaPage,
          $$MangaPagesTableFilterComposer,
          $$MangaPagesTableOrderingComposer,
          $$MangaPagesTableAnnotationComposer,
          $$MangaPagesTableCreateCompanionBuilder,
          $$MangaPagesTableUpdateCompanionBuilder,
          (MangaPage, $$MangaPagesTableReferences),
          MangaPage,
          PrefetchHooks Function({bool contentUnitId})
        > {
  $$MangaPagesTableTableManager(_$AppDatabase db, $MangaPagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaPagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MangaPagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MangaPagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> contentUnitId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<String> contentRef = const Value.absent(),
                Value<String> sourceLocator = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
                Value<String> mimeType = const Value.absent(),
                Value<int> byteLength = const Value.absent(),
                Value<int?> pixelWidth = const Value.absent(),
                Value<int?> pixelHeight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaPagesCompanion(
                id: id,
                contentUnitId: contentUnitId,
                orderIndex: orderIndex,
                contentRef: contentRef,
                sourceLocator: sourceLocator,
                contentHash: contentHash,
                mimeType: mimeType,
                byteLength: byteLength,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String contentUnitId,
                required int orderIndex,
                required String contentRef,
                required String sourceLocator,
                required String contentHash,
                required String mimeType,
                required int byteLength,
                Value<int?> pixelWidth = const Value.absent(),
                Value<int?> pixelHeight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaPagesCompanion.insert(
                id: id,
                contentUnitId: contentUnitId,
                orderIndex: orderIndex,
                contentRef: contentRef,
                sourceLocator: sourceLocator,
                contentHash: contentHash,
                mimeType: mimeType,
                byteLength: byteLength,
                pixelWidth: pixelWidth,
                pixelHeight: pixelHeight,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MangaPagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({contentUnitId = false}) {
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
                    if (contentUnitId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.contentUnitId,
                                referencedTable: $$MangaPagesTableReferences
                                    ._contentUnitIdTable(db),
                                referencedColumn: $$MangaPagesTableReferences
                                    ._contentUnitIdTable(db)
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

typedef $$MangaPagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangaPagesTable,
      MangaPage,
      $$MangaPagesTableFilterComposer,
      $$MangaPagesTableOrderingComposer,
      $$MangaPagesTableAnnotationComposer,
      $$MangaPagesTableCreateCompanionBuilder,
      $$MangaPagesTableUpdateCompanionBuilder,
      (MangaPage, $$MangaPagesTableReferences),
      MangaPage,
      PrefetchHooks Function({bool contentUnitId})
    >;
typedef $$ReadingProgressEntriesTableCreateCompanionBuilder =
    ReadingProgressEntriesCompanion Function({
      required String id,
      required String mediaItemId,
      required String contentUnitId,
      required String locator,
      required double fraction,
      required DateTime updatedAt,
      required int revision,
      Value<int> rowid,
    });
typedef $$ReadingProgressEntriesTableUpdateCompanionBuilder =
    ReadingProgressEntriesCompanion Function({
      Value<String> id,
      Value<String> mediaItemId,
      Value<String> contentUnitId,
      Value<String> locator,
      Value<double> fraction,
      Value<DateTime> updatedAt,
      Value<int> revision,
      Value<int> rowid,
    });

final class $$ReadingProgressEntriesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReadingProgressEntriesTable,
          ReadingProgressEntry
        > {
  $$ReadingProgressEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias('reading_progress__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ContentUnitsTable _contentUnitIdTable(_$AppDatabase db) => db
      .contentUnits
      .createAlias('reading_progress__content_unit_id__content_units__id');

  $$ContentUnitsTableProcessedTableManager get contentUnitId {
    final $_column = $_itemColumn<String>('content_unit_id')!;

    final manager = $$ContentUnitsTableTableManager(
      $_db,
      $_db.contentUnits,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_contentUnitIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingProgressEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingProgressEntriesTable> {
  $$ReadingProgressEntriesTableFilterComposer({
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

  ColumnFilters<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fraction => $composableBuilder(
    column: $table.fraction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContentUnitsTableFilterComposer get contentUnitId {
    final $$ContentUnitsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableFilterComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingProgressEntriesTable> {
  $$ReadingProgressEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get locator => $composableBuilder(
    column: $table.locator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fraction => $composableBuilder(
    column: $table.fraction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContentUnitsTableOrderingComposer get contentUnitId {
    final $$ContentUnitsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableOrderingComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingProgressEntriesTable> {
  $$ReadingProgressEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get locator =>
      $composableBuilder(column: $table.locator, builder: (column) => column);

  GeneratedColumn<double> get fraction =>
      $composableBuilder(column: $table.fraction, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ContentUnitsTableAnnotationComposer get contentUnitId {
    final $$ContentUnitsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.contentUnitId,
      referencedTable: $db.contentUnits,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ContentUnitsTableAnnotationComposer(
            $db: $db,
            $table: $db.contentUnits,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingProgressEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingProgressEntriesTable,
          ReadingProgressEntry,
          $$ReadingProgressEntriesTableFilterComposer,
          $$ReadingProgressEntriesTableOrderingComposer,
          $$ReadingProgressEntriesTableAnnotationComposer,
          $$ReadingProgressEntriesTableCreateCompanionBuilder,
          $$ReadingProgressEntriesTableUpdateCompanionBuilder,
          (ReadingProgressEntry, $$ReadingProgressEntriesTableReferences),
          ReadingProgressEntry,
          PrefetchHooks Function({bool mediaItemId, bool contentUnitId})
        > {
  $$ReadingProgressEntriesTableTableManager(
    _$AppDatabase db,
    $ReadingProgressEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressEntriesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReadingProgressEntriesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingProgressEntriesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> contentUnitId = const Value.absent(),
                Value<String> locator = const Value.absent(),
                Value<double> fraction = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> revision = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressEntriesCompanion(
                id: id,
                mediaItemId: mediaItemId,
                contentUnitId: contentUnitId,
                locator: locator,
                fraction: fraction,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaItemId,
                required String contentUnitId,
                required String locator,
                required double fraction,
                required DateTime updatedAt,
                required int revision,
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressEntriesCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                contentUnitId: contentUnitId,
                locator: locator,
                fraction: fraction,
                updatedAt: updatedAt,
                revision: revision,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReadingProgressEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({mediaItemId = false, contentUnitId = false}) {
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
                        if (mediaItemId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.mediaItemId,
                                    referencedTable:
                                        $$ReadingProgressEntriesTableReferences
                                            ._mediaItemIdTable(db),
                                    referencedColumn:
                                        $$ReadingProgressEntriesTableReferences
                                            ._mediaItemIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (contentUnitId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.contentUnitId,
                                    referencedTable:
                                        $$ReadingProgressEntriesTableReferences
                                            ._contentUnitIdTable(db),
                                    referencedColumn:
                                        $$ReadingProgressEntriesTableReferences
                                            ._contentUnitIdTable(db)
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

typedef $$ReadingProgressEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingProgressEntriesTable,
      ReadingProgressEntry,
      $$ReadingProgressEntriesTableFilterComposer,
      $$ReadingProgressEntriesTableOrderingComposer,
      $$ReadingProgressEntriesTableAnnotationComposer,
      $$ReadingProgressEntriesTableCreateCompanionBuilder,
      $$ReadingProgressEntriesTableUpdateCompanionBuilder,
      (ReadingProgressEntry, $$ReadingProgressEntriesTableReferences),
      ReadingProgressEntry,
      PrefetchHooks Function({bool mediaItemId, bool contentUnitId})
    >;
typedef $$ReaderPreferencesTableCreateCompanionBuilder =
    ReaderPreferencesCompanion Function({
      required String id,
      required String scope,
      Value<String?> mediaItemId,
      Value<double?> fontSize,
      Value<double?> lineHeight,
      Value<String?> themeKey,
      Value<String?> readingMode,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$ReaderPreferencesTableUpdateCompanionBuilder =
    ReaderPreferencesCompanion Function({
      Value<String> id,
      Value<String> scope,
      Value<String?> mediaItemId,
      Value<double?> fontSize,
      Value<double?> lineHeight,
      Value<String?> themeKey,
      Value<String?> readingMode,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$ReaderPreferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ReaderPreferencesTable,
          ReaderPreference
        > {
  $$ReaderPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias('reader_preferences__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager? get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id');
    if ($_column == null) return null;
    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReaderPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $ReaderPreferencesTable> {
  $$ReaderPreferencesTableFilterComposer({
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

  ColumnFilters<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeKey => $composableBuilder(
    column: $table.themeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get readingMode => $composableBuilder(
    column: $table.readingMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $ReaderPreferencesTable> {
  $$ReaderPreferencesTableOrderingComposer({
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

  ColumnOrderings<String> get scope => $composableBuilder(
    column: $table.scope,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fontSize => $composableBuilder(
    column: $table.fontSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeKey => $composableBuilder(
    column: $table.themeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get readingMode => $composableBuilder(
    column: $table.readingMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReaderPreferencesTable> {
  $$ReaderPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get scope =>
      $composableBuilder(column: $table.scope, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<double> get lineHeight => $composableBuilder(
    column: $table.lineHeight,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeKey =>
      $composableBuilder(column: $table.themeKey, builder: (column) => column);

  GeneratedColumn<String> get readingMode => $composableBuilder(
    column: $table.readingMode,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReaderPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReaderPreferencesTable,
          ReaderPreference,
          $$ReaderPreferencesTableFilterComposer,
          $$ReaderPreferencesTableOrderingComposer,
          $$ReaderPreferencesTableAnnotationComposer,
          $$ReaderPreferencesTableCreateCompanionBuilder,
          $$ReaderPreferencesTableUpdateCompanionBuilder,
          (ReaderPreference, $$ReaderPreferencesTableReferences),
          ReaderPreference,
          PrefetchHooks Function({bool mediaItemId})
        > {
  $$ReaderPreferencesTableTableManager(
    _$AppDatabase db,
    $ReaderPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReaderPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReaderPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReaderPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> scope = const Value.absent(),
                Value<String?> mediaItemId = const Value.absent(),
                Value<double?> fontSize = const Value.absent(),
                Value<double?> lineHeight = const Value.absent(),
                Value<String?> themeKey = const Value.absent(),
                Value<String?> readingMode = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReaderPreferencesCompanion(
                id: id,
                scope: scope,
                mediaItemId: mediaItemId,
                fontSize: fontSize,
                lineHeight: lineHeight,
                themeKey: themeKey,
                readingMode: readingMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String scope,
                Value<String?> mediaItemId = const Value.absent(),
                Value<double?> fontSize = const Value.absent(),
                Value<double?> lineHeight = const Value.absent(),
                Value<String?> themeKey = const Value.absent(),
                Value<String?> readingMode = const Value.absent(),
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ReaderPreferencesCompanion.insert(
                id: id,
                scope: scope,
                mediaItemId: mediaItemId,
                fontSize: fontSize,
                lineHeight: lineHeight,
                themeKey: themeKey,
                readingMode: readingMode,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ReaderPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemId = false}) {
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
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable:
                                    $$ReaderPreferencesTableReferences
                                        ._mediaItemIdTable(db),
                                referencedColumn:
                                    $$ReaderPreferencesTableReferences
                                        ._mediaItemIdTable(db)
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

typedef $$ReaderPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReaderPreferencesTable,
      ReaderPreference,
      $$ReaderPreferencesTableFilterComposer,
      $$ReaderPreferencesTableOrderingComposer,
      $$ReaderPreferencesTableAnnotationComposer,
      $$ReaderPreferencesTableCreateCompanionBuilder,
      $$ReaderPreferencesTableUpdateCompanionBuilder,
      (ReaderPreference, $$ReaderPreferencesTableReferences),
      ReaderPreference,
      PrefetchHooks Function({bool mediaItemId})
    >;
typedef $$MangaReaderPreferencesTableCreateCompanionBuilder =
    MangaReaderPreferencesCompanion Function({
      required String id,
      required String mediaItemId,
      required String readingMode,
      required String pageTurnDirection,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MangaReaderPreferencesTableUpdateCompanionBuilder =
    MangaReaderPreferencesCompanion Function({
      Value<String> id,
      Value<String> mediaItemId,
      Value<String> readingMode,
      Value<String> pageTurnDirection,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$MangaReaderPreferencesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MangaReaderPreferencesTable,
          MangaReaderPreference
        > {
  $$MangaReaderPreferencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias('manga_reader_preferences__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MangaReaderPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $MangaReaderPreferencesTable> {
  $$MangaReaderPreferencesTableFilterComposer({
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

  ColumnFilters<String> get readingMode => $composableBuilder(
    column: $table.readingMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pageTurnDirection => $composableBuilder(
    column: $table.pageTurnDirection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get updatedAt =>
      $composableBuilder(
        column: $table.updatedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaReaderPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $MangaReaderPreferencesTable> {
  $$MangaReaderPreferencesTableOrderingComposer({
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

  ColumnOrderings<String> get readingMode => $composableBuilder(
    column: $table.readingMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pageTurnDirection => $composableBuilder(
    column: $table.pageTurnDirection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaReaderPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MangaReaderPreferencesTable> {
  $$MangaReaderPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get readingMode => $composableBuilder(
    column: $table.readingMode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get pageTurnDirection => $composableBuilder(
    column: $table.pageTurnDirection,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MangaReaderPreferencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MangaReaderPreferencesTable,
          MangaReaderPreference,
          $$MangaReaderPreferencesTableFilterComposer,
          $$MangaReaderPreferencesTableOrderingComposer,
          $$MangaReaderPreferencesTableAnnotationComposer,
          $$MangaReaderPreferencesTableCreateCompanionBuilder,
          $$MangaReaderPreferencesTableUpdateCompanionBuilder,
          (MangaReaderPreference, $$MangaReaderPreferencesTableReferences),
          MangaReaderPreference,
          PrefetchHooks Function({bool mediaItemId})
        > {
  $$MangaReaderPreferencesTableTableManager(
    _$AppDatabase db,
    $MangaReaderPreferencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MangaReaderPreferencesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MangaReaderPreferencesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MangaReaderPreferencesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> mediaItemId = const Value.absent(),
                Value<String> readingMode = const Value.absent(),
                Value<String> pageTurnDirection = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MangaReaderPreferencesCompanion(
                id: id,
                mediaItemId: mediaItemId,
                readingMode: readingMode,
                pageTurnDirection: pageTurnDirection,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String mediaItemId,
                required String readingMode,
                required String pageTurnDirection,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MangaReaderPreferencesCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                readingMode: readingMode,
                pageTurnDirection: pageTurnDirection,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MangaReaderPreferencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemId = false}) {
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
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable:
                                    $$MangaReaderPreferencesTableReferences
                                        ._mediaItemIdTable(db),
                                referencedColumn:
                                    $$MangaReaderPreferencesTableReferences
                                        ._mediaItemIdTable(db)
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

typedef $$MangaReaderPreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MangaReaderPreferencesTable,
      MangaReaderPreference,
      $$MangaReaderPreferencesTableFilterComposer,
      $$MangaReaderPreferencesTableOrderingComposer,
      $$MangaReaderPreferencesTableAnnotationComposer,
      $$MangaReaderPreferencesTableCreateCompanionBuilder,
      $$MangaReaderPreferencesTableUpdateCompanionBuilder,
      (MangaReaderPreference, $$MangaReaderPreferencesTableReferences),
      MangaReaderPreference,
      PrefetchHooks Function({bool mediaItemId})
    >;
typedef $$ImportRecordsTableCreateCompanionBuilder =
    ImportRecordsCompanion Function({
      required String id,
      Value<String?> mediaItemId,
      required String sourcePath,
      required String sourceKind,
      required int fileSize,
      Value<DateTime?> modifiedAt,
      required String fingerprint,
      Value<String?> textEncoding,
      required String status,
      Value<String?> errorCode,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ImportRecordsTableUpdateCompanionBuilder =
    ImportRecordsCompanion Function({
      Value<String> id,
      Value<String?> mediaItemId,
      Value<String> sourcePath,
      Value<String> sourceKind,
      Value<int> fileSize,
      Value<DateTime?> modifiedAt,
      Value<String> fingerprint,
      Value<String?> textEncoding,
      Value<String> status,
      Value<String?> errorCode,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$ImportRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $ImportRecordsTable, ImportRecord> {
  $$ImportRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MediaItemsTable _mediaItemIdTable(_$AppDatabase db) => db.mediaItems
      .createAlias('import_records__media_item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager? get mediaItemId {
    final $_column = $_itemColumn<String>('media_item_id');
    if ($_column == null) return null;
    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mediaItemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ImportRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ImportRecordsTable> {
  $$ImportRecordsTableFilterComposer({
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

  ColumnFilters<String> get sourcePath => $composableBuilder(
    column: $table.sourcePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, int> get modifiedAt =>
      $composableBuilder(
        column: $table.modifiedAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get textEncoding => $composableBuilder(
    column: $table.textEncoding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, int> get createdAt =>
      $composableBuilder(
        column: $table.createdAt,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$MediaItemsTableFilterComposer get mediaItemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ImportRecordsTable> {
  $$ImportRecordsTableOrderingComposer({
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

  ColumnOrderings<String> get sourcePath => $composableBuilder(
    column: $table.sourcePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileSize => $composableBuilder(
    column: $table.fileSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get modifiedAt => $composableBuilder(
    column: $table.modifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get textEncoding => $composableBuilder(
    column: $table.textEncoding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorCode => $composableBuilder(
    column: $table.errorCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get mediaItemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ImportRecordsTable> {
  $$ImportRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourcePath => $composableBuilder(
    column: $table.sourcePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceKind => $composableBuilder(
    column: $table.sourceKind,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileSize =>
      $composableBuilder(column: $table.fileSize, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, int> get modifiedAt =>
      $composableBuilder(
        column: $table.modifiedAt,
        builder: (column) => column,
      );

  GeneratedColumn<String> get fingerprint => $composableBuilder(
    column: $table.fingerprint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get textEncoding => $composableBuilder(
    column: $table.textEncoding,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get errorCode =>
      $composableBuilder(column: $table.errorCode, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get mediaItemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.mediaItemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ImportRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ImportRecordsTable,
          ImportRecord,
          $$ImportRecordsTableFilterComposer,
          $$ImportRecordsTableOrderingComposer,
          $$ImportRecordsTableAnnotationComposer,
          $$ImportRecordsTableCreateCompanionBuilder,
          $$ImportRecordsTableUpdateCompanionBuilder,
          (ImportRecord, $$ImportRecordsTableReferences),
          ImportRecord,
          PrefetchHooks Function({bool mediaItemId})
        > {
  $$ImportRecordsTableTableManager(_$AppDatabase db, $ImportRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ImportRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ImportRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ImportRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> mediaItemId = const Value.absent(),
                Value<String> sourcePath = const Value.absent(),
                Value<String> sourceKind = const Value.absent(),
                Value<int> fileSize = const Value.absent(),
                Value<DateTime?> modifiedAt = const Value.absent(),
                Value<String> fingerprint = const Value.absent(),
                Value<String?> textEncoding = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> errorCode = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ImportRecordsCompanion(
                id: id,
                mediaItemId: mediaItemId,
                sourcePath: sourcePath,
                sourceKind: sourceKind,
                fileSize: fileSize,
                modifiedAt: modifiedAt,
                fingerprint: fingerprint,
                textEncoding: textEncoding,
                status: status,
                errorCode: errorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> mediaItemId = const Value.absent(),
                required String sourcePath,
                required String sourceKind,
                required int fileSize,
                Value<DateTime?> modifiedAt = const Value.absent(),
                required String fingerprint,
                Value<String?> textEncoding = const Value.absent(),
                required String status,
                Value<String?> errorCode = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ImportRecordsCompanion.insert(
                id: id,
                mediaItemId: mediaItemId,
                sourcePath: sourcePath,
                sourceKind: sourceKind,
                fileSize: fileSize,
                modifiedAt: modifiedAt,
                fingerprint: fingerprint,
                textEncoding: textEncoding,
                status: status,
                errorCode: errorCode,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ImportRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({mediaItemId = false}) {
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
                    if (mediaItemId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.mediaItemId,
                                referencedTable: $$ImportRecordsTableReferences
                                    ._mediaItemIdTable(db),
                                referencedColumn: $$ImportRecordsTableReferences
                                    ._mediaItemIdTable(db)
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

typedef $$ImportRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ImportRecordsTable,
      ImportRecord,
      $$ImportRecordsTableFilterComposer,
      $$ImportRecordsTableOrderingComposer,
      $$ImportRecordsTableAnnotationComposer,
      $$ImportRecordsTableCreateCompanionBuilder,
      $$ImportRecordsTableUpdateCompanionBuilder,
      (ImportRecord, $$ImportRecordsTableReferences),
      ImportRecord,
      PrefetchHooks Function({bool mediaItemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$ContentUnitsTableTableManager get contentUnits =>
      $$ContentUnitsTableTableManager(_db, _db.contentUnits);
  $$BookmarksTableTableManager get bookmarks =>
      $$BookmarksTableTableManager(_db, _db.bookmarks);
  $$LibraryEntriesTableTableManager get libraryEntries =>
      $$LibraryEntriesTableTableManager(_db, _db.libraryEntries);
  $$MangaPagesTableTableManager get mangaPages =>
      $$MangaPagesTableTableManager(_db, _db.mangaPages);
  $$ReadingProgressEntriesTableTableManager get readingProgressEntries =>
      $$ReadingProgressEntriesTableTableManager(
        _db,
        _db.readingProgressEntries,
      );
  $$ReaderPreferencesTableTableManager get readerPreferences =>
      $$ReaderPreferencesTableTableManager(_db, _db.readerPreferences);
  $$MangaReaderPreferencesTableTableManager get mangaReaderPreferences =>
      $$MangaReaderPreferencesTableTableManager(
        _db,
        _db.mangaReaderPreferences,
      );
  $$ImportRecordsTableTableManager get importRecords =>
      $$ImportRecordsTableTableManager(_db, _db.importRecords);
}
