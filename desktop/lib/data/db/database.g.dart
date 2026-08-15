// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SchoolsTable extends Schools with TableInfo<$SchoolsTable, School> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 200,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameEnMeta = const VerificationMeta('nameEn');
  @override
  late final GeneratedColumn<String> nameEn = GeneratedColumn<String>(
    'name_en',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _logoPathMeta = const VerificationMeta(
    'logoPath',
  );
  @override
  late final GeneratedColumn<String> logoPath = GeneratedColumn<String>(
    'logo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('school'),
  );
  static const VerificationMeta _dayStartMeta = const VerificationMeta(
    'dayStart',
  );
  @override
  late final GeneratedColumn<String> dayStart = GeneratedColumn<String>(
    'day_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('07:30'),
  );
  static const VerificationMeta _dayEndMeta = const VerificationMeta('dayEnd');
  @override
  late final GeneratedColumn<String> dayEnd = GeneratedColumn<String>(
    'day_end',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('12:30'),
  );
  static const VerificationMeta _lateAfterMinutesMeta = const VerificationMeta(
    'lateAfterMinutes',
  );
  @override
  late final GeneratedColumn<int> lateAfterMinutes = GeneratedColumn<int>(
    'late_after_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(15),
  );
  static const VerificationMeta _absentAfterMinutesMeta =
      const VerificationMeta('absentAfterMinutes');
  @override
  late final GeneratedColumn<int> absentAfterMinutes = GeneratedColumn<int>(
    'absent_after_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(45),
  );
  static const VerificationMeta _weekendDaysMeta = const VerificationMeta(
    'weekendDays',
  );
  @override
  late final GeneratedColumn<String> weekendDays = GeneratedColumn<String>(
    'weekend_days',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('4,5'),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    nameEn,
    address,
    phone,
    email,
    logoPath,
    kind,
    dayStart,
    dayEnd,
    lateAfterMinutes,
    absentAfterMinutes,
    weekendDays,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schools';
  @override
  VerificationContext validateIntegrity(
    Insertable<School> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('name_en')) {
      context.handle(
        _nameEnMeta,
        nameEn.isAcceptableOrUnknown(data['name_en']!, _nameEnMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('logo_path')) {
      context.handle(
        _logoPathMeta,
        logoPath.isAcceptableOrUnknown(data['logo_path']!, _logoPathMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('day_start')) {
      context.handle(
        _dayStartMeta,
        dayStart.isAcceptableOrUnknown(data['day_start']!, _dayStartMeta),
      );
    }
    if (data.containsKey('day_end')) {
      context.handle(
        _dayEndMeta,
        dayEnd.isAcceptableOrUnknown(data['day_end']!, _dayEndMeta),
      );
    }
    if (data.containsKey('late_after_minutes')) {
      context.handle(
        _lateAfterMinutesMeta,
        lateAfterMinutes.isAcceptableOrUnknown(
          data['late_after_minutes']!,
          _lateAfterMinutesMeta,
        ),
      );
    }
    if (data.containsKey('absent_after_minutes')) {
      context.handle(
        _absentAfterMinutesMeta,
        absentAfterMinutes.isAcceptableOrUnknown(
          data['absent_after_minutes']!,
          _absentAfterMinutesMeta,
        ),
      );
    }
    if (data.containsKey('weekend_days')) {
      context.handle(
        _weekendDaysMeta,
        weekendDays.isAcceptableOrUnknown(
          data['weekend_days']!,
          _weekendDaysMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  School map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return School(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nameEn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name_en'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      logoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}logo_path'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      dayStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_start'],
      )!,
      dayEnd: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day_end'],
      )!,
      lateAfterMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}late_after_minutes'],
      )!,
      absentAfterMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}absent_after_minutes'],
      )!,
      weekendDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}weekend_days'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SchoolsTable createAlias(String alias) {
    return $SchoolsTable(attachedDatabase, alias);
  }
}

class School extends DataClass implements Insertable<School> {
  final int id;
  final String name;
  final String? nameEn;
  final String? address;
  final String? phone;
  final String? email;
  final String? logoPath;

  /// `school` | `madrasa` | `both` — د حفظ ماډل پرې فعالېږي.
  final String kind;

  /// د درس د پیل او پای وخت — «HH:mm».
  final String dayStart;
  final String dayEnd;

  /// څو دقیقې وروسته «ناوخته» ګڼل کېږي، او څو وروسته «غیرحاضر».
  final int lateAfterMinutes;
  final int absentAfterMinutes;

  /// د اونۍ رخصتي ورځې — د شمېرو لیست، «5,6» (جمعه، پنجشنبه).
  final String weekendDays;
  final DateTime createdAt;
  const School({
    required this.id,
    required this.name,
    this.nameEn,
    this.address,
    this.phone,
    this.email,
    this.logoPath,
    required this.kind,
    required this.dayStart,
    required this.dayEnd,
    required this.lateAfterMinutes,
    required this.absentAfterMinutes,
    required this.weekendDays,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nameEn != null) {
      map['name_en'] = Variable<String>(nameEn);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || logoPath != null) {
      map['logo_path'] = Variable<String>(logoPath);
    }
    map['kind'] = Variable<String>(kind);
    map['day_start'] = Variable<String>(dayStart);
    map['day_end'] = Variable<String>(dayEnd);
    map['late_after_minutes'] = Variable<int>(lateAfterMinutes);
    map['absent_after_minutes'] = Variable<int>(absentAfterMinutes);
    map['weekend_days'] = Variable<String>(weekendDays);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SchoolsCompanion toCompanion(bool nullToAbsent) {
    return SchoolsCompanion(
      id: Value(id),
      name: Value(name),
      nameEn: nameEn == null && nullToAbsent
          ? const Value.absent()
          : Value(nameEn),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      logoPath: logoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(logoPath),
      kind: Value(kind),
      dayStart: Value(dayStart),
      dayEnd: Value(dayEnd),
      lateAfterMinutes: Value(lateAfterMinutes),
      absentAfterMinutes: Value(absentAfterMinutes),
      weekendDays: Value(weekendDays),
      createdAt: Value(createdAt),
    );
  }

  factory School.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return School(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      nameEn: serializer.fromJson<String?>(json['nameEn']),
      address: serializer.fromJson<String?>(json['address']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      logoPath: serializer.fromJson<String?>(json['logoPath']),
      kind: serializer.fromJson<String>(json['kind']),
      dayStart: serializer.fromJson<String>(json['dayStart']),
      dayEnd: serializer.fromJson<String>(json['dayEnd']),
      lateAfterMinutes: serializer.fromJson<int>(json['lateAfterMinutes']),
      absentAfterMinutes: serializer.fromJson<int>(json['absentAfterMinutes']),
      weekendDays: serializer.fromJson<String>(json['weekendDays']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'nameEn': serializer.toJson<String?>(nameEn),
      'address': serializer.toJson<String?>(address),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'logoPath': serializer.toJson<String?>(logoPath),
      'kind': serializer.toJson<String>(kind),
      'dayStart': serializer.toJson<String>(dayStart),
      'dayEnd': serializer.toJson<String>(dayEnd),
      'lateAfterMinutes': serializer.toJson<int>(lateAfterMinutes),
      'absentAfterMinutes': serializer.toJson<int>(absentAfterMinutes),
      'weekendDays': serializer.toJson<String>(weekendDays),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  School copyWith({
    int? id,
    String? name,
    Value<String?> nameEn = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> logoPath = const Value.absent(),
    String? kind,
    String? dayStart,
    String? dayEnd,
    int? lateAfterMinutes,
    int? absentAfterMinutes,
    String? weekendDays,
    DateTime? createdAt,
  }) => School(
    id: id ?? this.id,
    name: name ?? this.name,
    nameEn: nameEn.present ? nameEn.value : this.nameEn,
    address: address.present ? address.value : this.address,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    logoPath: logoPath.present ? logoPath.value : this.logoPath,
    kind: kind ?? this.kind,
    dayStart: dayStart ?? this.dayStart,
    dayEnd: dayEnd ?? this.dayEnd,
    lateAfterMinutes: lateAfterMinutes ?? this.lateAfterMinutes,
    absentAfterMinutes: absentAfterMinutes ?? this.absentAfterMinutes,
    weekendDays: weekendDays ?? this.weekendDays,
    createdAt: createdAt ?? this.createdAt,
  );
  School copyWithCompanion(SchoolsCompanion data) {
    return School(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      nameEn: data.nameEn.present ? data.nameEn.value : this.nameEn,
      address: data.address.present ? data.address.value : this.address,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      logoPath: data.logoPath.present ? data.logoPath.value : this.logoPath,
      kind: data.kind.present ? data.kind.value : this.kind,
      dayStart: data.dayStart.present ? data.dayStart.value : this.dayStart,
      dayEnd: data.dayEnd.present ? data.dayEnd.value : this.dayEnd,
      lateAfterMinutes: data.lateAfterMinutes.present
          ? data.lateAfterMinutes.value
          : this.lateAfterMinutes,
      absentAfterMinutes: data.absentAfterMinutes.present
          ? data.absentAfterMinutes.value
          : this.absentAfterMinutes,
      weekendDays: data.weekendDays.present
          ? data.weekendDays.value
          : this.weekendDays,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('School(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('kind: $kind, ')
          ..write('dayStart: $dayStart, ')
          ..write('dayEnd: $dayEnd, ')
          ..write('lateAfterMinutes: $lateAfterMinutes, ')
          ..write('absentAfterMinutes: $absentAfterMinutes, ')
          ..write('weekendDays: $weekendDays, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    nameEn,
    address,
    phone,
    email,
    logoPath,
    kind,
    dayStart,
    dayEnd,
    lateAfterMinutes,
    absentAfterMinutes,
    weekendDays,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is School &&
          other.id == this.id &&
          other.name == this.name &&
          other.nameEn == this.nameEn &&
          other.address == this.address &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.logoPath == this.logoPath &&
          other.kind == this.kind &&
          other.dayStart == this.dayStart &&
          other.dayEnd == this.dayEnd &&
          other.lateAfterMinutes == this.lateAfterMinutes &&
          other.absentAfterMinutes == this.absentAfterMinutes &&
          other.weekendDays == this.weekendDays &&
          other.createdAt == this.createdAt);
}

class SchoolsCompanion extends UpdateCompanion<School> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> nameEn;
  final Value<String?> address;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> logoPath;
  final Value<String> kind;
  final Value<String> dayStart;
  final Value<String> dayEnd;
  final Value<int> lateAfterMinutes;
  final Value<int> absentAfterMinutes;
  final Value<String> weekendDays;
  final Value<DateTime> createdAt;
  const SchoolsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.nameEn = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.kind = const Value.absent(),
    this.dayStart = const Value.absent(),
    this.dayEnd = const Value.absent(),
    this.lateAfterMinutes = const Value.absent(),
    this.absentAfterMinutes = const Value.absent(),
    this.weekendDays = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SchoolsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.nameEn = const Value.absent(),
    this.address = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.logoPath = const Value.absent(),
    this.kind = const Value.absent(),
    this.dayStart = const Value.absent(),
    this.dayEnd = const Value.absent(),
    this.lateAfterMinutes = const Value.absent(),
    this.absentAfterMinutes = const Value.absent(),
    this.weekendDays = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<School> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? nameEn,
    Expression<String>? address,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? logoPath,
    Expression<String>? kind,
    Expression<String>? dayStart,
    Expression<String>? dayEnd,
    Expression<int>? lateAfterMinutes,
    Expression<int>? absentAfterMinutes,
    Expression<String>? weekendDays,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (nameEn != null) 'name_en': nameEn,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (logoPath != null) 'logo_path': logoPath,
      if (kind != null) 'kind': kind,
      if (dayStart != null) 'day_start': dayStart,
      if (dayEnd != null) 'day_end': dayEnd,
      if (lateAfterMinutes != null) 'late_after_minutes': lateAfterMinutes,
      if (absentAfterMinutes != null)
        'absent_after_minutes': absentAfterMinutes,
      if (weekendDays != null) 'weekend_days': weekendDays,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SchoolsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? nameEn,
    Value<String?>? address,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? logoPath,
    Value<String>? kind,
    Value<String>? dayStart,
    Value<String>? dayEnd,
    Value<int>? lateAfterMinutes,
    Value<int>? absentAfterMinutes,
    Value<String>? weekendDays,
    Value<DateTime>? createdAt,
  }) {
    return SchoolsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      nameEn: nameEn ?? this.nameEn,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      logoPath: logoPath ?? this.logoPath,
      kind: kind ?? this.kind,
      dayStart: dayStart ?? this.dayStart,
      dayEnd: dayEnd ?? this.dayEnd,
      lateAfterMinutes: lateAfterMinutes ?? this.lateAfterMinutes,
      absentAfterMinutes: absentAfterMinutes ?? this.absentAfterMinutes,
      weekendDays: weekendDays ?? this.weekendDays,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nameEn.present) {
      map['name_en'] = Variable<String>(nameEn.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (logoPath.present) {
      map['logo_path'] = Variable<String>(logoPath.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (dayStart.present) {
      map['day_start'] = Variable<String>(dayStart.value);
    }
    if (dayEnd.present) {
      map['day_end'] = Variable<String>(dayEnd.value);
    }
    if (lateAfterMinutes.present) {
      map['late_after_minutes'] = Variable<int>(lateAfterMinutes.value);
    }
    if (absentAfterMinutes.present) {
      map['absent_after_minutes'] = Variable<int>(absentAfterMinutes.value);
    }
    if (weekendDays.present) {
      map['weekend_days'] = Variable<String>(weekendDays.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('nameEn: $nameEn, ')
          ..write('address: $address, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('logoPath: $logoPath, ')
          ..write('kind: $kind, ')
          ..write('dayStart: $dayStart, ')
          ..write('dayEnd: $dayEnd, ')
          ..write('lateAfterMinutes: $lateAfterMinutes, ')
          ..write('absentAfterMinutes: $absentAfterMinutes, ')
          ..write('weekendDays: $weekendDays, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AppUsersTable extends AppUsers with TableInfo<$AppUsersTable, AppUser> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _usernameMeta = const VerificationMeta(
    'username',
  );
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
    'username',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 3,
      maxTextLength: 60,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordHashMeta = const VerificationMeta(
    'passwordHash',
  );
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
    'password_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordSaltMeta = const VerificationMeta(
    'passwordSalt',
  );
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
    'password_salt',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _passwordIterationsMeta =
      const VerificationMeta('passwordIterations');
  @override
  late final GeneratedColumn<int> passwordIterations = GeneratedColumn<int>(
    'password_iterations',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(120000),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _permissionsJsonMeta = const VerificationMeta(
    'permissionsJson',
  );
  @override
  late final GeneratedColumn<String> permissionsJson = GeneratedColumn<String>(
    'permissions_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<int> teacherId = GeneratedColumn<int>(
    'teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _lastLoginAtMeta = const VerificationMeta(
    'lastLoginAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastLoginAt = GeneratedColumn<DateTime>(
    'last_login_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failedAttemptsMeta = const VerificationMeta(
    'failedAttempts',
  );
  @override
  late final GeneratedColumn<int> failedAttempts = GeneratedColumn<int>(
    'failed_attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lockedUntilMeta = const VerificationMeta(
    'lockedUntil',
  );
  @override
  late final GeneratedColumn<DateTime> lockedUntil = GeneratedColumn<DateTime>(
    'locked_until',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    username,
    fullName,
    passwordHash,
    passwordSalt,
    passwordIterations,
    role,
    permissionsJson,
    teacherId,
    isActive,
    lastLoginAt,
    failedAttempts,
    lockedUntil,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_users';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUser> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('username')) {
      context.handle(
        _usernameMeta,
        username.isAcceptableOrUnknown(data['username']!, _usernameMeta),
      );
    } else if (isInserting) {
      context.missing(_usernameMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
        _passwordHashMeta,
        passwordHash.isAcceptableOrUnknown(
          data['password_hash']!,
          _passwordHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordHashMeta);
    }
    if (data.containsKey('password_salt')) {
      context.handle(
        _passwordSaltMeta,
        passwordSalt.isAcceptableOrUnknown(
          data['password_salt']!,
          _passwordSaltMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_passwordSaltMeta);
    }
    if (data.containsKey('password_iterations')) {
      context.handle(
        _passwordIterationsMeta,
        passwordIterations.isAcceptableOrUnknown(
          data['password_iterations']!,
          _passwordIterationsMeta,
        ),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('permissions_json')) {
      context.handle(
        _permissionsJsonMeta,
        permissionsJson.isAcceptableOrUnknown(
          data['permissions_json']!,
          _permissionsJsonMeta,
        ),
      );
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('last_login_at')) {
      context.handle(
        _lastLoginAtMeta,
        lastLoginAt.isAcceptableOrUnknown(
          data['last_login_at']!,
          _lastLoginAtMeta,
        ),
      );
    }
    if (data.containsKey('failed_attempts')) {
      context.handle(
        _failedAttemptsMeta,
        failedAttempts.isAcceptableOrUnknown(
          data['failed_attempts']!,
          _failedAttemptsMeta,
        ),
      );
    }
    if (data.containsKey('locked_until')) {
      context.handle(
        _lockedUntilMeta,
        lockedUntil.isAcceptableOrUnknown(
          data['locked_until']!,
          _lockedUntilMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {username},
  ];
  @override
  AppUser map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUser(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      username: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}username'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      passwordHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_hash'],
      )!,
      passwordSalt: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}password_salt'],
      )!,
      passwordIterations: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}password_iterations'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      permissionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}permissions_json'],
      ),
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}teacher_id'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      lastLoginAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_login_at'],
      ),
      failedAttempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}failed_attempts'],
      )!,
      lockedUntil: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}locked_until'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AppUsersTable createAlias(String alias) {
    return $AppUsersTable(attachedDatabase, alias);
  }
}

class AppUser extends DataClass implements Insertable<AppUser> {
  final int id;
  final String username;
  final String fullName;

  /// PBKDF2-HMAC-SHA256، د مالګې (salt) او تکرارونو سره یو ځای.
  final String passwordHash;
  final String passwordSalt;
  final int passwordIterations;

  /// `admin` | `deputy` | `teacher` | `accountant` | `reception`
  final String role;

  /// د هر ماډل جلا اجازې — JSON، مثلاً {"students":["view","edit"]}.
  /// که تش وي، د رول تر ټاکل شوو اجازو لاندې راځي.
  final String? permissionsJson;
  final int? teacherId;
  final bool isActive;
  final DateTime? lastLoginAt;
  final int failedAttempts;
  final DateTime? lockedUntil;
  final DateTime createdAt;
  const AppUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.passwordHash,
    required this.passwordSalt,
    required this.passwordIterations,
    required this.role,
    this.permissionsJson,
    this.teacherId,
    required this.isActive,
    this.lastLoginAt,
    required this.failedAttempts,
    this.lockedUntil,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['username'] = Variable<String>(username);
    map['full_name'] = Variable<String>(fullName);
    map['password_hash'] = Variable<String>(passwordHash);
    map['password_salt'] = Variable<String>(passwordSalt);
    map['password_iterations'] = Variable<int>(passwordIterations);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || permissionsJson != null) {
      map['permissions_json'] = Variable<String>(permissionsJson);
    }
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<int>(teacherId);
    }
    map['is_active'] = Variable<bool>(isActive);
    if (!nullToAbsent || lastLoginAt != null) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt);
    }
    map['failed_attempts'] = Variable<int>(failedAttempts);
    if (!nullToAbsent || lockedUntil != null) {
      map['locked_until'] = Variable<DateTime>(lockedUntil);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppUsersCompanion toCompanion(bool nullToAbsent) {
    return AppUsersCompanion(
      id: Value(id),
      username: Value(username),
      fullName: Value(fullName),
      passwordHash: Value(passwordHash),
      passwordSalt: Value(passwordSalt),
      passwordIterations: Value(passwordIterations),
      role: Value(role),
      permissionsJson: permissionsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(permissionsJson),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      isActive: Value(isActive),
      lastLoginAt: lastLoginAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastLoginAt),
      failedAttempts: Value(failedAttempts),
      lockedUntil: lockedUntil == null && nullToAbsent
          ? const Value.absent()
          : Value(lockedUntil),
      createdAt: Value(createdAt),
    );
  }

  factory AppUser.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUser(
      id: serializer.fromJson<int>(json['id']),
      username: serializer.fromJson<String>(json['username']),
      fullName: serializer.fromJson<String>(json['fullName']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      passwordSalt: serializer.fromJson<String>(json['passwordSalt']),
      passwordIterations: serializer.fromJson<int>(json['passwordIterations']),
      role: serializer.fromJson<String>(json['role']),
      permissionsJson: serializer.fromJson<String?>(json['permissionsJson']),
      teacherId: serializer.fromJson<int?>(json['teacherId']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      lastLoginAt: serializer.fromJson<DateTime?>(json['lastLoginAt']),
      failedAttempts: serializer.fromJson<int>(json['failedAttempts']),
      lockedUntil: serializer.fromJson<DateTime?>(json['lockedUntil']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'username': serializer.toJson<String>(username),
      'fullName': serializer.toJson<String>(fullName),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'passwordSalt': serializer.toJson<String>(passwordSalt),
      'passwordIterations': serializer.toJson<int>(passwordIterations),
      'role': serializer.toJson<String>(role),
      'permissionsJson': serializer.toJson<String?>(permissionsJson),
      'teacherId': serializer.toJson<int?>(teacherId),
      'isActive': serializer.toJson<bool>(isActive),
      'lastLoginAt': serializer.toJson<DateTime?>(lastLoginAt),
      'failedAttempts': serializer.toJson<int>(failedAttempts),
      'lockedUntil': serializer.toJson<DateTime?>(lockedUntil),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppUser copyWith({
    int? id,
    String? username,
    String? fullName,
    String? passwordHash,
    String? passwordSalt,
    int? passwordIterations,
    String? role,
    Value<String?> permissionsJson = const Value.absent(),
    Value<int?> teacherId = const Value.absent(),
    bool? isActive,
    Value<DateTime?> lastLoginAt = const Value.absent(),
    int? failedAttempts,
    Value<DateTime?> lockedUntil = const Value.absent(),
    DateTime? createdAt,
  }) => AppUser(
    id: id ?? this.id,
    username: username ?? this.username,
    fullName: fullName ?? this.fullName,
    passwordHash: passwordHash ?? this.passwordHash,
    passwordSalt: passwordSalt ?? this.passwordSalt,
    passwordIterations: passwordIterations ?? this.passwordIterations,
    role: role ?? this.role,
    permissionsJson: permissionsJson.present
        ? permissionsJson.value
        : this.permissionsJson,
    teacherId: teacherId.present ? teacherId.value : this.teacherId,
    isActive: isActive ?? this.isActive,
    lastLoginAt: lastLoginAt.present ? lastLoginAt.value : this.lastLoginAt,
    failedAttempts: failedAttempts ?? this.failedAttempts,
    lockedUntil: lockedUntil.present ? lockedUntil.value : this.lockedUntil,
    createdAt: createdAt ?? this.createdAt,
  );
  AppUser copyWithCompanion(AppUsersCompanion data) {
    return AppUser(
      id: data.id.present ? data.id.value : this.id,
      username: data.username.present ? data.username.value : this.username,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      passwordIterations: data.passwordIterations.present
          ? data.passwordIterations.value
          : this.passwordIterations,
      role: data.role.present ? data.role.value : this.role,
      permissionsJson: data.permissionsJson.present
          ? data.permissionsJson.value
          : this.permissionsJson,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      lastLoginAt: data.lastLoginAt.present
          ? data.lastLoginAt.value
          : this.lastLoginAt,
      failedAttempts: data.failedAttempts.present
          ? data.failedAttempts.value
          : this.failedAttempts,
      lockedUntil: data.lockedUntil.present
          ? data.lockedUntil.value
          : this.lockedUntil,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUser(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('role: $role, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('teacherId: $teacherId, ')
          ..write('isActive: $isActive, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    username,
    fullName,
    passwordHash,
    passwordSalt,
    passwordIterations,
    role,
    permissionsJson,
    teacherId,
    isActive,
    lastLoginAt,
    failedAttempts,
    lockedUntil,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUser &&
          other.id == this.id &&
          other.username == this.username &&
          other.fullName == this.fullName &&
          other.passwordHash == this.passwordHash &&
          other.passwordSalt == this.passwordSalt &&
          other.passwordIterations == this.passwordIterations &&
          other.role == this.role &&
          other.permissionsJson == this.permissionsJson &&
          other.teacherId == this.teacherId &&
          other.isActive == this.isActive &&
          other.lastLoginAt == this.lastLoginAt &&
          other.failedAttempts == this.failedAttempts &&
          other.lockedUntil == this.lockedUntil &&
          other.createdAt == this.createdAt);
}

class AppUsersCompanion extends UpdateCompanion<AppUser> {
  final Value<int> id;
  final Value<String> username;
  final Value<String> fullName;
  final Value<String> passwordHash;
  final Value<String> passwordSalt;
  final Value<int> passwordIterations;
  final Value<String> role;
  final Value<String?> permissionsJson;
  final Value<int?> teacherId;
  final Value<bool> isActive;
  final Value<DateTime?> lastLoginAt;
  final Value<int> failedAttempts;
  final Value<DateTime?> lockedUntil;
  final Value<DateTime> createdAt;
  const AppUsersCompanion({
    this.id = const Value.absent(),
    this.username = const Value.absent(),
    this.fullName = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.passwordIterations = const Value.absent(),
    this.role = const Value.absent(),
    this.permissionsJson = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  AppUsersCompanion.insert({
    this.id = const Value.absent(),
    required String username,
    required String fullName,
    required String passwordHash,
    required String passwordSalt,
    this.passwordIterations = const Value.absent(),
    required String role,
    this.permissionsJson = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.isActive = const Value.absent(),
    this.lastLoginAt = const Value.absent(),
    this.failedAttempts = const Value.absent(),
    this.lockedUntil = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : username = Value(username),
       fullName = Value(fullName),
       passwordHash = Value(passwordHash),
       passwordSalt = Value(passwordSalt),
       role = Value(role);
  static Insertable<AppUser> custom({
    Expression<int>? id,
    Expression<String>? username,
    Expression<String>? fullName,
    Expression<String>? passwordHash,
    Expression<String>? passwordSalt,
    Expression<int>? passwordIterations,
    Expression<String>? role,
    Expression<String>? permissionsJson,
    Expression<int>? teacherId,
    Expression<bool>? isActive,
    Expression<DateTime>? lastLoginAt,
    Expression<int>? failedAttempts,
    Expression<DateTime>? lockedUntil,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (username != null) 'username': username,
      if (fullName != null) 'full_name': fullName,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (passwordIterations != null) 'password_iterations': passwordIterations,
      if (role != null) 'role': role,
      if (permissionsJson != null) 'permissions_json': permissionsJson,
      if (teacherId != null) 'teacher_id': teacherId,
      if (isActive != null) 'is_active': isActive,
      if (lastLoginAt != null) 'last_login_at': lastLoginAt,
      if (failedAttempts != null) 'failed_attempts': failedAttempts,
      if (lockedUntil != null) 'locked_until': lockedUntil,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  AppUsersCompanion copyWith({
    Value<int>? id,
    Value<String>? username,
    Value<String>? fullName,
    Value<String>? passwordHash,
    Value<String>? passwordSalt,
    Value<int>? passwordIterations,
    Value<String>? role,
    Value<String?>? permissionsJson,
    Value<int?>? teacherId,
    Value<bool>? isActive,
    Value<DateTime?>? lastLoginAt,
    Value<int>? failedAttempts,
    Value<DateTime?>? lockedUntil,
    Value<DateTime>? createdAt,
  }) {
    return AppUsersCompanion(
      id: id ?? this.id,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      passwordIterations: passwordIterations ?? this.passwordIterations,
      role: role ?? this.role,
      permissionsJson: permissionsJson ?? this.permissionsJson,
      teacherId: teacherId ?? this.teacherId,
      isActive: isActive ?? this.isActive,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil: lockedUntil ?? this.lockedUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (passwordIterations.present) {
      map['password_iterations'] = Variable<int>(passwordIterations.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (permissionsJson.present) {
      map['permissions_json'] = Variable<String>(permissionsJson.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<int>(teacherId.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (lastLoginAt.present) {
      map['last_login_at'] = Variable<DateTime>(lastLoginAt.value);
    }
    if (failedAttempts.present) {
      map['failed_attempts'] = Variable<int>(failedAttempts.value);
    }
    if (lockedUntil.present) {
      map['locked_until'] = Variable<DateTime>(lockedUntil.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsersCompanion(')
          ..write('id: $id, ')
          ..write('username: $username, ')
          ..write('fullName: $fullName, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('passwordIterations: $passwordIterations, ')
          ..write('role: $role, ')
          ..write('permissionsJson: $permissionsJson, ')
          ..write('teacherId: $teacherId, ')
          ..write('isActive: $isActive, ')
          ..write('lastLoginAt: $lastLoginAt, ')
          ..write('failedAttempts: $failedAttempts, ')
          ..write('lockedUntil: $lockedUntil, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AcademicYearsTable extends AcademicYears
    with TableInfo<$AcademicYearsTable, AcademicYear> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcademicYearsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<DateTime> startsOn = GeneratedColumn<DateTime>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<DateTime> endsOn = GeneratedColumn<DateTime>(
    'ends_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCurrentMeta = const VerificationMeta(
    'isCurrent',
  );
  @override
  late final GeneratedColumn<bool> isCurrent = GeneratedColumn<bool>(
    'is_current',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_current" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    label,
    startsOn,
    endsOn,
    isCurrent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'academic_years';
  @override
  VerificationContext validateIntegrity(
    Insertable<AcademicYear> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_endsOnMeta);
    }
    if (data.containsKey('is_current')) {
      context.handle(
        _isCurrentMeta,
        isCurrent.isAcceptableOrUnknown(data['is_current']!, _isCurrentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AcademicYear map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AcademicYear(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_on'],
      )!,
      isCurrent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_current'],
      )!,
    );
  }

  @override
  $AcademicYearsTable createAlias(String alias) {
    return $AcademicYearsTable(attachedDatabase, alias);
  }
}

class AcademicYear extends DataClass implements Insertable<AcademicYear> {
  final int id;

  /// «۱۴۰۵» یا «2026-2027»
  final String label;
  final DateTime startsOn;
  final DateTime endsOn;
  final bool isCurrent;
  const AcademicYear({
    required this.id,
    required this.label,
    required this.startsOn,
    required this.endsOn,
    required this.isCurrent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['label'] = Variable<String>(label);
    map['starts_on'] = Variable<DateTime>(startsOn);
    map['ends_on'] = Variable<DateTime>(endsOn);
    map['is_current'] = Variable<bool>(isCurrent);
    return map;
  }

  AcademicYearsCompanion toCompanion(bool nullToAbsent) {
    return AcademicYearsCompanion(
      id: Value(id),
      label: Value(label),
      startsOn: Value(startsOn),
      endsOn: Value(endsOn),
      isCurrent: Value(isCurrent),
    );
  }

  factory AcademicYear.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AcademicYear(
      id: serializer.fromJson<int>(json['id']),
      label: serializer.fromJson<String>(json['label']),
      startsOn: serializer.fromJson<DateTime>(json['startsOn']),
      endsOn: serializer.fromJson<DateTime>(json['endsOn']),
      isCurrent: serializer.fromJson<bool>(json['isCurrent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'label': serializer.toJson<String>(label),
      'startsOn': serializer.toJson<DateTime>(startsOn),
      'endsOn': serializer.toJson<DateTime>(endsOn),
      'isCurrent': serializer.toJson<bool>(isCurrent),
    };
  }

  AcademicYear copyWith({
    int? id,
    String? label,
    DateTime? startsOn,
    DateTime? endsOn,
    bool? isCurrent,
  }) => AcademicYear(
    id: id ?? this.id,
    label: label ?? this.label,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn ?? this.endsOn,
    isCurrent: isCurrent ?? this.isCurrent,
  );
  AcademicYear copyWithCompanion(AcademicYearsCompanion data) {
    return AcademicYear(
      id: data.id.present ? data.id.value : this.id,
      label: data.label.present ? data.label.value : this.label,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      isCurrent: data.isCurrent.present ? data.isCurrent.value : this.isCurrent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AcademicYear(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, label, startsOn, endsOn, isCurrent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcademicYear &&
          other.id == this.id &&
          other.label == this.label &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.isCurrent == this.isCurrent);
}

class AcademicYearsCompanion extends UpdateCompanion<AcademicYear> {
  final Value<int> id;
  final Value<String> label;
  final Value<DateTime> startsOn;
  final Value<DateTime> endsOn;
  final Value<bool> isCurrent;
  const AcademicYearsCompanion({
    this.id = const Value.absent(),
    this.label = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.isCurrent = const Value.absent(),
  });
  AcademicYearsCompanion.insert({
    this.id = const Value.absent(),
    required String label,
    required DateTime startsOn,
    required DateTime endsOn,
    this.isCurrent = const Value.absent(),
  }) : label = Value(label),
       startsOn = Value(startsOn),
       endsOn = Value(endsOn);
  static Insertable<AcademicYear> custom({
    Expression<int>? id,
    Expression<String>? label,
    Expression<DateTime>? startsOn,
    Expression<DateTime>? endsOn,
    Expression<bool>? isCurrent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (label != null) 'label': label,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (isCurrent != null) 'is_current': isCurrent,
    });
  }

  AcademicYearsCompanion copyWith({
    Value<int>? id,
    Value<String>? label,
    Value<DateTime>? startsOn,
    Value<DateTime>? endsOn,
    Value<bool>? isCurrent,
  }) {
    return AcademicYearsCompanion(
      id: id ?? this.id,
      label: label ?? this.label,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      isCurrent: isCurrent ?? this.isCurrent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<DateTime>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<DateTime>(endsOn.value);
    }
    if (isCurrent.present) {
      map['is_current'] = Variable<bool>(isCurrent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcademicYearsCompanion(')
          ..write('id: $id, ')
          ..write('label: $label, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('isCurrent: $isCurrent')
          ..write(')'))
        .toString();
  }
}

class $GradesTable extends Grades with TableInfo<$GradesTable, Grade> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GradesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  @override
  late final GeneratedColumn<int> level = GeneratedColumn<int>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name, level, sortOrder];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'grades';
  @override
  VerificationContext validateIntegrity(
    Insertable<Grade> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Grade map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Grade(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GradesTable createAlias(String alias) {
    return $GradesTable(attachedDatabase, alias);
  }
}

class Grade extends DataClass implements Insertable<Grade> {
  final int id;
  final String name;
  final int level;
  final int sortOrder;
  const Grade({
    required this.id,
    required this.name,
    required this.level,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['level'] = Variable<int>(level);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GradesCompanion toCompanion(bool nullToAbsent) {
    return GradesCompanion(
      id: Value(id),
      name: Value(name),
      level: Value(level),
      sortOrder: Value(sortOrder),
    );
  }

  factory Grade.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Grade(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      level: serializer.fromJson<int>(json['level']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'level': serializer.toJson<int>(level),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Grade copyWith({int? id, String? name, int? level, int? sortOrder}) => Grade(
    id: id ?? this.id,
    name: name ?? this.name,
    level: level ?? this.level,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Grade copyWithCompanion(GradesCompanion data) {
    return Grade(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      level: data.level.present ? data.level.value : this.level,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Grade(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, level, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Grade &&
          other.id == this.id &&
          other.name == this.name &&
          other.level == this.level &&
          other.sortOrder == this.sortOrder);
}

class GradesCompanion extends UpdateCompanion<Grade> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> level;
  final Value<int> sortOrder;
  const GradesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.level = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  GradesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int level,
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       level = Value(level);
  static Insertable<Grade> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? level,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (level != null) 'level': level,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  GradesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? level,
    Value<int>? sortOrder,
  }) {
    return GradesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      level: level ?? this.level,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (level.present) {
      map['level'] = Variable<int>(level.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GradesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('level: $level, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $SectionsTable extends Sections with TableInfo<$SectionsTable, Section> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SectionsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _gradeIdMeta = const VerificationMeta(
    'gradeId',
  );
  @override
  late final GeneratedColumn<int> gradeId = GeneratedColumn<int>(
    'grade_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grades (id)',
    ),
  );
  static const VerificationMeta _academicYearIdMeta = const VerificationMeta(
    'academicYearId',
  );
  @override
  late final GeneratedColumn<int> academicYearId = GeneratedColumn<int>(
    'academic_year_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES academic_years (id)',
    ),
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
  static const VerificationMeta _capacityMeta = const VerificationMeta(
    'capacity',
  );
  @override
  late final GeneratedColumn<int> capacity = GeneratedColumn<int>(
    'capacity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _headTeacherIdMeta = const VerificationMeta(
    'headTeacherId',
  );
  @override
  late final GeneratedColumn<int> headTeacherId = GeneratedColumn<int>(
    'head_teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gradeId,
    academicYearId,
    name,
    capacity,
    headTeacherId,
    room,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sections';
  @override
  VerificationContext validateIntegrity(
    Insertable<Section> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('grade_id')) {
      context.handle(
        _gradeIdMeta,
        gradeId.isAcceptableOrUnknown(data['grade_id']!, _gradeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeIdMeta);
    }
    if (data.containsKey('academic_year_id')) {
      context.handle(
        _academicYearIdMeta,
        academicYearId.isAcceptableOrUnknown(
          data['academic_year_id']!,
          _academicYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('capacity')) {
      context.handle(
        _capacityMeta,
        capacity.isAcceptableOrUnknown(data['capacity']!, _capacityMeta),
      );
    }
    if (data.containsKey('head_teacher_id')) {
      context.handle(
        _headTeacherIdMeta,
        headTeacherId.isAcceptableOrUnknown(
          data['head_teacher_id']!,
          _headTeacherIdMeta,
        ),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Section map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Section(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      gradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade_id'],
      )!,
      academicYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}academic_year_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      capacity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}capacity'],
      )!,
      headTeacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}head_teacher_id'],
      ),
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
    );
  }

  @override
  $SectionsTable createAlias(String alias) {
    return $SectionsTable(attachedDatabase, alias);
  }
}

class Section extends DataClass implements Insertable<Section> {
  final int id;
  final int gradeId;
  final int academicYearId;
  final String name;
  final int capacity;

  /// د ټولګي مشر استاد.
  final int? headTeacherId;
  final String? room;
  const Section({
    required this.id,
    required this.gradeId,
    required this.academicYearId,
    required this.name,
    required this.capacity,
    this.headTeacherId,
    this.room,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['grade_id'] = Variable<int>(gradeId);
    map['academic_year_id'] = Variable<int>(academicYearId);
    map['name'] = Variable<String>(name);
    map['capacity'] = Variable<int>(capacity);
    if (!nullToAbsent || headTeacherId != null) {
      map['head_teacher_id'] = Variable<int>(headTeacherId);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    return map;
  }

  SectionsCompanion toCompanion(bool nullToAbsent) {
    return SectionsCompanion(
      id: Value(id),
      gradeId: Value(gradeId),
      academicYearId: Value(academicYearId),
      name: Value(name),
      capacity: Value(capacity),
      headTeacherId: headTeacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(headTeacherId),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
    );
  }

  factory Section.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Section(
      id: serializer.fromJson<int>(json['id']),
      gradeId: serializer.fromJson<int>(json['gradeId']),
      academicYearId: serializer.fromJson<int>(json['academicYearId']),
      name: serializer.fromJson<String>(json['name']),
      capacity: serializer.fromJson<int>(json['capacity']),
      headTeacherId: serializer.fromJson<int?>(json['headTeacherId']),
      room: serializer.fromJson<String?>(json['room']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'gradeId': serializer.toJson<int>(gradeId),
      'academicYearId': serializer.toJson<int>(academicYearId),
      'name': serializer.toJson<String>(name),
      'capacity': serializer.toJson<int>(capacity),
      'headTeacherId': serializer.toJson<int?>(headTeacherId),
      'room': serializer.toJson<String?>(room),
    };
  }

  Section copyWith({
    int? id,
    int? gradeId,
    int? academicYearId,
    String? name,
    int? capacity,
    Value<int?> headTeacherId = const Value.absent(),
    Value<String?> room = const Value.absent(),
  }) => Section(
    id: id ?? this.id,
    gradeId: gradeId ?? this.gradeId,
    academicYearId: academicYearId ?? this.academicYearId,
    name: name ?? this.name,
    capacity: capacity ?? this.capacity,
    headTeacherId: headTeacherId.present
        ? headTeacherId.value
        : this.headTeacherId,
    room: room.present ? room.value : this.room,
  );
  Section copyWithCompanion(SectionsCompanion data) {
    return Section(
      id: data.id.present ? data.id.value : this.id,
      gradeId: data.gradeId.present ? data.gradeId.value : this.gradeId,
      academicYearId: data.academicYearId.present
          ? data.academicYearId.value
          : this.academicYearId,
      name: data.name.present ? data.name.value : this.name,
      capacity: data.capacity.present ? data.capacity.value : this.capacity,
      headTeacherId: data.headTeacherId.present
          ? data.headTeacherId.value
          : this.headTeacherId,
      room: data.room.present ? data.room.value : this.room,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Section(')
          ..write('id: $id, ')
          ..write('gradeId: $gradeId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('headTeacherId: $headTeacherId, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gradeId,
    academicYearId,
    name,
    capacity,
    headTeacherId,
    room,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Section &&
          other.id == this.id &&
          other.gradeId == this.gradeId &&
          other.academicYearId == this.academicYearId &&
          other.name == this.name &&
          other.capacity == this.capacity &&
          other.headTeacherId == this.headTeacherId &&
          other.room == this.room);
}

class SectionsCompanion extends UpdateCompanion<Section> {
  final Value<int> id;
  final Value<int> gradeId;
  final Value<int> academicYearId;
  final Value<String> name;
  final Value<int> capacity;
  final Value<int?> headTeacherId;
  final Value<String?> room;
  const SectionsCompanion({
    this.id = const Value.absent(),
    this.gradeId = const Value.absent(),
    this.academicYearId = const Value.absent(),
    this.name = const Value.absent(),
    this.capacity = const Value.absent(),
    this.headTeacherId = const Value.absent(),
    this.room = const Value.absent(),
  });
  SectionsCompanion.insert({
    this.id = const Value.absent(),
    required int gradeId,
    required int academicYearId,
    required String name,
    this.capacity = const Value.absent(),
    this.headTeacherId = const Value.absent(),
    this.room = const Value.absent(),
  }) : gradeId = Value(gradeId),
       academicYearId = Value(academicYearId),
       name = Value(name);
  static Insertable<Section> custom({
    Expression<int>? id,
    Expression<int>? gradeId,
    Expression<int>? academicYearId,
    Expression<String>? name,
    Expression<int>? capacity,
    Expression<int>? headTeacherId,
    Expression<String>? room,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gradeId != null) 'grade_id': gradeId,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (name != null) 'name': name,
      if (capacity != null) 'capacity': capacity,
      if (headTeacherId != null) 'head_teacher_id': headTeacherId,
      if (room != null) 'room': room,
    });
  }

  SectionsCompanion copyWith({
    Value<int>? id,
    Value<int>? gradeId,
    Value<int>? academicYearId,
    Value<String>? name,
    Value<int>? capacity,
    Value<int?>? headTeacherId,
    Value<String?>? room,
  }) {
    return SectionsCompanion(
      id: id ?? this.id,
      gradeId: gradeId ?? this.gradeId,
      academicYearId: academicYearId ?? this.academicYearId,
      name: name ?? this.name,
      capacity: capacity ?? this.capacity,
      headTeacherId: headTeacherId ?? this.headTeacherId,
      room: room ?? this.room,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (gradeId.present) {
      map['grade_id'] = Variable<int>(gradeId.value);
    }
    if (academicYearId.present) {
      map['academic_year_id'] = Variable<int>(academicYearId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (capacity.present) {
      map['capacity'] = Variable<int>(capacity.value);
    }
    if (headTeacherId.present) {
      map['head_teacher_id'] = Variable<int>(headTeacherId.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SectionsCompanion(')
          ..write('id: $id, ')
          ..write('gradeId: $gradeId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('name: $name, ')
          ..write('capacity: $capacity, ')
          ..write('headTeacherId: $headTeacherId, ')
          ..write('room: $room')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gradeIdMeta = const VerificationMeta(
    'gradeId',
  );
  @override
  late final GeneratedColumn<int> gradeId = GeneratedColumn<int>(
    'grade_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grades (id)',
    ),
  );
  static const VerificationMeta _fullMarkMeta = const VerificationMeta(
    'fullMark',
  );
  @override
  late final GeneratedColumn<int> fullMark = GeneratedColumn<int>(
    'full_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _passMarkMeta = const VerificationMeta(
    'passMark',
  );
  @override
  late final GeneratedColumn<int> passMark = GeneratedColumn<int>(
    'pass_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _isReligiousMeta = const VerificationMeta(
    'isReligious',
  );
  @override
  late final GeneratedColumn<bool> isReligious = GeneratedColumn<bool>(
    'is_religious',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_religious" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    code,
    gradeId,
    fullMark,
    passMark,
    isReligious,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    }
    if (data.containsKey('grade_id')) {
      context.handle(
        _gradeIdMeta,
        gradeId.isAcceptableOrUnknown(data['grade_id']!, _gradeIdMeta),
      );
    }
    if (data.containsKey('full_mark')) {
      context.handle(
        _fullMarkMeta,
        fullMark.isAcceptableOrUnknown(data['full_mark']!, _fullMarkMeta),
      );
    }
    if (data.containsKey('pass_mark')) {
      context.handle(
        _passMarkMeta,
        passMark.isAcceptableOrUnknown(data['pass_mark']!, _passMarkMeta),
      );
    }
    if (data.containsKey('is_religious')) {
      context.handle(
        _isReligiousMeta,
        isReligious.isAcceptableOrUnknown(
          data['is_religious']!,
          _isReligiousMeta,
        ),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      ),
      gradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade_id'],
      ),
      fullMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}full_mark'],
      )!,
      passMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_mark'],
      )!,
      isReligious: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_religious'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final int id;
  final String name;
  final String? code;
  final int? gradeId;
  final int fullMark;
  final int passMark;

  /// دیني مضمون دی؟ — د مدرسې د رپوټونو لپاره.
  final bool isReligious;
  final int sortOrder;
  const Subject({
    required this.id,
    required this.name,
    this.code,
    this.gradeId,
    required this.fullMark,
    required this.passMark,
    required this.isReligious,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || code != null) {
      map['code'] = Variable<String>(code);
    }
    if (!nullToAbsent || gradeId != null) {
      map['grade_id'] = Variable<int>(gradeId);
    }
    map['full_mark'] = Variable<int>(fullMark);
    map['pass_mark'] = Variable<int>(passMark);
    map['is_religious'] = Variable<bool>(isReligious);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      code: code == null && nullToAbsent ? const Value.absent() : Value(code),
      gradeId: gradeId == null && nullToAbsent
          ? const Value.absent()
          : Value(gradeId),
      fullMark: Value(fullMark),
      passMark: Value(passMark),
      isReligious: Value(isReligious),
      sortOrder: Value(sortOrder),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      code: serializer.fromJson<String?>(json['code']),
      gradeId: serializer.fromJson<int?>(json['gradeId']),
      fullMark: serializer.fromJson<int>(json['fullMark']),
      passMark: serializer.fromJson<int>(json['passMark']),
      isReligious: serializer.fromJson<bool>(json['isReligious']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'code': serializer.toJson<String?>(code),
      'gradeId': serializer.toJson<int?>(gradeId),
      'fullMark': serializer.toJson<int>(fullMark),
      'passMark': serializer.toJson<int>(passMark),
      'isReligious': serializer.toJson<bool>(isReligious),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Subject copyWith({
    int? id,
    String? name,
    Value<String?> code = const Value.absent(),
    Value<int?> gradeId = const Value.absent(),
    int? fullMark,
    int? passMark,
    bool? isReligious,
    int? sortOrder,
  }) => Subject(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code.present ? code.value : this.code,
    gradeId: gradeId.present ? gradeId.value : this.gradeId,
    fullMark: fullMark ?? this.fullMark,
    passMark: passMark ?? this.passMark,
    isReligious: isReligious ?? this.isReligious,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      code: data.code.present ? data.code.value : this.code,
      gradeId: data.gradeId.present ? data.gradeId.value : this.gradeId,
      fullMark: data.fullMark.present ? data.fullMark.value : this.fullMark,
      passMark: data.passMark.present ? data.passMark.value : this.passMark,
      isReligious: data.isReligious.present
          ? data.isReligious.value
          : this.isReligious,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('gradeId: $gradeId, ')
          ..write('fullMark: $fullMark, ')
          ..write('passMark: $passMark, ')
          ..write('isReligious: $isReligious, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    code,
    gradeId,
    fullMark,
    passMark,
    isReligious,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.name == this.name &&
          other.code == this.code &&
          other.gradeId == this.gradeId &&
          other.fullMark == this.fullMark &&
          other.passMark == this.passMark &&
          other.isReligious == this.isReligious &&
          other.sortOrder == this.sortOrder);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> code;
  final Value<int?> gradeId;
  final Value<int> fullMark;
  final Value<int> passMark;
  final Value<bool> isReligious;
  final Value<int> sortOrder;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.code = const Value.absent(),
    this.gradeId = const Value.absent(),
    this.fullMark = const Value.absent(),
    this.passMark = const Value.absent(),
    this.isReligious = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  SubjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.code = const Value.absent(),
    this.gradeId = const Value.absent(),
    this.fullMark = const Value.absent(),
    this.passMark = const Value.absent(),
    this.isReligious = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Subject> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? code,
    Expression<int>? gradeId,
    Expression<int>? fullMark,
    Expression<int>? passMark,
    Expression<bool>? isReligious,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (code != null) 'code': code,
      if (gradeId != null) 'grade_id': gradeId,
      if (fullMark != null) 'full_mark': fullMark,
      if (passMark != null) 'pass_mark': passMark,
      if (isReligious != null) 'is_religious': isReligious,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  SubjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? code,
    Value<int?>? gradeId,
    Value<int>? fullMark,
    Value<int>? passMark,
    Value<bool>? isReligious,
    Value<int>? sortOrder,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      gradeId: gradeId ?? this.gradeId,
      fullMark: fullMark ?? this.fullMark,
      passMark: passMark ?? this.passMark,
      isReligious: isReligious ?? this.isReligious,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (gradeId.present) {
      map['grade_id'] = Variable<int>(gradeId.value);
    }
    if (fullMark.present) {
      map['full_mark'] = Variable<int>(fullMark.value);
    }
    if (passMark.present) {
      map['pass_mark'] = Variable<int>(passMark.value);
    }
    if (isReligious.present) {
      map['is_religious'] = Variable<bool>(isReligious.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('code: $code, ')
          ..write('gradeId: $gradeId, ')
          ..write('fullMark: $fullMark, ')
          ..write('passMark: $passMark, ')
          ..write('isReligious: $isReligious, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _admissionNoMeta = const VerificationMeta(
    'admissionNo',
  );
  @override
  late final GeneratedColumn<String> admissionNo = GeneratedColumn<String>(
    'admission_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstNameMeta = const VerificationMeta(
    'firstName',
  );
  @override
  late final GeneratedColumn<String> firstName = GeneratedColumn<String>(
    'first_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _grandFatherNameMeta = const VerificationMeta(
    'grandFatherName',
  );
  @override
  late final GeneratedColumn<String> grandFatherName = GeneratedColumn<String>(
    'grand_father_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDateMeta = const VerificationMeta(
    'birthDate',
  );
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
    'birth_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _birthPlaceMeta = const VerificationMeta(
    'birthPlace',
  );
  @override
  late final GeneratedColumn<String> birthPlace = GeneratedColumn<String>(
    'birth_place',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bloodGroupMeta = const VerificationMeta(
    'bloodGroup',
  );
  @override
  late final GeneratedColumn<String> bloodGroup = GeneratedColumn<String>(
    'blood_group',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _medicalNotesMeta = const VerificationMeta(
    'medicalNotes',
  );
  @override
  late final GeneratedColumn<String> medicalNotes = GeneratedColumn<String>(
    'medical_notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _admittedOnMeta = const VerificationMeta(
    'admittedOn',
  );
  @override
  late final GeneratedColumn<DateTime> admittedOn = GeneratedColumn<DateTime>(
    'admitted_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _qrSecretMeta = const VerificationMeta(
    'qrSecret',
  );
  @override
  late final GeneratedColumn<String> qrSecret = GeneratedColumn<String>(
    'qr_secret',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardVersionMeta = const VerificationMeta(
    'cardVersion',
  );
  @override
  late final GeneratedColumn<int> cardVersion = GeneratedColumn<int>(
    'card_version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    admissionNo,
    firstName,
    lastName,
    fatherName,
    grandFatherName,
    gender,
    birthDate,
    birthPlace,
    nationalId,
    photoPath,
    phone,
    address,
    bloodGroup,
    medicalNotes,
    admittedOn,
    status,
    qrSecret,
    cardVersion,
    createdAt,
    updatedAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('admission_no')) {
      context.handle(
        _admissionNoMeta,
        admissionNo.isAcceptableOrUnknown(
          data['admission_no']!,
          _admissionNoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_admissionNoMeta);
    }
    if (data.containsKey('first_name')) {
      context.handle(
        _firstNameMeta,
        firstName.isAcceptableOrUnknown(data['first_name']!, _firstNameMeta),
      );
    } else if (isInserting) {
      context.missing(_firstNameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fatherNameMeta);
    }
    if (data.containsKey('grand_father_name')) {
      context.handle(
        _grandFatherNameMeta,
        grandFatherName.isAcceptableOrUnknown(
          data['grand_father_name']!,
          _grandFatherNameMeta,
        ),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('birth_date')) {
      context.handle(
        _birthDateMeta,
        birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta),
      );
    }
    if (data.containsKey('birth_place')) {
      context.handle(
        _birthPlaceMeta,
        birthPlace.isAcceptableOrUnknown(data['birth_place']!, _birthPlaceMeta),
      );
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('blood_group')) {
      context.handle(
        _bloodGroupMeta,
        bloodGroup.isAcceptableOrUnknown(data['blood_group']!, _bloodGroupMeta),
      );
    }
    if (data.containsKey('medical_notes')) {
      context.handle(
        _medicalNotesMeta,
        medicalNotes.isAcceptableOrUnknown(
          data['medical_notes']!,
          _medicalNotesMeta,
        ),
      );
    }
    if (data.containsKey('admitted_on')) {
      context.handle(
        _admittedOnMeta,
        admittedOn.isAcceptableOrUnknown(data['admitted_on']!, _admittedOnMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('qr_secret')) {
      context.handle(
        _qrSecretMeta,
        qrSecret.isAcceptableOrUnknown(data['qr_secret']!, _qrSecretMeta),
      );
    }
    if (data.containsKey('card_version')) {
      context.handle(
        _cardVersionMeta,
        cardVersion.isAcceptableOrUnknown(
          data['card_version']!,
          _cardVersionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {admissionNo},
  ];
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      admissionNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}admission_no'],
      )!,
      firstName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_name'],
      )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      )!,
      grandFatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}grand_father_name'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      birthDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}birth_date'],
      ),
      birthPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}birth_place'],
      ),
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      bloodGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}blood_group'],
      ),
      medicalNotes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}medical_notes'],
      ),
      admittedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}admitted_on'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      qrSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_secret'],
      ),
      cardVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}card_version'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final int id;

  /// هغه نمبر چې په آی‌ډي کارت او حاضرۍ کې کارېږي.
  final String admissionNo;
  final String firstName;
  final String? lastName;
  final String fatherName;
  final String? grandFatherName;

  /// `male` | `female`
  final String gender;
  final DateTime? birthDate;
  final String? birthPlace;
  final String? nationalId;
  final String? photoPath;
  final String? phone;
  final String? address;
  final String? bloodGroup;
  final String? medicalNotes;
  final DateTime admittedOn;

  /// `active` | `graduated` | `transferred` | `dropped` | `suspended`
  final String status;

  /// د QR کارت لپاره پټ کلید — د جعلي کارت مخنیوی کوي.
  /// کارت خپله نمبر نه، بلکې د دې کلید لاسلیک وړي.
  final String? qrSecret;
  final int cardVersion;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// ړنګول = پټول. ریکارډ هېڅکله له منځه نه ځي.
  final DateTime? deletedAt;
  const Student({
    required this.id,
    required this.admissionNo,
    required this.firstName,
    this.lastName,
    required this.fatherName,
    this.grandFatherName,
    required this.gender,
    this.birthDate,
    this.birthPlace,
    this.nationalId,
    this.photoPath,
    this.phone,
    this.address,
    this.bloodGroup,
    this.medicalNotes,
    required this.admittedOn,
    required this.status,
    this.qrSecret,
    required this.cardVersion,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['admission_no'] = Variable<String>(admissionNo);
    map['first_name'] = Variable<String>(firstName);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    map['father_name'] = Variable<String>(fatherName);
    if (!nullToAbsent || grandFatherName != null) {
      map['grand_father_name'] = Variable<String>(grandFatherName);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || birthPlace != null) {
      map['birth_place'] = Variable<String>(birthPlace);
    }
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || bloodGroup != null) {
      map['blood_group'] = Variable<String>(bloodGroup);
    }
    if (!nullToAbsent || medicalNotes != null) {
      map['medical_notes'] = Variable<String>(medicalNotes);
    }
    map['admitted_on'] = Variable<DateTime>(admittedOn);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || qrSecret != null) {
      map['qr_secret'] = Variable<String>(qrSecret);
    }
    map['card_version'] = Variable<int>(cardVersion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      admissionNo: Value(admissionNo),
      firstName: Value(firstName),
      lastName: lastName == null && nullToAbsent
          ? const Value.absent()
          : Value(lastName),
      fatherName: Value(fatherName),
      grandFatherName: grandFatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(grandFatherName),
      gender: Value(gender),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      birthPlace: birthPlace == null && nullToAbsent
          ? const Value.absent()
          : Value(birthPlace),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      bloodGroup: bloodGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(bloodGroup),
      medicalNotes: medicalNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(medicalNotes),
      admittedOn: Value(admittedOn),
      status: Value(status),
      qrSecret: qrSecret == null && nullToAbsent
          ? const Value.absent()
          : Value(qrSecret),
      cardVersion: Value(cardVersion),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<int>(json['id']),
      admissionNo: serializer.fromJson<String>(json['admissionNo']),
      firstName: serializer.fromJson<String>(json['firstName']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      fatherName: serializer.fromJson<String>(json['fatherName']),
      grandFatherName: serializer.fromJson<String?>(json['grandFatherName']),
      gender: serializer.fromJson<String>(json['gender']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      birthPlace: serializer.fromJson<String?>(json['birthPlace']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      bloodGroup: serializer.fromJson<String?>(json['bloodGroup']),
      medicalNotes: serializer.fromJson<String?>(json['medicalNotes']),
      admittedOn: serializer.fromJson<DateTime>(json['admittedOn']),
      status: serializer.fromJson<String>(json['status']),
      qrSecret: serializer.fromJson<String?>(json['qrSecret']),
      cardVersion: serializer.fromJson<int>(json['cardVersion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'admissionNo': serializer.toJson<String>(admissionNo),
      'firstName': serializer.toJson<String>(firstName),
      'lastName': serializer.toJson<String?>(lastName),
      'fatherName': serializer.toJson<String>(fatherName),
      'grandFatherName': serializer.toJson<String?>(grandFatherName),
      'gender': serializer.toJson<String>(gender),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'birthPlace': serializer.toJson<String?>(birthPlace),
      'nationalId': serializer.toJson<String?>(nationalId),
      'photoPath': serializer.toJson<String?>(photoPath),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'bloodGroup': serializer.toJson<String?>(bloodGroup),
      'medicalNotes': serializer.toJson<String?>(medicalNotes),
      'admittedOn': serializer.toJson<DateTime>(admittedOn),
      'status': serializer.toJson<String>(status),
      'qrSecret': serializer.toJson<String?>(qrSecret),
      'cardVersion': serializer.toJson<int>(cardVersion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Student copyWith({
    int? id,
    String? admissionNo,
    String? firstName,
    Value<String?> lastName = const Value.absent(),
    String? fatherName,
    Value<String?> grandFatherName = const Value.absent(),
    String? gender,
    Value<DateTime?> birthDate = const Value.absent(),
    Value<String?> birthPlace = const Value.absent(),
    Value<String?> nationalId = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> bloodGroup = const Value.absent(),
    Value<String?> medicalNotes = const Value.absent(),
    DateTime? admittedOn,
    String? status,
    Value<String?> qrSecret = const Value.absent(),
    int? cardVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Student(
    id: id ?? this.id,
    admissionNo: admissionNo ?? this.admissionNo,
    firstName: firstName ?? this.firstName,
    lastName: lastName.present ? lastName.value : this.lastName,
    fatherName: fatherName ?? this.fatherName,
    grandFatherName: grandFatherName.present
        ? grandFatherName.value
        : this.grandFatherName,
    gender: gender ?? this.gender,
    birthDate: birthDate.present ? birthDate.value : this.birthDate,
    birthPlace: birthPlace.present ? birthPlace.value : this.birthPlace,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    bloodGroup: bloodGroup.present ? bloodGroup.value : this.bloodGroup,
    medicalNotes: medicalNotes.present ? medicalNotes.value : this.medicalNotes,
    admittedOn: admittedOn ?? this.admittedOn,
    status: status ?? this.status,
    qrSecret: qrSecret.present ? qrSecret.value : this.qrSecret,
    cardVersion: cardVersion ?? this.cardVersion,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      admissionNo: data.admissionNo.present
          ? data.admissionNo.value
          : this.admissionNo,
      firstName: data.firstName.present ? data.firstName.value : this.firstName,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      grandFatherName: data.grandFatherName.present
          ? data.grandFatherName.value
          : this.grandFatherName,
      gender: data.gender.present ? data.gender.value : this.gender,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      birthPlace: data.birthPlace.present
          ? data.birthPlace.value
          : this.birthPlace,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      bloodGroup: data.bloodGroup.present
          ? data.bloodGroup.value
          : this.bloodGroup,
      medicalNotes: data.medicalNotes.present
          ? data.medicalNotes.value
          : this.medicalNotes,
      admittedOn: data.admittedOn.present
          ? data.admittedOn.value
          : this.admittedOn,
      status: data.status.present ? data.status.value : this.status,
      qrSecret: data.qrSecret.present ? data.qrSecret.value : this.qrSecret,
      cardVersion: data.cardVersion.present
          ? data.cardVersion.value
          : this.cardVersion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('admissionNo: $admissionNo, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('nationalId: $nationalId, ')
          ..write('photoPath: $photoPath, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('medicalNotes: $medicalNotes, ')
          ..write('admittedOn: $admittedOn, ')
          ..write('status: $status, ')
          ..write('qrSecret: $qrSecret, ')
          ..write('cardVersion: $cardVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    admissionNo,
    firstName,
    lastName,
    fatherName,
    grandFatherName,
    gender,
    birthDate,
    birthPlace,
    nationalId,
    photoPath,
    phone,
    address,
    bloodGroup,
    medicalNotes,
    admittedOn,
    status,
    qrSecret,
    cardVersion,
    createdAt,
    updatedAt,
    deletedAt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.admissionNo == this.admissionNo &&
          other.firstName == this.firstName &&
          other.lastName == this.lastName &&
          other.fatherName == this.fatherName &&
          other.grandFatherName == this.grandFatherName &&
          other.gender == this.gender &&
          other.birthDate == this.birthDate &&
          other.birthPlace == this.birthPlace &&
          other.nationalId == this.nationalId &&
          other.photoPath == this.photoPath &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.bloodGroup == this.bloodGroup &&
          other.medicalNotes == this.medicalNotes &&
          other.admittedOn == this.admittedOn &&
          other.status == this.status &&
          other.qrSecret == this.qrSecret &&
          other.cardVersion == this.cardVersion &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<int> id;
  final Value<String> admissionNo;
  final Value<String> firstName;
  final Value<String?> lastName;
  final Value<String> fatherName;
  final Value<String?> grandFatherName;
  final Value<String> gender;
  final Value<DateTime?> birthDate;
  final Value<String?> birthPlace;
  final Value<String?> nationalId;
  final Value<String?> photoPath;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> bloodGroup;
  final Value<String?> medicalNotes;
  final Value<DateTime> admittedOn;
  final Value<String> status;
  final Value<String?> qrSecret;
  final Value<int> cardVersion;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.admissionNo = const Value.absent(),
    this.firstName = const Value.absent(),
    this.lastName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.grandFatherName = const Value.absent(),
    this.gender = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.medicalNotes = const Value.absent(),
    this.admittedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.qrSecret = const Value.absent(),
    this.cardVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  StudentsCompanion.insert({
    this.id = const Value.absent(),
    required String admissionNo,
    required String firstName,
    this.lastName = const Value.absent(),
    required String fatherName,
    this.grandFatherName = const Value.absent(),
    required String gender,
    this.birthDate = const Value.absent(),
    this.birthPlace = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.bloodGroup = const Value.absent(),
    this.medicalNotes = const Value.absent(),
    this.admittedOn = const Value.absent(),
    this.status = const Value.absent(),
    this.qrSecret = const Value.absent(),
    this.cardVersion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : admissionNo = Value(admissionNo),
       firstName = Value(firstName),
       fatherName = Value(fatherName),
       gender = Value(gender);
  static Insertable<Student> custom({
    Expression<int>? id,
    Expression<String>? admissionNo,
    Expression<String>? firstName,
    Expression<String>? lastName,
    Expression<String>? fatherName,
    Expression<String>? grandFatherName,
    Expression<String>? gender,
    Expression<DateTime>? birthDate,
    Expression<String>? birthPlace,
    Expression<String>? nationalId,
    Expression<String>? photoPath,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? bloodGroup,
    Expression<String>? medicalNotes,
    Expression<DateTime>? admittedOn,
    Expression<String>? status,
    Expression<String>? qrSecret,
    Expression<int>? cardVersion,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (admissionNo != null) 'admission_no': admissionNo,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (fatherName != null) 'father_name': fatherName,
      if (grandFatherName != null) 'grand_father_name': grandFatherName,
      if (gender != null) 'gender': gender,
      if (birthDate != null) 'birth_date': birthDate,
      if (birthPlace != null) 'birth_place': birthPlace,
      if (nationalId != null) 'national_id': nationalId,
      if (photoPath != null) 'photo_path': photoPath,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (bloodGroup != null) 'blood_group': bloodGroup,
      if (medicalNotes != null) 'medical_notes': medicalNotes,
      if (admittedOn != null) 'admitted_on': admittedOn,
      if (status != null) 'status': status,
      if (qrSecret != null) 'qr_secret': qrSecret,
      if (cardVersion != null) 'card_version': cardVersion,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  StudentsCompanion copyWith({
    Value<int>? id,
    Value<String>? admissionNo,
    Value<String>? firstName,
    Value<String?>? lastName,
    Value<String>? fatherName,
    Value<String?>? grandFatherName,
    Value<String>? gender,
    Value<DateTime?>? birthDate,
    Value<String?>? birthPlace,
    Value<String?>? nationalId,
    Value<String?>? photoPath,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? bloodGroup,
    Value<String?>? medicalNotes,
    Value<DateTime>? admittedOn,
    Value<String>? status,
    Value<String?>? qrSecret,
    Value<int>? cardVersion,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      admissionNo: admissionNo ?? this.admissionNo,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      fatherName: fatherName ?? this.fatherName,
      grandFatherName: grandFatherName ?? this.grandFatherName,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
      birthPlace: birthPlace ?? this.birthPlace,
      nationalId: nationalId ?? this.nationalId,
      photoPath: photoPath ?? this.photoPath,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      medicalNotes: medicalNotes ?? this.medicalNotes,
      admittedOn: admittedOn ?? this.admittedOn,
      status: status ?? this.status,
      qrSecret: qrSecret ?? this.qrSecret,
      cardVersion: cardVersion ?? this.cardVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (admissionNo.present) {
      map['admission_no'] = Variable<String>(admissionNo.value);
    }
    if (firstName.present) {
      map['first_name'] = Variable<String>(firstName.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (grandFatherName.present) {
      map['grand_father_name'] = Variable<String>(grandFatherName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (birthPlace.present) {
      map['birth_place'] = Variable<String>(birthPlace.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (bloodGroup.present) {
      map['blood_group'] = Variable<String>(bloodGroup.value);
    }
    if (medicalNotes.present) {
      map['medical_notes'] = Variable<String>(medicalNotes.value);
    }
    if (admittedOn.present) {
      map['admitted_on'] = Variable<DateTime>(admittedOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (qrSecret.present) {
      map['qr_secret'] = Variable<String>(qrSecret.value);
    }
    if (cardVersion.present) {
      map['card_version'] = Variable<int>(cardVersion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('admissionNo: $admissionNo, ')
          ..write('firstName: $firstName, ')
          ..write('lastName: $lastName, ')
          ..write('fatherName: $fatherName, ')
          ..write('grandFatherName: $grandFatherName, ')
          ..write('gender: $gender, ')
          ..write('birthDate: $birthDate, ')
          ..write('birthPlace: $birthPlace, ')
          ..write('nationalId: $nationalId, ')
          ..write('photoPath: $photoPath, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('bloodGroup: $bloodGroup, ')
          ..write('medicalNotes: $medicalNotes, ')
          ..write('admittedOn: $admittedOn, ')
          ..write('status: $status, ')
          ..write('qrSecret: $qrSecret, ')
          ..write('cardVersion: $cardVersion, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $GuardiansTable extends Guardians
    with TableInfo<$GuardiansTable, Guardian> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GuardiansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _relationMeta = const VerificationMeta(
    'relation',
  );
  @override
  late final GeneratedColumn<String> relation = GeneratedColumn<String>(
    'relation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altPhoneMeta = const VerificationMeta(
    'altPhone',
  );
  @override
  late final GeneratedColumn<String> altPhone = GeneratedColumn<String>(
    'alt_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occupationMeta = const VerificationMeta(
    'occupation',
  );
  @override
  late final GeneratedColumn<String> occupation = GeneratedColumn<String>(
    'occupation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nationalIdMeta = const VerificationMeta(
    'nationalId',
  );
  @override
  late final GeneratedColumn<String> nationalId = GeneratedColumn<String>(
    'national_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appLoginCodeMeta = const VerificationMeta(
    'appLoginCode',
  );
  @override
  late final GeneratedColumn<String> appLoginCode = GeneratedColumn<String>(
    'app_login_code',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fcmTokenMeta = const VerificationMeta(
    'fcmToken',
  );
  @override
  late final GeneratedColumn<String> fcmToken = GeneratedColumn<String>(
    'fcm_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preferredChannelMeta = const VerificationMeta(
    'preferredChannel',
  );
  @override
  late final GeneratedColumn<String> preferredChannel = GeneratedColumn<String>(
    'preferred_channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('sms'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    fullName,
    relation,
    phone,
    altPhone,
    occupation,
    nationalId,
    address,
    appLoginCode,
    fcmToken,
    preferredChannel,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'guardians';
  @override
  VerificationContext validateIntegrity(
    Insertable<Guardian> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('relation')) {
      context.handle(
        _relationMeta,
        relation.isAcceptableOrUnknown(data['relation']!, _relationMeta),
      );
    } else if (isInserting) {
      context.missing(_relationMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('alt_phone')) {
      context.handle(
        _altPhoneMeta,
        altPhone.isAcceptableOrUnknown(data['alt_phone']!, _altPhoneMeta),
      );
    }
    if (data.containsKey('occupation')) {
      context.handle(
        _occupationMeta,
        occupation.isAcceptableOrUnknown(data['occupation']!, _occupationMeta),
      );
    }
    if (data.containsKey('national_id')) {
      context.handle(
        _nationalIdMeta,
        nationalId.isAcceptableOrUnknown(data['national_id']!, _nationalIdMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('app_login_code')) {
      context.handle(
        _appLoginCodeMeta,
        appLoginCode.isAcceptableOrUnknown(
          data['app_login_code']!,
          _appLoginCodeMeta,
        ),
      );
    }
    if (data.containsKey('fcm_token')) {
      context.handle(
        _fcmTokenMeta,
        fcmToken.isAcceptableOrUnknown(data['fcm_token']!, _fcmTokenMeta),
      );
    }
    if (data.containsKey('preferred_channel')) {
      context.handle(
        _preferredChannelMeta,
        preferredChannel.isAcceptableOrUnknown(
          data['preferred_channel']!,
          _preferredChannelMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Guardian map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Guardian(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      relation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relation'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      altPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alt_phone'],
      ),
      occupation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occupation'],
      ),
      nationalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}national_id'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      appLoginCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_login_code'],
      ),
      fcmToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fcm_token'],
      ),
      preferredChannel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_channel'],
      )!,
    );
  }

  @override
  $GuardiansTable createAlias(String alias) {
    return $GuardiansTable(attachedDatabase, alias);
  }
}

class Guardian extends DataClass implements Insertable<Guardian> {
  final int id;
  final String fullName;

  /// `father` | `mother` | `brother` | `uncle` | `other`
  final String relation;
  final String? phone;
  final String? altPhone;
  final String? occupation;
  final String? nationalId;
  final String? address;

  /// د والدینو اپ ته د ننوتلو لپاره.
  final String? appLoginCode;
  final String? fcmToken;

  /// کوم کانال ته پیغام ولېږل شي: `app` | `sms` | `whatsapp` | `none`
  final String preferredChannel;
  const Guardian({
    required this.id,
    required this.fullName,
    required this.relation,
    this.phone,
    this.altPhone,
    this.occupation,
    this.nationalId,
    this.address,
    this.appLoginCode,
    this.fcmToken,
    required this.preferredChannel,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['full_name'] = Variable<String>(fullName);
    map['relation'] = Variable<String>(relation);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || altPhone != null) {
      map['alt_phone'] = Variable<String>(altPhone);
    }
    if (!nullToAbsent || occupation != null) {
      map['occupation'] = Variable<String>(occupation);
    }
    if (!nullToAbsent || nationalId != null) {
      map['national_id'] = Variable<String>(nationalId);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || appLoginCode != null) {
      map['app_login_code'] = Variable<String>(appLoginCode);
    }
    if (!nullToAbsent || fcmToken != null) {
      map['fcm_token'] = Variable<String>(fcmToken);
    }
    map['preferred_channel'] = Variable<String>(preferredChannel);
    return map;
  }

  GuardiansCompanion toCompanion(bool nullToAbsent) {
    return GuardiansCompanion(
      id: Value(id),
      fullName: Value(fullName),
      relation: Value(relation),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      altPhone: altPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(altPhone),
      occupation: occupation == null && nullToAbsent
          ? const Value.absent()
          : Value(occupation),
      nationalId: nationalId == null && nullToAbsent
          ? const Value.absent()
          : Value(nationalId),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      appLoginCode: appLoginCode == null && nullToAbsent
          ? const Value.absent()
          : Value(appLoginCode),
      fcmToken: fcmToken == null && nullToAbsent
          ? const Value.absent()
          : Value(fcmToken),
      preferredChannel: Value(preferredChannel),
    );
  }

  factory Guardian.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Guardian(
      id: serializer.fromJson<int>(json['id']),
      fullName: serializer.fromJson<String>(json['fullName']),
      relation: serializer.fromJson<String>(json['relation']),
      phone: serializer.fromJson<String?>(json['phone']),
      altPhone: serializer.fromJson<String?>(json['altPhone']),
      occupation: serializer.fromJson<String?>(json['occupation']),
      nationalId: serializer.fromJson<String?>(json['nationalId']),
      address: serializer.fromJson<String?>(json['address']),
      appLoginCode: serializer.fromJson<String?>(json['appLoginCode']),
      fcmToken: serializer.fromJson<String?>(json['fcmToken']),
      preferredChannel: serializer.fromJson<String>(json['preferredChannel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'fullName': serializer.toJson<String>(fullName),
      'relation': serializer.toJson<String>(relation),
      'phone': serializer.toJson<String?>(phone),
      'altPhone': serializer.toJson<String?>(altPhone),
      'occupation': serializer.toJson<String?>(occupation),
      'nationalId': serializer.toJson<String?>(nationalId),
      'address': serializer.toJson<String?>(address),
      'appLoginCode': serializer.toJson<String?>(appLoginCode),
      'fcmToken': serializer.toJson<String?>(fcmToken),
      'preferredChannel': serializer.toJson<String>(preferredChannel),
    };
  }

  Guardian copyWith({
    int? id,
    String? fullName,
    String? relation,
    Value<String?> phone = const Value.absent(),
    Value<String?> altPhone = const Value.absent(),
    Value<String?> occupation = const Value.absent(),
    Value<String?> nationalId = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> appLoginCode = const Value.absent(),
    Value<String?> fcmToken = const Value.absent(),
    String? preferredChannel,
  }) => Guardian(
    id: id ?? this.id,
    fullName: fullName ?? this.fullName,
    relation: relation ?? this.relation,
    phone: phone.present ? phone.value : this.phone,
    altPhone: altPhone.present ? altPhone.value : this.altPhone,
    occupation: occupation.present ? occupation.value : this.occupation,
    nationalId: nationalId.present ? nationalId.value : this.nationalId,
    address: address.present ? address.value : this.address,
    appLoginCode: appLoginCode.present ? appLoginCode.value : this.appLoginCode,
    fcmToken: fcmToken.present ? fcmToken.value : this.fcmToken,
    preferredChannel: preferredChannel ?? this.preferredChannel,
  );
  Guardian copyWithCompanion(GuardiansCompanion data) {
    return Guardian(
      id: data.id.present ? data.id.value : this.id,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      relation: data.relation.present ? data.relation.value : this.relation,
      phone: data.phone.present ? data.phone.value : this.phone,
      altPhone: data.altPhone.present ? data.altPhone.value : this.altPhone,
      occupation: data.occupation.present
          ? data.occupation.value
          : this.occupation,
      nationalId: data.nationalId.present
          ? data.nationalId.value
          : this.nationalId,
      address: data.address.present ? data.address.value : this.address,
      appLoginCode: data.appLoginCode.present
          ? data.appLoginCode.value
          : this.appLoginCode,
      fcmToken: data.fcmToken.present ? data.fcmToken.value : this.fcmToken,
      preferredChannel: data.preferredChannel.present
          ? data.preferredChannel.value
          : this.preferredChannel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Guardian(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('relation: $relation, ')
          ..write('phone: $phone, ')
          ..write('altPhone: $altPhone, ')
          ..write('occupation: $occupation, ')
          ..write('nationalId: $nationalId, ')
          ..write('address: $address, ')
          ..write('appLoginCode: $appLoginCode, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('preferredChannel: $preferredChannel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    fullName,
    relation,
    phone,
    altPhone,
    occupation,
    nationalId,
    address,
    appLoginCode,
    fcmToken,
    preferredChannel,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Guardian &&
          other.id == this.id &&
          other.fullName == this.fullName &&
          other.relation == this.relation &&
          other.phone == this.phone &&
          other.altPhone == this.altPhone &&
          other.occupation == this.occupation &&
          other.nationalId == this.nationalId &&
          other.address == this.address &&
          other.appLoginCode == this.appLoginCode &&
          other.fcmToken == this.fcmToken &&
          other.preferredChannel == this.preferredChannel);
}

class GuardiansCompanion extends UpdateCompanion<Guardian> {
  final Value<int> id;
  final Value<String> fullName;
  final Value<String> relation;
  final Value<String?> phone;
  final Value<String?> altPhone;
  final Value<String?> occupation;
  final Value<String?> nationalId;
  final Value<String?> address;
  final Value<String?> appLoginCode;
  final Value<String?> fcmToken;
  final Value<String> preferredChannel;
  const GuardiansCompanion({
    this.id = const Value.absent(),
    this.fullName = const Value.absent(),
    this.relation = const Value.absent(),
    this.phone = const Value.absent(),
    this.altPhone = const Value.absent(),
    this.occupation = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.address = const Value.absent(),
    this.appLoginCode = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.preferredChannel = const Value.absent(),
  });
  GuardiansCompanion.insert({
    this.id = const Value.absent(),
    required String fullName,
    required String relation,
    this.phone = const Value.absent(),
    this.altPhone = const Value.absent(),
    this.occupation = const Value.absent(),
    this.nationalId = const Value.absent(),
    this.address = const Value.absent(),
    this.appLoginCode = const Value.absent(),
    this.fcmToken = const Value.absent(),
    this.preferredChannel = const Value.absent(),
  }) : fullName = Value(fullName),
       relation = Value(relation);
  static Insertable<Guardian> custom({
    Expression<int>? id,
    Expression<String>? fullName,
    Expression<String>? relation,
    Expression<String>? phone,
    Expression<String>? altPhone,
    Expression<String>? occupation,
    Expression<String>? nationalId,
    Expression<String>? address,
    Expression<String>? appLoginCode,
    Expression<String>? fcmToken,
    Expression<String>? preferredChannel,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (fullName != null) 'full_name': fullName,
      if (relation != null) 'relation': relation,
      if (phone != null) 'phone': phone,
      if (altPhone != null) 'alt_phone': altPhone,
      if (occupation != null) 'occupation': occupation,
      if (nationalId != null) 'national_id': nationalId,
      if (address != null) 'address': address,
      if (appLoginCode != null) 'app_login_code': appLoginCode,
      if (fcmToken != null) 'fcm_token': fcmToken,
      if (preferredChannel != null) 'preferred_channel': preferredChannel,
    });
  }

  GuardiansCompanion copyWith({
    Value<int>? id,
    Value<String>? fullName,
    Value<String>? relation,
    Value<String?>? phone,
    Value<String?>? altPhone,
    Value<String?>? occupation,
    Value<String?>? nationalId,
    Value<String?>? address,
    Value<String?>? appLoginCode,
    Value<String?>? fcmToken,
    Value<String>? preferredChannel,
  }) {
    return GuardiansCompanion(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      relation: relation ?? this.relation,
      phone: phone ?? this.phone,
      altPhone: altPhone ?? this.altPhone,
      occupation: occupation ?? this.occupation,
      nationalId: nationalId ?? this.nationalId,
      address: address ?? this.address,
      appLoginCode: appLoginCode ?? this.appLoginCode,
      fcmToken: fcmToken ?? this.fcmToken,
      preferredChannel: preferredChannel ?? this.preferredChannel,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (relation.present) {
      map['relation'] = Variable<String>(relation.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (altPhone.present) {
      map['alt_phone'] = Variable<String>(altPhone.value);
    }
    if (occupation.present) {
      map['occupation'] = Variable<String>(occupation.value);
    }
    if (nationalId.present) {
      map['national_id'] = Variable<String>(nationalId.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (appLoginCode.present) {
      map['app_login_code'] = Variable<String>(appLoginCode.value);
    }
    if (fcmToken.present) {
      map['fcm_token'] = Variable<String>(fcmToken.value);
    }
    if (preferredChannel.present) {
      map['preferred_channel'] = Variable<String>(preferredChannel.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GuardiansCompanion(')
          ..write('id: $id, ')
          ..write('fullName: $fullName, ')
          ..write('relation: $relation, ')
          ..write('phone: $phone, ')
          ..write('altPhone: $altPhone, ')
          ..write('occupation: $occupation, ')
          ..write('nationalId: $nationalId, ')
          ..write('address: $address, ')
          ..write('appLoginCode: $appLoginCode, ')
          ..write('fcmToken: $fcmToken, ')
          ..write('preferredChannel: $preferredChannel')
          ..write(')'))
        .toString();
  }
}

class $StudentGuardiansTable extends StudentGuardians
    with TableInfo<$StudentGuardiansTable, StudentGuardian> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentGuardiansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<int> guardianId = GeneratedColumn<int>(
    'guardian_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES guardians (id)',
    ),
  );
  static const VerificationMeta _isPrimaryMeta = const VerificationMeta(
    'isPrimary',
  );
  @override
  late final GeneratedColumn<bool> isPrimary = GeneratedColumn<bool>(
    'is_primary',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_primary" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [studentId, guardianId, isPrimary];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'student_guardians';
  @override
  VerificationContext validateIntegrity(
    Insertable<StudentGuardian> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    } else if (isInserting) {
      context.missing(_guardianIdMeta);
    }
    if (data.containsKey('is_primary')) {
      context.handle(
        _isPrimaryMeta,
        isPrimary.isAcceptableOrUnknown(data['is_primary']!, _isPrimaryMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {studentId, guardianId};
  @override
  StudentGuardian map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StudentGuardian(
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guardian_id'],
      )!,
      isPrimary: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_primary'],
      )!,
    );
  }

  @override
  $StudentGuardiansTable createAlias(String alias) {
    return $StudentGuardiansTable(attachedDatabase, alias);
  }
}

class StudentGuardian extends DataClass implements Insertable<StudentGuardian> {
  final int studentId;
  final int guardianId;

  /// اصلي سرپرست — خبرتیا لومړی ده ته ځي.
  final bool isPrimary;
  const StudentGuardian({
    required this.studentId,
    required this.guardianId,
    required this.isPrimary,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['student_id'] = Variable<int>(studentId);
    map['guardian_id'] = Variable<int>(guardianId);
    map['is_primary'] = Variable<bool>(isPrimary);
    return map;
  }

  StudentGuardiansCompanion toCompanion(bool nullToAbsent) {
    return StudentGuardiansCompanion(
      studentId: Value(studentId),
      guardianId: Value(guardianId),
      isPrimary: Value(isPrimary),
    );
  }

  factory StudentGuardian.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StudentGuardian(
      studentId: serializer.fromJson<int>(json['studentId']),
      guardianId: serializer.fromJson<int>(json['guardianId']),
      isPrimary: serializer.fromJson<bool>(json['isPrimary']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'studentId': serializer.toJson<int>(studentId),
      'guardianId': serializer.toJson<int>(guardianId),
      'isPrimary': serializer.toJson<bool>(isPrimary),
    };
  }

  StudentGuardian copyWith({
    int? studentId,
    int? guardianId,
    bool? isPrimary,
  }) => StudentGuardian(
    studentId: studentId ?? this.studentId,
    guardianId: guardianId ?? this.guardianId,
    isPrimary: isPrimary ?? this.isPrimary,
  );
  StudentGuardian copyWithCompanion(StudentGuardiansCompanion data) {
    return StudentGuardian(
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      isPrimary: data.isPrimary.present ? data.isPrimary.value : this.isPrimary,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StudentGuardian(')
          ..write('studentId: $studentId, ')
          ..write('guardianId: $guardianId, ')
          ..write('isPrimary: $isPrimary')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(studentId, guardianId, isPrimary);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StudentGuardian &&
          other.studentId == this.studentId &&
          other.guardianId == this.guardianId &&
          other.isPrimary == this.isPrimary);
}

class StudentGuardiansCompanion extends UpdateCompanion<StudentGuardian> {
  final Value<int> studentId;
  final Value<int> guardianId;
  final Value<bool> isPrimary;
  final Value<int> rowid;
  const StudentGuardiansCompanion({
    this.studentId = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentGuardiansCompanion.insert({
    required int studentId,
    required int guardianId,
    this.isPrimary = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : studentId = Value(studentId),
       guardianId = Value(guardianId);
  static Insertable<StudentGuardian> custom({
    Expression<int>? studentId,
    Expression<int>? guardianId,
    Expression<bool>? isPrimary,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (studentId != null) 'student_id': studentId,
      if (guardianId != null) 'guardian_id': guardianId,
      if (isPrimary != null) 'is_primary': isPrimary,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentGuardiansCompanion copyWith({
    Value<int>? studentId,
    Value<int>? guardianId,
    Value<bool>? isPrimary,
    Value<int>? rowid,
  }) {
    return StudentGuardiansCompanion(
      studentId: studentId ?? this.studentId,
      guardianId: guardianId ?? this.guardianId,
      isPrimary: isPrimary ?? this.isPrimary,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<int>(guardianId.value);
    }
    if (isPrimary.present) {
      map['is_primary'] = Variable<bool>(isPrimary.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentGuardiansCompanion(')
          ..write('studentId: $studentId, ')
          ..write('guardianId: $guardianId, ')
          ..write('isPrimary: $isPrimary, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeachersTable extends Teachers with TableInfo<$TeachersTable, Teacher> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeachersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _employeeNoMeta = const VerificationMeta(
    'employeeNo',
  );
  @override
  late final GeneratedColumn<String> employeeNo = GeneratedColumn<String>(
    'employee_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatherNameMeta = const VerificationMeta(
    'fatherName',
  );
  @override
  late final GeneratedColumn<String> fatherName = GeneratedColumn<String>(
    'father_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoPathMeta = const VerificationMeta(
    'photoPath',
  );
  @override
  late final GeneratedColumn<String> photoPath = GeneratedColumn<String>(
    'photo_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qualificationMeta = const VerificationMeta(
    'qualification',
  );
  @override
  late final GeneratedColumn<String> qualification = GeneratedColumn<String>(
    'qualification',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specializationMeta = const VerificationMeta(
    'specialization',
  );
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
    'specialization',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hiredOnMeta = const VerificationMeta(
    'hiredOn',
  );
  @override
  late final GeneratedColumn<DateTime> hiredOn = GeneratedColumn<DateTime>(
    'hired_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _monthlySalaryMeta = const VerificationMeta(
    'monthlySalary',
  );
  @override
  late final GeneratedColumn<int> monthlySalary = GeneratedColumn<int>(
    'monthly_salary',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _qrSecretMeta = const VerificationMeta(
    'qrSecret',
  );
  @override
  late final GeneratedColumn<String> qrSecret = GeneratedColumn<String>(
    'qr_secret',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeNo,
    fullName,
    fatherName,
    gender,
    phone,
    email,
    address,
    photoPath,
    qualification,
    specialization,
    hiredOn,
    status,
    monthlySalary,
    qrSecret,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teachers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Teacher> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('employee_no')) {
      context.handle(
        _employeeNoMeta,
        employeeNo.isAcceptableOrUnknown(data['employee_no']!, _employeeNoMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeNoMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('father_name')) {
      context.handle(
        _fatherNameMeta,
        fatherName.isAcceptableOrUnknown(data['father_name']!, _fatherNameMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('photo_path')) {
      context.handle(
        _photoPathMeta,
        photoPath.isAcceptableOrUnknown(data['photo_path']!, _photoPathMeta),
      );
    }
    if (data.containsKey('qualification')) {
      context.handle(
        _qualificationMeta,
        qualification.isAcceptableOrUnknown(
          data['qualification']!,
          _qualificationMeta,
        ),
      );
    }
    if (data.containsKey('specialization')) {
      context.handle(
        _specializationMeta,
        specialization.isAcceptableOrUnknown(
          data['specialization']!,
          _specializationMeta,
        ),
      );
    }
    if (data.containsKey('hired_on')) {
      context.handle(
        _hiredOnMeta,
        hiredOn.isAcceptableOrUnknown(data['hired_on']!, _hiredOnMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('monthly_salary')) {
      context.handle(
        _monthlySalaryMeta,
        monthlySalary.isAcceptableOrUnknown(
          data['monthly_salary']!,
          _monthlySalaryMeta,
        ),
      );
    }
    if (data.containsKey('qr_secret')) {
      context.handle(
        _qrSecretMeta,
        qrSecret.isAcceptableOrUnknown(data['qr_secret']!, _qrSecretMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {employeeNo},
  ];
  @override
  Teacher map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Teacher(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      employeeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_no'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      fatherName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}father_name'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      photoPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_path'],
      ),
      qualification: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qualification'],
      ),
      specialization: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialization'],
      ),
      hiredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hired_on'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      monthlySalary: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_salary'],
      ),
      qrSecret: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}qr_secret'],
      ),
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TeachersTable createAlias(String alias) {
    return $TeachersTable(attachedDatabase, alias);
  }
}

class Teacher extends DataClass implements Insertable<Teacher> {
  final int id;
  final String employeeNo;
  final String fullName;
  final String? fatherName;
  final String gender;
  final String? phone;
  final String? email;
  final String? address;
  final String? photoPath;
  final String? qualification;
  final String? specialization;
  final DateTime? hiredOn;

  /// `active` | `on_leave` | `resigned` | `terminated`
  final String status;
  final int? monthlySalary;
  final String? qrSecret;
  final DateTime? deletedAt;
  const Teacher({
    required this.id,
    required this.employeeNo,
    required this.fullName,
    this.fatherName,
    required this.gender,
    this.phone,
    this.email,
    this.address,
    this.photoPath,
    this.qualification,
    this.specialization,
    this.hiredOn,
    required this.status,
    this.monthlySalary,
    this.qrSecret,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['employee_no'] = Variable<String>(employeeNo);
    map['full_name'] = Variable<String>(fullName);
    if (!nullToAbsent || fatherName != null) {
      map['father_name'] = Variable<String>(fatherName);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || photoPath != null) {
      map['photo_path'] = Variable<String>(photoPath);
    }
    if (!nullToAbsent || qualification != null) {
      map['qualification'] = Variable<String>(qualification);
    }
    if (!nullToAbsent || specialization != null) {
      map['specialization'] = Variable<String>(specialization);
    }
    if (!nullToAbsent || hiredOn != null) {
      map['hired_on'] = Variable<DateTime>(hiredOn);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || monthlySalary != null) {
      map['monthly_salary'] = Variable<int>(monthlySalary);
    }
    if (!nullToAbsent || qrSecret != null) {
      map['qr_secret'] = Variable<String>(qrSecret);
    }
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TeachersCompanion toCompanion(bool nullToAbsent) {
    return TeachersCompanion(
      id: Value(id),
      employeeNo: Value(employeeNo),
      fullName: Value(fullName),
      fatherName: fatherName == null && nullToAbsent
          ? const Value.absent()
          : Value(fatherName),
      gender: Value(gender),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      photoPath: photoPath == null && nullToAbsent
          ? const Value.absent()
          : Value(photoPath),
      qualification: qualification == null && nullToAbsent
          ? const Value.absent()
          : Value(qualification),
      specialization: specialization == null && nullToAbsent
          ? const Value.absent()
          : Value(specialization),
      hiredOn: hiredOn == null && nullToAbsent
          ? const Value.absent()
          : Value(hiredOn),
      status: Value(status),
      monthlySalary: monthlySalary == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlySalary),
      qrSecret: qrSecret == null && nullToAbsent
          ? const Value.absent()
          : Value(qrSecret),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Teacher.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Teacher(
      id: serializer.fromJson<int>(json['id']),
      employeeNo: serializer.fromJson<String>(json['employeeNo']),
      fullName: serializer.fromJson<String>(json['fullName']),
      fatherName: serializer.fromJson<String?>(json['fatherName']),
      gender: serializer.fromJson<String>(json['gender']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      address: serializer.fromJson<String?>(json['address']),
      photoPath: serializer.fromJson<String?>(json['photoPath']),
      qualification: serializer.fromJson<String?>(json['qualification']),
      specialization: serializer.fromJson<String?>(json['specialization']),
      hiredOn: serializer.fromJson<DateTime?>(json['hiredOn']),
      status: serializer.fromJson<String>(json['status']),
      monthlySalary: serializer.fromJson<int?>(json['monthlySalary']),
      qrSecret: serializer.fromJson<String?>(json['qrSecret']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'employeeNo': serializer.toJson<String>(employeeNo),
      'fullName': serializer.toJson<String>(fullName),
      'fatherName': serializer.toJson<String?>(fatherName),
      'gender': serializer.toJson<String>(gender),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'address': serializer.toJson<String?>(address),
      'photoPath': serializer.toJson<String?>(photoPath),
      'qualification': serializer.toJson<String?>(qualification),
      'specialization': serializer.toJson<String?>(specialization),
      'hiredOn': serializer.toJson<DateTime?>(hiredOn),
      'status': serializer.toJson<String>(status),
      'monthlySalary': serializer.toJson<int?>(monthlySalary),
      'qrSecret': serializer.toJson<String?>(qrSecret),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Teacher copyWith({
    int? id,
    String? employeeNo,
    String? fullName,
    Value<String?> fatherName = const Value.absent(),
    String? gender,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> photoPath = const Value.absent(),
    Value<String?> qualification = const Value.absent(),
    Value<String?> specialization = const Value.absent(),
    Value<DateTime?> hiredOn = const Value.absent(),
    String? status,
    Value<int?> monthlySalary = const Value.absent(),
    Value<String?> qrSecret = const Value.absent(),
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Teacher(
    id: id ?? this.id,
    employeeNo: employeeNo ?? this.employeeNo,
    fullName: fullName ?? this.fullName,
    fatherName: fatherName.present ? fatherName.value : this.fatherName,
    gender: gender ?? this.gender,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    address: address.present ? address.value : this.address,
    photoPath: photoPath.present ? photoPath.value : this.photoPath,
    qualification: qualification.present
        ? qualification.value
        : this.qualification,
    specialization: specialization.present
        ? specialization.value
        : this.specialization,
    hiredOn: hiredOn.present ? hiredOn.value : this.hiredOn,
    status: status ?? this.status,
    monthlySalary: monthlySalary.present
        ? monthlySalary.value
        : this.monthlySalary,
    qrSecret: qrSecret.present ? qrSecret.value : this.qrSecret,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Teacher copyWithCompanion(TeachersCompanion data) {
    return Teacher(
      id: data.id.present ? data.id.value : this.id,
      employeeNo: data.employeeNo.present
          ? data.employeeNo.value
          : this.employeeNo,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      fatherName: data.fatherName.present
          ? data.fatherName.value
          : this.fatherName,
      gender: data.gender.present ? data.gender.value : this.gender,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      address: data.address.present ? data.address.value : this.address,
      photoPath: data.photoPath.present ? data.photoPath.value : this.photoPath,
      qualification: data.qualification.present
          ? data.qualification.value
          : this.qualification,
      specialization: data.specialization.present
          ? data.specialization.value
          : this.specialization,
      hiredOn: data.hiredOn.present ? data.hiredOn.value : this.hiredOn,
      status: data.status.present ? data.status.value : this.status,
      monthlySalary: data.monthlySalary.present
          ? data.monthlySalary.value
          : this.monthlySalary,
      qrSecret: data.qrSecret.present ? data.qrSecret.value : this.qrSecret,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Teacher(')
          ..write('id: $id, ')
          ..write('employeeNo: $employeeNo, ')
          ..write('fullName: $fullName, ')
          ..write('fatherName: $fatherName, ')
          ..write('gender: $gender, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('photoPath: $photoPath, ')
          ..write('qualification: $qualification, ')
          ..write('specialization: $specialization, ')
          ..write('hiredOn: $hiredOn, ')
          ..write('status: $status, ')
          ..write('monthlySalary: $monthlySalary, ')
          ..write('qrSecret: $qrSecret, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeNo,
    fullName,
    fatherName,
    gender,
    phone,
    email,
    address,
    photoPath,
    qualification,
    specialization,
    hiredOn,
    status,
    monthlySalary,
    qrSecret,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Teacher &&
          other.id == this.id &&
          other.employeeNo == this.employeeNo &&
          other.fullName == this.fullName &&
          other.fatherName == this.fatherName &&
          other.gender == this.gender &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.address == this.address &&
          other.photoPath == this.photoPath &&
          other.qualification == this.qualification &&
          other.specialization == this.specialization &&
          other.hiredOn == this.hiredOn &&
          other.status == this.status &&
          other.monthlySalary == this.monthlySalary &&
          other.qrSecret == this.qrSecret &&
          other.deletedAt == this.deletedAt);
}

class TeachersCompanion extends UpdateCompanion<Teacher> {
  final Value<int> id;
  final Value<String> employeeNo;
  final Value<String> fullName;
  final Value<String?> fatherName;
  final Value<String> gender;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> address;
  final Value<String?> photoPath;
  final Value<String?> qualification;
  final Value<String?> specialization;
  final Value<DateTime?> hiredOn;
  final Value<String> status;
  final Value<int?> monthlySalary;
  final Value<String?> qrSecret;
  final Value<DateTime?> deletedAt;
  const TeachersCompanion({
    this.id = const Value.absent(),
    this.employeeNo = const Value.absent(),
    this.fullName = const Value.absent(),
    this.fatherName = const Value.absent(),
    this.gender = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.qualification = const Value.absent(),
    this.specialization = const Value.absent(),
    this.hiredOn = const Value.absent(),
    this.status = const Value.absent(),
    this.monthlySalary = const Value.absent(),
    this.qrSecret = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  TeachersCompanion.insert({
    this.id = const Value.absent(),
    required String employeeNo,
    required String fullName,
    this.fatherName = const Value.absent(),
    required String gender,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.address = const Value.absent(),
    this.photoPath = const Value.absent(),
    this.qualification = const Value.absent(),
    this.specialization = const Value.absent(),
    this.hiredOn = const Value.absent(),
    this.status = const Value.absent(),
    this.monthlySalary = const Value.absent(),
    this.qrSecret = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : employeeNo = Value(employeeNo),
       fullName = Value(fullName),
       gender = Value(gender);
  static Insertable<Teacher> custom({
    Expression<int>? id,
    Expression<String>? employeeNo,
    Expression<String>? fullName,
    Expression<String>? fatherName,
    Expression<String>? gender,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? address,
    Expression<String>? photoPath,
    Expression<String>? qualification,
    Expression<String>? specialization,
    Expression<DateTime>? hiredOn,
    Expression<String>? status,
    Expression<int>? monthlySalary,
    Expression<String>? qrSecret,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeNo != null) 'employee_no': employeeNo,
      if (fullName != null) 'full_name': fullName,
      if (fatherName != null) 'father_name': fatherName,
      if (gender != null) 'gender': gender,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (address != null) 'address': address,
      if (photoPath != null) 'photo_path': photoPath,
      if (qualification != null) 'qualification': qualification,
      if (specialization != null) 'specialization': specialization,
      if (hiredOn != null) 'hired_on': hiredOn,
      if (status != null) 'status': status,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (qrSecret != null) 'qr_secret': qrSecret,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  TeachersCompanion copyWith({
    Value<int>? id,
    Value<String>? employeeNo,
    Value<String>? fullName,
    Value<String?>? fatherName,
    Value<String>? gender,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? address,
    Value<String?>? photoPath,
    Value<String?>? qualification,
    Value<String?>? specialization,
    Value<DateTime?>? hiredOn,
    Value<String>? status,
    Value<int?>? monthlySalary,
    Value<String?>? qrSecret,
    Value<DateTime?>? deletedAt,
  }) {
    return TeachersCompanion(
      id: id ?? this.id,
      employeeNo: employeeNo ?? this.employeeNo,
      fullName: fullName ?? this.fullName,
      fatherName: fatherName ?? this.fatherName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      photoPath: photoPath ?? this.photoPath,
      qualification: qualification ?? this.qualification,
      specialization: specialization ?? this.specialization,
      hiredOn: hiredOn ?? this.hiredOn,
      status: status ?? this.status,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      qrSecret: qrSecret ?? this.qrSecret,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (employeeNo.present) {
      map['employee_no'] = Variable<String>(employeeNo.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (fatherName.present) {
      map['father_name'] = Variable<String>(fatherName.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (photoPath.present) {
      map['photo_path'] = Variable<String>(photoPath.value);
    }
    if (qualification.present) {
      map['qualification'] = Variable<String>(qualification.value);
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    if (hiredOn.present) {
      map['hired_on'] = Variable<DateTime>(hiredOn.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (monthlySalary.present) {
      map['monthly_salary'] = Variable<int>(monthlySalary.value);
    }
    if (qrSecret.present) {
      map['qr_secret'] = Variable<String>(qrSecret.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeachersCompanion(')
          ..write('id: $id, ')
          ..write('employeeNo: $employeeNo, ')
          ..write('fullName: $fullName, ')
          ..write('fatherName: $fatherName, ')
          ..write('gender: $gender, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('address: $address, ')
          ..write('photoPath: $photoPath, ')
          ..write('qualification: $qualification, ')
          ..write('specialization: $specialization, ')
          ..write('hiredOn: $hiredOn, ')
          ..write('status: $status, ')
          ..write('monthlySalary: $monthlySalary, ')
          ..write('qrSecret: $qrSecret, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $StaffMembersTable extends StaffMembers
    with TableInfo<$StaffMembersTable, StaffMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StaffMembersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _employeeNoMeta = const VerificationMeta(
    'employeeNo',
  );
  @override
  late final GeneratedColumn<String> employeeNo = GeneratedColumn<String>(
    'employee_no',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _jobTitleMeta = const VerificationMeta(
    'jobTitle',
  );
  @override
  late final GeneratedColumn<String> jobTitle = GeneratedColumn<String>(
    'job_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _departmentMeta = const VerificationMeta(
    'department',
  );
  @override
  late final GeneratedColumn<String> department = GeneratedColumn<String>(
    'department',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genderMeta = const VerificationMeta('gender');
  @override
  late final GeneratedColumn<String> gender = GeneratedColumn<String>(
    'gender',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hiredOnMeta = const VerificationMeta(
    'hiredOn',
  );
  @override
  late final GeneratedColumn<DateTime> hiredOn = GeneratedColumn<DateTime>(
    'hired_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthlySalaryMeta = const VerificationMeta(
    'monthlySalary',
  );
  @override
  late final GeneratedColumn<int> monthlySalary = GeneratedColumn<int>(
    'monthly_salary',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    employeeNo,
    fullName,
    jobTitle,
    department,
    phone,
    gender,
    hiredOn,
    monthlySalary,
    status,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'staff_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<StaffMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('employee_no')) {
      context.handle(
        _employeeNoMeta,
        employeeNo.isAcceptableOrUnknown(data['employee_no']!, _employeeNoMeta),
      );
    } else if (isInserting) {
      context.missing(_employeeNoMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('job_title')) {
      context.handle(
        _jobTitleMeta,
        jobTitle.isAcceptableOrUnknown(data['job_title']!, _jobTitleMeta),
      );
    } else if (isInserting) {
      context.missing(_jobTitleMeta);
    }
    if (data.containsKey('department')) {
      context.handle(
        _departmentMeta,
        department.isAcceptableOrUnknown(data['department']!, _departmentMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('gender')) {
      context.handle(
        _genderMeta,
        gender.isAcceptableOrUnknown(data['gender']!, _genderMeta),
      );
    } else if (isInserting) {
      context.missing(_genderMeta);
    }
    if (data.containsKey('hired_on')) {
      context.handle(
        _hiredOnMeta,
        hiredOn.isAcceptableOrUnknown(data['hired_on']!, _hiredOnMeta),
      );
    }
    if (data.containsKey('monthly_salary')) {
      context.handle(
        _monthlySalaryMeta,
        monthlySalary.isAcceptableOrUnknown(
          data['monthly_salary']!,
          _monthlySalaryMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {employeeNo},
  ];
  @override
  StaffMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StaffMember(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      employeeNo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}employee_no'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      jobTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}job_title'],
      )!,
      department: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}department'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      gender: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}gender'],
      )!,
      hiredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}hired_on'],
      ),
      monthlySalary: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}monthly_salary'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $StaffMembersTable createAlias(String alias) {
    return $StaffMembersTable(attachedDatabase, alias);
  }
}

class StaffMember extends DataClass implements Insertable<StaffMember> {
  final int id;
  final String employeeNo;
  final String fullName;
  final String jobTitle;
  final String? department;
  final String? phone;
  final String gender;
  final DateTime? hiredOn;
  final int? monthlySalary;
  final String status;
  final DateTime? deletedAt;
  const StaffMember({
    required this.id,
    required this.employeeNo,
    required this.fullName,
    required this.jobTitle,
    this.department,
    this.phone,
    required this.gender,
    this.hiredOn,
    this.monthlySalary,
    required this.status,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['employee_no'] = Variable<String>(employeeNo);
    map['full_name'] = Variable<String>(fullName);
    map['job_title'] = Variable<String>(jobTitle);
    if (!nullToAbsent || department != null) {
      map['department'] = Variable<String>(department);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['gender'] = Variable<String>(gender);
    if (!nullToAbsent || hiredOn != null) {
      map['hired_on'] = Variable<DateTime>(hiredOn);
    }
    if (!nullToAbsent || monthlySalary != null) {
      map['monthly_salary'] = Variable<int>(monthlySalary);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  StaffMembersCompanion toCompanion(bool nullToAbsent) {
    return StaffMembersCompanion(
      id: Value(id),
      employeeNo: Value(employeeNo),
      fullName: Value(fullName),
      jobTitle: Value(jobTitle),
      department: department == null && nullToAbsent
          ? const Value.absent()
          : Value(department),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      gender: Value(gender),
      hiredOn: hiredOn == null && nullToAbsent
          ? const Value.absent()
          : Value(hiredOn),
      monthlySalary: monthlySalary == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlySalary),
      status: Value(status),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory StaffMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StaffMember(
      id: serializer.fromJson<int>(json['id']),
      employeeNo: serializer.fromJson<String>(json['employeeNo']),
      fullName: serializer.fromJson<String>(json['fullName']),
      jobTitle: serializer.fromJson<String>(json['jobTitle']),
      department: serializer.fromJson<String?>(json['department']),
      phone: serializer.fromJson<String?>(json['phone']),
      gender: serializer.fromJson<String>(json['gender']),
      hiredOn: serializer.fromJson<DateTime?>(json['hiredOn']),
      monthlySalary: serializer.fromJson<int?>(json['monthlySalary']),
      status: serializer.fromJson<String>(json['status']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'employeeNo': serializer.toJson<String>(employeeNo),
      'fullName': serializer.toJson<String>(fullName),
      'jobTitle': serializer.toJson<String>(jobTitle),
      'department': serializer.toJson<String?>(department),
      'phone': serializer.toJson<String?>(phone),
      'gender': serializer.toJson<String>(gender),
      'hiredOn': serializer.toJson<DateTime?>(hiredOn),
      'monthlySalary': serializer.toJson<int?>(monthlySalary),
      'status': serializer.toJson<String>(status),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  StaffMember copyWith({
    int? id,
    String? employeeNo,
    String? fullName,
    String? jobTitle,
    Value<String?> department = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    String? gender,
    Value<DateTime?> hiredOn = const Value.absent(),
    Value<int?> monthlySalary = const Value.absent(),
    String? status,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => StaffMember(
    id: id ?? this.id,
    employeeNo: employeeNo ?? this.employeeNo,
    fullName: fullName ?? this.fullName,
    jobTitle: jobTitle ?? this.jobTitle,
    department: department.present ? department.value : this.department,
    phone: phone.present ? phone.value : this.phone,
    gender: gender ?? this.gender,
    hiredOn: hiredOn.present ? hiredOn.value : this.hiredOn,
    monthlySalary: monthlySalary.present
        ? monthlySalary.value
        : this.monthlySalary,
    status: status ?? this.status,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  StaffMember copyWithCompanion(StaffMembersCompanion data) {
    return StaffMember(
      id: data.id.present ? data.id.value : this.id,
      employeeNo: data.employeeNo.present
          ? data.employeeNo.value
          : this.employeeNo,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      jobTitle: data.jobTitle.present ? data.jobTitle.value : this.jobTitle,
      department: data.department.present
          ? data.department.value
          : this.department,
      phone: data.phone.present ? data.phone.value : this.phone,
      gender: data.gender.present ? data.gender.value : this.gender,
      hiredOn: data.hiredOn.present ? data.hiredOn.value : this.hiredOn,
      monthlySalary: data.monthlySalary.present
          ? data.monthlySalary.value
          : this.monthlySalary,
      status: data.status.present ? data.status.value : this.status,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StaffMember(')
          ..write('id: $id, ')
          ..write('employeeNo: $employeeNo, ')
          ..write('fullName: $fullName, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('department: $department, ')
          ..write('phone: $phone, ')
          ..write('gender: $gender, ')
          ..write('hiredOn: $hiredOn, ')
          ..write('monthlySalary: $monthlySalary, ')
          ..write('status: $status, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    employeeNo,
    fullName,
    jobTitle,
    department,
    phone,
    gender,
    hiredOn,
    monthlySalary,
    status,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StaffMember &&
          other.id == this.id &&
          other.employeeNo == this.employeeNo &&
          other.fullName == this.fullName &&
          other.jobTitle == this.jobTitle &&
          other.department == this.department &&
          other.phone == this.phone &&
          other.gender == this.gender &&
          other.hiredOn == this.hiredOn &&
          other.monthlySalary == this.monthlySalary &&
          other.status == this.status &&
          other.deletedAt == this.deletedAt);
}

class StaffMembersCompanion extends UpdateCompanion<StaffMember> {
  final Value<int> id;
  final Value<String> employeeNo;
  final Value<String> fullName;
  final Value<String> jobTitle;
  final Value<String?> department;
  final Value<String?> phone;
  final Value<String> gender;
  final Value<DateTime?> hiredOn;
  final Value<int?> monthlySalary;
  final Value<String> status;
  final Value<DateTime?> deletedAt;
  const StaffMembersCompanion({
    this.id = const Value.absent(),
    this.employeeNo = const Value.absent(),
    this.fullName = const Value.absent(),
    this.jobTitle = const Value.absent(),
    this.department = const Value.absent(),
    this.phone = const Value.absent(),
    this.gender = const Value.absent(),
    this.hiredOn = const Value.absent(),
    this.monthlySalary = const Value.absent(),
    this.status = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  StaffMembersCompanion.insert({
    this.id = const Value.absent(),
    required String employeeNo,
    required String fullName,
    required String jobTitle,
    this.department = const Value.absent(),
    this.phone = const Value.absent(),
    required String gender,
    this.hiredOn = const Value.absent(),
    this.monthlySalary = const Value.absent(),
    this.status = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : employeeNo = Value(employeeNo),
       fullName = Value(fullName),
       jobTitle = Value(jobTitle),
       gender = Value(gender);
  static Insertable<StaffMember> custom({
    Expression<int>? id,
    Expression<String>? employeeNo,
    Expression<String>? fullName,
    Expression<String>? jobTitle,
    Expression<String>? department,
    Expression<String>? phone,
    Expression<String>? gender,
    Expression<DateTime>? hiredOn,
    Expression<int>? monthlySalary,
    Expression<String>? status,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (employeeNo != null) 'employee_no': employeeNo,
      if (fullName != null) 'full_name': fullName,
      if (jobTitle != null) 'job_title': jobTitle,
      if (department != null) 'department': department,
      if (phone != null) 'phone': phone,
      if (gender != null) 'gender': gender,
      if (hiredOn != null) 'hired_on': hiredOn,
      if (monthlySalary != null) 'monthly_salary': monthlySalary,
      if (status != null) 'status': status,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  StaffMembersCompanion copyWith({
    Value<int>? id,
    Value<String>? employeeNo,
    Value<String>? fullName,
    Value<String>? jobTitle,
    Value<String?>? department,
    Value<String?>? phone,
    Value<String>? gender,
    Value<DateTime?>? hiredOn,
    Value<int?>? monthlySalary,
    Value<String>? status,
    Value<DateTime?>? deletedAt,
  }) {
    return StaffMembersCompanion(
      id: id ?? this.id,
      employeeNo: employeeNo ?? this.employeeNo,
      fullName: fullName ?? this.fullName,
      jobTitle: jobTitle ?? this.jobTitle,
      department: department ?? this.department,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      hiredOn: hiredOn ?? this.hiredOn,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      status: status ?? this.status,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (employeeNo.present) {
      map['employee_no'] = Variable<String>(employeeNo.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (jobTitle.present) {
      map['job_title'] = Variable<String>(jobTitle.value);
    }
    if (department.present) {
      map['department'] = Variable<String>(department.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (gender.present) {
      map['gender'] = Variable<String>(gender.value);
    }
    if (hiredOn.present) {
      map['hired_on'] = Variable<DateTime>(hiredOn.value);
    }
    if (monthlySalary.present) {
      map['monthly_salary'] = Variable<int>(monthlySalary.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StaffMembersCompanion(')
          ..write('id: $id, ')
          ..write('employeeNo: $employeeNo, ')
          ..write('fullName: $fullName, ')
          ..write('jobTitle: $jobTitle, ')
          ..write('department: $department, ')
          ..write('phone: $phone, ')
          ..write('gender: $gender, ')
          ..write('hiredOn: $hiredOn, ')
          ..write('monthlySalary: $monthlySalary, ')
          ..write('status: $status, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $EnrollmentsTable extends Enrollments
    with TableInfo<$EnrollmentsTable, Enrollment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EnrollmentsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
    ),
  );
  static const VerificationMeta _academicYearIdMeta = const VerificationMeta(
    'academicYearId',
  );
  @override
  late final GeneratedColumn<int> academicYearId = GeneratedColumn<int>(
    'academic_year_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES academic_years (id)',
    ),
  );
  static const VerificationMeta _rollNoMeta = const VerificationMeta('rollNo');
  @override
  late final GeneratedColumn<int> rollNo = GeneratedColumn<int>(
    'roll_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enrolledOnMeta = const VerificationMeta(
    'enrolledOn',
  );
  @override
  late final GeneratedColumn<DateTime> enrolledOn = GeneratedColumn<DateTime>(
    'enrolled_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _leftOnMeta = const VerificationMeta('leftOn');
  @override
  late final GeneratedColumn<DateTime> leftOn = GeneratedColumn<DateTime>(
    'left_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sectionId,
    academicYearId,
    rollNo,
    enrolledOn,
    leftOn,
    isActive,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'enrollments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Enrollment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('academic_year_id')) {
      context.handle(
        _academicYearIdMeta,
        academicYearId.isAcceptableOrUnknown(
          data['academic_year_id']!,
          _academicYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearIdMeta);
    }
    if (data.containsKey('roll_no')) {
      context.handle(
        _rollNoMeta,
        rollNo.isAcceptableOrUnknown(data['roll_no']!, _rollNoMeta),
      );
    }
    if (data.containsKey('enrolled_on')) {
      context.handle(
        _enrolledOnMeta,
        enrolledOn.isAcceptableOrUnknown(data['enrolled_on']!, _enrolledOnMeta),
      );
    }
    if (data.containsKey('left_on')) {
      context.handle(
        _leftOnMeta,
        leftOn.isAcceptableOrUnknown(data['left_on']!, _leftOnMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Enrollment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Enrollment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      academicYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}academic_year_id'],
      )!,
      rollNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}roll_no'],
      ),
      enrolledOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}enrolled_on'],
      )!,
      leftOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}left_on'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
    );
  }

  @override
  $EnrollmentsTable createAlias(String alias) {
    return $EnrollmentsTable(attachedDatabase, alias);
  }
}

class Enrollment extends DataClass implements Insertable<Enrollment> {
  final int id;
  final int studentId;
  final int sectionId;
  final int academicYearId;

  /// د حاضرۍ لیست کې د ترتیب لپاره.
  final int? rollNo;
  final DateTime enrolledOn;
  final DateTime? leftOn;
  final bool isActive;
  const Enrollment({
    required this.id,
    required this.studentId,
    required this.sectionId,
    required this.academicYearId,
    this.rollNo,
    required this.enrolledOn,
    this.leftOn,
    required this.isActive,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['section_id'] = Variable<int>(sectionId);
    map['academic_year_id'] = Variable<int>(academicYearId);
    if (!nullToAbsent || rollNo != null) {
      map['roll_no'] = Variable<int>(rollNo);
    }
    map['enrolled_on'] = Variable<DateTime>(enrolledOn);
    if (!nullToAbsent || leftOn != null) {
      map['left_on'] = Variable<DateTime>(leftOn);
    }
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  EnrollmentsCompanion toCompanion(bool nullToAbsent) {
    return EnrollmentsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sectionId: Value(sectionId),
      academicYearId: Value(academicYearId),
      rollNo: rollNo == null && nullToAbsent
          ? const Value.absent()
          : Value(rollNo),
      enrolledOn: Value(enrolledOn),
      leftOn: leftOn == null && nullToAbsent
          ? const Value.absent()
          : Value(leftOn),
      isActive: Value(isActive),
    );
  }

  factory Enrollment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Enrollment(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      academicYearId: serializer.fromJson<int>(json['academicYearId']),
      rollNo: serializer.fromJson<int?>(json['rollNo']),
      enrolledOn: serializer.fromJson<DateTime>(json['enrolledOn']),
      leftOn: serializer.fromJson<DateTime?>(json['leftOn']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'sectionId': serializer.toJson<int>(sectionId),
      'academicYearId': serializer.toJson<int>(academicYearId),
      'rollNo': serializer.toJson<int?>(rollNo),
      'enrolledOn': serializer.toJson<DateTime>(enrolledOn),
      'leftOn': serializer.toJson<DateTime?>(leftOn),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  Enrollment copyWith({
    int? id,
    int? studentId,
    int? sectionId,
    int? academicYearId,
    Value<int?> rollNo = const Value.absent(),
    DateTime? enrolledOn,
    Value<DateTime?> leftOn = const Value.absent(),
    bool? isActive,
  }) => Enrollment(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sectionId: sectionId ?? this.sectionId,
    academicYearId: academicYearId ?? this.academicYearId,
    rollNo: rollNo.present ? rollNo.value : this.rollNo,
    enrolledOn: enrolledOn ?? this.enrolledOn,
    leftOn: leftOn.present ? leftOn.value : this.leftOn,
    isActive: isActive ?? this.isActive,
  );
  Enrollment copyWithCompanion(EnrollmentsCompanion data) {
    return Enrollment(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      academicYearId: data.academicYearId.present
          ? data.academicYearId.value
          : this.academicYearId,
      rollNo: data.rollNo.present ? data.rollNo.value : this.rollNo,
      enrolledOn: data.enrolledOn.present
          ? data.enrolledOn.value
          : this.enrolledOn,
      leftOn: data.leftOn.present ? data.leftOn.value : this.leftOn,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Enrollment(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('rollNo: $rollNo, ')
          ..write('enrolledOn: $enrolledOn, ')
          ..write('leftOn: $leftOn, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    sectionId,
    academicYearId,
    rollNo,
    enrolledOn,
    leftOn,
    isActive,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Enrollment &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sectionId == this.sectionId &&
          other.academicYearId == this.academicYearId &&
          other.rollNo == this.rollNo &&
          other.enrolledOn == this.enrolledOn &&
          other.leftOn == this.leftOn &&
          other.isActive == this.isActive);
}

class EnrollmentsCompanion extends UpdateCompanion<Enrollment> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int> sectionId;
  final Value<int> academicYearId;
  final Value<int?> rollNo;
  final Value<DateTime> enrolledOn;
  final Value<DateTime?> leftOn;
  final Value<bool> isActive;
  const EnrollmentsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.academicYearId = const Value.absent(),
    this.rollNo = const Value.absent(),
    this.enrolledOn = const Value.absent(),
    this.leftOn = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  EnrollmentsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required int sectionId,
    required int academicYearId,
    this.rollNo = const Value.absent(),
    this.enrolledOn = const Value.absent(),
    this.leftOn = const Value.absent(),
    this.isActive = const Value.absent(),
  }) : studentId = Value(studentId),
       sectionId = Value(sectionId),
       academicYearId = Value(academicYearId);
  static Insertable<Enrollment> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? sectionId,
    Expression<int>? academicYearId,
    Expression<int>? rollNo,
    Expression<DateTime>? enrolledOn,
    Expression<DateTime>? leftOn,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sectionId != null) 'section_id': sectionId,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (rollNo != null) 'roll_no': rollNo,
      if (enrolledOn != null) 'enrolled_on': enrolledOn,
      if (leftOn != null) 'left_on': leftOn,
      if (isActive != null) 'is_active': isActive,
    });
  }

  EnrollmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int>? sectionId,
    Value<int>? academicYearId,
    Value<int?>? rollNo,
    Value<DateTime>? enrolledOn,
    Value<DateTime?>? leftOn,
    Value<bool>? isActive,
  }) {
    return EnrollmentsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sectionId: sectionId ?? this.sectionId,
      academicYearId: academicYearId ?? this.academicYearId,
      rollNo: rollNo ?? this.rollNo,
      enrolledOn: enrolledOn ?? this.enrolledOn,
      leftOn: leftOn ?? this.leftOn,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (academicYearId.present) {
      map['academic_year_id'] = Variable<int>(academicYearId.value);
    }
    if (rollNo.present) {
      map['roll_no'] = Variable<int>(rollNo.value);
    }
    if (enrolledOn.present) {
      map['enrolled_on'] = Variable<DateTime>(enrolledOn.value);
    }
    if (leftOn.present) {
      map['left_on'] = Variable<DateTime>(leftOn.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EnrollmentsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('rollNo: $rollNo, ')
          ..write('enrolledOn: $enrolledOn, ')
          ..write('leftOn: $leftOn, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $AttendancesTable extends Attendances
    with TableInfo<$AttendancesTable, Attendance> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttendancesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
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
  static const VerificationMeta _checkInAtMeta = const VerificationMeta(
    'checkInAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkInAt = GeneratedColumn<DateTime>(
    'check_in_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _checkOutAtMeta = const VerificationMeta(
    'checkOutAt',
  );
  @override
  late final GeneratedColumn<DateTime> checkOutAt = GeneratedColumn<DateTime>(
    'check_out_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _methodMeta = const VerificationMeta('method');
  @override
  late final GeneratedColumn<String> method = GeneratedColumn<String>(
    'method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('roster'),
  );
  static const VerificationMeta _leaveRequestIdMeta = const VerificationMeta(
    'leaveRequestId',
  );
  @override
  late final GeneratedColumn<int> leaveRequestId = GeneratedColumn<int>(
    'leave_request_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedByUserIdMeta = const VerificationMeta(
    'recordedByUserId',
  );
  @override
  late final GeneratedColumn<int> recordedByUserId = GeneratedColumn<int>(
    'recorded_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recordedAtMeta = const VerificationMeta(
    'recordedAt',
  );
  @override
  late final GeneratedColumn<DateTime> recordedAt = GeneratedColumn<DateTime>(
    'recorded_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _parentNotifiedMeta = const VerificationMeta(
    'parentNotified',
  );
  @override
  late final GeneratedColumn<bool> parentNotified = GeneratedColumn<bool>(
    'parent_notified',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("parent_notified" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _parentNotifiedAtMeta = const VerificationMeta(
    'parentNotifiedAt',
  );
  @override
  late final GeneratedColumn<DateTime> parentNotifiedAt =
      GeneratedColumn<DateTime>(
        'parent_notified_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    sectionId,
    date,
    status,
    checkInAt,
    checkOutAt,
    method,
    leaveRequestId,
    note,
    recordedByUserId,
    recordedAt,
    parentNotified,
    parentNotifiedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attendances';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attendance> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('check_in_at')) {
      context.handle(
        _checkInAtMeta,
        checkInAt.isAcceptableOrUnknown(data['check_in_at']!, _checkInAtMeta),
      );
    }
    if (data.containsKey('check_out_at')) {
      context.handle(
        _checkOutAtMeta,
        checkOutAt.isAcceptableOrUnknown(
          data['check_out_at']!,
          _checkOutAtMeta,
        ),
      );
    }
    if (data.containsKey('method')) {
      context.handle(
        _methodMeta,
        method.isAcceptableOrUnknown(data['method']!, _methodMeta),
      );
    }
    if (data.containsKey('leave_request_id')) {
      context.handle(
        _leaveRequestIdMeta,
        leaveRequestId.isAcceptableOrUnknown(
          data['leave_request_id']!,
          _leaveRequestIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('recorded_by_user_id')) {
      context.handle(
        _recordedByUserIdMeta,
        recordedByUserId.isAcceptableOrUnknown(
          data['recorded_by_user_id']!,
          _recordedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('recorded_at')) {
      context.handle(
        _recordedAtMeta,
        recordedAt.isAcceptableOrUnknown(data['recorded_at']!, _recordedAtMeta),
      );
    }
    if (data.containsKey('parent_notified')) {
      context.handle(
        _parentNotifiedMeta,
        parentNotified.isAcceptableOrUnknown(
          data['parent_notified']!,
          _parentNotifiedMeta,
        ),
      );
    }
    if (data.containsKey('parent_notified_at')) {
      context.handle(
        _parentNotifiedAtMeta,
        parentNotifiedAt.isAcceptableOrUnknown(
          data['parent_notified_at']!,
          _parentNotifiedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {studentId, date},
  ];
  @override
  Attendance map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attendance(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      checkInAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_at'],
      ),
      checkOutAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_out_at'],
      ),
      method: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}method'],
      )!,
      leaveRequestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}leave_request_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      recordedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recorded_by_user_id'],
      ),
      recordedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}recorded_at'],
      )!,
      parentNotified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}parent_notified'],
      )!,
      parentNotifiedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}parent_notified_at'],
      ),
    );
  }

  @override
  $AttendancesTable createAlias(String alias) {
    return $AttendancesTable(attachedDatabase, alias);
  }
}

class Attendance extends DataClass implements Insertable<Attendance> {
  final int id;
  final int studentId;
  final int? sectionId;

  /// یوازې نېټه — بې وخته. د ورځې د یووالي لپاره.
  final DateTime date;

  /// `present` | `late` | `absent` | `leave` | `holiday`
  final String status;
  final DateTime? checkInAt;
  final DateTime? checkOutAt;

  /// څنګه ثبت شو: `qr` | `manual_id` | `roster` | `auto`
  final String method;

  /// که د اجازت‌نامې له امله «رخصت» شوی وي، دلته يې تړاو دی.
  final int? leaveRequestId;
  final String? note;
  final int? recordedByUserId;
  final DateTime recordedAt;

  /// ایا والدینو ته پیغام تللی؟ — چې دوه ځله ونه لېږل شي.
  final bool parentNotified;
  final DateTime? parentNotifiedAt;
  const Attendance({
    required this.id,
    required this.studentId,
    this.sectionId,
    required this.date,
    required this.status,
    this.checkInAt,
    this.checkOutAt,
    required this.method,
    this.leaveRequestId,
    this.note,
    this.recordedByUserId,
    required this.recordedAt,
    required this.parentNotified,
    this.parentNotifiedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    if (!nullToAbsent || sectionId != null) {
      map['section_id'] = Variable<int>(sectionId);
    }
    map['date'] = Variable<DateTime>(date);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || checkInAt != null) {
      map['check_in_at'] = Variable<DateTime>(checkInAt);
    }
    if (!nullToAbsent || checkOutAt != null) {
      map['check_out_at'] = Variable<DateTime>(checkOutAt);
    }
    map['method'] = Variable<String>(method);
    if (!nullToAbsent || leaveRequestId != null) {
      map['leave_request_id'] = Variable<int>(leaveRequestId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    if (!nullToAbsent || recordedByUserId != null) {
      map['recorded_by_user_id'] = Variable<int>(recordedByUserId);
    }
    map['recorded_at'] = Variable<DateTime>(recordedAt);
    map['parent_notified'] = Variable<bool>(parentNotified);
    if (!nullToAbsent || parentNotifiedAt != null) {
      map['parent_notified_at'] = Variable<DateTime>(parentNotifiedAt);
    }
    return map;
  }

  AttendancesCompanion toCompanion(bool nullToAbsent) {
    return AttendancesCompanion(
      id: Value(id),
      studentId: Value(studentId),
      sectionId: sectionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sectionId),
      date: Value(date),
      status: Value(status),
      checkInAt: checkInAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkInAt),
      checkOutAt: checkOutAt == null && nullToAbsent
          ? const Value.absent()
          : Value(checkOutAt),
      method: Value(method),
      leaveRequestId: leaveRequestId == null && nullToAbsent
          ? const Value.absent()
          : Value(leaveRequestId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      recordedByUserId: recordedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(recordedByUserId),
      recordedAt: Value(recordedAt),
      parentNotified: Value(parentNotified),
      parentNotifiedAt: parentNotifiedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(parentNotifiedAt),
    );
  }

  factory Attendance.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attendance(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      sectionId: serializer.fromJson<int?>(json['sectionId']),
      date: serializer.fromJson<DateTime>(json['date']),
      status: serializer.fromJson<String>(json['status']),
      checkInAt: serializer.fromJson<DateTime?>(json['checkInAt']),
      checkOutAt: serializer.fromJson<DateTime?>(json['checkOutAt']),
      method: serializer.fromJson<String>(json['method']),
      leaveRequestId: serializer.fromJson<int?>(json['leaveRequestId']),
      note: serializer.fromJson<String?>(json['note']),
      recordedByUserId: serializer.fromJson<int?>(json['recordedByUserId']),
      recordedAt: serializer.fromJson<DateTime>(json['recordedAt']),
      parentNotified: serializer.fromJson<bool>(json['parentNotified']),
      parentNotifiedAt: serializer.fromJson<DateTime?>(
        json['parentNotifiedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'sectionId': serializer.toJson<int?>(sectionId),
      'date': serializer.toJson<DateTime>(date),
      'status': serializer.toJson<String>(status),
      'checkInAt': serializer.toJson<DateTime?>(checkInAt),
      'checkOutAt': serializer.toJson<DateTime?>(checkOutAt),
      'method': serializer.toJson<String>(method),
      'leaveRequestId': serializer.toJson<int?>(leaveRequestId),
      'note': serializer.toJson<String?>(note),
      'recordedByUserId': serializer.toJson<int?>(recordedByUserId),
      'recordedAt': serializer.toJson<DateTime>(recordedAt),
      'parentNotified': serializer.toJson<bool>(parentNotified),
      'parentNotifiedAt': serializer.toJson<DateTime?>(parentNotifiedAt),
    };
  }

  Attendance copyWith({
    int? id,
    int? studentId,
    Value<int?> sectionId = const Value.absent(),
    DateTime? date,
    String? status,
    Value<DateTime?> checkInAt = const Value.absent(),
    Value<DateTime?> checkOutAt = const Value.absent(),
    String? method,
    Value<int?> leaveRequestId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    Value<int?> recordedByUserId = const Value.absent(),
    DateTime? recordedAt,
    bool? parentNotified,
    Value<DateTime?> parentNotifiedAt = const Value.absent(),
  }) => Attendance(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    sectionId: sectionId.present ? sectionId.value : this.sectionId,
    date: date ?? this.date,
    status: status ?? this.status,
    checkInAt: checkInAt.present ? checkInAt.value : this.checkInAt,
    checkOutAt: checkOutAt.present ? checkOutAt.value : this.checkOutAt,
    method: method ?? this.method,
    leaveRequestId: leaveRequestId.present
        ? leaveRequestId.value
        : this.leaveRequestId,
    note: note.present ? note.value : this.note,
    recordedByUserId: recordedByUserId.present
        ? recordedByUserId.value
        : this.recordedByUserId,
    recordedAt: recordedAt ?? this.recordedAt,
    parentNotified: parentNotified ?? this.parentNotified,
    parentNotifiedAt: parentNotifiedAt.present
        ? parentNotifiedAt.value
        : this.parentNotifiedAt,
  );
  Attendance copyWithCompanion(AttendancesCompanion data) {
    return Attendance(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      date: data.date.present ? data.date.value : this.date,
      status: data.status.present ? data.status.value : this.status,
      checkInAt: data.checkInAt.present ? data.checkInAt.value : this.checkInAt,
      checkOutAt: data.checkOutAt.present
          ? data.checkOutAt.value
          : this.checkOutAt,
      method: data.method.present ? data.method.value : this.method,
      leaveRequestId: data.leaveRequestId.present
          ? data.leaveRequestId.value
          : this.leaveRequestId,
      note: data.note.present ? data.note.value : this.note,
      recordedByUserId: data.recordedByUserId.present
          ? data.recordedByUserId.value
          : this.recordedByUserId,
      recordedAt: data.recordedAt.present
          ? data.recordedAt.value
          : this.recordedAt,
      parentNotified: data.parentNotified.present
          ? data.parentNotified.value
          : this.parentNotified,
      parentNotifiedAt: data.parentNotifiedAt.present
          ? data.parentNotifiedAt.value
          : this.parentNotifiedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attendance(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('checkInAt: $checkInAt, ')
          ..write('checkOutAt: $checkOutAt, ')
          ..write('method: $method, ')
          ..write('leaveRequestId: $leaveRequestId, ')
          ..write('note: $note, ')
          ..write('recordedByUserId: $recordedByUserId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('parentNotified: $parentNotified, ')
          ..write('parentNotifiedAt: $parentNotifiedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    sectionId,
    date,
    status,
    checkInAt,
    checkOutAt,
    method,
    leaveRequestId,
    note,
    recordedByUserId,
    recordedAt,
    parentNotified,
    parentNotifiedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attendance &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.sectionId == this.sectionId &&
          other.date == this.date &&
          other.status == this.status &&
          other.checkInAt == this.checkInAt &&
          other.checkOutAt == this.checkOutAt &&
          other.method == this.method &&
          other.leaveRequestId == this.leaveRequestId &&
          other.note == this.note &&
          other.recordedByUserId == this.recordedByUserId &&
          other.recordedAt == this.recordedAt &&
          other.parentNotified == this.parentNotified &&
          other.parentNotifiedAt == this.parentNotifiedAt);
}

class AttendancesCompanion extends UpdateCompanion<Attendance> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<int?> sectionId;
  final Value<DateTime> date;
  final Value<String> status;
  final Value<DateTime?> checkInAt;
  final Value<DateTime?> checkOutAt;
  final Value<String> method;
  final Value<int?> leaveRequestId;
  final Value<String?> note;
  final Value<int?> recordedByUserId;
  final Value<DateTime> recordedAt;
  final Value<bool> parentNotified;
  final Value<DateTime?> parentNotifiedAt;
  const AttendancesCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.date = const Value.absent(),
    this.status = const Value.absent(),
    this.checkInAt = const Value.absent(),
    this.checkOutAt = const Value.absent(),
    this.method = const Value.absent(),
    this.leaveRequestId = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedByUserId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.parentNotified = const Value.absent(),
    this.parentNotifiedAt = const Value.absent(),
  });
  AttendancesCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    this.sectionId = const Value.absent(),
    required DateTime date,
    required String status,
    this.checkInAt = const Value.absent(),
    this.checkOutAt = const Value.absent(),
    this.method = const Value.absent(),
    this.leaveRequestId = const Value.absent(),
    this.note = const Value.absent(),
    this.recordedByUserId = const Value.absent(),
    this.recordedAt = const Value.absent(),
    this.parentNotified = const Value.absent(),
    this.parentNotifiedAt = const Value.absent(),
  }) : studentId = Value(studentId),
       date = Value(date),
       status = Value(status);
  static Insertable<Attendance> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<int>? sectionId,
    Expression<DateTime>? date,
    Expression<String>? status,
    Expression<DateTime>? checkInAt,
    Expression<DateTime>? checkOutAt,
    Expression<String>? method,
    Expression<int>? leaveRequestId,
    Expression<String>? note,
    Expression<int>? recordedByUserId,
    Expression<DateTime>? recordedAt,
    Expression<bool>? parentNotified,
    Expression<DateTime>? parentNotifiedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (sectionId != null) 'section_id': sectionId,
      if (date != null) 'date': date,
      if (status != null) 'status': status,
      if (checkInAt != null) 'check_in_at': checkInAt,
      if (checkOutAt != null) 'check_out_at': checkOutAt,
      if (method != null) 'method': method,
      if (leaveRequestId != null) 'leave_request_id': leaveRequestId,
      if (note != null) 'note': note,
      if (recordedByUserId != null) 'recorded_by_user_id': recordedByUserId,
      if (recordedAt != null) 'recorded_at': recordedAt,
      if (parentNotified != null) 'parent_notified': parentNotified,
      if (parentNotifiedAt != null) 'parent_notified_at': parentNotifiedAt,
    });
  }

  AttendancesCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<int?>? sectionId,
    Value<DateTime>? date,
    Value<String>? status,
    Value<DateTime?>? checkInAt,
    Value<DateTime?>? checkOutAt,
    Value<String>? method,
    Value<int?>? leaveRequestId,
    Value<String?>? note,
    Value<int?>? recordedByUserId,
    Value<DateTime>? recordedAt,
    Value<bool>? parentNotified,
    Value<DateTime?>? parentNotifiedAt,
  }) {
    return AttendancesCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      sectionId: sectionId ?? this.sectionId,
      date: date ?? this.date,
      status: status ?? this.status,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      method: method ?? this.method,
      leaveRequestId: leaveRequestId ?? this.leaveRequestId,
      note: note ?? this.note,
      recordedByUserId: recordedByUserId ?? this.recordedByUserId,
      recordedAt: recordedAt ?? this.recordedAt,
      parentNotified: parentNotified ?? this.parentNotified,
      parentNotifiedAt: parentNotifiedAt ?? this.parentNotifiedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (checkInAt.present) {
      map['check_in_at'] = Variable<DateTime>(checkInAt.value);
    }
    if (checkOutAt.present) {
      map['check_out_at'] = Variable<DateTime>(checkOutAt.value);
    }
    if (method.present) {
      map['method'] = Variable<String>(method.value);
    }
    if (leaveRequestId.present) {
      map['leave_request_id'] = Variable<int>(leaveRequestId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (recordedByUserId.present) {
      map['recorded_by_user_id'] = Variable<int>(recordedByUserId.value);
    }
    if (recordedAt.present) {
      map['recorded_at'] = Variable<DateTime>(recordedAt.value);
    }
    if (parentNotified.present) {
      map['parent_notified'] = Variable<bool>(parentNotified.value);
    }
    if (parentNotifiedAt.present) {
      map['parent_notified_at'] = Variable<DateTime>(parentNotifiedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttendancesCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('sectionId: $sectionId, ')
          ..write('date: $date, ')
          ..write('status: $status, ')
          ..write('checkInAt: $checkInAt, ')
          ..write('checkOutAt: $checkOutAt, ')
          ..write('method: $method, ')
          ..write('leaveRequestId: $leaveRequestId, ')
          ..write('note: $note, ')
          ..write('recordedByUserId: $recordedByUserId, ')
          ..write('recordedAt: $recordedAt, ')
          ..write('parentNotified: $parentNotified, ')
          ..write('parentNotifiedAt: $parentNotifiedAt')
          ..write(')'))
        .toString();
  }
}

class $LeaveRequestsTable extends LeaveRequests
    with TableInfo<$LeaveRequestsTable, LeaveRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LeaveRequestsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _reasonTypeMeta = const VerificationMeta(
    'reasonType',
  );
  @override
  late final GeneratedColumn<String> reasonType = GeneratedColumn<String>(
    'reason_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonTextMeta = const VerificationMeta(
    'reasonText',
  );
  @override
  late final GeneratedColumn<String> reasonText = GeneratedColumn<String>(
    'reason_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fromDateMeta = const VerificationMeta(
    'fromDate',
  );
  @override
  late final GeneratedColumn<DateTime> fromDate = GeneratedColumn<DateTime>(
    'from_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toDateMeta = const VerificationMeta('toDate');
  @override
  late final GeneratedColumn<DateTime> toDate = GeneratedColumn<DateTime>(
    'to_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromTimeMeta = const VerificationMeta(
    'fromTime',
  );
  @override
  late final GeneratedColumn<String> fromTime = GeneratedColumn<String>(
    'from_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toTimeMeta = const VerificationMeta('toTime');
  @override
  late final GeneratedColumn<String> toTime = GeneratedColumn<String>(
    'to_time',
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
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _requestedViaMeta = const VerificationMeta(
    'requestedVia',
  );
  @override
  late final GeneratedColumn<String> requestedVia = GeneratedColumn<String>(
    'requested_via',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('reception'),
  );
  static const VerificationMeta _requestedByUserIdMeta = const VerificationMeta(
    'requestedByUserId',
  );
  @override
  late final GeneratedColumn<int> requestedByUserId = GeneratedColumn<int>(
    'requested_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedByUserIdMeta = const VerificationMeta(
    'decidedByUserId',
  );
  @override
  late final GeneratedColumn<int> decidedByUserId = GeneratedColumn<int>(
    'decided_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _decisionNoteMeta = const VerificationMeta(
    'decisionNote',
  );
  @override
  late final GeneratedColumn<String> decisionNote = GeneratedColumn<String>(
    'decision_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attachmentPathMeta = const VerificationMeta(
    'attachmentPath',
  );
  @override
  late final GeneratedColumn<String> attachmentPath = GeneratedColumn<String>(
    'attachment_path',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    studentId,
    reasonType,
    reasonText,
    fromDate,
    toDate,
    fromTime,
    toTime,
    status,
    requestedVia,
    requestedByUserId,
    decidedByUserId,
    decidedAt,
    decisionNote,
    attachmentPath,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'leave_requests';
  @override
  VerificationContext validateIntegrity(
    Insertable<LeaveRequest> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('reason_type')) {
      context.handle(
        _reasonTypeMeta,
        reasonType.isAcceptableOrUnknown(data['reason_type']!, _reasonTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonTypeMeta);
    }
    if (data.containsKey('reason_text')) {
      context.handle(
        _reasonTextMeta,
        reasonText.isAcceptableOrUnknown(data['reason_text']!, _reasonTextMeta),
      );
    }
    if (data.containsKey('from_date')) {
      context.handle(
        _fromDateMeta,
        fromDate.isAcceptableOrUnknown(data['from_date']!, _fromDateMeta),
      );
    } else if (isInserting) {
      context.missing(_fromDateMeta);
    }
    if (data.containsKey('to_date')) {
      context.handle(
        _toDateMeta,
        toDate.isAcceptableOrUnknown(data['to_date']!, _toDateMeta),
      );
    } else if (isInserting) {
      context.missing(_toDateMeta);
    }
    if (data.containsKey('from_time')) {
      context.handle(
        _fromTimeMeta,
        fromTime.isAcceptableOrUnknown(data['from_time']!, _fromTimeMeta),
      );
    }
    if (data.containsKey('to_time')) {
      context.handle(
        _toTimeMeta,
        toTime.isAcceptableOrUnknown(data['to_time']!, _toTimeMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('requested_via')) {
      context.handle(
        _requestedViaMeta,
        requestedVia.isAcceptableOrUnknown(
          data['requested_via']!,
          _requestedViaMeta,
        ),
      );
    }
    if (data.containsKey('requested_by_user_id')) {
      context.handle(
        _requestedByUserIdMeta,
        requestedByUserId.isAcceptableOrUnknown(
          data['requested_by_user_id']!,
          _requestedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('decided_by_user_id')) {
      context.handle(
        _decidedByUserIdMeta,
        decidedByUserId.isAcceptableOrUnknown(
          data['decided_by_user_id']!,
          _decidedByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    }
    if (data.containsKey('decision_note')) {
      context.handle(
        _decisionNoteMeta,
        decisionNote.isAcceptableOrUnknown(
          data['decision_note']!,
          _decisionNoteMeta,
        ),
      );
    }
    if (data.containsKey('attachment_path')) {
      context.handle(
        _attachmentPathMeta,
        attachmentPath.isAcceptableOrUnknown(
          data['attachment_path']!,
          _attachmentPathMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LeaveRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LeaveRequest(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      reasonType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_type'],
      )!,
      reasonText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason_text'],
      ),
      fromDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}from_date'],
      )!,
      toDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}to_date'],
      )!,
      fromTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}from_time'],
      ),
      toTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_time'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      requestedVia: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}requested_via'],
      )!,
      requestedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}requested_by_user_id'],
      ),
      decidedByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decided_by_user_id'],
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      ),
      decisionNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision_note'],
      ),
      attachmentPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attachment_path'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $LeaveRequestsTable createAlias(String alias) {
    return $LeaveRequestsTable(attachedDatabase, alias);
  }
}

class LeaveRequest extends DataClass implements Insertable<LeaveRequest> {
  final int id;
  final int studentId;

  /// `sick` | `family` | `travel` | `official` | `other`
  final String reasonType;
  final String? reasonText;
  final DateTime fromDate;
  final DateTime toDate;

  /// د ورځې دننه وتل — «HH:mm»، که ټوله ورځ نه وي.
  final String? fromTime;
  final String? toTime;

  /// `pending` | `approved` | `rejected` | `cancelled`
  final String status;

  /// چا غوښتنه وکړه: `reception` | `parent_app` | `teacher`
  final String requestedVia;
  final int? requestedByUserId;
  final int? decidedByUserId;
  final DateTime? decidedAt;
  final String? decisionNote;

  /// د ډاکټر پرچه یا نور سند.
  final String? attachmentPath;
  final DateTime createdAt;
  const LeaveRequest({
    required this.id,
    required this.studentId,
    required this.reasonType,
    this.reasonText,
    required this.fromDate,
    required this.toDate,
    this.fromTime,
    this.toTime,
    required this.status,
    required this.requestedVia,
    this.requestedByUserId,
    this.decidedByUserId,
    this.decidedAt,
    this.decisionNote,
    this.attachmentPath,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['student_id'] = Variable<int>(studentId);
    map['reason_type'] = Variable<String>(reasonType);
    if (!nullToAbsent || reasonText != null) {
      map['reason_text'] = Variable<String>(reasonText);
    }
    map['from_date'] = Variable<DateTime>(fromDate);
    map['to_date'] = Variable<DateTime>(toDate);
    if (!nullToAbsent || fromTime != null) {
      map['from_time'] = Variable<String>(fromTime);
    }
    if (!nullToAbsent || toTime != null) {
      map['to_time'] = Variable<String>(toTime);
    }
    map['status'] = Variable<String>(status);
    map['requested_via'] = Variable<String>(requestedVia);
    if (!nullToAbsent || requestedByUserId != null) {
      map['requested_by_user_id'] = Variable<int>(requestedByUserId);
    }
    if (!nullToAbsent || decidedByUserId != null) {
      map['decided_by_user_id'] = Variable<int>(decidedByUserId);
    }
    if (!nullToAbsent || decidedAt != null) {
      map['decided_at'] = Variable<DateTime>(decidedAt);
    }
    if (!nullToAbsent || decisionNote != null) {
      map['decision_note'] = Variable<String>(decisionNote);
    }
    if (!nullToAbsent || attachmentPath != null) {
      map['attachment_path'] = Variable<String>(attachmentPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  LeaveRequestsCompanion toCompanion(bool nullToAbsent) {
    return LeaveRequestsCompanion(
      id: Value(id),
      studentId: Value(studentId),
      reasonType: Value(reasonType),
      reasonText: reasonText == null && nullToAbsent
          ? const Value.absent()
          : Value(reasonText),
      fromDate: Value(fromDate),
      toDate: Value(toDate),
      fromTime: fromTime == null && nullToAbsent
          ? const Value.absent()
          : Value(fromTime),
      toTime: toTime == null && nullToAbsent
          ? const Value.absent()
          : Value(toTime),
      status: Value(status),
      requestedVia: Value(requestedVia),
      requestedByUserId: requestedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(requestedByUserId),
      decidedByUserId: decidedByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedByUserId),
      decidedAt: decidedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(decidedAt),
      decisionNote: decisionNote == null && nullToAbsent
          ? const Value.absent()
          : Value(decisionNote),
      attachmentPath: attachmentPath == null && nullToAbsent
          ? const Value.absent()
          : Value(attachmentPath),
      createdAt: Value(createdAt),
    );
  }

  factory LeaveRequest.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LeaveRequest(
      id: serializer.fromJson<int>(json['id']),
      studentId: serializer.fromJson<int>(json['studentId']),
      reasonType: serializer.fromJson<String>(json['reasonType']),
      reasonText: serializer.fromJson<String?>(json['reasonText']),
      fromDate: serializer.fromJson<DateTime>(json['fromDate']),
      toDate: serializer.fromJson<DateTime>(json['toDate']),
      fromTime: serializer.fromJson<String?>(json['fromTime']),
      toTime: serializer.fromJson<String?>(json['toTime']),
      status: serializer.fromJson<String>(json['status']),
      requestedVia: serializer.fromJson<String>(json['requestedVia']),
      requestedByUserId: serializer.fromJson<int?>(json['requestedByUserId']),
      decidedByUserId: serializer.fromJson<int?>(json['decidedByUserId']),
      decidedAt: serializer.fromJson<DateTime?>(json['decidedAt']),
      decisionNote: serializer.fromJson<String?>(json['decisionNote']),
      attachmentPath: serializer.fromJson<String?>(json['attachmentPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'studentId': serializer.toJson<int>(studentId),
      'reasonType': serializer.toJson<String>(reasonType),
      'reasonText': serializer.toJson<String?>(reasonText),
      'fromDate': serializer.toJson<DateTime>(fromDate),
      'toDate': serializer.toJson<DateTime>(toDate),
      'fromTime': serializer.toJson<String?>(fromTime),
      'toTime': serializer.toJson<String?>(toTime),
      'status': serializer.toJson<String>(status),
      'requestedVia': serializer.toJson<String>(requestedVia),
      'requestedByUserId': serializer.toJson<int?>(requestedByUserId),
      'decidedByUserId': serializer.toJson<int?>(decidedByUserId),
      'decidedAt': serializer.toJson<DateTime?>(decidedAt),
      'decisionNote': serializer.toJson<String?>(decisionNote),
      'attachmentPath': serializer.toJson<String?>(attachmentPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  LeaveRequest copyWith({
    int? id,
    int? studentId,
    String? reasonType,
    Value<String?> reasonText = const Value.absent(),
    DateTime? fromDate,
    DateTime? toDate,
    Value<String?> fromTime = const Value.absent(),
    Value<String?> toTime = const Value.absent(),
    String? status,
    String? requestedVia,
    Value<int?> requestedByUserId = const Value.absent(),
    Value<int?> decidedByUserId = const Value.absent(),
    Value<DateTime?> decidedAt = const Value.absent(),
    Value<String?> decisionNote = const Value.absent(),
    Value<String?> attachmentPath = const Value.absent(),
    DateTime? createdAt,
  }) => LeaveRequest(
    id: id ?? this.id,
    studentId: studentId ?? this.studentId,
    reasonType: reasonType ?? this.reasonType,
    reasonText: reasonText.present ? reasonText.value : this.reasonText,
    fromDate: fromDate ?? this.fromDate,
    toDate: toDate ?? this.toDate,
    fromTime: fromTime.present ? fromTime.value : this.fromTime,
    toTime: toTime.present ? toTime.value : this.toTime,
    status: status ?? this.status,
    requestedVia: requestedVia ?? this.requestedVia,
    requestedByUserId: requestedByUserId.present
        ? requestedByUserId.value
        : this.requestedByUserId,
    decidedByUserId: decidedByUserId.present
        ? decidedByUserId.value
        : this.decidedByUserId,
    decidedAt: decidedAt.present ? decidedAt.value : this.decidedAt,
    decisionNote: decisionNote.present ? decisionNote.value : this.decisionNote,
    attachmentPath: attachmentPath.present
        ? attachmentPath.value
        : this.attachmentPath,
    createdAt: createdAt ?? this.createdAt,
  );
  LeaveRequest copyWithCompanion(LeaveRequestsCompanion data) {
    return LeaveRequest(
      id: data.id.present ? data.id.value : this.id,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      reasonType: data.reasonType.present
          ? data.reasonType.value
          : this.reasonType,
      reasonText: data.reasonText.present
          ? data.reasonText.value
          : this.reasonText,
      fromDate: data.fromDate.present ? data.fromDate.value : this.fromDate,
      toDate: data.toDate.present ? data.toDate.value : this.toDate,
      fromTime: data.fromTime.present ? data.fromTime.value : this.fromTime,
      toTime: data.toTime.present ? data.toTime.value : this.toTime,
      status: data.status.present ? data.status.value : this.status,
      requestedVia: data.requestedVia.present
          ? data.requestedVia.value
          : this.requestedVia,
      requestedByUserId: data.requestedByUserId.present
          ? data.requestedByUserId.value
          : this.requestedByUserId,
      decidedByUserId: data.decidedByUserId.present
          ? data.decidedByUserId.value
          : this.decidedByUserId,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
      decisionNote: data.decisionNote.present
          ? data.decisionNote.value
          : this.decisionNote,
      attachmentPath: data.attachmentPath.present
          ? data.attachmentPath.value
          : this.attachmentPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LeaveRequest(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('reasonType: $reasonType, ')
          ..write('reasonText: $reasonText, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('fromTime: $fromTime, ')
          ..write('toTime: $toTime, ')
          ..write('status: $status, ')
          ..write('requestedVia: $requestedVia, ')
          ..write('requestedByUserId: $requestedByUserId, ')
          ..write('decidedByUserId: $decidedByUserId, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('decisionNote: $decisionNote, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    studentId,
    reasonType,
    reasonText,
    fromDate,
    toDate,
    fromTime,
    toTime,
    status,
    requestedVia,
    requestedByUserId,
    decidedByUserId,
    decidedAt,
    decisionNote,
    attachmentPath,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LeaveRequest &&
          other.id == this.id &&
          other.studentId == this.studentId &&
          other.reasonType == this.reasonType &&
          other.reasonText == this.reasonText &&
          other.fromDate == this.fromDate &&
          other.toDate == this.toDate &&
          other.fromTime == this.fromTime &&
          other.toTime == this.toTime &&
          other.status == this.status &&
          other.requestedVia == this.requestedVia &&
          other.requestedByUserId == this.requestedByUserId &&
          other.decidedByUserId == this.decidedByUserId &&
          other.decidedAt == this.decidedAt &&
          other.decisionNote == this.decisionNote &&
          other.attachmentPath == this.attachmentPath &&
          other.createdAt == this.createdAt);
}

class LeaveRequestsCompanion extends UpdateCompanion<LeaveRequest> {
  final Value<int> id;
  final Value<int> studentId;
  final Value<String> reasonType;
  final Value<String?> reasonText;
  final Value<DateTime> fromDate;
  final Value<DateTime> toDate;
  final Value<String?> fromTime;
  final Value<String?> toTime;
  final Value<String> status;
  final Value<String> requestedVia;
  final Value<int?> requestedByUserId;
  final Value<int?> decidedByUserId;
  final Value<DateTime?> decidedAt;
  final Value<String?> decisionNote;
  final Value<String?> attachmentPath;
  final Value<DateTime> createdAt;
  const LeaveRequestsCompanion({
    this.id = const Value.absent(),
    this.studentId = const Value.absent(),
    this.reasonType = const Value.absent(),
    this.reasonText = const Value.absent(),
    this.fromDate = const Value.absent(),
    this.toDate = const Value.absent(),
    this.fromTime = const Value.absent(),
    this.toTime = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedVia = const Value.absent(),
    this.requestedByUserId = const Value.absent(),
    this.decidedByUserId = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.decisionNote = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  LeaveRequestsCompanion.insert({
    this.id = const Value.absent(),
    required int studentId,
    required String reasonType,
    this.reasonText = const Value.absent(),
    required DateTime fromDate,
    required DateTime toDate,
    this.fromTime = const Value.absent(),
    this.toTime = const Value.absent(),
    this.status = const Value.absent(),
    this.requestedVia = const Value.absent(),
    this.requestedByUserId = const Value.absent(),
    this.decidedByUserId = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.decisionNote = const Value.absent(),
    this.attachmentPath = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : studentId = Value(studentId),
       reasonType = Value(reasonType),
       fromDate = Value(fromDate),
       toDate = Value(toDate);
  static Insertable<LeaveRequest> custom({
    Expression<int>? id,
    Expression<int>? studentId,
    Expression<String>? reasonType,
    Expression<String>? reasonText,
    Expression<DateTime>? fromDate,
    Expression<DateTime>? toDate,
    Expression<String>? fromTime,
    Expression<String>? toTime,
    Expression<String>? status,
    Expression<String>? requestedVia,
    Expression<int>? requestedByUserId,
    Expression<int>? decidedByUserId,
    Expression<DateTime>? decidedAt,
    Expression<String>? decisionNote,
    Expression<String>? attachmentPath,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (studentId != null) 'student_id': studentId,
      if (reasonType != null) 'reason_type': reasonType,
      if (reasonText != null) 'reason_text': reasonText,
      if (fromDate != null) 'from_date': fromDate,
      if (toDate != null) 'to_date': toDate,
      if (fromTime != null) 'from_time': fromTime,
      if (toTime != null) 'to_time': toTime,
      if (status != null) 'status': status,
      if (requestedVia != null) 'requested_via': requestedVia,
      if (requestedByUserId != null) 'requested_by_user_id': requestedByUserId,
      if (decidedByUserId != null) 'decided_by_user_id': decidedByUserId,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (decisionNote != null) 'decision_note': decisionNote,
      if (attachmentPath != null) 'attachment_path': attachmentPath,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  LeaveRequestsCompanion copyWith({
    Value<int>? id,
    Value<int>? studentId,
    Value<String>? reasonType,
    Value<String?>? reasonText,
    Value<DateTime>? fromDate,
    Value<DateTime>? toDate,
    Value<String?>? fromTime,
    Value<String?>? toTime,
    Value<String>? status,
    Value<String>? requestedVia,
    Value<int?>? requestedByUserId,
    Value<int?>? decidedByUserId,
    Value<DateTime?>? decidedAt,
    Value<String?>? decisionNote,
    Value<String?>? attachmentPath,
    Value<DateTime>? createdAt,
  }) {
    return LeaveRequestsCompanion(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      reasonType: reasonType ?? this.reasonType,
      reasonText: reasonText ?? this.reasonText,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      fromTime: fromTime ?? this.fromTime,
      toTime: toTime ?? this.toTime,
      status: status ?? this.status,
      requestedVia: requestedVia ?? this.requestedVia,
      requestedByUserId: requestedByUserId ?? this.requestedByUserId,
      decidedByUserId: decidedByUserId ?? this.decidedByUserId,
      decidedAt: decidedAt ?? this.decidedAt,
      decisionNote: decisionNote ?? this.decisionNote,
      attachmentPath: attachmentPath ?? this.attachmentPath,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (reasonType.present) {
      map['reason_type'] = Variable<String>(reasonType.value);
    }
    if (reasonText.present) {
      map['reason_text'] = Variable<String>(reasonText.value);
    }
    if (fromDate.present) {
      map['from_date'] = Variable<DateTime>(fromDate.value);
    }
    if (toDate.present) {
      map['to_date'] = Variable<DateTime>(toDate.value);
    }
    if (fromTime.present) {
      map['from_time'] = Variable<String>(fromTime.value);
    }
    if (toTime.present) {
      map['to_time'] = Variable<String>(toTime.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (requestedVia.present) {
      map['requested_via'] = Variable<String>(requestedVia.value);
    }
    if (requestedByUserId.present) {
      map['requested_by_user_id'] = Variable<int>(requestedByUserId.value);
    }
    if (decidedByUserId.present) {
      map['decided_by_user_id'] = Variable<int>(decidedByUserId.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (decisionNote.present) {
      map['decision_note'] = Variable<String>(decisionNote.value);
    }
    if (attachmentPath.present) {
      map['attachment_path'] = Variable<String>(attachmentPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LeaveRequestsCompanion(')
          ..write('id: $id, ')
          ..write('studentId: $studentId, ')
          ..write('reasonType: $reasonType, ')
          ..write('reasonText: $reasonText, ')
          ..write('fromDate: $fromDate, ')
          ..write('toDate: $toDate, ')
          ..write('fromTime: $fromTime, ')
          ..write('toTime: $toTime, ')
          ..write('status: $status, ')
          ..write('requestedVia: $requestedVia, ')
          ..write('requestedByUserId: $requestedByUserId, ')
          ..write('decidedByUserId: $decidedByUserId, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('decisionNote: $decisionNote, ')
          ..write('attachmentPath: $attachmentPath, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AuditLogsTable extends AuditLogs
    with TableInfo<$AuditLogsTable, AuditLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AuditLogsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userNameMeta = const VerificationMeta(
    'userName',
  );
  @override
  late final GeneratedColumn<String> userName = GeneratedColumn<String>(
    'user_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actionMeta = const VerificationMeta('action');
  @override
  late final GeneratedColumn<String> action = GeneratedColumn<String>(
    'action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
    'entity',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<int> entityId = GeneratedColumn<int>(
    'entity_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _changesJsonMeta = const VerificationMeta(
    'changesJson',
  );
  @override
  late final GeneratedColumn<String> changesJson = GeneratedColumn<String>(
    'changes_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _atMeta = const VerificationMeta('at');
  @override
  late final GeneratedColumn<DateTime> at = GeneratedColumn<DateTime>(
    'at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userId,
    userName,
    action,
    entity,
    entityId,
    changesJson,
    at,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLog> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('user_name')) {
      context.handle(
        _userNameMeta,
        userName.isAcceptableOrUnknown(data['user_name']!, _userNameMeta),
      );
    }
    if (data.containsKey('action')) {
      context.handle(
        _actionMeta,
        action.isAcceptableOrUnknown(data['action']!, _actionMeta),
      );
    } else if (isInserting) {
      context.missing(_actionMeta);
    }
    if (data.containsKey('entity')) {
      context.handle(
        _entityMeta,
        entity.isAcceptableOrUnknown(data['entity']!, _entityMeta),
      );
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    }
    if (data.containsKey('changes_json')) {
      context.handle(
        _changesJsonMeta,
        changesJson.isAcceptableOrUnknown(
          data['changes_json']!,
          _changesJsonMeta,
        ),
      );
    }
    if (data.containsKey('at')) {
      context.handle(_atMeta, at.isAcceptableOrUnknown(data['at']!, _atMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLog(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      userName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_name'],
      ),
      action: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action'],
      )!,
      entity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entity_id'],
      ),
      changesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}changes_json'],
      ),
      at: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}at'],
      )!,
    );
  }

  @override
  $AuditLogsTable createAlias(String alias) {
    return $AuditLogsTable(attachedDatabase, alias);
  }
}

class AuditLog extends DataClass implements Insertable<AuditLog> {
  final int id;
  final int? userId;
  final String? userName;

  /// `create` | `update` | `delete` | `login` | `logout` | `export`
  final String action;

  /// کوم جدول یا ماډل — «students»، «attendance».
  final String entity;
  final int? entityId;

  /// د بدلون توپیر — JSON {"field": {"from": …, "to": …}}
  final String? changesJson;
  final DateTime at;
  const AuditLog({
    required this.id,
    this.userId,
    this.userName,
    required this.action,
    required this.entity,
    this.entityId,
    this.changesJson,
    required this.at,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || userName != null) {
      map['user_name'] = Variable<String>(userName);
    }
    map['action'] = Variable<String>(action);
    map['entity'] = Variable<String>(entity);
    if (!nullToAbsent || entityId != null) {
      map['entity_id'] = Variable<int>(entityId);
    }
    if (!nullToAbsent || changesJson != null) {
      map['changes_json'] = Variable<String>(changesJson);
    }
    map['at'] = Variable<DateTime>(at);
    return map;
  }

  AuditLogsCompanion toCompanion(bool nullToAbsent) {
    return AuditLogsCompanion(
      id: Value(id),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      userName: userName == null && nullToAbsent
          ? const Value.absent()
          : Value(userName),
      action: Value(action),
      entity: Value(entity),
      entityId: entityId == null && nullToAbsent
          ? const Value.absent()
          : Value(entityId),
      changesJson: changesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(changesJson),
      at: Value(at),
    );
  }

  factory AuditLog.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLog(
      id: serializer.fromJson<int>(json['id']),
      userId: serializer.fromJson<int?>(json['userId']),
      userName: serializer.fromJson<String?>(json['userName']),
      action: serializer.fromJson<String>(json['action']),
      entity: serializer.fromJson<String>(json['entity']),
      entityId: serializer.fromJson<int?>(json['entityId']),
      changesJson: serializer.fromJson<String?>(json['changesJson']),
      at: serializer.fromJson<DateTime>(json['at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userId': serializer.toJson<int?>(userId),
      'userName': serializer.toJson<String?>(userName),
      'action': serializer.toJson<String>(action),
      'entity': serializer.toJson<String>(entity),
      'entityId': serializer.toJson<int?>(entityId),
      'changesJson': serializer.toJson<String?>(changesJson),
      'at': serializer.toJson<DateTime>(at),
    };
  }

  AuditLog copyWith({
    int? id,
    Value<int?> userId = const Value.absent(),
    Value<String?> userName = const Value.absent(),
    String? action,
    String? entity,
    Value<int?> entityId = const Value.absent(),
    Value<String?> changesJson = const Value.absent(),
    DateTime? at,
  }) => AuditLog(
    id: id ?? this.id,
    userId: userId.present ? userId.value : this.userId,
    userName: userName.present ? userName.value : this.userName,
    action: action ?? this.action,
    entity: entity ?? this.entity,
    entityId: entityId.present ? entityId.value : this.entityId,
    changesJson: changesJson.present ? changesJson.value : this.changesJson,
    at: at ?? this.at,
  );
  AuditLog copyWithCompanion(AuditLogsCompanion data) {
    return AuditLog(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      userName: data.userName.present ? data.userName.value : this.userName,
      action: data.action.present ? data.action.value : this.action,
      entity: data.entity.present ? data.entity.value : this.entity,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      changesJson: data.changesJson.present
          ? data.changesJson.value
          : this.changesJson,
      at: data.at.present ? data.at.value : this.at,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLog(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('changesJson: $changesJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    userName,
    action,
    entity,
    entityId,
    changesJson,
    at,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLog &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.userName == this.userName &&
          other.action == this.action &&
          other.entity == this.entity &&
          other.entityId == this.entityId &&
          other.changesJson == this.changesJson &&
          other.at == this.at);
}

class AuditLogsCompanion extends UpdateCompanion<AuditLog> {
  final Value<int> id;
  final Value<int?> userId;
  final Value<String?> userName;
  final Value<String> action;
  final Value<String> entity;
  final Value<int?> entityId;
  final Value<String?> changesJson;
  final Value<DateTime> at;
  const AuditLogsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    this.action = const Value.absent(),
    this.entity = const Value.absent(),
    this.entityId = const Value.absent(),
    this.changesJson = const Value.absent(),
    this.at = const Value.absent(),
  });
  AuditLogsCompanion.insert({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.userName = const Value.absent(),
    required String action,
    required String entity,
    this.entityId = const Value.absent(),
    this.changesJson = const Value.absent(),
    this.at = const Value.absent(),
  }) : action = Value(action),
       entity = Value(entity);
  static Insertable<AuditLog> custom({
    Expression<int>? id,
    Expression<int>? userId,
    Expression<String>? userName,
    Expression<String>? action,
    Expression<String>? entity,
    Expression<int>? entityId,
    Expression<String>? changesJson,
    Expression<DateTime>? at,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (userName != null) 'user_name': userName,
      if (action != null) 'action': action,
      if (entity != null) 'entity': entity,
      if (entityId != null) 'entity_id': entityId,
      if (changesJson != null) 'changes_json': changesJson,
      if (at != null) 'at': at,
    });
  }

  AuditLogsCompanion copyWith({
    Value<int>? id,
    Value<int?>? userId,
    Value<String?>? userName,
    Value<String>? action,
    Value<String>? entity,
    Value<int?>? entityId,
    Value<String?>? changesJson,
    Value<DateTime>? at,
  }) {
    return AuditLogsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      action: action ?? this.action,
      entity: entity ?? this.entity,
      entityId: entityId ?? this.entityId,
      changesJson: changesJson ?? this.changesJson,
      at: at ?? this.at,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (userName.present) {
      map['user_name'] = Variable<String>(userName.value);
    }
    if (action.present) {
      map['action'] = Variable<String>(action.value);
    }
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<int>(entityId.value);
    }
    if (changesJson.present) {
      map['changes_json'] = Variable<String>(changesJson.value);
    }
    if (at.present) {
      map['at'] = Variable<DateTime>(at.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('userName: $userName, ')
          ..write('action: $action, ')
          ..write('entity: $entity, ')
          ..write('entityId: $entityId, ')
          ..write('changesJson: $changesJson, ')
          ..write('at: $at')
          ..write(')'))
        .toString();
  }
}

class $DevicesTable extends Devices with TableInfo<$DevicesTable, Device> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _platformMeta = const VerificationMeta(
    'platform',
  );
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
    'platform',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('android'),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<int> guardianId = GeneratedColumn<int>(
    'guardian_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES guardians (id)',
    ),
  );
  static const VerificationMeta _tokenHashMeta = const VerificationMeta(
    'tokenHash',
  );
  @override
  late final GeneratedColumn<String> tokenHash = GeneratedColumn<String>(
    'token_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pushTokenMeta = const VerificationMeta(
    'pushToken',
  );
  @override
  late final GeneratedColumn<String> pushToken = GeneratedColumn<String>(
    'push_token',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pairedAtMeta = const VerificationMeta(
    'pairedAt',
  );
  @override
  late final GeneratedColumn<DateTime> pairedAt = GeneratedColumn<DateTime>(
    'paired_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastSeenAtMeta = const VerificationMeta(
    'lastSeenAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSeenAt = GeneratedColumn<DateTime>(
    'last_seen_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastIpMeta = const VerificationMeta('lastIp');
  @override
  late final GeneratedColumn<String> lastIp = GeneratedColumn<String>(
    'last_ip',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revokedAtMeta = const VerificationMeta(
    'revokedAt',
  );
  @override
  late final GeneratedColumn<DateTime> revokedAt = GeneratedColumn<DateTime>(
    'revoked_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    platform,
    role,
    userId,
    guardianId,
    tokenHash,
    pushToken,
    pairedAt,
    lastSeenAt,
    lastIp,
    revokedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices';
  @override
  VerificationContext validateIntegrity(
    Insertable<Device> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('platform')) {
      context.handle(
        _platformMeta,
        platform.isAcceptableOrUnknown(data['platform']!, _platformMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    }
    if (data.containsKey('token_hash')) {
      context.handle(
        _tokenHashMeta,
        tokenHash.isAcceptableOrUnknown(data['token_hash']!, _tokenHashMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenHashMeta);
    }
    if (data.containsKey('push_token')) {
      context.handle(
        _pushTokenMeta,
        pushToken.isAcceptableOrUnknown(data['push_token']!, _pushTokenMeta),
      );
    }
    if (data.containsKey('paired_at')) {
      context.handle(
        _pairedAtMeta,
        pairedAt.isAcceptableOrUnknown(data['paired_at']!, _pairedAtMeta),
      );
    }
    if (data.containsKey('last_seen_at')) {
      context.handle(
        _lastSeenAtMeta,
        lastSeenAt.isAcceptableOrUnknown(
          data['last_seen_at']!,
          _lastSeenAtMeta,
        ),
      );
    }
    if (data.containsKey('last_ip')) {
      context.handle(
        _lastIpMeta,
        lastIp.isAcceptableOrUnknown(data['last_ip']!, _lastIpMeta),
      );
    }
    if (data.containsKey('revoked_at')) {
      context.handle(
        _revokedAtMeta,
        revokedAt.isAcceptableOrUnknown(data['revoked_at']!, _revokedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {tokenHash},
  ];
  @override
  Device map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Device(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      platform: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}platform'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guardian_id'],
      ),
      tokenHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_hash'],
      )!,
      pushToken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}push_token'],
      ),
      pairedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}paired_at'],
      )!,
      lastSeenAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_seen_at'],
      ),
      lastIp: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_ip'],
      ),
      revokedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}revoked_at'],
      ),
    );
  }

  @override
  $DevicesTable createAlias(String alias) {
    return $DevicesTable(attachedDatabase, alias);
  }
}

class Device extends DataClass implements Insertable<Device> {
  final int id;

  /// «د مدیر Samsung» — کارن يې پخپله ولیکي.
  final String name;
  final String platform;

  /// `manager` | `parent`
  final String role;

  /// که مدیر وي — کوم کارن ته تړلی.
  final int? userId;

  /// که والدین وي — کوم سرپرست ته تړلی.
  final int? guardianId;

  /// د bearer توکن SHA-256.
  final String tokenHash;

  /// د FCM/پش لپاره — اوس یوازې ساتل کېږي، په اوږد مهال کې کارېږي.
  final String? pushToken;
  final DateTime pairedAt;
  final DateTime? lastSeenAt;
  final String? lastIp;
  final DateTime? revokedAt;
  const Device({
    required this.id,
    required this.name,
    required this.platform,
    required this.role,
    this.userId,
    this.guardianId,
    required this.tokenHash,
    this.pushToken,
    required this.pairedAt,
    this.lastSeenAt,
    this.lastIp,
    this.revokedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['platform'] = Variable<String>(platform);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || guardianId != null) {
      map['guardian_id'] = Variable<int>(guardianId);
    }
    map['token_hash'] = Variable<String>(tokenHash);
    if (!nullToAbsent || pushToken != null) {
      map['push_token'] = Variable<String>(pushToken);
    }
    map['paired_at'] = Variable<DateTime>(pairedAt);
    if (!nullToAbsent || lastSeenAt != null) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt);
    }
    if (!nullToAbsent || lastIp != null) {
      map['last_ip'] = Variable<String>(lastIp);
    }
    if (!nullToAbsent || revokedAt != null) {
      map['revoked_at'] = Variable<DateTime>(revokedAt);
    }
    return map;
  }

  DevicesCompanion toCompanion(bool nullToAbsent) {
    return DevicesCompanion(
      id: Value(id),
      name: Value(name),
      platform: Value(platform),
      role: Value(role),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      guardianId: guardianId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianId),
      tokenHash: Value(tokenHash),
      pushToken: pushToken == null && nullToAbsent
          ? const Value.absent()
          : Value(pushToken),
      pairedAt: Value(pairedAt),
      lastSeenAt: lastSeenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSeenAt),
      lastIp: lastIp == null && nullToAbsent
          ? const Value.absent()
          : Value(lastIp),
      revokedAt: revokedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(revokedAt),
    );
  }

  factory Device.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Device(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      platform: serializer.fromJson<String>(json['platform']),
      role: serializer.fromJson<String>(json['role']),
      userId: serializer.fromJson<int?>(json['userId']),
      guardianId: serializer.fromJson<int?>(json['guardianId']),
      tokenHash: serializer.fromJson<String>(json['tokenHash']),
      pushToken: serializer.fromJson<String?>(json['pushToken']),
      pairedAt: serializer.fromJson<DateTime>(json['pairedAt']),
      lastSeenAt: serializer.fromJson<DateTime?>(json['lastSeenAt']),
      lastIp: serializer.fromJson<String?>(json['lastIp']),
      revokedAt: serializer.fromJson<DateTime?>(json['revokedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'platform': serializer.toJson<String>(platform),
      'role': serializer.toJson<String>(role),
      'userId': serializer.toJson<int?>(userId),
      'guardianId': serializer.toJson<int?>(guardianId),
      'tokenHash': serializer.toJson<String>(tokenHash),
      'pushToken': serializer.toJson<String?>(pushToken),
      'pairedAt': serializer.toJson<DateTime>(pairedAt),
      'lastSeenAt': serializer.toJson<DateTime?>(lastSeenAt),
      'lastIp': serializer.toJson<String?>(lastIp),
      'revokedAt': serializer.toJson<DateTime?>(revokedAt),
    };
  }

  Device copyWith({
    int? id,
    String? name,
    String? platform,
    String? role,
    Value<int?> userId = const Value.absent(),
    Value<int?> guardianId = const Value.absent(),
    String? tokenHash,
    Value<String?> pushToken = const Value.absent(),
    DateTime? pairedAt,
    Value<DateTime?> lastSeenAt = const Value.absent(),
    Value<String?> lastIp = const Value.absent(),
    Value<DateTime?> revokedAt = const Value.absent(),
  }) => Device(
    id: id ?? this.id,
    name: name ?? this.name,
    platform: platform ?? this.platform,
    role: role ?? this.role,
    userId: userId.present ? userId.value : this.userId,
    guardianId: guardianId.present ? guardianId.value : this.guardianId,
    tokenHash: tokenHash ?? this.tokenHash,
    pushToken: pushToken.present ? pushToken.value : this.pushToken,
    pairedAt: pairedAt ?? this.pairedAt,
    lastSeenAt: lastSeenAt.present ? lastSeenAt.value : this.lastSeenAt,
    lastIp: lastIp.present ? lastIp.value : this.lastIp,
    revokedAt: revokedAt.present ? revokedAt.value : this.revokedAt,
  );
  Device copyWithCompanion(DevicesCompanion data) {
    return Device(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      platform: data.platform.present ? data.platform.value : this.platform,
      role: data.role.present ? data.role.value : this.role,
      userId: data.userId.present ? data.userId.value : this.userId,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      tokenHash: data.tokenHash.present ? data.tokenHash.value : this.tokenHash,
      pushToken: data.pushToken.present ? data.pushToken.value : this.pushToken,
      pairedAt: data.pairedAt.present ? data.pairedAt.value : this.pairedAt,
      lastSeenAt: data.lastSeenAt.present
          ? data.lastSeenAt.value
          : this.lastSeenAt,
      lastIp: data.lastIp.present ? data.lastIp.value : this.lastIp,
      revokedAt: data.revokedAt.present ? data.revokedAt.value : this.revokedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Device(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('role: $role, ')
          ..write('userId: $userId, ')
          ..write('guardianId: $guardianId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('pushToken: $pushToken, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastIp: $lastIp, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    platform,
    role,
    userId,
    guardianId,
    tokenHash,
    pushToken,
    pairedAt,
    lastSeenAt,
    lastIp,
    revokedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Device &&
          other.id == this.id &&
          other.name == this.name &&
          other.platform == this.platform &&
          other.role == this.role &&
          other.userId == this.userId &&
          other.guardianId == this.guardianId &&
          other.tokenHash == this.tokenHash &&
          other.pushToken == this.pushToken &&
          other.pairedAt == this.pairedAt &&
          other.lastSeenAt == this.lastSeenAt &&
          other.lastIp == this.lastIp &&
          other.revokedAt == this.revokedAt);
}

class DevicesCompanion extends UpdateCompanion<Device> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> platform;
  final Value<String> role;
  final Value<int?> userId;
  final Value<int?> guardianId;
  final Value<String> tokenHash;
  final Value<String?> pushToken;
  final Value<DateTime> pairedAt;
  final Value<DateTime?> lastSeenAt;
  final Value<String?> lastIp;
  final Value<DateTime?> revokedAt;
  const DevicesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.platform = const Value.absent(),
    this.role = const Value.absent(),
    this.userId = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.tokenHash = const Value.absent(),
    this.pushToken = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastIp = const Value.absent(),
    this.revokedAt = const Value.absent(),
  });
  DevicesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.platform = const Value.absent(),
    required String role,
    this.userId = const Value.absent(),
    this.guardianId = const Value.absent(),
    required String tokenHash,
    this.pushToken = const Value.absent(),
    this.pairedAt = const Value.absent(),
    this.lastSeenAt = const Value.absent(),
    this.lastIp = const Value.absent(),
    this.revokedAt = const Value.absent(),
  }) : name = Value(name),
       role = Value(role),
       tokenHash = Value(tokenHash);
  static Insertable<Device> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? platform,
    Expression<String>? role,
    Expression<int>? userId,
    Expression<int>? guardianId,
    Expression<String>? tokenHash,
    Expression<String>? pushToken,
    Expression<DateTime>? pairedAt,
    Expression<DateTime>? lastSeenAt,
    Expression<String>? lastIp,
    Expression<DateTime>? revokedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (platform != null) 'platform': platform,
      if (role != null) 'role': role,
      if (userId != null) 'user_id': userId,
      if (guardianId != null) 'guardian_id': guardianId,
      if (tokenHash != null) 'token_hash': tokenHash,
      if (pushToken != null) 'push_token': pushToken,
      if (pairedAt != null) 'paired_at': pairedAt,
      if (lastSeenAt != null) 'last_seen_at': lastSeenAt,
      if (lastIp != null) 'last_ip': lastIp,
      if (revokedAt != null) 'revoked_at': revokedAt,
    });
  }

  DevicesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? platform,
    Value<String>? role,
    Value<int?>? userId,
    Value<int?>? guardianId,
    Value<String>? tokenHash,
    Value<String?>? pushToken,
    Value<DateTime>? pairedAt,
    Value<DateTime?>? lastSeenAt,
    Value<String?>? lastIp,
    Value<DateTime?>? revokedAt,
  }) {
    return DevicesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      platform: platform ?? this.platform,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      guardianId: guardianId ?? this.guardianId,
      tokenHash: tokenHash ?? this.tokenHash,
      pushToken: pushToken ?? this.pushToken,
      pairedAt: pairedAt ?? this.pairedAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      lastIp: lastIp ?? this.lastIp,
      revokedAt: revokedAt ?? this.revokedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<int>(guardianId.value);
    }
    if (tokenHash.present) {
      map['token_hash'] = Variable<String>(tokenHash.value);
    }
    if (pushToken.present) {
      map['push_token'] = Variable<String>(pushToken.value);
    }
    if (pairedAt.present) {
      map['paired_at'] = Variable<DateTime>(pairedAt.value);
    }
    if (lastSeenAt.present) {
      map['last_seen_at'] = Variable<DateTime>(lastSeenAt.value);
    }
    if (lastIp.present) {
      map['last_ip'] = Variable<String>(lastIp.value);
    }
    if (revokedAt.present) {
      map['revoked_at'] = Variable<DateTime>(revokedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DevicesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('platform: $platform, ')
          ..write('role: $role, ')
          ..write('userId: $userId, ')
          ..write('guardianId: $guardianId, ')
          ..write('tokenHash: $tokenHash, ')
          ..write('pushToken: $pushToken, ')
          ..write('pairedAt: $pairedAt, ')
          ..write('lastSeenAt: $lastSeenAt, ')
          ..write('lastIp: $lastIp, ')
          ..write('revokedAt: $revokedAt')
          ..write(')'))
        .toString();
  }
}

class $PairingCodesTable extends PairingCodes
    with TableInfo<$PairingCodesTable, PairingCode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PairingCodesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
    'code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<int> userId = GeneratedColumn<int>(
    'user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<int> guardianId = GeneratedColumn<int>(
    'guardian_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES guardians (id)',
    ),
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _usedAtMeta = const VerificationMeta('usedAt');
  @override
  late final GeneratedColumn<DateTime> usedAt = GeneratedColumn<DateTime>(
    'used_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usedByDeviceIdMeta = const VerificationMeta(
    'usedByDeviceId',
  );
  @override
  late final GeneratedColumn<int> usedByDeviceId = GeneratedColumn<int>(
    'used_by_device_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<int> createdByUserId = GeneratedColumn<int>(
    'created_by_user_id',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    code,
    role,
    userId,
    guardianId,
    expiresAt,
    usedAt,
    usedByDeviceId,
    createdByUserId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pairing_codes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PairingCode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('code')) {
      context.handle(
        _codeMeta,
        code.isAcceptableOrUnknown(data['code']!, _codeMeta),
      );
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('used_at')) {
      context.handle(
        _usedAtMeta,
        usedAt.isAcceptableOrUnknown(data['used_at']!, _usedAtMeta),
      );
    }
    if (data.containsKey('used_by_device_id')) {
      context.handle(
        _usedByDeviceIdMeta,
        usedByDeviceId.isAcceptableOrUnknown(
          data['used_by_device_id']!,
          _usedByDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {code},
  ];
  @override
  PairingCode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PairingCode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      code: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}code'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_id'],
      ),
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guardian_id'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      usedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}used_at'],
      ),
      usedByDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}used_by_device_id'],
      ),
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PairingCodesTable createAlias(String alias) {
    return $PairingCodesTable(attachedDatabase, alias);
  }
}

class PairingCode extends DataClass implements Insertable<PairingCode> {
  final int id;
  final String code;

  /// `manager` | `parent`
  final String role;
  final int? userId;
  final int? guardianId;
  final DateTime expiresAt;
  final DateTime? usedAt;
  final int? usedByDeviceId;
  final int? createdByUserId;
  final DateTime createdAt;
  const PairingCode({
    required this.id,
    required this.code,
    required this.role,
    this.userId,
    this.guardianId,
    required this.expiresAt,
    this.usedAt,
    this.usedByDeviceId,
    this.createdByUserId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['code'] = Variable<String>(code);
    map['role'] = Variable<String>(role);
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<int>(userId);
    }
    if (!nullToAbsent || guardianId != null) {
      map['guardian_id'] = Variable<int>(guardianId);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    if (!nullToAbsent || usedAt != null) {
      map['used_at'] = Variable<DateTime>(usedAt);
    }
    if (!nullToAbsent || usedByDeviceId != null) {
      map['used_by_device_id'] = Variable<int>(usedByDeviceId);
    }
    if (!nullToAbsent || createdByUserId != null) {
      map['created_by_user_id'] = Variable<int>(createdByUserId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PairingCodesCompanion toCompanion(bool nullToAbsent) {
    return PairingCodesCompanion(
      id: Value(id),
      code: Value(code),
      role: Value(role),
      userId: userId == null && nullToAbsent
          ? const Value.absent()
          : Value(userId),
      guardianId: guardianId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianId),
      expiresAt: Value(expiresAt),
      usedAt: usedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(usedAt),
      usedByDeviceId: usedByDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(usedByDeviceId),
      createdByUserId: createdByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByUserId),
      createdAt: Value(createdAt),
    );
  }

  factory PairingCode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PairingCode(
      id: serializer.fromJson<int>(json['id']),
      code: serializer.fromJson<String>(json['code']),
      role: serializer.fromJson<String>(json['role']),
      userId: serializer.fromJson<int?>(json['userId']),
      guardianId: serializer.fromJson<int?>(json['guardianId']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      usedAt: serializer.fromJson<DateTime?>(json['usedAt']),
      usedByDeviceId: serializer.fromJson<int?>(json['usedByDeviceId']),
      createdByUserId: serializer.fromJson<int?>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'code': serializer.toJson<String>(code),
      'role': serializer.toJson<String>(role),
      'userId': serializer.toJson<int?>(userId),
      'guardianId': serializer.toJson<int?>(guardianId),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'usedAt': serializer.toJson<DateTime?>(usedAt),
      'usedByDeviceId': serializer.toJson<int?>(usedByDeviceId),
      'createdByUserId': serializer.toJson<int?>(createdByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PairingCode copyWith({
    int? id,
    String? code,
    String? role,
    Value<int?> userId = const Value.absent(),
    Value<int?> guardianId = const Value.absent(),
    DateTime? expiresAt,
    Value<DateTime?> usedAt = const Value.absent(),
    Value<int?> usedByDeviceId = const Value.absent(),
    Value<int?> createdByUserId = const Value.absent(),
    DateTime? createdAt,
  }) => PairingCode(
    id: id ?? this.id,
    code: code ?? this.code,
    role: role ?? this.role,
    userId: userId.present ? userId.value : this.userId,
    guardianId: guardianId.present ? guardianId.value : this.guardianId,
    expiresAt: expiresAt ?? this.expiresAt,
    usedAt: usedAt.present ? usedAt.value : this.usedAt,
    usedByDeviceId: usedByDeviceId.present
        ? usedByDeviceId.value
        : this.usedByDeviceId,
    createdByUserId: createdByUserId.present
        ? createdByUserId.value
        : this.createdByUserId,
    createdAt: createdAt ?? this.createdAt,
  );
  PairingCode copyWithCompanion(PairingCodesCompanion data) {
    return PairingCode(
      id: data.id.present ? data.id.value : this.id,
      code: data.code.present ? data.code.value : this.code,
      role: data.role.present ? data.role.value : this.role,
      userId: data.userId.present ? data.userId.value : this.userId,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      usedAt: data.usedAt.present ? data.usedAt.value : this.usedAt,
      usedByDeviceId: data.usedByDeviceId.present
          ? data.usedByDeviceId.value
          : this.usedByDeviceId,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PairingCode(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('role: $role, ')
          ..write('userId: $userId, ')
          ..write('guardianId: $guardianId, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('usedAt: $usedAt, ')
          ..write('usedByDeviceId: $usedByDeviceId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    code,
    role,
    userId,
    guardianId,
    expiresAt,
    usedAt,
    usedByDeviceId,
    createdByUserId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PairingCode &&
          other.id == this.id &&
          other.code == this.code &&
          other.role == this.role &&
          other.userId == this.userId &&
          other.guardianId == this.guardianId &&
          other.expiresAt == this.expiresAt &&
          other.usedAt == this.usedAt &&
          other.usedByDeviceId == this.usedByDeviceId &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt);
}

class PairingCodesCompanion extends UpdateCompanion<PairingCode> {
  final Value<int> id;
  final Value<String> code;
  final Value<String> role;
  final Value<int?> userId;
  final Value<int?> guardianId;
  final Value<DateTime> expiresAt;
  final Value<DateTime?> usedAt;
  final Value<int?> usedByDeviceId;
  final Value<int?> createdByUserId;
  final Value<DateTime> createdAt;
  const PairingCodesCompanion({
    this.id = const Value.absent(),
    this.code = const Value.absent(),
    this.role = const Value.absent(),
    this.userId = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.usedAt = const Value.absent(),
    this.usedByDeviceId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PairingCodesCompanion.insert({
    this.id = const Value.absent(),
    required String code,
    required String role,
    this.userId = const Value.absent(),
    this.guardianId = const Value.absent(),
    required DateTime expiresAt,
    this.usedAt = const Value.absent(),
    this.usedByDeviceId = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : code = Value(code),
       role = Value(role),
       expiresAt = Value(expiresAt);
  static Insertable<PairingCode> custom({
    Expression<int>? id,
    Expression<String>? code,
    Expression<String>? role,
    Expression<int>? userId,
    Expression<int>? guardianId,
    Expression<DateTime>? expiresAt,
    Expression<DateTime>? usedAt,
    Expression<int>? usedByDeviceId,
    Expression<int>? createdByUserId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (code != null) 'code': code,
      if (role != null) 'role': role,
      if (userId != null) 'user_id': userId,
      if (guardianId != null) 'guardian_id': guardianId,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (usedAt != null) 'used_at': usedAt,
      if (usedByDeviceId != null) 'used_by_device_id': usedByDeviceId,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PairingCodesCompanion copyWith({
    Value<int>? id,
    Value<String>? code,
    Value<String>? role,
    Value<int?>? userId,
    Value<int?>? guardianId,
    Value<DateTime>? expiresAt,
    Value<DateTime?>? usedAt,
    Value<int?>? usedByDeviceId,
    Value<int?>? createdByUserId,
    Value<DateTime>? createdAt,
  }) {
    return PairingCodesCompanion(
      id: id ?? this.id,
      code: code ?? this.code,
      role: role ?? this.role,
      userId: userId ?? this.userId,
      guardianId: guardianId ?? this.guardianId,
      expiresAt: expiresAt ?? this.expiresAt,
      usedAt: usedAt ?? this.usedAt,
      usedByDeviceId: usedByDeviceId ?? this.usedByDeviceId,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<int>(userId.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<int>(guardianId.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (usedAt.present) {
      map['used_at'] = Variable<DateTime>(usedAt.value);
    }
    if (usedByDeviceId.present) {
      map['used_by_device_id'] = Variable<int>(usedByDeviceId.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<int>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PairingCodesCompanion(')
          ..write('id: $id, ')
          ..write('code: $code, ')
          ..write('role: $role, ')
          ..write('userId: $userId, ')
          ..write('guardianId: $guardianId, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('usedAt: $usedAt, ')
          ..write('usedByDeviceId: $usedByDeviceId, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MessageTemplatesTable extends MessageTemplates
    with TableInfo<$MessageTemplatesTable, MessageTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessageTemplatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _templateKeyMeta = const VerificationMeta(
    'templateKey',
  );
  @override
  late final GeneratedColumn<String> templateKey = GeneratedColumn<String>(
    'template_key',
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('any'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isBuiltInMeta = const VerificationMeta(
    'isBuiltIn',
  );
  @override
  late final GeneratedColumn<bool> isBuiltIn = GeneratedColumn<bool>(
    'is_built_in',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_built_in" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateKey,
    title,
    body,
    channel,
    isActive,
    isBuiltIn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'message_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<MessageTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_key')) {
      context.handle(
        _templateKeyMeta,
        templateKey.isAcceptableOrUnknown(
          data['template_key']!,
          _templateKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_templateKeyMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('is_built_in')) {
      context.handle(
        _isBuiltInMeta,
        isBuiltIn.isAcceptableOrUnknown(data['is_built_in']!, _isBuiltInMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {templateKey},
  ];
  @override
  MessageTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MessageTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_key'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      isBuiltIn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_built_in'],
      )!,
    );
  }

  @override
  $MessageTemplatesTable createAlias(String alias) {
    return $MessageTemplatesTable(attachedDatabase, alias);
  }
}

class MessageTemplate extends DataClass implements Insertable<MessageTemplate> {
  final int id;

  /// `absence` | `absence_repeat` | `leave_approved` | `leave_rejected`
  /// | `fee_due` | `announcement`
  final String templateKey;
  final String title;
  final String body;

  /// `sms` | `app` | `any`
  final String channel;
  final bool isActive;
  final bool isBuiltIn;
  const MessageTemplate({
    required this.id,
    required this.templateKey,
    required this.title,
    required this.body,
    required this.channel,
    required this.isActive,
    required this.isBuiltIn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_key'] = Variable<String>(templateKey);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['channel'] = Variable<String>(channel);
    map['is_active'] = Variable<bool>(isActive);
    map['is_built_in'] = Variable<bool>(isBuiltIn);
    return map;
  }

  MessageTemplatesCompanion toCompanion(bool nullToAbsent) {
    return MessageTemplatesCompanion(
      id: Value(id),
      templateKey: Value(templateKey),
      title: Value(title),
      body: Value(body),
      channel: Value(channel),
      isActive: Value(isActive),
      isBuiltIn: Value(isBuiltIn),
    );
  }

  factory MessageTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MessageTemplate(
      id: serializer.fromJson<int>(json['id']),
      templateKey: serializer.fromJson<String>(json['templateKey']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      channel: serializer.fromJson<String>(json['channel']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isBuiltIn: serializer.fromJson<bool>(json['isBuiltIn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateKey': serializer.toJson<String>(templateKey),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'channel': serializer.toJson<String>(channel),
      'isActive': serializer.toJson<bool>(isActive),
      'isBuiltIn': serializer.toJson<bool>(isBuiltIn),
    };
  }

  MessageTemplate copyWith({
    int? id,
    String? templateKey,
    String? title,
    String? body,
    String? channel,
    bool? isActive,
    bool? isBuiltIn,
  }) => MessageTemplate(
    id: id ?? this.id,
    templateKey: templateKey ?? this.templateKey,
    title: title ?? this.title,
    body: body ?? this.body,
    channel: channel ?? this.channel,
    isActive: isActive ?? this.isActive,
    isBuiltIn: isBuiltIn ?? this.isBuiltIn,
  );
  MessageTemplate copyWithCompanion(MessageTemplatesCompanion data) {
    return MessageTemplate(
      id: data.id.present ? data.id.value : this.id,
      templateKey: data.templateKey.present
          ? data.templateKey.value
          : this.templateKey,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      channel: data.channel.present ? data.channel.value : this.channel,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isBuiltIn: data.isBuiltIn.present ? data.isBuiltIn.value : this.isBuiltIn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MessageTemplate(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('channel: $channel, ')
          ..write('isActive: $isActive, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, templateKey, title, body, channel, isActive, isBuiltIn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MessageTemplate &&
          other.id == this.id &&
          other.templateKey == this.templateKey &&
          other.title == this.title &&
          other.body == this.body &&
          other.channel == this.channel &&
          other.isActive == this.isActive &&
          other.isBuiltIn == this.isBuiltIn);
}

class MessageTemplatesCompanion extends UpdateCompanion<MessageTemplate> {
  final Value<int> id;
  final Value<String> templateKey;
  final Value<String> title;
  final Value<String> body;
  final Value<String> channel;
  final Value<bool> isActive;
  final Value<bool> isBuiltIn;
  const MessageTemplatesCompanion({
    this.id = const Value.absent(),
    this.templateKey = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.channel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  });
  MessageTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String templateKey,
    required String title,
    required String body,
    this.channel = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isBuiltIn = const Value.absent(),
  }) : templateKey = Value(templateKey),
       title = Value(title),
       body = Value(body);
  static Insertable<MessageTemplate> custom({
    Expression<int>? id,
    Expression<String>? templateKey,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? channel,
    Expression<bool>? isActive,
    Expression<bool>? isBuiltIn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateKey != null) 'template_key': templateKey,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (channel != null) 'channel': channel,
      if (isActive != null) 'is_active': isActive,
      if (isBuiltIn != null) 'is_built_in': isBuiltIn,
    });
  }

  MessageTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? templateKey,
    Value<String>? title,
    Value<String>? body,
    Value<String>? channel,
    Value<bool>? isActive,
    Value<bool>? isBuiltIn,
  }) {
    return MessageTemplatesCompanion(
      id: id ?? this.id,
      templateKey: templateKey ?? this.templateKey,
      title: title ?? this.title,
      body: body ?? this.body,
      channel: channel ?? this.channel,
      isActive: isActive ?? this.isActive,
      isBuiltIn: isBuiltIn ?? this.isBuiltIn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateKey.present) {
      map['template_key'] = Variable<String>(templateKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isBuiltIn.present) {
      map['is_built_in'] = Variable<bool>(isBuiltIn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessageTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('templateKey: $templateKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('channel: $channel, ')
          ..write('isActive: $isActive, ')
          ..write('isBuiltIn: $isBuiltIn')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _batchIdMeta = const VerificationMeta(
    'batchId',
  );
  @override
  late final GeneratedColumn<String> batchId = GeneratedColumn<String>(
    'batch_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<int> guardianId = GeneratedColumn<int>(
    'guardian_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES guardians (id)',
    ),
  );
  static const VerificationMeta _toNameMeta = const VerificationMeta('toName');
  @override
  late final GeneratedColumn<String> toName = GeneratedColumn<String>(
    'to_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _toPhoneMeta = const VerificationMeta(
    'toPhone',
  );
  @override
  late final GeneratedColumn<String> toPhone = GeneratedColumn<String>(
    'to_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<String> channel = GeneratedColumn<String>(
    'channel',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('app'),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _relatedDateMeta = const VerificationMeta(
    'relatedDate',
  );
  @override
  late final GeneratedColumn<DateTime> relatedDate = GeneratedColumn<DateTime>(
    'related_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdByUserIdMeta = const VerificationMeta(
    'createdByUserId',
  );
  @override
  late final GeneratedColumn<int> createdByUserId = GeneratedColumn<int>(
    'created_by_user_id',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _sentAtMeta = const VerificationMeta('sentAt');
  @override
  late final GeneratedColumn<DateTime> sentAt = GeneratedColumn<DateTime>(
    'sent_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    batchId,
    kind,
    studentId,
    guardianId,
    toName,
    toPhone,
    channel,
    body,
    status,
    attempts,
    error,
    relatedDate,
    createdByUserId,
    createdAt,
    sentAt,
    readAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('batch_id')) {
      context.handle(
        _batchIdMeta,
        batchId.isAcceptableOrUnknown(data['batch_id']!, _batchIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    }
    if (data.containsKey('to_name')) {
      context.handle(
        _toNameMeta,
        toName.isAcceptableOrUnknown(data['to_name']!, _toNameMeta),
      );
    }
    if (data.containsKey('to_phone')) {
      context.handle(
        _toPhoneMeta,
        toPhone.isAcceptableOrUnknown(data['to_phone']!, _toPhoneMeta),
      );
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('related_date')) {
      context.handle(
        _relatedDateMeta,
        relatedDate.isAcceptableOrUnknown(
          data['related_date']!,
          _relatedDateMeta,
        ),
      );
    }
    if (data.containsKey('created_by_user_id')) {
      context.handle(
        _createdByUserIdMeta,
        createdByUserId.isAcceptableOrUnknown(
          data['created_by_user_id']!,
          _createdByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('sent_at')) {
      context.handle(
        _sentAtMeta,
        sentAt.isAcceptableOrUnknown(data['sent_at']!, _sentAtMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      batchId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}batch_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      ),
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guardian_id'],
      ),
      toName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_name'],
      ),
      toPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}to_phone'],
      ),
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      relatedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}related_date'],
      ),
      createdByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_by_user_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      sentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}sent_at'],
      ),
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }
}

class Message extends DataClass implements Insertable<Message> {
  final int id;

  /// یوه ډله چې یو ځای ولېږل شوه — «نن ۴۷ غیرحاضر».
  final String? batchId;

  /// `absence` | `leave` | `announcement` | `fee` | `custom`
  final String kind;
  final int? studentId;
  final int? guardianId;
  final String? toName;
  final String? toPhone;

  /// `app` | `sms` | `whatsapp`
  final String channel;
  final String body;

  /// `queued` | `sent` | `failed` | `read`
  final String status;
  final int attempts;
  final String? error;

  /// کومې ورځې پورې اړه لري — د غیرحاضرۍ نېټه.
  final DateTime? relatedDate;
  final int? createdByUserId;
  final DateTime createdAt;
  final DateTime? sentAt;
  final DateTime? readAt;
  const Message({
    required this.id,
    this.batchId,
    required this.kind,
    this.studentId,
    this.guardianId,
    this.toName,
    this.toPhone,
    required this.channel,
    required this.body,
    required this.status,
    required this.attempts,
    this.error,
    this.relatedDate,
    this.createdByUserId,
    required this.createdAt,
    this.sentAt,
    this.readAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || batchId != null) {
      map['batch_id'] = Variable<String>(batchId);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || studentId != null) {
      map['student_id'] = Variable<int>(studentId);
    }
    if (!nullToAbsent || guardianId != null) {
      map['guardian_id'] = Variable<int>(guardianId);
    }
    if (!nullToAbsent || toName != null) {
      map['to_name'] = Variable<String>(toName);
    }
    if (!nullToAbsent || toPhone != null) {
      map['to_phone'] = Variable<String>(toPhone);
    }
    map['channel'] = Variable<String>(channel);
    map['body'] = Variable<String>(body);
    map['status'] = Variable<String>(status);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || relatedDate != null) {
      map['related_date'] = Variable<DateTime>(relatedDate);
    }
    if (!nullToAbsent || createdByUserId != null) {
      map['created_by_user_id'] = Variable<int>(createdByUserId);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || sentAt != null) {
      map['sent_at'] = Variable<DateTime>(sentAt);
    }
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      batchId: batchId == null && nullToAbsent
          ? const Value.absent()
          : Value(batchId),
      kind: Value(kind),
      studentId: studentId == null && nullToAbsent
          ? const Value.absent()
          : Value(studentId),
      guardianId: guardianId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianId),
      toName: toName == null && nullToAbsent
          ? const Value.absent()
          : Value(toName),
      toPhone: toPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(toPhone),
      channel: Value(channel),
      body: Value(body),
      status: Value(status),
      attempts: Value(attempts),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      relatedDate: relatedDate == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedDate),
      createdByUserId: createdByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(createdByUserId),
      createdAt: Value(createdAt),
      sentAt: sentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(sentAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      batchId: serializer.fromJson<String?>(json['batchId']),
      kind: serializer.fromJson<String>(json['kind']),
      studentId: serializer.fromJson<int?>(json['studentId']),
      guardianId: serializer.fromJson<int?>(json['guardianId']),
      toName: serializer.fromJson<String?>(json['toName']),
      toPhone: serializer.fromJson<String?>(json['toPhone']),
      channel: serializer.fromJson<String>(json['channel']),
      body: serializer.fromJson<String>(json['body']),
      status: serializer.fromJson<String>(json['status']),
      attempts: serializer.fromJson<int>(json['attempts']),
      error: serializer.fromJson<String?>(json['error']),
      relatedDate: serializer.fromJson<DateTime?>(json['relatedDate']),
      createdByUserId: serializer.fromJson<int?>(json['createdByUserId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      sentAt: serializer.fromJson<DateTime?>(json['sentAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'batchId': serializer.toJson<String?>(batchId),
      'kind': serializer.toJson<String>(kind),
      'studentId': serializer.toJson<int?>(studentId),
      'guardianId': serializer.toJson<int?>(guardianId),
      'toName': serializer.toJson<String?>(toName),
      'toPhone': serializer.toJson<String?>(toPhone),
      'channel': serializer.toJson<String>(channel),
      'body': serializer.toJson<String>(body),
      'status': serializer.toJson<String>(status),
      'attempts': serializer.toJson<int>(attempts),
      'error': serializer.toJson<String?>(error),
      'relatedDate': serializer.toJson<DateTime?>(relatedDate),
      'createdByUserId': serializer.toJson<int?>(createdByUserId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'sentAt': serializer.toJson<DateTime?>(sentAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
    };
  }

  Message copyWith({
    int? id,
    Value<String?> batchId = const Value.absent(),
    String? kind,
    Value<int?> studentId = const Value.absent(),
    Value<int?> guardianId = const Value.absent(),
    Value<String?> toName = const Value.absent(),
    Value<String?> toPhone = const Value.absent(),
    String? channel,
    String? body,
    String? status,
    int? attempts,
    Value<String?> error = const Value.absent(),
    Value<DateTime?> relatedDate = const Value.absent(),
    Value<int?> createdByUserId = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> sentAt = const Value.absent(),
    Value<DateTime?> readAt = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    batchId: batchId.present ? batchId.value : this.batchId,
    kind: kind ?? this.kind,
    studentId: studentId.present ? studentId.value : this.studentId,
    guardianId: guardianId.present ? guardianId.value : this.guardianId,
    toName: toName.present ? toName.value : this.toName,
    toPhone: toPhone.present ? toPhone.value : this.toPhone,
    channel: channel ?? this.channel,
    body: body ?? this.body,
    status: status ?? this.status,
    attempts: attempts ?? this.attempts,
    error: error.present ? error.value : this.error,
    relatedDate: relatedDate.present ? relatedDate.value : this.relatedDate,
    createdByUserId: createdByUserId.present
        ? createdByUserId.value
        : this.createdByUserId,
    createdAt: createdAt ?? this.createdAt,
    sentAt: sentAt.present ? sentAt.value : this.sentAt,
    readAt: readAt.present ? readAt.value : this.readAt,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      batchId: data.batchId.present ? data.batchId.value : this.batchId,
      kind: data.kind.present ? data.kind.value : this.kind,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      toName: data.toName.present ? data.toName.value : this.toName,
      toPhone: data.toPhone.present ? data.toPhone.value : this.toPhone,
      channel: data.channel.present ? data.channel.value : this.channel,
      body: data.body.present ? data.body.value : this.body,
      status: data.status.present ? data.status.value : this.status,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      error: data.error.present ? data.error.value : this.error,
      relatedDate: data.relatedDate.present
          ? data.relatedDate.value
          : this.relatedDate,
      createdByUserId: data.createdByUserId.present
          ? data.createdByUserId.value
          : this.createdByUserId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      sentAt: data.sentAt.present ? data.sentAt.value : this.sentAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('kind: $kind, ')
          ..write('studentId: $studentId, ')
          ..write('guardianId: $guardianId, ')
          ..write('toName: $toName, ')
          ..write('toPhone: $toPhone, ')
          ..write('channel: $channel, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('error: $error, ')
          ..write('relatedDate: $relatedDate, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    batchId,
    kind,
    studentId,
    guardianId,
    toName,
    toPhone,
    channel,
    body,
    status,
    attempts,
    error,
    relatedDate,
    createdByUserId,
    createdAt,
    sentAt,
    readAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.batchId == this.batchId &&
          other.kind == this.kind &&
          other.studentId == this.studentId &&
          other.guardianId == this.guardianId &&
          other.toName == this.toName &&
          other.toPhone == this.toPhone &&
          other.channel == this.channel &&
          other.body == this.body &&
          other.status == this.status &&
          other.attempts == this.attempts &&
          other.error == this.error &&
          other.relatedDate == this.relatedDate &&
          other.createdByUserId == this.createdByUserId &&
          other.createdAt == this.createdAt &&
          other.sentAt == this.sentAt &&
          other.readAt == this.readAt);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<String?> batchId;
  final Value<String> kind;
  final Value<int?> studentId;
  final Value<int?> guardianId;
  final Value<String?> toName;
  final Value<String?> toPhone;
  final Value<String> channel;
  final Value<String> body;
  final Value<String> status;
  final Value<int> attempts;
  final Value<String?> error;
  final Value<DateTime?> relatedDate;
  final Value<int?> createdByUserId;
  final Value<DateTime> createdAt;
  final Value<DateTime?> sentAt;
  final Value<DateTime?> readAt;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    this.kind = const Value.absent(),
    this.studentId = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.toName = const Value.absent(),
    this.toPhone = const Value.absent(),
    this.channel = const Value.absent(),
    this.body = const Value.absent(),
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.error = const Value.absent(),
    this.relatedDate = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.readAt = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    this.batchId = const Value.absent(),
    required String kind,
    this.studentId = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.toName = const Value.absent(),
    this.toPhone = const Value.absent(),
    this.channel = const Value.absent(),
    required String body,
    this.status = const Value.absent(),
    this.attempts = const Value.absent(),
    this.error = const Value.absent(),
    this.relatedDate = const Value.absent(),
    this.createdByUserId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.sentAt = const Value.absent(),
    this.readAt = const Value.absent(),
  }) : kind = Value(kind),
       body = Value(body);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<String>? batchId,
    Expression<String>? kind,
    Expression<int>? studentId,
    Expression<int>? guardianId,
    Expression<String>? toName,
    Expression<String>? toPhone,
    Expression<String>? channel,
    Expression<String>? body,
    Expression<String>? status,
    Expression<int>? attempts,
    Expression<String>? error,
    Expression<DateTime>? relatedDate,
    Expression<int>? createdByUserId,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? sentAt,
    Expression<DateTime>? readAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (batchId != null) 'batch_id': batchId,
      if (kind != null) 'kind': kind,
      if (studentId != null) 'student_id': studentId,
      if (guardianId != null) 'guardian_id': guardianId,
      if (toName != null) 'to_name': toName,
      if (toPhone != null) 'to_phone': toPhone,
      if (channel != null) 'channel': channel,
      if (body != null) 'body': body,
      if (status != null) 'status': status,
      if (attempts != null) 'attempts': attempts,
      if (error != null) 'error': error,
      if (relatedDate != null) 'related_date': relatedDate,
      if (createdByUserId != null) 'created_by_user_id': createdByUserId,
      if (createdAt != null) 'created_at': createdAt,
      if (sentAt != null) 'sent_at': sentAt,
      if (readAt != null) 'read_at': readAt,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<String?>? batchId,
    Value<String>? kind,
    Value<int?>? studentId,
    Value<int?>? guardianId,
    Value<String?>? toName,
    Value<String?>? toPhone,
    Value<String>? channel,
    Value<String>? body,
    Value<String>? status,
    Value<int>? attempts,
    Value<String?>? error,
    Value<DateTime?>? relatedDate,
    Value<int?>? createdByUserId,
    Value<DateTime>? createdAt,
    Value<DateTime?>? sentAt,
    Value<DateTime?>? readAt,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      batchId: batchId ?? this.batchId,
      kind: kind ?? this.kind,
      studentId: studentId ?? this.studentId,
      guardianId: guardianId ?? this.guardianId,
      toName: toName ?? this.toName,
      toPhone: toPhone ?? this.toPhone,
      channel: channel ?? this.channel,
      body: body ?? this.body,
      status: status ?? this.status,
      attempts: attempts ?? this.attempts,
      error: error ?? this.error,
      relatedDate: relatedDate ?? this.relatedDate,
      createdByUserId: createdByUserId ?? this.createdByUserId,
      createdAt: createdAt ?? this.createdAt,
      sentAt: sentAt ?? this.sentAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (batchId.present) {
      map['batch_id'] = Variable<String>(batchId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<int>(guardianId.value);
    }
    if (toName.present) {
      map['to_name'] = Variable<String>(toName.value);
    }
    if (toPhone.present) {
      map['to_phone'] = Variable<String>(toPhone.value);
    }
    if (channel.present) {
      map['channel'] = Variable<String>(channel.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (relatedDate.present) {
      map['related_date'] = Variable<DateTime>(relatedDate.value);
    }
    if (createdByUserId.present) {
      map['created_by_user_id'] = Variable<int>(createdByUserId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (sentAt.present) {
      map['sent_at'] = Variable<DateTime>(sentAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('batchId: $batchId, ')
          ..write('kind: $kind, ')
          ..write('studentId: $studentId, ')
          ..write('guardianId: $guardianId, ')
          ..write('toName: $toName, ')
          ..write('toPhone: $toPhone, ')
          ..write('channel: $channel, ')
          ..write('body: $body, ')
          ..write('status: $status, ')
          ..write('attempts: $attempts, ')
          ..write('error: $error, ')
          ..write('relatedDate: $relatedDate, ')
          ..write('createdByUserId: $createdByUserId, ')
          ..write('createdAt: $createdAt, ')
          ..write('sentAt: $sentAt, ')
          ..write('readAt: $readAt')
          ..write(')'))
        .toString();
  }
}

class $AppNotificationsTable extends AppNotifications
    with TableInfo<$AppNotificationsTable, AppNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppNotificationsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audienceMeta = const VerificationMeta(
    'audience',
  );
  @override
  late final GeneratedColumn<String> audience = GeneratedColumn<String>(
    'audience',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('manager'),
  );
  static const VerificationMeta _guardianIdMeta = const VerificationMeta(
    'guardianId',
  );
  @override
  late final GeneratedColumn<int> guardianId = GeneratedColumn<int>(
    'guardian_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES guardians (id)',
    ),
  );
  static const VerificationMeta _dedupeKeyMeta = const VerificationMeta(
    'dedupeKey',
  );
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
    'dedupe_key',
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _readAtMeta = const VerificationMeta('readAt');
  @override
  late final GeneratedColumn<DateTime> readAt = GeneratedColumn<DateTime>(
    'read_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _actedAtMeta = const VerificationMeta(
    'actedAt',
  );
  @override
  late final GeneratedColumn<DateTime> actedAt = GeneratedColumn<DateTime>(
    'acted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    title,
    body,
    payloadJson,
    audience,
    guardianId,
    dedupeKey,
    createdAt,
    updatedAt,
    readAt,
    actedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    }
    if (data.containsKey('audience')) {
      context.handle(
        _audienceMeta,
        audience.isAcceptableOrUnknown(data['audience']!, _audienceMeta),
      );
    }
    if (data.containsKey('guardian_id')) {
      context.handle(
        _guardianIdMeta,
        guardianId.isAcceptableOrUnknown(data['guardian_id']!, _guardianIdMeta),
      );
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(
        _dedupeKeyMeta,
        dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('read_at')) {
      context.handle(
        _readAtMeta,
        readAt.isAcceptableOrUnknown(data['read_at']!, _readAtMeta),
      );
    }
    if (data.containsKey('acted_at')) {
      context.handle(
        _actedAtMeta,
        actedAt.isAcceptableOrUnknown(data['acted_at']!, _actedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {dedupeKey},
  ];
  @override
  AppNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      ),
      audience: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audience'],
      )!,
      guardianId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}guardian_id'],
      ),
      dedupeKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dedupe_key'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      readAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}read_at'],
      ),
      actedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}acted_at'],
      ),
    );
  }

  @override
  $AppNotificationsTable createAlias(String alias) {
    return $AppNotificationsTable(attachedDatabase, alias);
  }
}

class AppNotification extends DataClass implements Insertable<AppNotification> {
  final int id;

  /// `absence_digest` | `leave_request` | `chronic_absence` | `system`
  final String kind;
  final String title;
  final String body;

  /// د تڼۍ لپاره ډیټا — {"date":"2026-08-14","studentIds":[…]}
  final String? payloadJson;

  /// `manager` | `parent`
  final String audience;
  final int? guardianId;

  /// د دوه‌ځلي مخنیوي کلی — «absence_digest:2026-08-14».
  /// یوه ورځ یوازې یوه خبرتیا لري، خو شمېره يې تازه کېږي.
  final String? dedupeKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? readAt;
  final DateTime? actedAt;
  const AppNotification({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    this.payloadJson,
    required this.audience,
    this.guardianId,
    this.dedupeKey,
    required this.createdAt,
    required this.updatedAt,
    this.readAt,
    this.actedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || payloadJson != null) {
      map['payload_json'] = Variable<String>(payloadJson);
    }
    map['audience'] = Variable<String>(audience);
    if (!nullToAbsent || guardianId != null) {
      map['guardian_id'] = Variable<int>(guardianId);
    }
    if (!nullToAbsent || dedupeKey != null) {
      map['dedupe_key'] = Variable<String>(dedupeKey);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || readAt != null) {
      map['read_at'] = Variable<DateTime>(readAt);
    }
    if (!nullToAbsent || actedAt != null) {
      map['acted_at'] = Variable<DateTime>(actedAt);
    }
    return map;
  }

  AppNotificationsCompanion toCompanion(bool nullToAbsent) {
    return AppNotificationsCompanion(
      id: Value(id),
      kind: Value(kind),
      title: Value(title),
      body: Value(body),
      payloadJson: payloadJson == null && nullToAbsent
          ? const Value.absent()
          : Value(payloadJson),
      audience: Value(audience),
      guardianId: guardianId == null && nullToAbsent
          ? const Value.absent()
          : Value(guardianId),
      dedupeKey: dedupeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dedupeKey),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      readAt: readAt == null && nullToAbsent
          ? const Value.absent()
          : Value(readAt),
      actedAt: actedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(actedAt),
    );
  }

  factory AppNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppNotification(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      payloadJson: serializer.fromJson<String?>(json['payloadJson']),
      audience: serializer.fromJson<String>(json['audience']),
      guardianId: serializer.fromJson<int?>(json['guardianId']),
      dedupeKey: serializer.fromJson<String?>(json['dedupeKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      readAt: serializer.fromJson<DateTime?>(json['readAt']),
      actedAt: serializer.fromJson<DateTime?>(json['actedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'payloadJson': serializer.toJson<String?>(payloadJson),
      'audience': serializer.toJson<String>(audience),
      'guardianId': serializer.toJson<int?>(guardianId),
      'dedupeKey': serializer.toJson<String?>(dedupeKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'readAt': serializer.toJson<DateTime?>(readAt),
      'actedAt': serializer.toJson<DateTime?>(actedAt),
    };
  }

  AppNotification copyWith({
    int? id,
    String? kind,
    String? title,
    String? body,
    Value<String?> payloadJson = const Value.absent(),
    String? audience,
    Value<int?> guardianId = const Value.absent(),
    Value<String?> dedupeKey = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> readAt = const Value.absent(),
    Value<DateTime?> actedAt = const Value.absent(),
  }) => AppNotification(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    title: title ?? this.title,
    body: body ?? this.body,
    payloadJson: payloadJson.present ? payloadJson.value : this.payloadJson,
    audience: audience ?? this.audience,
    guardianId: guardianId.present ? guardianId.value : this.guardianId,
    dedupeKey: dedupeKey.present ? dedupeKey.value : this.dedupeKey,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    readAt: readAt.present ? readAt.value : this.readAt,
    actedAt: actedAt.present ? actedAt.value : this.actedAt,
  );
  AppNotification copyWithCompanion(AppNotificationsCompanion data) {
    return AppNotification(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      audience: data.audience.present ? data.audience.value : this.audience,
      guardianId: data.guardianId.present
          ? data.guardianId.value
          : this.guardianId,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      readAt: data.readAt.present ? data.readAt.value : this.readAt,
      actedAt: data.actedAt.present ? data.actedAt.value : this.actedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppNotification(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('audience: $audience, ')
          ..write('guardianId: $guardianId, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readAt: $readAt, ')
          ..write('actedAt: $actedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    kind,
    title,
    body,
    payloadJson,
    audience,
    guardianId,
    dedupeKey,
    createdAt,
    updatedAt,
    readAt,
    actedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNotification &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.title == this.title &&
          other.body == this.body &&
          other.payloadJson == this.payloadJson &&
          other.audience == this.audience &&
          other.guardianId == this.guardianId &&
          other.dedupeKey == this.dedupeKey &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.readAt == this.readAt &&
          other.actedAt == this.actedAt);
}

class AppNotificationsCompanion extends UpdateCompanion<AppNotification> {
  final Value<int> id;
  final Value<String> kind;
  final Value<String> title;
  final Value<String> body;
  final Value<String?> payloadJson;
  final Value<String> audience;
  final Value<int?> guardianId;
  final Value<String?> dedupeKey;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> readAt;
  final Value<DateTime?> actedAt;
  const AppNotificationsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.audience = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.actedAt = const Value.absent(),
  });
  AppNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    required String title,
    required String body,
    this.payloadJson = const Value.absent(),
    this.audience = const Value.absent(),
    this.guardianId = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.readAt = const Value.absent(),
    this.actedAt = const Value.absent(),
  }) : kind = Value(kind),
       title = Value(title),
       body = Value(body);
  static Insertable<AppNotification> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? payloadJson,
    Expression<String>? audience,
    Expression<int>? guardianId,
    Expression<String>? dedupeKey,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? readAt,
    Expression<DateTime>? actedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (audience != null) 'audience': audience,
      if (guardianId != null) 'guardian_id': guardianId,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (readAt != null) 'read_at': readAt,
      if (actedAt != null) 'acted_at': actedAt,
    });
  }

  AppNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<String>? title,
    Value<String>? body,
    Value<String?>? payloadJson,
    Value<String>? audience,
    Value<int?>? guardianId,
    Value<String?>? dedupeKey,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? readAt,
    Value<DateTime?>? actedAt,
  }) {
    return AppNotificationsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      body: body ?? this.body,
      payloadJson: payloadJson ?? this.payloadJson,
      audience: audience ?? this.audience,
      guardianId: guardianId ?? this.guardianId,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      readAt: readAt ?? this.readAt,
      actedAt: actedAt ?? this.actedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (audience.present) {
      map['audience'] = Variable<String>(audience.value);
    }
    if (guardianId.present) {
      map['guardian_id'] = Variable<int>(guardianId.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (readAt.present) {
      map['read_at'] = Variable<DateTime>(readAt.value);
    }
    if (actedAt.present) {
      map['acted_at'] = Variable<DateTime>(actedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('audience: $audience, ')
          ..write('guardianId: $guardianId, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('readAt: $readAt, ')
          ..write('actedAt: $actedAt')
          ..write(')'))
        .toString();
  }
}

class $TimeSlotsTable extends TimeSlots
    with TableInfo<$TimeSlotsTable, TimeSlot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeSlotsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  @override
  late final GeneratedColumn<String> startTime = GeneratedColumn<String>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  @override
  late final GeneratedColumn<String> endTime = GeneratedColumn<String>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBreakMeta = const VerificationMeta(
    'isBreak',
  );
  @override
  late final GeneratedColumn<bool> isBreak = GeneratedColumn<bool>(
    'is_break',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_break" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    startTime,
    endTime,
    isBreak,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_slots';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimeSlot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('is_break')) {
      context.handle(
        _isBreakMeta,
        isBreak.isAcceptableOrUnknown(data['is_break']!, _isBreakMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeSlot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeSlot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}end_time'],
      )!,
      isBreak: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_break'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $TimeSlotsTable createAlias(String alias) {
    return $TimeSlotsTable(attachedDatabase, alias);
  }
}

class TimeSlot extends DataClass implements Insertable<TimeSlot> {
  final int id;
  final String name;

  /// «HH:mm»
  final String startTime;
  final String endTime;

  /// تفریح دی؟ — د مهالویش په جدول کې بېل رنګ اخلي او مضمون نه مني.
  final bool isBreak;
  final int sortOrder;
  const TimeSlot({
    required this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.isBreak,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['start_time'] = Variable<String>(startTime);
    map['end_time'] = Variable<String>(endTime);
    map['is_break'] = Variable<bool>(isBreak);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  TimeSlotsCompanion toCompanion(bool nullToAbsent) {
    return TimeSlotsCompanion(
      id: Value(id),
      name: Value(name),
      startTime: Value(startTime),
      endTime: Value(endTime),
      isBreak: Value(isBreak),
      sortOrder: Value(sortOrder),
    );
  }

  factory TimeSlot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeSlot(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startTime: serializer.fromJson<String>(json['startTime']),
      endTime: serializer.fromJson<String>(json['endTime']),
      isBreak: serializer.fromJson<bool>(json['isBreak']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startTime': serializer.toJson<String>(startTime),
      'endTime': serializer.toJson<String>(endTime),
      'isBreak': serializer.toJson<bool>(isBreak),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  TimeSlot copyWith({
    int? id,
    String? name,
    String? startTime,
    String? endTime,
    bool? isBreak,
    int? sortOrder,
  }) => TimeSlot(
    id: id ?? this.id,
    name: name ?? this.name,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    isBreak: isBreak ?? this.isBreak,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  TimeSlot copyWithCompanion(TimeSlotsCompanion data) {
    return TimeSlot(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      isBreak: data.isBreak.present ? data.isBreak.value : this.isBreak,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeSlot(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isBreak: $isBreak, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, startTime, endTime, isBreak, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeSlot &&
          other.id == this.id &&
          other.name == this.name &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.isBreak == this.isBreak &&
          other.sortOrder == this.sortOrder);
}

class TimeSlotsCompanion extends UpdateCompanion<TimeSlot> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> startTime;
  final Value<String> endTime;
  final Value<bool> isBreak;
  final Value<int> sortOrder;
  const TimeSlotsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.isBreak = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  TimeSlotsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String startTime,
    required String endTime,
    this.isBreak = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       startTime = Value(startTime),
       endTime = Value(endTime);
  static Insertable<TimeSlot> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? startTime,
    Expression<String>? endTime,
    Expression<bool>? isBreak,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (isBreak != null) 'is_break': isBreak,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  TimeSlotsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? startTime,
    Value<String>? endTime,
    Value<bool>? isBreak,
    Value<int>? sortOrder,
  }) {
    return TimeSlotsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isBreak: isBreak ?? this.isBreak,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<String>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<String>(endTime.value);
    }
    if (isBreak.present) {
      map['is_break'] = Variable<bool>(isBreak.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeSlotsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('isBreak: $isBreak, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TimetableEntriesTable extends TimetableEntries
    with TableInfo<$TimetableEntriesTable, TimetableEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimetableEntriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sectionIdMeta = const VerificationMeta(
    'sectionId',
  );
  @override
  late final GeneratedColumn<int> sectionId = GeneratedColumn<int>(
    'section_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sections (id)',
    ),
  );
  static const VerificationMeta _dayOfWeekMeta = const VerificationMeta(
    'dayOfWeek',
  );
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
    'day_of_week',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slotIdMeta = const VerificationMeta('slotId');
  @override
  late final GeneratedColumn<int> slotId = GeneratedColumn<int>(
    'slot_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES time_slots (id)',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<int> teacherId = GeneratedColumn<int>(
    'teacher_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES teachers (id)',
    ),
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sectionId,
    dayOfWeek,
    slotId,
    subjectId,
    teacherId,
    room,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timetable_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimetableEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('section_id')) {
      context.handle(
        _sectionIdMeta,
        sectionId.isAcceptableOrUnknown(data['section_id']!, _sectionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sectionIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
        _dayOfWeekMeta,
        dayOfWeek.isAcceptableOrUnknown(data['day_of_week']!, _dayOfWeekMeta),
      );
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('slot_id')) {
      context.handle(
        _slotIdMeta,
        slotId.isAcceptableOrUnknown(data['slot_id']!, _slotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_slotIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {sectionId, dayOfWeek, slotId},
  ];
  @override
  TimetableEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimetableEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}section_id'],
      )!,
      dayOfWeek: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}day_of_week'],
      )!,
      slotId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}slot_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}teacher_id'],
      ),
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TimetableEntriesTable createAlias(String alias) {
    return $TimetableEntriesTable(attachedDatabase, alias);
  }
}

class TimetableEntry extends DataClass implements Insertable<TimetableEntry> {
  final int id;
  final int sectionId;

  /// ۱ = دوشنبه … ۷ = یکشنبه (د Dart `DateTime.weekday` په څېر).
  final int dayOfWeek;
  final int slotId;
  final int subjectId;
  final int? teacherId;
  final String? room;
  final DateTime updatedAt;
  const TimetableEntry({
    required this.id,
    required this.sectionId,
    required this.dayOfWeek,
    required this.slotId,
    required this.subjectId,
    this.teacherId,
    this.room,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['section_id'] = Variable<int>(sectionId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['slot_id'] = Variable<int>(slotId);
    map['subject_id'] = Variable<int>(subjectId);
    if (!nullToAbsent || teacherId != null) {
      map['teacher_id'] = Variable<int>(teacherId);
    }
    if (!nullToAbsent || room != null) {
      map['room'] = Variable<String>(room);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TimetableEntriesCompanion toCompanion(bool nullToAbsent) {
    return TimetableEntriesCompanion(
      id: Value(id),
      sectionId: Value(sectionId),
      dayOfWeek: Value(dayOfWeek),
      slotId: Value(slotId),
      subjectId: Value(subjectId),
      teacherId: teacherId == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherId),
      room: room == null && nullToAbsent ? const Value.absent() : Value(room),
      updatedAt: Value(updatedAt),
    );
  }

  factory TimetableEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimetableEntry(
      id: serializer.fromJson<int>(json['id']),
      sectionId: serializer.fromJson<int>(json['sectionId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      slotId: serializer.fromJson<int>(json['slotId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      teacherId: serializer.fromJson<int?>(json['teacherId']),
      room: serializer.fromJson<String?>(json['room']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sectionId': serializer.toJson<int>(sectionId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'slotId': serializer.toJson<int>(slotId),
      'subjectId': serializer.toJson<int>(subjectId),
      'teacherId': serializer.toJson<int?>(teacherId),
      'room': serializer.toJson<String?>(room),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  TimetableEntry copyWith({
    int? id,
    int? sectionId,
    int? dayOfWeek,
    int? slotId,
    int? subjectId,
    Value<int?> teacherId = const Value.absent(),
    Value<String?> room = const Value.absent(),
    DateTime? updatedAt,
  }) => TimetableEntry(
    id: id ?? this.id,
    sectionId: sectionId ?? this.sectionId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    slotId: slotId ?? this.slotId,
    subjectId: subjectId ?? this.subjectId,
    teacherId: teacherId.present ? teacherId.value : this.teacherId,
    room: room.present ? room.value : this.room,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  TimetableEntry copyWithCompanion(TimetableEntriesCompanion data) {
    return TimetableEntry(
      id: data.id.present ? data.id.value : this.id,
      sectionId: data.sectionId.present ? data.sectionId.value : this.sectionId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      slotId: data.slotId.present ? data.slotId.value : this.slotId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      room: data.room.present ? data.room.value : this.room,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntry(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('slotId: $slotId, ')
          ..write('subjectId: $subjectId, ')
          ..write('teacherId: $teacherId, ')
          ..write('room: $room, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sectionId,
    dayOfWeek,
    slotId,
    subjectId,
    teacherId,
    room,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimetableEntry &&
          other.id == this.id &&
          other.sectionId == this.sectionId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.slotId == this.slotId &&
          other.subjectId == this.subjectId &&
          other.teacherId == this.teacherId &&
          other.room == this.room &&
          other.updatedAt == this.updatedAt);
}

class TimetableEntriesCompanion extends UpdateCompanion<TimetableEntry> {
  final Value<int> id;
  final Value<int> sectionId;
  final Value<int> dayOfWeek;
  final Value<int> slotId;
  final Value<int> subjectId;
  final Value<int?> teacherId;
  final Value<String?> room;
  final Value<DateTime> updatedAt;
  const TimetableEntriesCompanion({
    this.id = const Value.absent(),
    this.sectionId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.slotId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.room = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  TimetableEntriesCompanion.insert({
    this.id = const Value.absent(),
    required int sectionId,
    required int dayOfWeek,
    required int slotId,
    required int subjectId,
    this.teacherId = const Value.absent(),
    this.room = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : sectionId = Value(sectionId),
       dayOfWeek = Value(dayOfWeek),
       slotId = Value(slotId),
       subjectId = Value(subjectId);
  static Insertable<TimetableEntry> custom({
    Expression<int>? id,
    Expression<int>? sectionId,
    Expression<int>? dayOfWeek,
    Expression<int>? slotId,
    Expression<int>? subjectId,
    Expression<int>? teacherId,
    Expression<String>? room,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sectionId != null) 'section_id': sectionId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (slotId != null) 'slot_id': slotId,
      if (subjectId != null) 'subject_id': subjectId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (room != null) 'room': room,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  TimetableEntriesCompanion copyWith({
    Value<int>? id,
    Value<int>? sectionId,
    Value<int>? dayOfWeek,
    Value<int>? slotId,
    Value<int>? subjectId,
    Value<int?>? teacherId,
    Value<String?>? room,
    Value<DateTime>? updatedAt,
  }) {
    return TimetableEntriesCompanion(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      slotId: slotId ?? this.slotId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      room: room ?? this.room,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sectionId.present) {
      map['section_id'] = Variable<int>(sectionId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (slotId.present) {
      map['slot_id'] = Variable<int>(slotId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<int>(teacherId.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimetableEntriesCompanion(')
          ..write('id: $id, ')
          ..write('sectionId: $sectionId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('slotId: $slotId, ')
          ..write('subjectId: $subjectId, ')
          ..write('teacherId: $teacherId, ')
          ..write('room: $room, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ExamsTable extends Exams with TableInfo<$ExamsTable, Exam> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _examTypeMeta = const VerificationMeta(
    'examType',
  );
  @override
  late final GeneratedColumn<String> examType = GeneratedColumn<String>(
    'exam_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('midterm'),
  );
  static const VerificationMeta _academicYearIdMeta = const VerificationMeta(
    'academicYearId',
  );
  @override
  late final GeneratedColumn<int> academicYearId = GeneratedColumn<int>(
    'academic_year_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES academic_years (id)',
    ),
  );
  static const VerificationMeta _termMeta = const VerificationMeta('term');
  @override
  late final GeneratedColumn<int> term = GeneratedColumn<int>(
    'term',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _startsOnMeta = const VerificationMeta(
    'startsOn',
  );
  @override
  late final GeneratedColumn<DateTime> startsOn = GeneratedColumn<DateTime>(
    'starts_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsOnMeta = const VerificationMeta('endsOn');
  @override
  late final GeneratedColumn<DateTime> endsOn = GeneratedColumn<DateTime>(
    'ends_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isPublishedMeta = const VerificationMeta(
    'isPublished',
  );
  @override
  late final GeneratedColumn<bool> isPublished = GeneratedColumn<bool>(
    'is_published',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_published" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    examType,
    academicYearId,
    term,
    startsOn,
    endsOn,
    isPublished,
    publishedAt,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exams';
  @override
  VerificationContext validateIntegrity(
    Insertable<Exam> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('exam_type')) {
      context.handle(
        _examTypeMeta,
        examType.isAcceptableOrUnknown(data['exam_type']!, _examTypeMeta),
      );
    }
    if (data.containsKey('academic_year_id')) {
      context.handle(
        _academicYearIdMeta,
        academicYearId.isAcceptableOrUnknown(
          data['academic_year_id']!,
          _academicYearIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearIdMeta);
    }
    if (data.containsKey('term')) {
      context.handle(
        _termMeta,
        term.isAcceptableOrUnknown(data['term']!, _termMeta),
      );
    }
    if (data.containsKey('starts_on')) {
      context.handle(
        _startsOnMeta,
        startsOn.isAcceptableOrUnknown(data['starts_on']!, _startsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_startsOnMeta);
    }
    if (data.containsKey('ends_on')) {
      context.handle(
        _endsOnMeta,
        endsOn.isAcceptableOrUnknown(data['ends_on']!, _endsOnMeta),
      );
    } else if (isInserting) {
      context.missing(_endsOnMeta);
    }
    if (data.containsKey('is_published')) {
      context.handle(
        _isPublishedMeta,
        isPublished.isAcceptableOrUnknown(
          data['is_published']!,
          _isPublishedMeta,
        ),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Exam map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Exam(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      examType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exam_type'],
      )!,
      academicYearId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}academic_year_id'],
      )!,
      term: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}term'],
      )!,
      startsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}starts_on'],
      )!,
      endsOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_on'],
      )!,
      isPublished: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_published'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $ExamsTable createAlias(String alias) {
    return $ExamsTable(attachedDatabase, alias);
  }
}

class Exam extends DataClass implements Insertable<Exam> {
  final int id;
  final String name;

  /// `monthly` | `midterm` | `final` | `quiz`
  final String examType;
  final int academicYearId;

  /// ربع/سمستر — ۱ یا ۲. د کلني نتیجې لپاره پکار دی.
  final int term;
  final DateTime startsOn;
  final DateTime endsOn;

  /// **خپرول یوه پرېکړه ده، نه یو حالت.** تر څو چې خپره نه شي،
  /// نمرې یوازې استادان ویني — نه والدین. که نه، یوه نیمګړې لیکل
  /// شوې نمره به د کور خوا ته د اندېښنې لامل شوه.
  final bool isPublished;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const Exam({
    required this.id,
    required this.name,
    required this.examType,
    required this.academicYearId,
    required this.term,
    required this.startsOn,
    required this.endsOn,
    required this.isPublished,
    this.publishedAt,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['exam_type'] = Variable<String>(examType);
    map['academic_year_id'] = Variable<int>(academicYearId);
    map['term'] = Variable<int>(term);
    map['starts_on'] = Variable<DateTime>(startsOn);
    map['ends_on'] = Variable<DateTime>(endsOn);
    map['is_published'] = Variable<bool>(isPublished);
    if (!nullToAbsent || publishedAt != null) {
      map['published_at'] = Variable<DateTime>(publishedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  ExamsCompanion toCompanion(bool nullToAbsent) {
    return ExamsCompanion(
      id: Value(id),
      name: Value(name),
      examType: Value(examType),
      academicYearId: Value(academicYearId),
      term: Value(term),
      startsOn: Value(startsOn),
      endsOn: Value(endsOn),
      isPublished: Value(isPublished),
      publishedAt: publishedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(publishedAt),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory Exam.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Exam(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      examType: serializer.fromJson<String>(json['examType']),
      academicYearId: serializer.fromJson<int>(json['academicYearId']),
      term: serializer.fromJson<int>(json['term']),
      startsOn: serializer.fromJson<DateTime>(json['startsOn']),
      endsOn: serializer.fromJson<DateTime>(json['endsOn']),
      isPublished: serializer.fromJson<bool>(json['isPublished']),
      publishedAt: serializer.fromJson<DateTime?>(json['publishedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'examType': serializer.toJson<String>(examType),
      'academicYearId': serializer.toJson<int>(academicYearId),
      'term': serializer.toJson<int>(term),
      'startsOn': serializer.toJson<DateTime>(startsOn),
      'endsOn': serializer.toJson<DateTime>(endsOn),
      'isPublished': serializer.toJson<bool>(isPublished),
      'publishedAt': serializer.toJson<DateTime?>(publishedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  Exam copyWith({
    int? id,
    String? name,
    String? examType,
    int? academicYearId,
    int? term,
    DateTime? startsOn,
    DateTime? endsOn,
    bool? isPublished,
    Value<DateTime?> publishedAt = const Value.absent(),
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => Exam(
    id: id ?? this.id,
    name: name ?? this.name,
    examType: examType ?? this.examType,
    academicYearId: academicYearId ?? this.academicYearId,
    term: term ?? this.term,
    startsOn: startsOn ?? this.startsOn,
    endsOn: endsOn ?? this.endsOn,
    isPublished: isPublished ?? this.isPublished,
    publishedAt: publishedAt.present ? publishedAt.value : this.publishedAt,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  Exam copyWithCompanion(ExamsCompanion data) {
    return Exam(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      examType: data.examType.present ? data.examType.value : this.examType,
      academicYearId: data.academicYearId.present
          ? data.academicYearId.value
          : this.academicYearId,
      term: data.term.present ? data.term.value : this.term,
      startsOn: data.startsOn.present ? data.startsOn.value : this.startsOn,
      endsOn: data.endsOn.present ? data.endsOn.value : this.endsOn,
      isPublished: data.isPublished.present
          ? data.isPublished.value
          : this.isPublished,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Exam(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('examType: $examType, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('term: $term, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('isPublished: $isPublished, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    examType,
    academicYearId,
    term,
    startsOn,
    endsOn,
    isPublished,
    publishedAt,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Exam &&
          other.id == this.id &&
          other.name == this.name &&
          other.examType == this.examType &&
          other.academicYearId == this.academicYearId &&
          other.term == this.term &&
          other.startsOn == this.startsOn &&
          other.endsOn == this.endsOn &&
          other.isPublished == this.isPublished &&
          other.publishedAt == this.publishedAt &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class ExamsCompanion extends UpdateCompanion<Exam> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> examType;
  final Value<int> academicYearId;
  final Value<int> term;
  final Value<DateTime> startsOn;
  final Value<DateTime> endsOn;
  final Value<bool> isPublished;
  final Value<DateTime?> publishedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const ExamsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.examType = const Value.absent(),
    this.academicYearId = const Value.absent(),
    this.term = const Value.absent(),
    this.startsOn = const Value.absent(),
    this.endsOn = const Value.absent(),
    this.isPublished = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  ExamsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.examType = const Value.absent(),
    required int academicYearId,
    this.term = const Value.absent(),
    required DateTime startsOn,
    required DateTime endsOn,
    this.isPublished = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : name = Value(name),
       academicYearId = Value(academicYearId),
       startsOn = Value(startsOn),
       endsOn = Value(endsOn);
  static Insertable<Exam> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? examType,
    Expression<int>? academicYearId,
    Expression<int>? term,
    Expression<DateTime>? startsOn,
    Expression<DateTime>? endsOn,
    Expression<bool>? isPublished,
    Expression<DateTime>? publishedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (examType != null) 'exam_type': examType,
      if (academicYearId != null) 'academic_year_id': academicYearId,
      if (term != null) 'term': term,
      if (startsOn != null) 'starts_on': startsOn,
      if (endsOn != null) 'ends_on': endsOn,
      if (isPublished != null) 'is_published': isPublished,
      if (publishedAt != null) 'published_at': publishedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  ExamsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? examType,
    Value<int>? academicYearId,
    Value<int>? term,
    Value<DateTime>? startsOn,
    Value<DateTime>? endsOn,
    Value<bool>? isPublished,
    Value<DateTime?>? publishedAt,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
  }) {
    return ExamsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      examType: examType ?? this.examType,
      academicYearId: academicYearId ?? this.academicYearId,
      term: term ?? this.term,
      startsOn: startsOn ?? this.startsOn,
      endsOn: endsOn ?? this.endsOn,
      isPublished: isPublished ?? this.isPublished,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (examType.present) {
      map['exam_type'] = Variable<String>(examType.value);
    }
    if (academicYearId.present) {
      map['academic_year_id'] = Variable<int>(academicYearId.value);
    }
    if (term.present) {
      map['term'] = Variable<int>(term.value);
    }
    if (startsOn.present) {
      map['starts_on'] = Variable<DateTime>(startsOn.value);
    }
    if (endsOn.present) {
      map['ends_on'] = Variable<DateTime>(endsOn.value);
    }
    if (isPublished.present) {
      map['is_published'] = Variable<bool>(isPublished.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('examType: $examType, ')
          ..write('academicYearId: $academicYearId, ')
          ..write('term: $term, ')
          ..write('startsOn: $startsOn, ')
          ..write('endsOn: $endsOn, ')
          ..write('isPublished: $isPublished, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

class $ExamSubjectsTable extends ExamSubjects
    with TableInfo<$ExamSubjectsTable, ExamSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamSubjectsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _examIdMeta = const VerificationMeta('examId');
  @override
  late final GeneratedColumn<int> examId = GeneratedColumn<int>(
    'exam_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exams (id)',
    ),
  );
  static const VerificationMeta _gradeIdMeta = const VerificationMeta(
    'gradeId',
  );
  @override
  late final GeneratedColumn<int> gradeId = GeneratedColumn<int>(
    'grade_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES grades (id)',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<int> subjectId = GeneratedColumn<int>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _fullMarkMeta = const VerificationMeta(
    'fullMark',
  );
  @override
  late final GeneratedColumn<int> fullMark = GeneratedColumn<int>(
    'full_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
  );
  static const VerificationMeta _passMarkMeta = const VerificationMeta(
    'passMark',
  );
  @override
  late final GeneratedColumn<int> passMark = GeneratedColumn<int>(
    'pass_mark',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(40),
  );
  static const VerificationMeta _examDateMeta = const VerificationMeta(
    'examDate',
  );
  @override
  late final GeneratedColumn<DateTime> examDate = GeneratedColumn<DateTime>(
    'exam_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examId,
    gradeId,
    subjectId,
    fullMark,
    passMark,
    examDate,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_id')) {
      context.handle(
        _examIdMeta,
        examId.isAcceptableOrUnknown(data['exam_id']!, _examIdMeta),
      );
    } else if (isInserting) {
      context.missing(_examIdMeta);
    }
    if (data.containsKey('grade_id')) {
      context.handle(
        _gradeIdMeta,
        gradeId.isAcceptableOrUnknown(data['grade_id']!, _gradeIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gradeIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('full_mark')) {
      context.handle(
        _fullMarkMeta,
        fullMark.isAcceptableOrUnknown(data['full_mark']!, _fullMarkMeta),
      );
    }
    if (data.containsKey('pass_mark')) {
      context.handle(
        _passMarkMeta,
        passMark.isAcceptableOrUnknown(data['pass_mark']!, _passMarkMeta),
      );
    }
    if (data.containsKey('exam_date')) {
      context.handle(
        _examDateMeta,
        examDate.isAcceptableOrUnknown(data['exam_date']!, _examDateMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {examId, gradeId, subjectId},
  ];
  @override
  ExamSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_id'],
      )!,
      gradeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grade_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}subject_id'],
      )!,
      fullMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}full_mark'],
      )!,
      passMark: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pass_mark'],
      )!,
      examDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exam_date'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $ExamSubjectsTable createAlias(String alias) {
    return $ExamSubjectsTable(attachedDatabase, alias);
  }
}

class ExamSubject extends DataClass implements Insertable<ExamSubject> {
  final int id;
  final int examId;
  final int gradeId;
  final int subjectId;
  final int fullMark;
  final int passMark;
  final DateTime? examDate;
  final int sortOrder;
  const ExamSubject({
    required this.id,
    required this.examId,
    required this.gradeId,
    required this.subjectId,
    required this.fullMark,
    required this.passMark,
    this.examDate,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_id'] = Variable<int>(examId);
    map['grade_id'] = Variable<int>(gradeId);
    map['subject_id'] = Variable<int>(subjectId);
    map['full_mark'] = Variable<int>(fullMark);
    map['pass_mark'] = Variable<int>(passMark);
    if (!nullToAbsent || examDate != null) {
      map['exam_date'] = Variable<DateTime>(examDate);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  ExamSubjectsCompanion toCompanion(bool nullToAbsent) {
    return ExamSubjectsCompanion(
      id: Value(id),
      examId: Value(examId),
      gradeId: Value(gradeId),
      subjectId: Value(subjectId),
      fullMark: Value(fullMark),
      passMark: Value(passMark),
      examDate: examDate == null && nullToAbsent
          ? const Value.absent()
          : Value(examDate),
      sortOrder: Value(sortOrder),
    );
  }

  factory ExamSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamSubject(
      id: serializer.fromJson<int>(json['id']),
      examId: serializer.fromJson<int>(json['examId']),
      gradeId: serializer.fromJson<int>(json['gradeId']),
      subjectId: serializer.fromJson<int>(json['subjectId']),
      fullMark: serializer.fromJson<int>(json['fullMark']),
      passMark: serializer.fromJson<int>(json['passMark']),
      examDate: serializer.fromJson<DateTime?>(json['examDate']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examId': serializer.toJson<int>(examId),
      'gradeId': serializer.toJson<int>(gradeId),
      'subjectId': serializer.toJson<int>(subjectId),
      'fullMark': serializer.toJson<int>(fullMark),
      'passMark': serializer.toJson<int>(passMark),
      'examDate': serializer.toJson<DateTime?>(examDate),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  ExamSubject copyWith({
    int? id,
    int? examId,
    int? gradeId,
    int? subjectId,
    int? fullMark,
    int? passMark,
    Value<DateTime?> examDate = const Value.absent(),
    int? sortOrder,
  }) => ExamSubject(
    id: id ?? this.id,
    examId: examId ?? this.examId,
    gradeId: gradeId ?? this.gradeId,
    subjectId: subjectId ?? this.subjectId,
    fullMark: fullMark ?? this.fullMark,
    passMark: passMark ?? this.passMark,
    examDate: examDate.present ? examDate.value : this.examDate,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  ExamSubject copyWithCompanion(ExamSubjectsCompanion data) {
    return ExamSubject(
      id: data.id.present ? data.id.value : this.id,
      examId: data.examId.present ? data.examId.value : this.examId,
      gradeId: data.gradeId.present ? data.gradeId.value : this.gradeId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      fullMark: data.fullMark.present ? data.fullMark.value : this.fullMark,
      passMark: data.passMark.present ? data.passMark.value : this.passMark,
      examDate: data.examDate.present ? data.examDate.value : this.examDate,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamSubject(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('gradeId: $gradeId, ')
          ..write('subjectId: $subjectId, ')
          ..write('fullMark: $fullMark, ')
          ..write('passMark: $passMark, ')
          ..write('examDate: $examDate, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examId,
    gradeId,
    subjectId,
    fullMark,
    passMark,
    examDate,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamSubject &&
          other.id == this.id &&
          other.examId == this.examId &&
          other.gradeId == this.gradeId &&
          other.subjectId == this.subjectId &&
          other.fullMark == this.fullMark &&
          other.passMark == this.passMark &&
          other.examDate == this.examDate &&
          other.sortOrder == this.sortOrder);
}

class ExamSubjectsCompanion extends UpdateCompanion<ExamSubject> {
  final Value<int> id;
  final Value<int> examId;
  final Value<int> gradeId;
  final Value<int> subjectId;
  final Value<int> fullMark;
  final Value<int> passMark;
  final Value<DateTime?> examDate;
  final Value<int> sortOrder;
  const ExamSubjectsCompanion({
    this.id = const Value.absent(),
    this.examId = const Value.absent(),
    this.gradeId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.fullMark = const Value.absent(),
    this.passMark = const Value.absent(),
    this.examDate = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  ExamSubjectsCompanion.insert({
    this.id = const Value.absent(),
    required int examId,
    required int gradeId,
    required int subjectId,
    this.fullMark = const Value.absent(),
    this.passMark = const Value.absent(),
    this.examDate = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : examId = Value(examId),
       gradeId = Value(gradeId),
       subjectId = Value(subjectId);
  static Insertable<ExamSubject> custom({
    Expression<int>? id,
    Expression<int>? examId,
    Expression<int>? gradeId,
    Expression<int>? subjectId,
    Expression<int>? fullMark,
    Expression<int>? passMark,
    Expression<DateTime>? examDate,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examId != null) 'exam_id': examId,
      if (gradeId != null) 'grade_id': gradeId,
      if (subjectId != null) 'subject_id': subjectId,
      if (fullMark != null) 'full_mark': fullMark,
      if (passMark != null) 'pass_mark': passMark,
      if (examDate != null) 'exam_date': examDate,
      if (sortOrder != null) 'sort_order': sortOrder,
    });
  }

  ExamSubjectsCompanion copyWith({
    Value<int>? id,
    Value<int>? examId,
    Value<int>? gradeId,
    Value<int>? subjectId,
    Value<int>? fullMark,
    Value<int>? passMark,
    Value<DateTime?>? examDate,
    Value<int>? sortOrder,
  }) {
    return ExamSubjectsCompanion(
      id: id ?? this.id,
      examId: examId ?? this.examId,
      gradeId: gradeId ?? this.gradeId,
      subjectId: subjectId ?? this.subjectId,
      fullMark: fullMark ?? this.fullMark,
      passMark: passMark ?? this.passMark,
      examDate: examDate ?? this.examDate,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examId.present) {
      map['exam_id'] = Variable<int>(examId.value);
    }
    if (gradeId.present) {
      map['grade_id'] = Variable<int>(gradeId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<int>(subjectId.value);
    }
    if (fullMark.present) {
      map['full_mark'] = Variable<int>(fullMark.value);
    }
    if (passMark.present) {
      map['pass_mark'] = Variable<int>(passMark.value);
    }
    if (examDate.present) {
      map['exam_date'] = Variable<DateTime>(examDate.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('examId: $examId, ')
          ..write('gradeId: $gradeId, ')
          ..write('subjectId: $subjectId, ')
          ..write('fullMark: $fullMark, ')
          ..write('passMark: $passMark, ')
          ..write('examDate: $examDate, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $MarksTable extends Marks with TableInfo<$MarksTable, Mark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarksTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _examSubjectIdMeta = const VerificationMeta(
    'examSubjectId',
  );
  @override
  late final GeneratedColumn<int> examSubjectId = GeneratedColumn<int>(
    'exam_subject_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exam_subjects (id)',
    ),
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<int> studentId = GeneratedColumn<int>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES students (id)',
    ),
  );
  static const VerificationMeta _obtainedMeta = const VerificationMeta(
    'obtained',
  );
  @override
  late final GeneratedColumn<double> obtained = GeneratedColumn<double>(
    'obtained',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isAbsentMeta = const VerificationMeta(
    'isAbsent',
  );
  @override
  late final GeneratedColumn<bool> isAbsent = GeneratedColumn<bool>(
    'is_absent',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_absent" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _remarksMeta = const VerificationMeta(
    'remarks',
  );
  @override
  late final GeneratedColumn<String> remarks = GeneratedColumn<String>(
    'remarks',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enteredByUserIdMeta = const VerificationMeta(
    'enteredByUserId',
  );
  @override
  late final GeneratedColumn<int> enteredByUserId = GeneratedColumn<int>(
    'entered_by_user_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _enteredAtMeta = const VerificationMeta(
    'enteredAt',
  );
  @override
  late final GeneratedColumn<DateTime> enteredAt = GeneratedColumn<DateTime>(
    'entered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    examSubjectId,
    studentId,
    obtained,
    isAbsent,
    remarks,
    enteredByUserId,
    enteredAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'marks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Mark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exam_subject_id')) {
      context.handle(
        _examSubjectIdMeta,
        examSubjectId.isAcceptableOrUnknown(
          data['exam_subject_id']!,
          _examSubjectIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_examSubjectIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('obtained')) {
      context.handle(
        _obtainedMeta,
        obtained.isAcceptableOrUnknown(data['obtained']!, _obtainedMeta),
      );
    }
    if (data.containsKey('is_absent')) {
      context.handle(
        _isAbsentMeta,
        isAbsent.isAcceptableOrUnknown(data['is_absent']!, _isAbsentMeta),
      );
    }
    if (data.containsKey('remarks')) {
      context.handle(
        _remarksMeta,
        remarks.isAcceptableOrUnknown(data['remarks']!, _remarksMeta),
      );
    }
    if (data.containsKey('entered_by_user_id')) {
      context.handle(
        _enteredByUserIdMeta,
        enteredByUserId.isAcceptableOrUnknown(
          data['entered_by_user_id']!,
          _enteredByUserIdMeta,
        ),
      );
    }
    if (data.containsKey('entered_at')) {
      context.handle(
        _enteredAtMeta,
        enteredAt.isAcceptableOrUnknown(data['entered_at']!, _enteredAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {examSubjectId, studentId},
  ];
  @override
  Mark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Mark(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      examSubjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exam_subject_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}student_id'],
      )!,
      obtained: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}obtained'],
      ),
      isAbsent: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_absent'],
      )!,
      remarks: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}remarks'],
      ),
      enteredByUserId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entered_by_user_id'],
      ),
      enteredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}entered_at'],
      )!,
    );
  }

  @override
  $MarksTable createAlias(String alias) {
    return $MarksTable(attachedDatabase, alias);
  }
}

class Mark extends DataClass implements Insertable<Mark> {
  final int id;
  final int examSubjectId;
  final int studentId;

  /// **ولې `real` نه `int`؟** ځینې ښوونځي نیمې نمرې ورکوي —
  /// «۱۷.۵ له ۲۰ څخه». که پوره عدد وای، استاد به يې ګردول ته اړ و
  /// او د کال په پای کې به توپیر راټول شوی و.
  final double? obtained;

  /// **دا ولې له صفر نمرې څخه بېل دی؟** ځکه چې «راغلی نه و» او
  /// «راغی خو څه يې ونه لیکل» دوه بېل شیان دي. که دواړه صفر وای،
  /// د اوسط شمېرل به غلط وو.
  final bool isAbsent;
  final String? remarks;
  final int? enteredByUserId;
  final DateTime enteredAt;
  const Mark({
    required this.id,
    required this.examSubjectId,
    required this.studentId,
    this.obtained,
    required this.isAbsent,
    this.remarks,
    this.enteredByUserId,
    required this.enteredAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exam_subject_id'] = Variable<int>(examSubjectId);
    map['student_id'] = Variable<int>(studentId);
    if (!nullToAbsent || obtained != null) {
      map['obtained'] = Variable<double>(obtained);
    }
    map['is_absent'] = Variable<bool>(isAbsent);
    if (!nullToAbsent || remarks != null) {
      map['remarks'] = Variable<String>(remarks);
    }
    if (!nullToAbsent || enteredByUserId != null) {
      map['entered_by_user_id'] = Variable<int>(enteredByUserId);
    }
    map['entered_at'] = Variable<DateTime>(enteredAt);
    return map;
  }

  MarksCompanion toCompanion(bool nullToAbsent) {
    return MarksCompanion(
      id: Value(id),
      examSubjectId: Value(examSubjectId),
      studentId: Value(studentId),
      obtained: obtained == null && nullToAbsent
          ? const Value.absent()
          : Value(obtained),
      isAbsent: Value(isAbsent),
      remarks: remarks == null && nullToAbsent
          ? const Value.absent()
          : Value(remarks),
      enteredByUserId: enteredByUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(enteredByUserId),
      enteredAt: Value(enteredAt),
    );
  }

  factory Mark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Mark(
      id: serializer.fromJson<int>(json['id']),
      examSubjectId: serializer.fromJson<int>(json['examSubjectId']),
      studentId: serializer.fromJson<int>(json['studentId']),
      obtained: serializer.fromJson<double?>(json['obtained']),
      isAbsent: serializer.fromJson<bool>(json['isAbsent']),
      remarks: serializer.fromJson<String?>(json['remarks']),
      enteredByUserId: serializer.fromJson<int?>(json['enteredByUserId']),
      enteredAt: serializer.fromJson<DateTime>(json['enteredAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'examSubjectId': serializer.toJson<int>(examSubjectId),
      'studentId': serializer.toJson<int>(studentId),
      'obtained': serializer.toJson<double?>(obtained),
      'isAbsent': serializer.toJson<bool>(isAbsent),
      'remarks': serializer.toJson<String?>(remarks),
      'enteredByUserId': serializer.toJson<int?>(enteredByUserId),
      'enteredAt': serializer.toJson<DateTime>(enteredAt),
    };
  }

  Mark copyWith({
    int? id,
    int? examSubjectId,
    int? studentId,
    Value<double?> obtained = const Value.absent(),
    bool? isAbsent,
    Value<String?> remarks = const Value.absent(),
    Value<int?> enteredByUserId = const Value.absent(),
    DateTime? enteredAt,
  }) => Mark(
    id: id ?? this.id,
    examSubjectId: examSubjectId ?? this.examSubjectId,
    studentId: studentId ?? this.studentId,
    obtained: obtained.present ? obtained.value : this.obtained,
    isAbsent: isAbsent ?? this.isAbsent,
    remarks: remarks.present ? remarks.value : this.remarks,
    enteredByUserId: enteredByUserId.present
        ? enteredByUserId.value
        : this.enteredByUserId,
    enteredAt: enteredAt ?? this.enteredAt,
  );
  Mark copyWithCompanion(MarksCompanion data) {
    return Mark(
      id: data.id.present ? data.id.value : this.id,
      examSubjectId: data.examSubjectId.present
          ? data.examSubjectId.value
          : this.examSubjectId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      obtained: data.obtained.present ? data.obtained.value : this.obtained,
      isAbsent: data.isAbsent.present ? data.isAbsent.value : this.isAbsent,
      remarks: data.remarks.present ? data.remarks.value : this.remarks,
      enteredByUserId: data.enteredByUserId.present
          ? data.enteredByUserId.value
          : this.enteredByUserId,
      enteredAt: data.enteredAt.present ? data.enteredAt.value : this.enteredAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Mark(')
          ..write('id: $id, ')
          ..write('examSubjectId: $examSubjectId, ')
          ..write('studentId: $studentId, ')
          ..write('obtained: $obtained, ')
          ..write('isAbsent: $isAbsent, ')
          ..write('remarks: $remarks, ')
          ..write('enteredByUserId: $enteredByUserId, ')
          ..write('enteredAt: $enteredAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    examSubjectId,
    studentId,
    obtained,
    isAbsent,
    remarks,
    enteredByUserId,
    enteredAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Mark &&
          other.id == this.id &&
          other.examSubjectId == this.examSubjectId &&
          other.studentId == this.studentId &&
          other.obtained == this.obtained &&
          other.isAbsent == this.isAbsent &&
          other.remarks == this.remarks &&
          other.enteredByUserId == this.enteredByUserId &&
          other.enteredAt == this.enteredAt);
}

class MarksCompanion extends UpdateCompanion<Mark> {
  final Value<int> id;
  final Value<int> examSubjectId;
  final Value<int> studentId;
  final Value<double?> obtained;
  final Value<bool> isAbsent;
  final Value<String?> remarks;
  final Value<int?> enteredByUserId;
  final Value<DateTime> enteredAt;
  const MarksCompanion({
    this.id = const Value.absent(),
    this.examSubjectId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.obtained = const Value.absent(),
    this.isAbsent = const Value.absent(),
    this.remarks = const Value.absent(),
    this.enteredByUserId = const Value.absent(),
    this.enteredAt = const Value.absent(),
  });
  MarksCompanion.insert({
    this.id = const Value.absent(),
    required int examSubjectId,
    required int studentId,
    this.obtained = const Value.absent(),
    this.isAbsent = const Value.absent(),
    this.remarks = const Value.absent(),
    this.enteredByUserId = const Value.absent(),
    this.enteredAt = const Value.absent(),
  }) : examSubjectId = Value(examSubjectId),
       studentId = Value(studentId);
  static Insertable<Mark> custom({
    Expression<int>? id,
    Expression<int>? examSubjectId,
    Expression<int>? studentId,
    Expression<double>? obtained,
    Expression<bool>? isAbsent,
    Expression<String>? remarks,
    Expression<int>? enteredByUserId,
    Expression<DateTime>? enteredAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (examSubjectId != null) 'exam_subject_id': examSubjectId,
      if (studentId != null) 'student_id': studentId,
      if (obtained != null) 'obtained': obtained,
      if (isAbsent != null) 'is_absent': isAbsent,
      if (remarks != null) 'remarks': remarks,
      if (enteredByUserId != null) 'entered_by_user_id': enteredByUserId,
      if (enteredAt != null) 'entered_at': enteredAt,
    });
  }

  MarksCompanion copyWith({
    Value<int>? id,
    Value<int>? examSubjectId,
    Value<int>? studentId,
    Value<double?>? obtained,
    Value<bool>? isAbsent,
    Value<String?>? remarks,
    Value<int?>? enteredByUserId,
    Value<DateTime>? enteredAt,
  }) {
    return MarksCompanion(
      id: id ?? this.id,
      examSubjectId: examSubjectId ?? this.examSubjectId,
      studentId: studentId ?? this.studentId,
      obtained: obtained ?? this.obtained,
      isAbsent: isAbsent ?? this.isAbsent,
      remarks: remarks ?? this.remarks,
      enteredByUserId: enteredByUserId ?? this.enteredByUserId,
      enteredAt: enteredAt ?? this.enteredAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (examSubjectId.present) {
      map['exam_subject_id'] = Variable<int>(examSubjectId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<int>(studentId.value);
    }
    if (obtained.present) {
      map['obtained'] = Variable<double>(obtained.value);
    }
    if (isAbsent.present) {
      map['is_absent'] = Variable<bool>(isAbsent.value);
    }
    if (remarks.present) {
      map['remarks'] = Variable<String>(remarks.value);
    }
    if (enteredByUserId.present) {
      map['entered_by_user_id'] = Variable<int>(enteredByUserId.value);
    }
    if (enteredAt.present) {
      map['entered_at'] = Variable<DateTime>(enteredAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarksCompanion(')
          ..write('id: $id, ')
          ..write('examSubjectId: $examSubjectId, ')
          ..write('studentId: $studentId, ')
          ..write('obtained: $obtained, ')
          ..write('isAbsent: $isAbsent, ')
          ..write('remarks: $remarks, ')
          ..write('enteredByUserId: $enteredByUserId, ')
          ..write('enteredAt: $enteredAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SchoolsTable schools = $SchoolsTable(this);
  late final $AppUsersTable appUsers = $AppUsersTable(this);
  late final $AcademicYearsTable academicYears = $AcademicYearsTable(this);
  late final $GradesTable grades = $GradesTable(this);
  late final $SectionsTable sections = $SectionsTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $GuardiansTable guardians = $GuardiansTable(this);
  late final $StudentGuardiansTable studentGuardians = $StudentGuardiansTable(
    this,
  );
  late final $TeachersTable teachers = $TeachersTable(this);
  late final $StaffMembersTable staffMembers = $StaffMembersTable(this);
  late final $EnrollmentsTable enrollments = $EnrollmentsTable(this);
  late final $AttendancesTable attendances = $AttendancesTable(this);
  late final $LeaveRequestsTable leaveRequests = $LeaveRequestsTable(this);
  late final $AuditLogsTable auditLogs = $AuditLogsTable(this);
  late final $DevicesTable devices = $DevicesTable(this);
  late final $PairingCodesTable pairingCodes = $PairingCodesTable(this);
  late final $MessageTemplatesTable messageTemplates = $MessageTemplatesTable(
    this,
  );
  late final $MessagesTable messages = $MessagesTable(this);
  late final $AppNotificationsTable appNotifications = $AppNotificationsTable(
    this,
  );
  late final $TimeSlotsTable timeSlots = $TimeSlotsTable(this);
  late final $TimetableEntriesTable timetableEntries = $TimetableEntriesTable(
    this,
  );
  late final $ExamsTable exams = $ExamsTable(this);
  late final $ExamSubjectsTable examSubjects = $ExamSubjectsTable(this);
  late final $MarksTable marks = $MarksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schools,
    appUsers,
    academicYears,
    grades,
    sections,
    subjects,
    students,
    guardians,
    studentGuardians,
    teachers,
    staffMembers,
    enrollments,
    attendances,
    leaveRequests,
    auditLogs,
    devices,
    pairingCodes,
    messageTemplates,
    messages,
    appNotifications,
    timeSlots,
    timetableEntries,
    exams,
    examSubjects,
    marks,
  ];
}

typedef $$SchoolsTableCreateCompanionBuilder =
    SchoolsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> nameEn,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> logoPath,
      Value<String> kind,
      Value<String> dayStart,
      Value<String> dayEnd,
      Value<int> lateAfterMinutes,
      Value<int> absentAfterMinutes,
      Value<String> weekendDays,
      Value<DateTime> createdAt,
    });
typedef $$SchoolsTableUpdateCompanionBuilder =
    SchoolsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> nameEn,
      Value<String?> address,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> logoPath,
      Value<String> kind,
      Value<String> dayStart,
      Value<String> dayEnd,
      Value<int> lateAfterMinutes,
      Value<int> absentAfterMinutes,
      Value<String> weekendDays,
      Value<DateTime> createdAt,
    });

class $$SchoolsTableFilterComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayStart => $composableBuilder(
    column: $table.dayStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayEnd => $composableBuilder(
    column: $table.dayEnd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lateAfterMinutes => $composableBuilder(
    column: $table.lateAfterMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get absentAfterMinutes => $composableBuilder(
    column: $table.absentAfterMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekendDays => $composableBuilder(
    column: $table.weekendDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolsTableOrderingComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nameEn => $composableBuilder(
    column: $table.nameEn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get logoPath => $composableBuilder(
    column: $table.logoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayStart => $composableBuilder(
    column: $table.dayStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayEnd => $composableBuilder(
    column: $table.dayEnd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lateAfterMinutes => $composableBuilder(
    column: $table.lateAfterMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get absentAfterMinutes => $composableBuilder(
    column: $table.absentAfterMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekendDays => $composableBuilder(
    column: $table.weekendDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SchoolsTable> {
  $$SchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get nameEn =>
      $composableBuilder(column: $table.nameEn, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get logoPath =>
      $composableBuilder(column: $table.logoPath, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get dayStart =>
      $composableBuilder(column: $table.dayStart, builder: (column) => column);

  GeneratedColumn<String> get dayEnd =>
      $composableBuilder(column: $table.dayEnd, builder: (column) => column);

  GeneratedColumn<int> get lateAfterMinutes => $composableBuilder(
    column: $table.lateAfterMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get absentAfterMinutes => $composableBuilder(
    column: $table.absentAfterMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get weekendDays => $composableBuilder(
    column: $table.weekendDays,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SchoolsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SchoolsTable,
          School,
          $$SchoolsTableFilterComposer,
          $$SchoolsTableOrderingComposer,
          $$SchoolsTableAnnotationComposer,
          $$SchoolsTableCreateCompanionBuilder,
          $$SchoolsTableUpdateCompanionBuilder,
          (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
          School,
          PrefetchHooks Function()
        > {
  $$SchoolsTableTableManager(_$AppDatabase db, $SchoolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> nameEn = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> dayStart = const Value.absent(),
                Value<String> dayEnd = const Value.absent(),
                Value<int> lateAfterMinutes = const Value.absent(),
                Value<int> absentAfterMinutes = const Value.absent(),
                Value<String> weekendDays = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SchoolsCompanion(
                id: id,
                name: name,
                nameEn: nameEn,
                address: address,
                phone: phone,
                email: email,
                logoPath: logoPath,
                kind: kind,
                dayStart: dayStart,
                dayEnd: dayEnd,
                lateAfterMinutes: lateAfterMinutes,
                absentAfterMinutes: absentAfterMinutes,
                weekendDays: weekendDays,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> nameEn = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> logoPath = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> dayStart = const Value.absent(),
                Value<String> dayEnd = const Value.absent(),
                Value<int> lateAfterMinutes = const Value.absent(),
                Value<int> absentAfterMinutes = const Value.absent(),
                Value<String> weekendDays = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SchoolsCompanion.insert(
                id: id,
                name: name,
                nameEn: nameEn,
                address: address,
                phone: phone,
                email: email,
                logoPath: logoPath,
                kind: kind,
                dayStart: dayStart,
                dayEnd: dayEnd,
                lateAfterMinutes: lateAfterMinutes,
                absentAfterMinutes: absentAfterMinutes,
                weekendDays: weekendDays,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SchoolsTable,
      School,
      $$SchoolsTableFilterComposer,
      $$SchoolsTableOrderingComposer,
      $$SchoolsTableAnnotationComposer,
      $$SchoolsTableCreateCompanionBuilder,
      $$SchoolsTableUpdateCompanionBuilder,
      (School, BaseReferences<_$AppDatabase, $SchoolsTable, School>),
      School,
      PrefetchHooks Function()
    >;
typedef $$AppUsersTableCreateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> id,
      required String username,
      required String fullName,
      required String passwordHash,
      required String passwordSalt,
      Value<int> passwordIterations,
      required String role,
      Value<String?> permissionsJson,
      Value<int?> teacherId,
      Value<bool> isActive,
      Value<DateTime?> lastLoginAt,
      Value<int> failedAttempts,
      Value<DateTime?> lockedUntil,
      Value<DateTime> createdAt,
    });
typedef $$AppUsersTableUpdateCompanionBuilder =
    AppUsersCompanion Function({
      Value<int> id,
      Value<String> username,
      Value<String> fullName,
      Value<String> passwordHash,
      Value<String> passwordSalt,
      Value<int> passwordIterations,
      Value<String> role,
      Value<String?> permissionsJson,
      Value<int?> teacherId,
      Value<bool> isActive,
      Value<DateTime?> lastLoginAt,
      Value<int> failedAttempts,
      Value<DateTime?> lockedUntil,
      Value<DateTime> createdAt,
    });

class $$AppUsersTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableFilterComposer({
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

  ColumnFilters<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passwordIterations => $composableBuilder(
    column: $table.passwordIterations,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsersTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableOrderingComposer({
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

  ColumnOrderings<String> get username => $composableBuilder(
    column: $table.username,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passwordIterations => $composableBuilder(
    column: $table.passwordIterations,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsersTable> {
  $$AppUsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
    column: $table.passwordHash,
    builder: (column) => column,
  );

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
    column: $table.passwordSalt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get passwordIterations => $composableBuilder(
    column: $table.passwordIterations,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get permissionsJson => $composableBuilder(
    column: $table.permissionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get lastLoginAt => $composableBuilder(
    column: $table.lastLoginAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get failedAttempts => $composableBuilder(
    column: $table.failedAttempts,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lockedUntil => $composableBuilder(
    column: $table.lockedUntil,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AppUsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsersTable,
          AppUser,
          $$AppUsersTableFilterComposer,
          $$AppUsersTableOrderingComposer,
          $$AppUsersTableAnnotationComposer,
          $$AppUsersTableCreateCompanionBuilder,
          $$AppUsersTableUpdateCompanionBuilder,
          (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
          AppUser,
          PrefetchHooks Function()
        > {
  $$AppUsersTableTableManager(_$AppDatabase db, $AppUsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppUsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppUsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> username = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> passwordHash = const Value.absent(),
                Value<String> passwordSalt = const Value.absent(),
                Value<int> passwordIterations = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String?> permissionsJson = const Value.absent(),
                Value<int?> teacherId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppUsersCompanion(
                id: id,
                username: username,
                fullName: fullName,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                passwordIterations: passwordIterations,
                role: role,
                permissionsJson: permissionsJson,
                teacherId: teacherId,
                isActive: isActive,
                lastLoginAt: lastLoginAt,
                failedAttempts: failedAttempts,
                lockedUntil: lockedUntil,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String username,
                required String fullName,
                required String passwordHash,
                required String passwordSalt,
                Value<int> passwordIterations = const Value.absent(),
                required String role,
                Value<String?> permissionsJson = const Value.absent(),
                Value<int?> teacherId = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime?> lastLoginAt = const Value.absent(),
                Value<int> failedAttempts = const Value.absent(),
                Value<DateTime?> lockedUntil = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => AppUsersCompanion.insert(
                id: id,
                username: username,
                fullName: fullName,
                passwordHash: passwordHash,
                passwordSalt: passwordSalt,
                passwordIterations: passwordIterations,
                role: role,
                permissionsJson: permissionsJson,
                teacherId: teacherId,
                isActive: isActive,
                lastLoginAt: lastLoginAt,
                failedAttempts: failedAttempts,
                lockedUntil: lockedUntil,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsersTable,
      AppUser,
      $$AppUsersTableFilterComposer,
      $$AppUsersTableOrderingComposer,
      $$AppUsersTableAnnotationComposer,
      $$AppUsersTableCreateCompanionBuilder,
      $$AppUsersTableUpdateCompanionBuilder,
      (AppUser, BaseReferences<_$AppDatabase, $AppUsersTable, AppUser>),
      AppUser,
      PrefetchHooks Function()
    >;
typedef $$AcademicYearsTableCreateCompanionBuilder =
    AcademicYearsCompanion Function({
      Value<int> id,
      required String label,
      required DateTime startsOn,
      required DateTime endsOn,
      Value<bool> isCurrent,
    });
typedef $$AcademicYearsTableUpdateCompanionBuilder =
    AcademicYearsCompanion Function({
      Value<int> id,
      Value<String> label,
      Value<DateTime> startsOn,
      Value<DateTime> endsOn,
      Value<bool> isCurrent,
    });

final class $$AcademicYearsTableReferences
    extends BaseReferences<_$AppDatabase, $AcademicYearsTable, AcademicYear> {
  $$AcademicYearsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$SectionsTable, List<Section>> _sectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sections,
    aliasName: $_aliasNameGenerator(
      db.academicYears.id,
      db.sections.academicYearId,
    ),
  );

  $$SectionsTableProcessedTableManager get sectionsRefs {
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.academicYearId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EnrollmentsTable, List<Enrollment>>
  _enrollmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.enrollments,
    aliasName: $_aliasNameGenerator(
      db.academicYears.id,
      db.enrollments.academicYearId,
    ),
  );

  $$EnrollmentsTableProcessedTableManager get enrollmentsRefs {
    final manager = $$EnrollmentsTableTableManager(
      $_db,
      $_db.enrollments,
    ).filter((f) => f.academicYearId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_enrollmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamsTable, List<Exam>> _examsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.exams,
    aliasName: $_aliasNameGenerator(
      db.academicYears.id,
      db.exams.academicYearId,
    ),
  );

  $$ExamsTableProcessedTableManager get examsRefs {
    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.academicYearId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AcademicYearsTableFilterComposer
    extends Composer<_$AppDatabase, $AcademicYearsTable> {
  $$AcademicYearsTableFilterComposer({
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

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sectionsRefs(
    Expression<bool> Function($$SectionsTableFilterComposer f) f,
  ) {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.academicYearId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> enrollmentsRefs(
    Expression<bool> Function($$EnrollmentsTableFilterComposer f) f,
  ) {
    final $$EnrollmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.enrollments,
      getReferencedColumn: (t) => t.academicYearId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnrollmentsTableFilterComposer(
            $db: $db,
            $table: $db.enrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examsRefs(
    Expression<bool> Function($$ExamsTableFilterComposer f) f,
  ) {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.academicYearId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AcademicYearsTableOrderingComposer
    extends Composer<_$AppDatabase, $AcademicYearsTable> {
  $$AcademicYearsTableOrderingComposer({
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

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCurrent => $composableBuilder(
    column: $table.isCurrent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcademicYearsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AcademicYearsTable> {
  $$AcademicYearsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<DateTime> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<bool> get isCurrent =>
      $composableBuilder(column: $table.isCurrent, builder: (column) => column);

  Expression<T> sectionsRefs<T extends Object>(
    Expression<T> Function($$SectionsTableAnnotationComposer a) f,
  ) {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.academicYearId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> enrollmentsRefs<T extends Object>(
    Expression<T> Function($$EnrollmentsTableAnnotationComposer a) f,
  ) {
    final $$EnrollmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.enrollments,
      getReferencedColumn: (t) => t.academicYearId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnrollmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.enrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examsRefs<T extends Object>(
    Expression<T> Function($$ExamsTableAnnotationComposer a) f,
  ) {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.academicYearId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AcademicYearsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AcademicYearsTable,
          AcademicYear,
          $$AcademicYearsTableFilterComposer,
          $$AcademicYearsTableOrderingComposer,
          $$AcademicYearsTableAnnotationComposer,
          $$AcademicYearsTableCreateCompanionBuilder,
          $$AcademicYearsTableUpdateCompanionBuilder,
          (AcademicYear, $$AcademicYearsTableReferences),
          AcademicYear,
          PrefetchHooks Function({
            bool sectionsRefs,
            bool enrollmentsRefs,
            bool examsRefs,
          })
        > {
  $$AcademicYearsTableTableManager(_$AppDatabase db, $AcademicYearsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcademicYearsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcademicYearsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcademicYearsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<DateTime> startsOn = const Value.absent(),
                Value<DateTime> endsOn = const Value.absent(),
                Value<bool> isCurrent = const Value.absent(),
              }) => AcademicYearsCompanion(
                id: id,
                label: label,
                startsOn: startsOn,
                endsOn: endsOn,
                isCurrent: isCurrent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String label,
                required DateTime startsOn,
                required DateTime endsOn,
                Value<bool> isCurrent = const Value.absent(),
              }) => AcademicYearsCompanion.insert(
                id: id,
                label: label,
                startsOn: startsOn,
                endsOn: endsOn,
                isCurrent: isCurrent,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AcademicYearsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sectionsRefs = false,
                enrollmentsRefs = false,
                examsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sectionsRefs) db.sections,
                    if (enrollmentsRefs) db.enrollments,
                    if (examsRefs) db.exams,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sectionsRefs)
                        await $_getPrefetchedData<
                          AcademicYear,
                          $AcademicYearsTable,
                          Section
                        >(
                          currentTable: table,
                          referencedTable: $$AcademicYearsTableReferences
                              ._sectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AcademicYearsTableReferences(
                                db,
                                table,
                                p0,
                              ).sectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.academicYearId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (enrollmentsRefs)
                        await $_getPrefetchedData<
                          AcademicYear,
                          $AcademicYearsTable,
                          Enrollment
                        >(
                          currentTable: table,
                          referencedTable: $$AcademicYearsTableReferences
                              ._enrollmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AcademicYearsTableReferences(
                                db,
                                table,
                                p0,
                              ).enrollmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.academicYearId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examsRefs)
                        await $_getPrefetchedData<
                          AcademicYear,
                          $AcademicYearsTable,
                          Exam
                        >(
                          currentTable: table,
                          referencedTable: $$AcademicYearsTableReferences
                              ._examsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$AcademicYearsTableReferences(
                                db,
                                table,
                                p0,
                              ).examsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.academicYearId == item.id,
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

typedef $$AcademicYearsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AcademicYearsTable,
      AcademicYear,
      $$AcademicYearsTableFilterComposer,
      $$AcademicYearsTableOrderingComposer,
      $$AcademicYearsTableAnnotationComposer,
      $$AcademicYearsTableCreateCompanionBuilder,
      $$AcademicYearsTableUpdateCompanionBuilder,
      (AcademicYear, $$AcademicYearsTableReferences),
      AcademicYear,
      PrefetchHooks Function({
        bool sectionsRefs,
        bool enrollmentsRefs,
        bool examsRefs,
      })
    >;
typedef $$GradesTableCreateCompanionBuilder =
    GradesCompanion Function({
      Value<int> id,
      required String name,
      required int level,
      Value<int> sortOrder,
    });
typedef $$GradesTableUpdateCompanionBuilder =
    GradesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> level,
      Value<int> sortOrder,
    });

final class $$GradesTableReferences
    extends BaseReferences<_$AppDatabase, $GradesTable, Grade> {
  $$GradesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SectionsTable, List<Section>> _sectionsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.sections,
    aliasName: $_aliasNameGenerator(db.grades.id, db.sections.gradeId),
  );

  $$SectionsTableProcessedTableManager get sectionsRefs {
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.gradeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sectionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SubjectsTable, List<Subject>> _subjectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.subjects,
    aliasName: $_aliasNameGenerator(db.grades.id, db.subjects.gradeId),
  );

  $$SubjectsTableProcessedTableManager get subjectsRefs {
    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.gradeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_subjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamSubjectsTable, List<ExamSubject>>
  _examSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examSubjects,
    aliasName: $_aliasNameGenerator(db.grades.id, db.examSubjects.gradeId),
  );

  $$ExamSubjectsTableProcessedTableManager get examSubjectsRefs {
    final manager = $$ExamSubjectsTableTableManager(
      $_db,
      $_db.examSubjects,
    ).filter((f) => f.gradeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GradesTableFilterComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sectionsRefs(
    Expression<bool> Function($$SectionsTableFilterComposer f) f,
  ) {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.gradeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> subjectsRefs(
    Expression<bool> Function($$SubjectsTableFilterComposer f) f,
  ) {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.gradeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examSubjectsRefs(
    Expression<bool> Function($$ExamSubjectsTableFilterComposer f) f,
  ) {
    final $$ExamSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.gradeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GradesTableOrderingComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GradesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GradesTable> {
  $$GradesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> sectionsRefs<T extends Object>(
    Expression<T> Function($$SectionsTableAnnotationComposer a) f,
  ) {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.gradeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> subjectsRefs<T extends Object>(
    Expression<T> Function($$SubjectsTableAnnotationComposer a) f,
  ) {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.gradeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examSubjectsRefs<T extends Object>(
    Expression<T> Function($$ExamSubjectsTableAnnotationComposer a) f,
  ) {
    final $$ExamSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.gradeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GradesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GradesTable,
          Grade,
          $$GradesTableFilterComposer,
          $$GradesTableOrderingComposer,
          $$GradesTableAnnotationComposer,
          $$GradesTableCreateCompanionBuilder,
          $$GradesTableUpdateCompanionBuilder,
          (Grade, $$GradesTableReferences),
          Grade,
          PrefetchHooks Function({
            bool sectionsRefs,
            bool subjectsRefs,
            bool examSubjectsRefs,
          })
        > {
  $$GradesTableTableManager(_$AppDatabase db, $GradesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GradesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GradesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GradesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> level = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => GradesCompanion(
                id: id,
                name: name,
                level: level,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int level,
                Value<int> sortOrder = const Value.absent(),
              }) => GradesCompanion.insert(
                id: id,
                name: name,
                level: level,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GradesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sectionsRefs = false,
                subjectsRefs = false,
                examSubjectsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sectionsRefs) db.sections,
                    if (subjectsRefs) db.subjects,
                    if (examSubjectsRefs) db.examSubjects,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sectionsRefs)
                        await $_getPrefetchedData<Grade, $GradesTable, Section>(
                          currentTable: table,
                          referencedTable: $$GradesTableReferences
                              ._sectionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GradesTableReferences(
                                db,
                                table,
                                p0,
                              ).sectionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gradeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (subjectsRefs)
                        await $_getPrefetchedData<Grade, $GradesTable, Subject>(
                          currentTable: table,
                          referencedTable: $$GradesTableReferences
                              ._subjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GradesTableReferences(
                                db,
                                table,
                                p0,
                              ).subjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gradeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examSubjectsRefs)
                        await $_getPrefetchedData<
                          Grade,
                          $GradesTable,
                          ExamSubject
                        >(
                          currentTable: table,
                          referencedTable: $$GradesTableReferences
                              ._examSubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GradesTableReferences(
                                db,
                                table,
                                p0,
                              ).examSubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gradeId == item.id,
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

typedef $$GradesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GradesTable,
      Grade,
      $$GradesTableFilterComposer,
      $$GradesTableOrderingComposer,
      $$GradesTableAnnotationComposer,
      $$GradesTableCreateCompanionBuilder,
      $$GradesTableUpdateCompanionBuilder,
      (Grade, $$GradesTableReferences),
      Grade,
      PrefetchHooks Function({
        bool sectionsRefs,
        bool subjectsRefs,
        bool examSubjectsRefs,
      })
    >;
typedef $$SectionsTableCreateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      required int gradeId,
      required int academicYearId,
      required String name,
      Value<int> capacity,
      Value<int?> headTeacherId,
      Value<String?> room,
    });
typedef $$SectionsTableUpdateCompanionBuilder =
    SectionsCompanion Function({
      Value<int> id,
      Value<int> gradeId,
      Value<int> academicYearId,
      Value<String> name,
      Value<int> capacity,
      Value<int?> headTeacherId,
      Value<String?> room,
    });

final class $$SectionsTableReferences
    extends BaseReferences<_$AppDatabase, $SectionsTable, Section> {
  $$SectionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GradesTable _gradeIdTable(_$AppDatabase db) => db.grades.createAlias(
    $_aliasNameGenerator(db.sections.gradeId, db.grades.id),
  );

  $$GradesTableProcessedTableManager get gradeId {
    final $_column = $_itemColumn<int>('grade_id')!;

    final manager = $$GradesTableTableManager(
      $_db,
      $_db.grades,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gradeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AcademicYearsTable _academicYearIdTable(_$AppDatabase db) =>
      db.academicYears.createAlias(
        $_aliasNameGenerator(db.sections.academicYearId, db.academicYears.id),
      );

  $$AcademicYearsTableProcessedTableManager get academicYearId {
    final $_column = $_itemColumn<int>('academic_year_id')!;

    final manager = $$AcademicYearsTableTableManager(
      $_db,
      $_db.academicYears,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_academicYearIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EnrollmentsTable, List<Enrollment>>
  _enrollmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.enrollments,
    aliasName: $_aliasNameGenerator(db.sections.id, db.enrollments.sectionId),
  );

  $$EnrollmentsTableProcessedTableManager get enrollmentsRefs {
    final manager = $$EnrollmentsTableTableManager(
      $_db,
      $_db.enrollments,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_enrollmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendancesTable, List<Attendance>>
  _attendancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendances,
    aliasName: $_aliasNameGenerator(db.sections.id, db.attendances.sectionId),
  );

  $$AttendancesTableProcessedTableManager get attendancesRefs {
    final manager = $$AttendancesTableTableManager(
      $_db,
      $_db.attendances,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TimetableEntriesTable, List<TimetableEntry>>
  _timetableEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetableEntries,
    aliasName: $_aliasNameGenerator(
      db.sections.id,
      db.timetableEntries.sectionId,
    ),
  );

  $$TimetableEntriesTableProcessedTableManager get timetableEntriesRefs {
    final manager = $$TimetableEntriesTableTableManager(
      $_db,
      $_db.timetableEntries,
    ).filter((f) => f.sectionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timetableEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SectionsTableFilterComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get headTeacherId => $composableBuilder(
    column: $table.headTeacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  $$GradesTableFilterComposer get gradeId {
    final $$GradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableFilterComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AcademicYearsTableFilterComposer get academicYearId {
    final $$AcademicYearsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableFilterComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> enrollmentsRefs(
    Expression<bool> Function($$EnrollmentsTableFilterComposer f) f,
  ) {
    final $$EnrollmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.enrollments,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnrollmentsTableFilterComposer(
            $db: $db,
            $table: $db.enrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendancesRefs(
    Expression<bool> Function($$AttendancesTableFilterComposer f) f,
  ) {
    final $$AttendancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendances,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendancesTableFilterComposer(
            $db: $db,
            $table: $db.attendances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> timetableEntriesRefs(
    Expression<bool> Function($$TimetableEntriesTableFilterComposer f) f,
  ) {
    final $$TimetableEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get capacity => $composableBuilder(
    column: $table.capacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get headTeacherId => $composableBuilder(
    column: $table.headTeacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  $$GradesTableOrderingComposer get gradeId {
    final $$GradesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableOrderingComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AcademicYearsTableOrderingComposer get academicYearId {
    final $$AcademicYearsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableOrderingComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SectionsTable> {
  $$SectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get capacity =>
      $composableBuilder(column: $table.capacity, builder: (column) => column);

  GeneratedColumn<int> get headTeacherId => $composableBuilder(
    column: $table.headTeacherId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  $$GradesTableAnnotationComposer get gradeId {
    final $$GradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableAnnotationComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AcademicYearsTableAnnotationComposer get academicYearId {
    final $$AcademicYearsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableAnnotationComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> enrollmentsRefs<T extends Object>(
    Expression<T> Function($$EnrollmentsTableAnnotationComposer a) f,
  ) {
    final $$EnrollmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.enrollments,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnrollmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.enrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendancesRefs<T extends Object>(
    Expression<T> Function($$AttendancesTableAnnotationComposer a) f,
  ) {
    final $$AttendancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendances,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendancesTableAnnotationComposer(
            $db: $db,
            $table: $db.attendances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> timetableEntriesRefs<T extends Object>(
    Expression<T> Function($$TimetableEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimetableEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.sectionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SectionsTable,
          Section,
          $$SectionsTableFilterComposer,
          $$SectionsTableOrderingComposer,
          $$SectionsTableAnnotationComposer,
          $$SectionsTableCreateCompanionBuilder,
          $$SectionsTableUpdateCompanionBuilder,
          (Section, $$SectionsTableReferences),
          Section,
          PrefetchHooks Function({
            bool gradeId,
            bool academicYearId,
            bool enrollmentsRefs,
            bool attendancesRefs,
            bool timetableEntriesRefs,
          })
        > {
  $$SectionsTableTableManager(_$AppDatabase db, $SectionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> gradeId = const Value.absent(),
                Value<int> academicYearId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> capacity = const Value.absent(),
                Value<int?> headTeacherId = const Value.absent(),
                Value<String?> room = const Value.absent(),
              }) => SectionsCompanion(
                id: id,
                gradeId: gradeId,
                academicYearId: academicYearId,
                name: name,
                capacity: capacity,
                headTeacherId: headTeacherId,
                room: room,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int gradeId,
                required int academicYearId,
                required String name,
                Value<int> capacity = const Value.absent(),
                Value<int?> headTeacherId = const Value.absent(),
                Value<String?> room = const Value.absent(),
              }) => SectionsCompanion.insert(
                id: id,
                gradeId: gradeId,
                academicYearId: academicYearId,
                name: name,
                capacity: capacity,
                headTeacherId: headTeacherId,
                room: room,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SectionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gradeId = false,
                academicYearId = false,
                enrollmentsRefs = false,
                attendancesRefs = false,
                timetableEntriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (enrollmentsRefs) db.enrollments,
                    if (attendancesRefs) db.attendances,
                    if (timetableEntriesRefs) db.timetableEntries,
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
                        if (gradeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gradeId,
                                    referencedTable: $$SectionsTableReferences
                                        ._gradeIdTable(db),
                                    referencedColumn: $$SectionsTableReferences
                                        ._gradeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (academicYearId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.academicYearId,
                                    referencedTable: $$SectionsTableReferences
                                        ._academicYearIdTable(db),
                                    referencedColumn: $$SectionsTableReferences
                                        ._academicYearIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (enrollmentsRefs)
                        await $_getPrefetchedData<
                          Section,
                          $SectionsTable,
                          Enrollment
                        >(
                          currentTable: table,
                          referencedTable: $$SectionsTableReferences
                              ._enrollmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).enrollmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendancesRefs)
                        await $_getPrefetchedData<
                          Section,
                          $SectionsTable,
                          Attendance
                        >(
                          currentTable: table,
                          referencedTable: $$SectionsTableReferences
                              ._attendancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (timetableEntriesRefs)
                        await $_getPrefetchedData<
                          Section,
                          $SectionsTable,
                          TimetableEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SectionsTableReferences
                              ._timetableEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SectionsTableReferences(
                                db,
                                table,
                                p0,
                              ).timetableEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sectionId == item.id,
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

typedef $$SectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SectionsTable,
      Section,
      $$SectionsTableFilterComposer,
      $$SectionsTableOrderingComposer,
      $$SectionsTableAnnotationComposer,
      $$SectionsTableCreateCompanionBuilder,
      $$SectionsTableUpdateCompanionBuilder,
      (Section, $$SectionsTableReferences),
      Section,
      PrefetchHooks Function({
        bool gradeId,
        bool academicYearId,
        bool enrollmentsRefs,
        bool attendancesRefs,
        bool timetableEntriesRefs,
      })
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> code,
      Value<int?> gradeId,
      Value<int> fullMark,
      Value<int> passMark,
      Value<bool> isReligious,
      Value<int> sortOrder,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> code,
      Value<int?> gradeId,
      Value<int> fullMark,
      Value<int> passMark,
      Value<bool> isReligious,
      Value<int> sortOrder,
    });

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, Subject> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GradesTable _gradeIdTable(_$AppDatabase db) => db.grades.createAlias(
    $_aliasNameGenerator(db.subjects.gradeId, db.grades.id),
  );

  $$GradesTableProcessedTableManager? get gradeId {
    final $_column = $_itemColumn<int>('grade_id');
    if ($_column == null) return null;
    final manager = $$GradesTableTableManager(
      $_db,
      $_db.grades,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gradeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TimetableEntriesTable, List<TimetableEntry>>
  _timetableEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetableEntries,
    aliasName: $_aliasNameGenerator(
      db.subjects.id,
      db.timetableEntries.subjectId,
    ),
  );

  $$TimetableEntriesTableProcessedTableManager get timetableEntriesRefs {
    final manager = $$TimetableEntriesTableTableManager(
      $_db,
      $_db.timetableEntries,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timetableEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ExamSubjectsTable, List<ExamSubject>>
  _examSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examSubjects,
    aliasName: $_aliasNameGenerator(db.subjects.id, db.examSubjects.subjectId),
  );

  $$ExamSubjectsTableProcessedTableManager get examSubjectsRefs {
    final manager = $$ExamSubjectsTableTableManager(
      $_db,
      $_db.examSubjects,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fullMark => $composableBuilder(
    column: $table.fullMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passMark => $composableBuilder(
    column: $table.passMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isReligious => $composableBuilder(
    column: $table.isReligious,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$GradesTableFilterComposer get gradeId {
    final $$GradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableFilterComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> timetableEntriesRefs(
    Expression<bool> Function($$TimetableEntriesTableFilterComposer f) f,
  ) {
    final $$TimetableEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> examSubjectsRefs(
    Expression<bool> Function($$ExamSubjectsTableFilterComposer f) f,
  ) {
    final $$ExamSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fullMark => $composableBuilder(
    column: $table.fullMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passMark => $composableBuilder(
    column: $table.passMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isReligious => $composableBuilder(
    column: $table.isReligious,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$GradesTableOrderingComposer get gradeId {
    final $$GradesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableOrderingComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<int> get fullMark =>
      $composableBuilder(column: $table.fullMark, builder: (column) => column);

  GeneratedColumn<int> get passMark =>
      $composableBuilder(column: $table.passMark, builder: (column) => column);

  GeneratedColumn<bool> get isReligious => $composableBuilder(
    column: $table.isReligious,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$GradesTableAnnotationComposer get gradeId {
    final $$GradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableAnnotationComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> timetableEntriesRefs<T extends Object>(
    Expression<T> Function($$TimetableEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimetableEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> examSubjectsRefs<T extends Object>(
    Expression<T> Function($$ExamSubjectsTableAnnotationComposer a) f,
  ) {
    final $$ExamSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, $$SubjectsTableReferences),
          Subject,
          PrefetchHooks Function({
            bool gradeId,
            bool timetableEntriesRefs,
            bool examSubjectsRefs,
          })
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> code = const Value.absent(),
                Value<int?> gradeId = const Value.absent(),
                Value<int> fullMark = const Value.absent(),
                Value<int> passMark = const Value.absent(),
                Value<bool> isReligious = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                code: code,
                gradeId: gradeId,
                fullMark: fullMark,
                passMark: passMark,
                isReligious: isReligious,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> code = const Value.absent(),
                Value<int?> gradeId = const Value.absent(),
                Value<int> fullMark = const Value.absent(),
                Value<int> passMark = const Value.absent(),
                Value<bool> isReligious = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                code: code,
                gradeId: gradeId,
                fullMark: fullMark,
                passMark: passMark,
                isReligious: isReligious,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gradeId = false,
                timetableEntriesRefs = false,
                examSubjectsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (timetableEntriesRefs) db.timetableEntries,
                    if (examSubjectsRefs) db.examSubjects,
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
                        if (gradeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gradeId,
                                    referencedTable: $$SubjectsTableReferences
                                        ._gradeIdTable(db),
                                    referencedColumn: $$SubjectsTableReferences
                                        ._gradeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (timetableEntriesRefs)
                        await $_getPrefetchedData<
                          Subject,
                          $SubjectsTable,
                          TimetableEntry
                        >(
                          currentTable: table,
                          referencedTable: $$SubjectsTableReferences
                              ._timetableEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).timetableEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subjectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (examSubjectsRefs)
                        await $_getPrefetchedData<
                          Subject,
                          $SubjectsTable,
                          ExamSubject
                        >(
                          currentTable: table,
                          referencedTable: $$SubjectsTableReferences
                              ._examSubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).examSubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subjectId == item.id,
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

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, $$SubjectsTableReferences),
      Subject,
      PrefetchHooks Function({
        bool gradeId,
        bool timetableEntriesRefs,
        bool examSubjectsRefs,
      })
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      required String admissionNo,
      required String firstName,
      Value<String?> lastName,
      required String fatherName,
      Value<String?> grandFatherName,
      required String gender,
      Value<DateTime?> birthDate,
      Value<String?> birthPlace,
      Value<String?> nationalId,
      Value<String?> photoPath,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> bloodGroup,
      Value<String?> medicalNotes,
      Value<DateTime> admittedOn,
      Value<String> status,
      Value<String?> qrSecret,
      Value<int> cardVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<int> id,
      Value<String> admissionNo,
      Value<String> firstName,
      Value<String?> lastName,
      Value<String> fatherName,
      Value<String?> grandFatherName,
      Value<String> gender,
      Value<DateTime?> birthDate,
      Value<String?> birthPlace,
      Value<String?> nationalId,
      Value<String?> photoPath,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> bloodGroup,
      Value<String?> medicalNotes,
      Value<DateTime> admittedOn,
      Value<String> status,
      Value<String?> qrSecret,
      Value<int> cardVersion,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
    });

final class $$StudentsTableReferences
    extends BaseReferences<_$AppDatabase, $StudentsTable, Student> {
  $$StudentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudentGuardiansTable, List<StudentGuardian>>
  _studentGuardiansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studentGuardians,
    aliasName: $_aliasNameGenerator(
      db.students.id,
      db.studentGuardians.studentId,
    ),
  );

  $$StudentGuardiansTableProcessedTableManager get studentGuardiansRefs {
    final manager = $$StudentGuardiansTableTableManager(
      $_db,
      $_db.studentGuardians,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studentGuardiansRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EnrollmentsTable, List<Enrollment>>
  _enrollmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.enrollments,
    aliasName: $_aliasNameGenerator(db.students.id, db.enrollments.studentId),
  );

  $$EnrollmentsTableProcessedTableManager get enrollmentsRefs {
    final manager = $$EnrollmentsTableTableManager(
      $_db,
      $_db.enrollments,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_enrollmentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AttendancesTable, List<Attendance>>
  _attendancesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.attendances,
    aliasName: $_aliasNameGenerator(db.students.id, db.attendances.studentId),
  );

  $$AttendancesTableProcessedTableManager get attendancesRefs {
    final manager = $$AttendancesTableTableManager(
      $_db,
      $_db.attendances,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_attendancesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LeaveRequestsTable, List<LeaveRequest>>
  _leaveRequestsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.leaveRequests,
    aliasName: $_aliasNameGenerator(db.students.id, db.leaveRequests.studentId),
  );

  $$LeaveRequestsTableProcessedTableManager get leaveRequestsRefs {
    final manager = $$LeaveRequestsTableTableManager(
      $_db,
      $_db.leaveRequests,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_leaveRequestsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.students.id, db.messages.studentId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MarksTable, List<Mark>> _marksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.marks,
    aliasName: $_aliasNameGenerator(db.students.id, db.marks.studentId),
  );

  $$MarksTableProcessedTableManager get marksRefs {
    final manager = $$MarksTableTableManager(
      $_db,
      $_db.marks,
    ).filter((f) => f.studentId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_marksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$StudentsTableFilterComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
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

  ColumnFilters<String> get admissionNo => $composableBuilder(
    column: $table.admissionNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get medicalNotes => $composableBuilder(
    column: $table.medicalNotes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get admittedOn => $composableBuilder(
    column: $table.admittedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrSecret => $composableBuilder(
    column: $table.qrSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cardVersion => $composableBuilder(
    column: $table.cardVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> studentGuardiansRefs(
    Expression<bool> Function($$StudentGuardiansTableFilterComposer f) f,
  ) {
    final $$StudentGuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentGuardians,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentGuardiansTableFilterComposer(
            $db: $db,
            $table: $db.studentGuardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> enrollmentsRefs(
    Expression<bool> Function($$EnrollmentsTableFilterComposer f) f,
  ) {
    final $$EnrollmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.enrollments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnrollmentsTableFilterComposer(
            $db: $db,
            $table: $db.enrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> attendancesRefs(
    Expression<bool> Function($$AttendancesTableFilterComposer f) f,
  ) {
    final $$AttendancesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendances,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendancesTableFilterComposer(
            $db: $db,
            $table: $db.attendances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> leaveRequestsRefs(
    Expression<bool> Function($$LeaveRequestsTableFilterComposer f) f,
  ) {
    final $$LeaveRequestsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.leaveRequests,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LeaveRequestsTableFilterComposer(
            $db: $db,
            $table: $db.leaveRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> marksRefs(
    Expression<bool> Function($$MarksTableFilterComposer f) f,
  ) {
    final $$MarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.marks,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarksTableFilterComposer(
            $db: $db,
            $table: $db.marks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
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

  ColumnOrderings<String> get admissionNo => $composableBuilder(
    column: $table.admissionNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstName => $composableBuilder(
    column: $table.firstName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
    column: $table.birthDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get medicalNotes => $composableBuilder(
    column: $table.medicalNotes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get admittedOn => $composableBuilder(
    column: $table.admittedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrSecret => $composableBuilder(
    column: $table.qrSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cardVersion => $composableBuilder(
    column: $table.cardVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get admissionNo => $composableBuilder(
    column: $table.admissionNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firstName =>
      $composableBuilder(column: $table.firstName, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get grandFatherName => $composableBuilder(
    column: $table.grandFatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<String> get birthPlace => $composableBuilder(
    column: $table.birthPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get bloodGroup => $composableBuilder(
    column: $table.bloodGroup,
    builder: (column) => column,
  );

  GeneratedColumn<String> get medicalNotes => $composableBuilder(
    column: $table.medicalNotes,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get admittedOn => $composableBuilder(
    column: $table.admittedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get qrSecret =>
      $composableBuilder(column: $table.qrSecret, builder: (column) => column);

  GeneratedColumn<int> get cardVersion => $composableBuilder(
    column: $table.cardVersion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> studentGuardiansRefs<T extends Object>(
    Expression<T> Function($$StudentGuardiansTableAnnotationComposer a) f,
  ) {
    final $$StudentGuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentGuardians,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentGuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.studentGuardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> enrollmentsRefs<T extends Object>(
    Expression<T> Function($$EnrollmentsTableAnnotationComposer a) f,
  ) {
    final $$EnrollmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.enrollments,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EnrollmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.enrollments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> attendancesRefs<T extends Object>(
    Expression<T> Function($$AttendancesTableAnnotationComposer a) f,
  ) {
    final $$AttendancesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.attendances,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AttendancesTableAnnotationComposer(
            $db: $db,
            $table: $db.attendances,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> leaveRequestsRefs<T extends Object>(
    Expression<T> Function($$LeaveRequestsTableAnnotationComposer a) f,
  ) {
    final $$LeaveRequestsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.leaveRequests,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LeaveRequestsTableAnnotationComposer(
            $db: $db,
            $table: $db.leaveRequests,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> marksRefs<T extends Object>(
    Expression<T> Function($$MarksTableAnnotationComposer a) f,
  ) {
    final $$MarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.marks,
      getReferencedColumn: (t) => t.studentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarksTableAnnotationComposer(
            $db: $db,
            $table: $db.marks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, $$StudentsTableReferences),
          Student,
          PrefetchHooks Function({
            bool studentGuardiansRefs,
            bool enrollmentsRefs,
            bool attendancesRefs,
            bool leaveRequestsRefs,
            bool messagesRefs,
            bool marksRefs,
          })
        > {
  $$StudentsTableTableManager(_$AppDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> admissionNo = const Value.absent(),
                Value<String> firstName = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String> fatherName = const Value.absent(),
                Value<String?> grandFatherName = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<String?> medicalNotes = const Value.absent(),
                Value<DateTime> admittedOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> qrSecret = const Value.absent(),
                Value<int> cardVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                admissionNo: admissionNo,
                firstName: firstName,
                lastName: lastName,
                fatherName: fatherName,
                grandFatherName: grandFatherName,
                gender: gender,
                birthDate: birthDate,
                birthPlace: birthPlace,
                nationalId: nationalId,
                photoPath: photoPath,
                phone: phone,
                address: address,
                bloodGroup: bloodGroup,
                medicalNotes: medicalNotes,
                admittedOn: admittedOn,
                status: status,
                qrSecret: qrSecret,
                cardVersion: cardVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String admissionNo,
                required String firstName,
                Value<String?> lastName = const Value.absent(),
                required String fatherName,
                Value<String?> grandFatherName = const Value.absent(),
                required String gender,
                Value<DateTime?> birthDate = const Value.absent(),
                Value<String?> birthPlace = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> bloodGroup = const Value.absent(),
                Value<String?> medicalNotes = const Value.absent(),
                Value<DateTime> admittedOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> qrSecret = const Value.absent(),
                Value<int> cardVersion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                admissionNo: admissionNo,
                firstName: firstName,
                lastName: lastName,
                fatherName: fatherName,
                grandFatherName: grandFatherName,
                gender: gender,
                birthDate: birthDate,
                birthPlace: birthPlace,
                nationalId: nationalId,
                photoPath: photoPath,
                phone: phone,
                address: address,
                bloodGroup: bloodGroup,
                medicalNotes: medicalNotes,
                admittedOn: admittedOn,
                status: status,
                qrSecret: qrSecret,
                cardVersion: cardVersion,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                studentGuardiansRefs = false,
                enrollmentsRefs = false,
                attendancesRefs = false,
                leaveRequestsRefs = false,
                messagesRefs = false,
                marksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studentGuardiansRefs) db.studentGuardians,
                    if (enrollmentsRefs) db.enrollments,
                    if (attendancesRefs) db.attendances,
                    if (leaveRequestsRefs) db.leaveRequests,
                    if (messagesRefs) db.messages,
                    if (marksRefs) db.marks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studentGuardiansRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          StudentGuardian
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._studentGuardiansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).studentGuardiansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (enrollmentsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Enrollment
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._enrollmentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).enrollmentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (attendancesRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Attendance
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._attendancesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).attendancesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (leaveRequestsRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          LeaveRequest
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._leaveRequestsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).leaveRequestsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Message
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (marksRefs)
                        await $_getPrefetchedData<
                          Student,
                          $StudentsTable,
                          Mark
                        >(
                          currentTable: table,
                          referencedTable: $$StudentsTableReferences
                              ._marksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$StudentsTableReferences(
                                db,
                                table,
                                p0,
                              ).marksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.studentId == item.id,
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

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, $$StudentsTableReferences),
      Student,
      PrefetchHooks Function({
        bool studentGuardiansRefs,
        bool enrollmentsRefs,
        bool attendancesRefs,
        bool leaveRequestsRefs,
        bool messagesRefs,
        bool marksRefs,
      })
    >;
typedef $$GuardiansTableCreateCompanionBuilder =
    GuardiansCompanion Function({
      Value<int> id,
      required String fullName,
      required String relation,
      Value<String?> phone,
      Value<String?> altPhone,
      Value<String?> occupation,
      Value<String?> nationalId,
      Value<String?> address,
      Value<String?> appLoginCode,
      Value<String?> fcmToken,
      Value<String> preferredChannel,
    });
typedef $$GuardiansTableUpdateCompanionBuilder =
    GuardiansCompanion Function({
      Value<int> id,
      Value<String> fullName,
      Value<String> relation,
      Value<String?> phone,
      Value<String?> altPhone,
      Value<String?> occupation,
      Value<String?> nationalId,
      Value<String?> address,
      Value<String?> appLoginCode,
      Value<String?> fcmToken,
      Value<String> preferredChannel,
    });

final class $$GuardiansTableReferences
    extends BaseReferences<_$AppDatabase, $GuardiansTable, Guardian> {
  $$GuardiansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StudentGuardiansTable, List<StudentGuardian>>
  _studentGuardiansRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.studentGuardians,
    aliasName: $_aliasNameGenerator(
      db.guardians.id,
      db.studentGuardians.guardianId,
    ),
  );

  $$StudentGuardiansTableProcessedTableManager get studentGuardiansRefs {
    final manager = $$StudentGuardiansTableTableManager(
      $_db,
      $_db.studentGuardians,
    ).filter((f) => f.guardianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _studentGuardiansRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DevicesTable, List<Device>> _devicesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.devices,
    aliasName: $_aliasNameGenerator(db.guardians.id, db.devices.guardianId),
  );

  $$DevicesTableProcessedTableManager get devicesRefs {
    final manager = $$DevicesTableTableManager(
      $_db,
      $_db.devices,
    ).filter((f) => f.guardianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_devicesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PairingCodesTable, List<PairingCode>>
  _pairingCodesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.pairingCodes,
    aliasName: $_aliasNameGenerator(
      db.guardians.id,
      db.pairingCodes.guardianId,
    ),
  );

  $$PairingCodesTableProcessedTableManager get pairingCodesRefs {
    final manager = $$PairingCodesTableTableManager(
      $_db,
      $_db.pairingCodes,
    ).filter((f) => f.guardianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_pairingCodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MessagesTable, List<Message>> _messagesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.messages,
    aliasName: $_aliasNameGenerator(db.guardians.id, db.messages.guardianId),
  );

  $$MessagesTableProcessedTableManager get messagesRefs {
    final manager = $$MessagesTableTableManager(
      $_db,
      $_db.messages,
    ).filter((f) => f.guardianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_messagesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AppNotificationsTable, List<AppNotification>>
  _appNotificationsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.appNotifications,
    aliasName: $_aliasNameGenerator(
      db.guardians.id,
      db.appNotifications.guardianId,
    ),
  );

  $$AppNotificationsTableProcessedTableManager get appNotificationsRefs {
    final manager = $$AppNotificationsTableTableManager(
      $_db,
      $_db.appNotifications,
    ).filter((f) => f.guardianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _appNotificationsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GuardiansTableFilterComposer
    extends Composer<_$AppDatabase, $GuardiansTable> {
  $$GuardiansTableFilterComposer({
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

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get altPhone => $composableBuilder(
    column: $table.altPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appLoginCode => $composableBuilder(
    column: $table.appLoginCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredChannel => $composableBuilder(
    column: $table.preferredChannel,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> studentGuardiansRefs(
    Expression<bool> Function($$StudentGuardiansTableFilterComposer f) f,
  ) {
    final $$StudentGuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentGuardians,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentGuardiansTableFilterComposer(
            $db: $db,
            $table: $db.studentGuardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> devicesRefs(
    Expression<bool> Function($$DevicesTableFilterComposer f) f,
  ) {
    final $$DevicesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableFilterComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> pairingCodesRefs(
    Expression<bool> Function($$PairingCodesTableFilterComposer f) f,
  ) {
    final $$PairingCodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairingCodes,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairingCodesTableFilterComposer(
            $db: $db,
            $table: $db.pairingCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> messagesRefs(
    Expression<bool> Function($$MessagesTableFilterComposer f) f,
  ) {
    final $$MessagesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableFilterComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> appNotificationsRefs(
    Expression<bool> Function($$AppNotificationsTableFilterComposer f) f,
  ) {
    final $$AppNotificationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appNotifications,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppNotificationsTableFilterComposer(
            $db: $db,
            $table: $db.appNotifications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GuardiansTableOrderingComposer
    extends Composer<_$AppDatabase, $GuardiansTable> {
  $$GuardiansTableOrderingComposer({
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

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relation => $composableBuilder(
    column: $table.relation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get altPhone => $composableBuilder(
    column: $table.altPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appLoginCode => $composableBuilder(
    column: $table.appLoginCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fcmToken => $composableBuilder(
    column: $table.fcmToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredChannel => $composableBuilder(
    column: $table.preferredChannel,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GuardiansTableAnnotationComposer
    extends Composer<_$AppDatabase, $GuardiansTable> {
  $$GuardiansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get relation =>
      $composableBuilder(column: $table.relation, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get altPhone =>
      $composableBuilder(column: $table.altPhone, builder: (column) => column);

  GeneratedColumn<String> get occupation => $composableBuilder(
    column: $table.occupation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nationalId => $composableBuilder(
    column: $table.nationalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get appLoginCode => $composableBuilder(
    column: $table.appLoginCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fcmToken =>
      $composableBuilder(column: $table.fcmToken, builder: (column) => column);

  GeneratedColumn<String> get preferredChannel => $composableBuilder(
    column: $table.preferredChannel,
    builder: (column) => column,
  );

  Expression<T> studentGuardiansRefs<T extends Object>(
    Expression<T> Function($$StudentGuardiansTableAnnotationComposer a) f,
  ) {
    final $$StudentGuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.studentGuardians,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentGuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.studentGuardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> devicesRefs<T extends Object>(
    Expression<T> Function($$DevicesTableAnnotationComposer a) f,
  ) {
    final $$DevicesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.devices,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableAnnotationComposer(
            $db: $db,
            $table: $db.devices,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> pairingCodesRefs<T extends Object>(
    Expression<T> Function($$PairingCodesTableAnnotationComposer a) f,
  ) {
    final $$PairingCodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.pairingCodes,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PairingCodesTableAnnotationComposer(
            $db: $db,
            $table: $db.pairingCodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> messagesRefs<T extends Object>(
    Expression<T> Function($$MessagesTableAnnotationComposer a) f,
  ) {
    final $$MessagesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.messages,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MessagesTableAnnotationComposer(
            $db: $db,
            $table: $db.messages,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> appNotificationsRefs<T extends Object>(
    Expression<T> Function($$AppNotificationsTableAnnotationComposer a) f,
  ) {
    final $$AppNotificationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.appNotifications,
      getReferencedColumn: (t) => t.guardianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AppNotificationsTableAnnotationComposer(
            $db: $db,
            $table: $db.appNotifications,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GuardiansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GuardiansTable,
          Guardian,
          $$GuardiansTableFilterComposer,
          $$GuardiansTableOrderingComposer,
          $$GuardiansTableAnnotationComposer,
          $$GuardiansTableCreateCompanionBuilder,
          $$GuardiansTableUpdateCompanionBuilder,
          (Guardian, $$GuardiansTableReferences),
          Guardian,
          PrefetchHooks Function({
            bool studentGuardiansRefs,
            bool devicesRefs,
            bool pairingCodesRefs,
            bool messagesRefs,
            bool appNotificationsRefs,
          })
        > {
  $$GuardiansTableTableManager(_$AppDatabase db, $GuardiansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GuardiansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GuardiansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GuardiansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> relation = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> altPhone = const Value.absent(),
                Value<String?> occupation = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> appLoginCode = const Value.absent(),
                Value<String?> fcmToken = const Value.absent(),
                Value<String> preferredChannel = const Value.absent(),
              }) => GuardiansCompanion(
                id: id,
                fullName: fullName,
                relation: relation,
                phone: phone,
                altPhone: altPhone,
                occupation: occupation,
                nationalId: nationalId,
                address: address,
                appLoginCode: appLoginCode,
                fcmToken: fcmToken,
                preferredChannel: preferredChannel,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String fullName,
                required String relation,
                Value<String?> phone = const Value.absent(),
                Value<String?> altPhone = const Value.absent(),
                Value<String?> occupation = const Value.absent(),
                Value<String?> nationalId = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> appLoginCode = const Value.absent(),
                Value<String?> fcmToken = const Value.absent(),
                Value<String> preferredChannel = const Value.absent(),
              }) => GuardiansCompanion.insert(
                id: id,
                fullName: fullName,
                relation: relation,
                phone: phone,
                altPhone: altPhone,
                occupation: occupation,
                nationalId: nationalId,
                address: address,
                appLoginCode: appLoginCode,
                fcmToken: fcmToken,
                preferredChannel: preferredChannel,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$GuardiansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                studentGuardiansRefs = false,
                devicesRefs = false,
                pairingCodesRefs = false,
                messagesRefs = false,
                appNotificationsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (studentGuardiansRefs) db.studentGuardians,
                    if (devicesRefs) db.devices,
                    if (pairingCodesRefs) db.pairingCodes,
                    if (messagesRefs) db.messages,
                    if (appNotificationsRefs) db.appNotifications,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (studentGuardiansRefs)
                        await $_getPrefetchedData<
                          Guardian,
                          $GuardiansTable,
                          StudentGuardian
                        >(
                          currentTable: table,
                          referencedTable: $$GuardiansTableReferences
                              ._studentGuardiansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GuardiansTableReferences(
                                db,
                                table,
                                p0,
                              ).studentGuardiansRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.guardianId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (devicesRefs)
                        await $_getPrefetchedData<
                          Guardian,
                          $GuardiansTable,
                          Device
                        >(
                          currentTable: table,
                          referencedTable: $$GuardiansTableReferences
                              ._devicesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GuardiansTableReferences(
                                db,
                                table,
                                p0,
                              ).devicesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.guardianId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (pairingCodesRefs)
                        await $_getPrefetchedData<
                          Guardian,
                          $GuardiansTable,
                          PairingCode
                        >(
                          currentTable: table,
                          referencedTable: $$GuardiansTableReferences
                              ._pairingCodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GuardiansTableReferences(
                                db,
                                table,
                                p0,
                              ).pairingCodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.guardianId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (messagesRefs)
                        await $_getPrefetchedData<
                          Guardian,
                          $GuardiansTable,
                          Message
                        >(
                          currentTable: table,
                          referencedTable: $$GuardiansTableReferences
                              ._messagesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GuardiansTableReferences(
                                db,
                                table,
                                p0,
                              ).messagesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.guardianId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (appNotificationsRefs)
                        await $_getPrefetchedData<
                          Guardian,
                          $GuardiansTable,
                          AppNotification
                        >(
                          currentTable: table,
                          referencedTable: $$GuardiansTableReferences
                              ._appNotificationsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GuardiansTableReferences(
                                db,
                                table,
                                p0,
                              ).appNotificationsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.guardianId == item.id,
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

typedef $$GuardiansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GuardiansTable,
      Guardian,
      $$GuardiansTableFilterComposer,
      $$GuardiansTableOrderingComposer,
      $$GuardiansTableAnnotationComposer,
      $$GuardiansTableCreateCompanionBuilder,
      $$GuardiansTableUpdateCompanionBuilder,
      (Guardian, $$GuardiansTableReferences),
      Guardian,
      PrefetchHooks Function({
        bool studentGuardiansRefs,
        bool devicesRefs,
        bool pairingCodesRefs,
        bool messagesRefs,
        bool appNotificationsRefs,
      })
    >;
typedef $$StudentGuardiansTableCreateCompanionBuilder =
    StudentGuardiansCompanion Function({
      required int studentId,
      required int guardianId,
      Value<bool> isPrimary,
      Value<int> rowid,
    });
typedef $$StudentGuardiansTableUpdateCompanionBuilder =
    StudentGuardiansCompanion Function({
      Value<int> studentId,
      Value<int> guardianId,
      Value<bool> isPrimary,
      Value<int> rowid,
    });

final class $$StudentGuardiansTableReferences
    extends
        BaseReferences<_$AppDatabase, $StudentGuardiansTable, StudentGuardian> {
  $$StudentGuardiansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
        $_aliasNameGenerator(db.studentGuardians.studentId, db.students.id),
      );

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GuardiansTable _guardianIdTable(_$AppDatabase db) =>
      db.guardians.createAlias(
        $_aliasNameGenerator(db.studentGuardians.guardianId, db.guardians.id),
      );

  $$GuardiansTableProcessedTableManager get guardianId {
    final $_column = $_itemColumn<int>('guardian_id')!;

    final manager = $$GuardiansTableTableManager(
      $_db,
      $_db.guardians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_guardianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StudentGuardiansTableFilterComposer
    extends Composer<_$AppDatabase, $StudentGuardiansTable> {
  $$StudentGuardiansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GuardiansTableFilterComposer get guardianId {
    final $$GuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableFilterComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentGuardiansTableOrderingComposer
    extends Composer<_$AppDatabase, $StudentGuardiansTable> {
  $$StudentGuardiansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get isPrimary => $composableBuilder(
    column: $table.isPrimary,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GuardiansTableOrderingComposer get guardianId {
    final $$GuardiansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableOrderingComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentGuardiansTableAnnotationComposer
    extends Composer<_$AppDatabase, $StudentGuardiansTable> {
  $$StudentGuardiansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get isPrimary =>
      $composableBuilder(column: $table.isPrimary, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GuardiansTableAnnotationComposer get guardianId {
    final $$GuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StudentGuardiansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StudentGuardiansTable,
          StudentGuardian,
          $$StudentGuardiansTableFilterComposer,
          $$StudentGuardiansTableOrderingComposer,
          $$StudentGuardiansTableAnnotationComposer,
          $$StudentGuardiansTableCreateCompanionBuilder,
          $$StudentGuardiansTableUpdateCompanionBuilder,
          (StudentGuardian, $$StudentGuardiansTableReferences),
          StudentGuardian,
          PrefetchHooks Function({bool studentId, bool guardianId})
        > {
  $$StudentGuardiansTableTableManager(
    _$AppDatabase db,
    $StudentGuardiansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentGuardiansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentGuardiansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentGuardiansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> studentId = const Value.absent(),
                Value<int> guardianId = const Value.absent(),
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentGuardiansCompanion(
                studentId: studentId,
                guardianId: guardianId,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int studentId,
                required int guardianId,
                Value<bool> isPrimary = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentGuardiansCompanion.insert(
                studentId: studentId,
                guardianId: guardianId,
                isPrimary: isPrimary,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StudentGuardiansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, guardianId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable:
                                    $$StudentGuardiansTableReferences
                                        ._studentIdTable(db),
                                referencedColumn:
                                    $$StudentGuardiansTableReferences
                                        ._studentIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (guardianId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.guardianId,
                                referencedTable:
                                    $$StudentGuardiansTableReferences
                                        ._guardianIdTable(db),
                                referencedColumn:
                                    $$StudentGuardiansTableReferences
                                        ._guardianIdTable(db)
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

typedef $$StudentGuardiansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StudentGuardiansTable,
      StudentGuardian,
      $$StudentGuardiansTableFilterComposer,
      $$StudentGuardiansTableOrderingComposer,
      $$StudentGuardiansTableAnnotationComposer,
      $$StudentGuardiansTableCreateCompanionBuilder,
      $$StudentGuardiansTableUpdateCompanionBuilder,
      (StudentGuardian, $$StudentGuardiansTableReferences),
      StudentGuardian,
      PrefetchHooks Function({bool studentId, bool guardianId})
    >;
typedef $$TeachersTableCreateCompanionBuilder =
    TeachersCompanion Function({
      Value<int> id,
      required String employeeNo,
      required String fullName,
      Value<String?> fatherName,
      required String gender,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> photoPath,
      Value<String?> qualification,
      Value<String?> specialization,
      Value<DateTime?> hiredOn,
      Value<String> status,
      Value<int?> monthlySalary,
      Value<String?> qrSecret,
      Value<DateTime?> deletedAt,
    });
typedef $$TeachersTableUpdateCompanionBuilder =
    TeachersCompanion Function({
      Value<int> id,
      Value<String> employeeNo,
      Value<String> fullName,
      Value<String?> fatherName,
      Value<String> gender,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> address,
      Value<String?> photoPath,
      Value<String?> qualification,
      Value<String?> specialization,
      Value<DateTime?> hiredOn,
      Value<String> status,
      Value<int?> monthlySalary,
      Value<String?> qrSecret,
      Value<DateTime?> deletedAt,
    });

final class $$TeachersTableReferences
    extends BaseReferences<_$AppDatabase, $TeachersTable, Teacher> {
  $$TeachersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimetableEntriesTable, List<TimetableEntry>>
  _timetableEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetableEntries,
    aliasName: $_aliasNameGenerator(
      db.teachers.id,
      db.timetableEntries.teacherId,
    ),
  );

  $$TimetableEntriesTableProcessedTableManager get timetableEntriesRefs {
    final manager = $$TimetableEntriesTableTableManager(
      $_db,
      $_db.timetableEntries,
    ).filter((f) => f.teacherId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timetableEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TeachersTableFilterComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableFilterComposer({
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

  ColumnFilters<String> get employeeNo => $composableBuilder(
    column: $table.employeeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hiredOn => $composableBuilder(
    column: $table.hiredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlySalary => $composableBuilder(
    column: $table.monthlySalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get qrSecret => $composableBuilder(
    column: $table.qrSecret,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timetableEntriesRefs(
    Expression<bool> Function($$TimetableEntriesTableFilterComposer f) f,
  ) {
    final $$TimetableEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.teacherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeachersTableOrderingComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableOrderingComposer({
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

  ColumnOrderings<String> get employeeNo => $composableBuilder(
    column: $table.employeeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoPath => $composableBuilder(
    column: $table.photoPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hiredOn => $composableBuilder(
    column: $table.hiredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlySalary => $composableBuilder(
    column: $table.monthlySalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get qrSecret => $composableBuilder(
    column: $table.qrSecret,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeachersTableAnnotationComposer
    extends Composer<_$AppDatabase, $TeachersTable> {
  $$TeachersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeNo => $composableBuilder(
    column: $table.employeeNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get fatherName => $composableBuilder(
    column: $table.fatherName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get photoPath =>
      $composableBuilder(column: $table.photoPath, builder: (column) => column);

  GeneratedColumn<String> get qualification => $composableBuilder(
    column: $table.qualification,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialization => $composableBuilder(
    column: $table.specialization,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get hiredOn =>
      $composableBuilder(column: $table.hiredOn, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get monthlySalary => $composableBuilder(
    column: $table.monthlySalary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get qrSecret =>
      $composableBuilder(column: $table.qrSecret, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  Expression<T> timetableEntriesRefs<T extends Object>(
    Expression<T> Function($$TimetableEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimetableEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.teacherId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TeachersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TeachersTable,
          Teacher,
          $$TeachersTableFilterComposer,
          $$TeachersTableOrderingComposer,
          $$TeachersTableAnnotationComposer,
          $$TeachersTableCreateCompanionBuilder,
          $$TeachersTableUpdateCompanionBuilder,
          (Teacher, $$TeachersTableReferences),
          Teacher,
          PrefetchHooks Function({bool timetableEntriesRefs})
        > {
  $$TeachersTableTableManager(_$AppDatabase db, $TeachersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeachersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeachersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeachersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> employeeNo = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String?> fatherName = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> qualification = const Value.absent(),
                Value<String?> specialization = const Value.absent(),
                Value<DateTime?> hiredOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> monthlySalary = const Value.absent(),
                Value<String?> qrSecret = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TeachersCompanion(
                id: id,
                employeeNo: employeeNo,
                fullName: fullName,
                fatherName: fatherName,
                gender: gender,
                phone: phone,
                email: email,
                address: address,
                photoPath: photoPath,
                qualification: qualification,
                specialization: specialization,
                hiredOn: hiredOn,
                status: status,
                monthlySalary: monthlySalary,
                qrSecret: qrSecret,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String employeeNo,
                required String fullName,
                Value<String?> fatherName = const Value.absent(),
                required String gender,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> photoPath = const Value.absent(),
                Value<String?> qualification = const Value.absent(),
                Value<String?> specialization = const Value.absent(),
                Value<DateTime?> hiredOn = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> monthlySalary = const Value.absent(),
                Value<String?> qrSecret = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => TeachersCompanion.insert(
                id: id,
                employeeNo: employeeNo,
                fullName: fullName,
                fatherName: fatherName,
                gender: gender,
                phone: phone,
                email: email,
                address: address,
                photoPath: photoPath,
                qualification: qualification,
                specialization: specialization,
                hiredOn: hiredOn,
                status: status,
                monthlySalary: monthlySalary,
                qrSecret: qrSecret,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TeachersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timetableEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timetableEntriesRefs) db.timetableEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timetableEntriesRefs)
                    await $_getPrefetchedData<
                      Teacher,
                      $TeachersTable,
                      TimetableEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TeachersTableReferences
                          ._timetableEntriesRefsTable(db),
                      managerFromTypedResult: (p0) => $$TeachersTableReferences(
                        db,
                        table,
                        p0,
                      ).timetableEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.teacherId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TeachersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TeachersTable,
      Teacher,
      $$TeachersTableFilterComposer,
      $$TeachersTableOrderingComposer,
      $$TeachersTableAnnotationComposer,
      $$TeachersTableCreateCompanionBuilder,
      $$TeachersTableUpdateCompanionBuilder,
      (Teacher, $$TeachersTableReferences),
      Teacher,
      PrefetchHooks Function({bool timetableEntriesRefs})
    >;
typedef $$StaffMembersTableCreateCompanionBuilder =
    StaffMembersCompanion Function({
      Value<int> id,
      required String employeeNo,
      required String fullName,
      required String jobTitle,
      Value<String?> department,
      Value<String?> phone,
      required String gender,
      Value<DateTime?> hiredOn,
      Value<int?> monthlySalary,
      Value<String> status,
      Value<DateTime?> deletedAt,
    });
typedef $$StaffMembersTableUpdateCompanionBuilder =
    StaffMembersCompanion Function({
      Value<int> id,
      Value<String> employeeNo,
      Value<String> fullName,
      Value<String> jobTitle,
      Value<String?> department,
      Value<String?> phone,
      Value<String> gender,
      Value<DateTime?> hiredOn,
      Value<int?> monthlySalary,
      Value<String> status,
      Value<DateTime?> deletedAt,
    });

class $$StaffMembersTableFilterComposer
    extends Composer<_$AppDatabase, $StaffMembersTable> {
  $$StaffMembersTableFilterComposer({
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

  ColumnFilters<String> get employeeNo => $composableBuilder(
    column: $table.employeeNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get hiredOn => $composableBuilder(
    column: $table.hiredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get monthlySalary => $composableBuilder(
    column: $table.monthlySalary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StaffMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $StaffMembersTable> {
  $$StaffMembersTableOrderingComposer({
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

  ColumnOrderings<String> get employeeNo => $composableBuilder(
    column: $table.employeeNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get jobTitle => $composableBuilder(
    column: $table.jobTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gender => $composableBuilder(
    column: $table.gender,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get hiredOn => $composableBuilder(
    column: $table.hiredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get monthlySalary => $composableBuilder(
    column: $table.monthlySalary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StaffMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $StaffMembersTable> {
  $$StaffMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get employeeNo => $composableBuilder(
    column: $table.employeeNo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get jobTitle =>
      $composableBuilder(column: $table.jobTitle, builder: (column) => column);

  GeneratedColumn<String> get department => $composableBuilder(
    column: $table.department,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get gender =>
      $composableBuilder(column: $table.gender, builder: (column) => column);

  GeneratedColumn<DateTime> get hiredOn =>
      $composableBuilder(column: $table.hiredOn, builder: (column) => column);

  GeneratedColumn<int> get monthlySalary => $composableBuilder(
    column: $table.monthlySalary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$StaffMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StaffMembersTable,
          StaffMember,
          $$StaffMembersTableFilterComposer,
          $$StaffMembersTableOrderingComposer,
          $$StaffMembersTableAnnotationComposer,
          $$StaffMembersTableCreateCompanionBuilder,
          $$StaffMembersTableUpdateCompanionBuilder,
          (
            StaffMember,
            BaseReferences<_$AppDatabase, $StaffMembersTable, StaffMember>,
          ),
          StaffMember,
          PrefetchHooks Function()
        > {
  $$StaffMembersTableTableManager(_$AppDatabase db, $StaffMembersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StaffMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StaffMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StaffMembersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> employeeNo = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> jobTitle = const Value.absent(),
                Value<String?> department = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String> gender = const Value.absent(),
                Value<DateTime?> hiredOn = const Value.absent(),
                Value<int?> monthlySalary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => StaffMembersCompanion(
                id: id,
                employeeNo: employeeNo,
                fullName: fullName,
                jobTitle: jobTitle,
                department: department,
                phone: phone,
                gender: gender,
                hiredOn: hiredOn,
                monthlySalary: monthlySalary,
                status: status,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String employeeNo,
                required String fullName,
                required String jobTitle,
                Value<String?> department = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                required String gender,
                Value<DateTime?> hiredOn = const Value.absent(),
                Value<int?> monthlySalary = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => StaffMembersCompanion.insert(
                id: id,
                employeeNo: employeeNo,
                fullName: fullName,
                jobTitle: jobTitle,
                department: department,
                phone: phone,
                gender: gender,
                hiredOn: hiredOn,
                monthlySalary: monthlySalary,
                status: status,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StaffMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StaffMembersTable,
      StaffMember,
      $$StaffMembersTableFilterComposer,
      $$StaffMembersTableOrderingComposer,
      $$StaffMembersTableAnnotationComposer,
      $$StaffMembersTableCreateCompanionBuilder,
      $$StaffMembersTableUpdateCompanionBuilder,
      (
        StaffMember,
        BaseReferences<_$AppDatabase, $StaffMembersTable, StaffMember>,
      ),
      StaffMember,
      PrefetchHooks Function()
    >;
typedef $$EnrollmentsTableCreateCompanionBuilder =
    EnrollmentsCompanion Function({
      Value<int> id,
      required int studentId,
      required int sectionId,
      required int academicYearId,
      Value<int?> rollNo,
      Value<DateTime> enrolledOn,
      Value<DateTime?> leftOn,
      Value<bool> isActive,
    });
typedef $$EnrollmentsTableUpdateCompanionBuilder =
    EnrollmentsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int> sectionId,
      Value<int> academicYearId,
      Value<int?> rollNo,
      Value<DateTime> enrolledOn,
      Value<DateTime?> leftOn,
      Value<bool> isActive,
    });

final class $$EnrollmentsTableReferences
    extends BaseReferences<_$AppDatabase, $EnrollmentsTable, Enrollment> {
  $$EnrollmentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
        $_aliasNameGenerator(db.enrollments.studentId, db.students.id),
      );

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias(
        $_aliasNameGenerator(db.enrollments.sectionId, db.sections.id),
      );

  $$SectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<int>('section_id')!;

    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $AcademicYearsTable _academicYearIdTable(_$AppDatabase db) =>
      db.academicYears.createAlias(
        $_aliasNameGenerator(
          db.enrollments.academicYearId,
          db.academicYears.id,
        ),
      );

  $$AcademicYearsTableProcessedTableManager get academicYearId {
    final $_column = $_itemColumn<int>('academic_year_id')!;

    final manager = $$AcademicYearsTableTableManager(
      $_db,
      $_db.academicYears,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_academicYearIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EnrollmentsTableFilterComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableFilterComposer({
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

  ColumnFilters<int> get rollNo => $composableBuilder(
    column: $table.rollNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enrolledOn => $composableBuilder(
    column: $table.enrolledOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get leftOn => $composableBuilder(
    column: $table.leftOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AcademicYearsTableFilterComposer get academicYearId {
    final $$AcademicYearsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableFilterComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnrollmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableOrderingComposer({
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

  ColumnOrderings<int> get rollNo => $composableBuilder(
    column: $table.rollNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enrolledOn => $composableBuilder(
    column: $table.enrolledOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get leftOn => $composableBuilder(
    column: $table.leftOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AcademicYearsTableOrderingComposer get academicYearId {
    final $$AcademicYearsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableOrderingComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnrollmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EnrollmentsTable> {
  $$EnrollmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get rollNo =>
      $composableBuilder(column: $table.rollNo, builder: (column) => column);

  GeneratedColumn<DateTime> get enrolledOn => $composableBuilder(
    column: $table.enrolledOn,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get leftOn =>
      $composableBuilder(column: $table.leftOn, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$AcademicYearsTableAnnotationComposer get academicYearId {
    final $$AcademicYearsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableAnnotationComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EnrollmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EnrollmentsTable,
          Enrollment,
          $$EnrollmentsTableFilterComposer,
          $$EnrollmentsTableOrderingComposer,
          $$EnrollmentsTableAnnotationComposer,
          $$EnrollmentsTableCreateCompanionBuilder,
          $$EnrollmentsTableUpdateCompanionBuilder,
          (Enrollment, $$EnrollmentsTableReferences),
          Enrollment,
          PrefetchHooks Function({
            bool studentId,
            bool sectionId,
            bool academicYearId,
          })
        > {
  $$EnrollmentsTableTableManager(_$AppDatabase db, $EnrollmentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EnrollmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EnrollmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EnrollmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<int> academicYearId = const Value.absent(),
                Value<int?> rollNo = const Value.absent(),
                Value<DateTime> enrolledOn = const Value.absent(),
                Value<DateTime?> leftOn = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => EnrollmentsCompanion(
                id: id,
                studentId: studentId,
                sectionId: sectionId,
                academicYearId: academicYearId,
                rollNo: rollNo,
                enrolledOn: enrolledOn,
                leftOn: leftOn,
                isActive: isActive,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required int sectionId,
                required int academicYearId,
                Value<int?> rollNo = const Value.absent(),
                Value<DateTime> enrolledOn = const Value.absent(),
                Value<DateTime?> leftOn = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
              }) => EnrollmentsCompanion.insert(
                id: id,
                studentId: studentId,
                sectionId: sectionId,
                academicYearId: academicYearId,
                rollNo: rollNo,
                enrolledOn: enrolledOn,
                leftOn: leftOn,
                isActive: isActive,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EnrollmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({studentId = false, sectionId = false, academicYearId = false}) {
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
                        if (studentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.studentId,
                                    referencedTable:
                                        $$EnrollmentsTableReferences
                                            ._studentIdTable(db),
                                    referencedColumn:
                                        $$EnrollmentsTableReferences
                                            ._studentIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (sectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sectionId,
                                    referencedTable:
                                        $$EnrollmentsTableReferences
                                            ._sectionIdTable(db),
                                    referencedColumn:
                                        $$EnrollmentsTableReferences
                                            ._sectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (academicYearId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.academicYearId,
                                    referencedTable:
                                        $$EnrollmentsTableReferences
                                            ._academicYearIdTable(db),
                                    referencedColumn:
                                        $$EnrollmentsTableReferences
                                            ._academicYearIdTable(db)
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

typedef $$EnrollmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EnrollmentsTable,
      Enrollment,
      $$EnrollmentsTableFilterComposer,
      $$EnrollmentsTableOrderingComposer,
      $$EnrollmentsTableAnnotationComposer,
      $$EnrollmentsTableCreateCompanionBuilder,
      $$EnrollmentsTableUpdateCompanionBuilder,
      (Enrollment, $$EnrollmentsTableReferences),
      Enrollment,
      PrefetchHooks Function({
        bool studentId,
        bool sectionId,
        bool academicYearId,
      })
    >;
typedef $$AttendancesTableCreateCompanionBuilder =
    AttendancesCompanion Function({
      Value<int> id,
      required int studentId,
      Value<int?> sectionId,
      required DateTime date,
      required String status,
      Value<DateTime?> checkInAt,
      Value<DateTime?> checkOutAt,
      Value<String> method,
      Value<int?> leaveRequestId,
      Value<String?> note,
      Value<int?> recordedByUserId,
      Value<DateTime> recordedAt,
      Value<bool> parentNotified,
      Value<DateTime?> parentNotifiedAt,
    });
typedef $$AttendancesTableUpdateCompanionBuilder =
    AttendancesCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<int?> sectionId,
      Value<DateTime> date,
      Value<String> status,
      Value<DateTime?> checkInAt,
      Value<DateTime?> checkOutAt,
      Value<String> method,
      Value<int?> leaveRequestId,
      Value<String?> note,
      Value<int?> recordedByUserId,
      Value<DateTime> recordedAt,
      Value<bool> parentNotified,
      Value<DateTime?> parentNotifiedAt,
    });

final class $$AttendancesTableReferences
    extends BaseReferences<_$AppDatabase, $AttendancesTable, Attendance> {
  $$AttendancesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
        $_aliasNameGenerator(db.attendances.studentId, db.students.id),
      );

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias(
        $_aliasNameGenerator(db.attendances.sectionId, db.sections.id),
      );

  $$SectionsTableProcessedTableManager? get sectionId {
    final $_column = $_itemColumn<int>('section_id');
    if ($_column == null) return null;
    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AttendancesTableFilterComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableFilterComposer({
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

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkInAt => $composableBuilder(
    column: $table.checkInAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get checkOutAt => $composableBuilder(
    column: $table.checkOutAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get leaveRequestId => $composableBuilder(
    column: $table.leaveRequestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get recordedByUserId => $composableBuilder(
    column: $table.recordedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get parentNotified => $composableBuilder(
    column: $table.parentNotified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get parentNotifiedAt => $composableBuilder(
    column: $table.parentNotifiedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendancesTableOrderingComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableOrderingComposer({
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

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkInAt => $composableBuilder(
    column: $table.checkInAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get checkOutAt => $composableBuilder(
    column: $table.checkOutAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get method => $composableBuilder(
    column: $table.method,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get leaveRequestId => $composableBuilder(
    column: $table.leaveRequestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get recordedByUserId => $composableBuilder(
    column: $table.recordedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get parentNotified => $composableBuilder(
    column: $table.parentNotified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get parentNotifiedAt => $composableBuilder(
    column: $table.parentNotifiedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendancesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AttendancesTable> {
  $$AttendancesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get checkInAt =>
      $composableBuilder(column: $table.checkInAt, builder: (column) => column);

  GeneratedColumn<DateTime> get checkOutAt => $composableBuilder(
    column: $table.checkOutAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get method =>
      $composableBuilder(column: $table.method, builder: (column) => column);

  GeneratedColumn<int> get leaveRequestId => $composableBuilder(
    column: $table.leaveRequestId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get recordedByUserId => $composableBuilder(
    column: $table.recordedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get recordedAt => $composableBuilder(
    column: $table.recordedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get parentNotified => $composableBuilder(
    column: $table.parentNotified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get parentNotifiedAt => $composableBuilder(
    column: $table.parentNotifiedAt,
    builder: (column) => column,
  );

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AttendancesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AttendancesTable,
          Attendance,
          $$AttendancesTableFilterComposer,
          $$AttendancesTableOrderingComposer,
          $$AttendancesTableAnnotationComposer,
          $$AttendancesTableCreateCompanionBuilder,
          $$AttendancesTableUpdateCompanionBuilder,
          (Attendance, $$AttendancesTableReferences),
          Attendance,
          PrefetchHooks Function({bool studentId, bool sectionId})
        > {
  $$AttendancesTableTableManager(_$AppDatabase db, $AttendancesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttendancesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttendancesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttendancesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<int?> sectionId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime?> checkInAt = const Value.absent(),
                Value<DateTime?> checkOutAt = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int?> leaveRequestId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> recordedByUserId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<bool> parentNotified = const Value.absent(),
                Value<DateTime?> parentNotifiedAt = const Value.absent(),
              }) => AttendancesCompanion(
                id: id,
                studentId: studentId,
                sectionId: sectionId,
                date: date,
                status: status,
                checkInAt: checkInAt,
                checkOutAt: checkOutAt,
                method: method,
                leaveRequestId: leaveRequestId,
                note: note,
                recordedByUserId: recordedByUserId,
                recordedAt: recordedAt,
                parentNotified: parentNotified,
                parentNotifiedAt: parentNotifiedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                Value<int?> sectionId = const Value.absent(),
                required DateTime date,
                required String status,
                Value<DateTime?> checkInAt = const Value.absent(),
                Value<DateTime?> checkOutAt = const Value.absent(),
                Value<String> method = const Value.absent(),
                Value<int?> leaveRequestId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int?> recordedByUserId = const Value.absent(),
                Value<DateTime> recordedAt = const Value.absent(),
                Value<bool> parentNotified = const Value.absent(),
                Value<DateTime?> parentNotifiedAt = const Value.absent(),
              }) => AttendancesCompanion.insert(
                id: id,
                studentId: studentId,
                sectionId: sectionId,
                date: date,
                status: status,
                checkInAt: checkInAt,
                checkOutAt: checkOutAt,
                method: method,
                leaveRequestId: leaveRequestId,
                note: note,
                recordedByUserId: recordedByUserId,
                recordedAt: recordedAt,
                parentNotified: parentNotified,
                parentNotifiedAt: parentNotifiedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AttendancesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, sectionId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$AttendancesTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$AttendancesTableReferences
                                    ._studentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (sectionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sectionId,
                                referencedTable: $$AttendancesTableReferences
                                    ._sectionIdTable(db),
                                referencedColumn: $$AttendancesTableReferences
                                    ._sectionIdTable(db)
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

typedef $$AttendancesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AttendancesTable,
      Attendance,
      $$AttendancesTableFilterComposer,
      $$AttendancesTableOrderingComposer,
      $$AttendancesTableAnnotationComposer,
      $$AttendancesTableCreateCompanionBuilder,
      $$AttendancesTableUpdateCompanionBuilder,
      (Attendance, $$AttendancesTableReferences),
      Attendance,
      PrefetchHooks Function({bool studentId, bool sectionId})
    >;
typedef $$LeaveRequestsTableCreateCompanionBuilder =
    LeaveRequestsCompanion Function({
      Value<int> id,
      required int studentId,
      required String reasonType,
      Value<String?> reasonText,
      required DateTime fromDate,
      required DateTime toDate,
      Value<String?> fromTime,
      Value<String?> toTime,
      Value<String> status,
      Value<String> requestedVia,
      Value<int?> requestedByUserId,
      Value<int?> decidedByUserId,
      Value<DateTime?> decidedAt,
      Value<String?> decisionNote,
      Value<String?> attachmentPath,
      Value<DateTime> createdAt,
    });
typedef $$LeaveRequestsTableUpdateCompanionBuilder =
    LeaveRequestsCompanion Function({
      Value<int> id,
      Value<int> studentId,
      Value<String> reasonType,
      Value<String?> reasonText,
      Value<DateTime> fromDate,
      Value<DateTime> toDate,
      Value<String?> fromTime,
      Value<String?> toTime,
      Value<String> status,
      Value<String> requestedVia,
      Value<int?> requestedByUserId,
      Value<int?> decidedByUserId,
      Value<DateTime?> decidedAt,
      Value<String?> decisionNote,
      Value<String?> attachmentPath,
      Value<DateTime> createdAt,
    });

final class $$LeaveRequestsTableReferences
    extends BaseReferences<_$AppDatabase, $LeaveRequestsTable, LeaveRequest> {
  $$LeaveRequestsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $StudentsTable _studentIdTable(_$AppDatabase db) =>
      db.students.createAlias(
        $_aliasNameGenerator(db.leaveRequests.studentId, db.students.id),
      );

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LeaveRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableFilterComposer({
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

  ColumnFilters<String> get reasonType => $composableBuilder(
    column: $table.reasonType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasonText => $composableBuilder(
    column: $table.reasonText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fromTime => $composableBuilder(
    column: $table.fromTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toTime => $composableBuilder(
    column: $table.toTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get requestedVia => $composableBuilder(
    column: $table.requestedVia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decidedByUserId => $composableBuilder(
    column: $table.decidedByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decisionNote => $composableBuilder(
    column: $table.decisionNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LeaveRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableOrderingComposer({
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

  ColumnOrderings<String> get reasonType => $composableBuilder(
    column: $table.reasonType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasonText => $composableBuilder(
    column: $table.reasonText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fromDate => $composableBuilder(
    column: $table.fromDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get toDate => $composableBuilder(
    column: $table.toDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fromTime => $composableBuilder(
    column: $table.fromTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toTime => $composableBuilder(
    column: $table.toTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get requestedVia => $composableBuilder(
    column: $table.requestedVia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decidedByUserId => $composableBuilder(
    column: $table.decidedByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decisionNote => $composableBuilder(
    column: $table.decisionNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LeaveRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LeaveRequestsTable> {
  $$LeaveRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get reasonType => $composableBuilder(
    column: $table.reasonType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reasonText => $composableBuilder(
    column: $table.reasonText,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fromDate =>
      $composableBuilder(column: $table.fromDate, builder: (column) => column);

  GeneratedColumn<DateTime> get toDate =>
      $composableBuilder(column: $table.toDate, builder: (column) => column);

  GeneratedColumn<String> get fromTime =>
      $composableBuilder(column: $table.fromTime, builder: (column) => column);

  GeneratedColumn<String> get toTime =>
      $composableBuilder(column: $table.toTime, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get requestedVia => $composableBuilder(
    column: $table.requestedVia,
    builder: (column) => column,
  );

  GeneratedColumn<int> get requestedByUserId => $composableBuilder(
    column: $table.requestedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get decidedByUserId => $composableBuilder(
    column: $table.decidedByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);

  GeneratedColumn<String> get decisionNote => $composableBuilder(
    column: $table.decisionNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attachmentPath => $composableBuilder(
    column: $table.attachmentPath,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LeaveRequestsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LeaveRequestsTable,
          LeaveRequest,
          $$LeaveRequestsTableFilterComposer,
          $$LeaveRequestsTableOrderingComposer,
          $$LeaveRequestsTableAnnotationComposer,
          $$LeaveRequestsTableCreateCompanionBuilder,
          $$LeaveRequestsTableUpdateCompanionBuilder,
          (LeaveRequest, $$LeaveRequestsTableReferences),
          LeaveRequest,
          PrefetchHooks Function({bool studentId})
        > {
  $$LeaveRequestsTableTableManager(_$AppDatabase db, $LeaveRequestsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LeaveRequestsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LeaveRequestsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LeaveRequestsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<String> reasonType = const Value.absent(),
                Value<String?> reasonText = const Value.absent(),
                Value<DateTime> fromDate = const Value.absent(),
                Value<DateTime> toDate = const Value.absent(),
                Value<String?> fromTime = const Value.absent(),
                Value<String?> toTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> requestedVia = const Value.absent(),
                Value<int?> requestedByUserId = const Value.absent(),
                Value<int?> decidedByUserId = const Value.absent(),
                Value<DateTime?> decidedAt = const Value.absent(),
                Value<String?> decisionNote = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LeaveRequestsCompanion(
                id: id,
                studentId: studentId,
                reasonType: reasonType,
                reasonText: reasonText,
                fromDate: fromDate,
                toDate: toDate,
                fromTime: fromTime,
                toTime: toTime,
                status: status,
                requestedVia: requestedVia,
                requestedByUserId: requestedByUserId,
                decidedByUserId: decidedByUserId,
                decidedAt: decidedAt,
                decisionNote: decisionNote,
                attachmentPath: attachmentPath,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int studentId,
                required String reasonType,
                Value<String?> reasonText = const Value.absent(),
                required DateTime fromDate,
                required DateTime toDate,
                Value<String?> fromTime = const Value.absent(),
                Value<String?> toTime = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String> requestedVia = const Value.absent(),
                Value<int?> requestedByUserId = const Value.absent(),
                Value<int?> decidedByUserId = const Value.absent(),
                Value<DateTime?> decidedAt = const Value.absent(),
                Value<String?> decisionNote = const Value.absent(),
                Value<String?> attachmentPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => LeaveRequestsCompanion.insert(
                id: id,
                studentId: studentId,
                reasonType: reasonType,
                reasonText: reasonText,
                fromDate: fromDate,
                toDate: toDate,
                fromTime: fromTime,
                toTime: toTime,
                status: status,
                requestedVia: requestedVia,
                requestedByUserId: requestedByUserId,
                decidedByUserId: decidedByUserId,
                decidedAt: decidedAt,
                decisionNote: decisionNote,
                attachmentPath: attachmentPath,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$LeaveRequestsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$LeaveRequestsTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$LeaveRequestsTableReferences
                                    ._studentIdTable(db)
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

typedef $$LeaveRequestsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LeaveRequestsTable,
      LeaveRequest,
      $$LeaveRequestsTableFilterComposer,
      $$LeaveRequestsTableOrderingComposer,
      $$LeaveRequestsTableAnnotationComposer,
      $$LeaveRequestsTableCreateCompanionBuilder,
      $$LeaveRequestsTableUpdateCompanionBuilder,
      (LeaveRequest, $$LeaveRequestsTableReferences),
      LeaveRequest,
      PrefetchHooks Function({bool studentId})
    >;
typedef $$AuditLogsTableCreateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      Value<int?> userId,
      Value<String?> userName,
      required String action,
      required String entity,
      Value<int?> entityId,
      Value<String?> changesJson,
      Value<DateTime> at,
    });
typedef $$AuditLogsTableUpdateCompanionBuilder =
    AuditLogsCompanion Function({
      Value<int> id,
      Value<int?> userId,
      Value<String?> userName,
      Value<String> action,
      Value<String> entity,
      Value<int?> entityId,
      Value<String?> changesJson,
      Value<DateTime> at,
    });

class $$AuditLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableFilterComposer({
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

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AuditLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableOrderingComposer({
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

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userName => $composableBuilder(
    column: $table.userName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get action => $composableBuilder(
    column: $table.action,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entity => $composableBuilder(
    column: $table.entity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get at => $composableBuilder(
    column: $table.at,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AuditLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AuditLogsTable> {
  $$AuditLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get userName =>
      $composableBuilder(column: $table.userName, builder: (column) => column);

  GeneratedColumn<String> get action =>
      $composableBuilder(column: $table.action, builder: (column) => column);

  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get changesJson => $composableBuilder(
    column: $table.changesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get at =>
      $composableBuilder(column: $table.at, builder: (column) => column);
}

class $$AuditLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AuditLogsTable,
          AuditLog,
          $$AuditLogsTableFilterComposer,
          $$AuditLogsTableOrderingComposer,
          $$AuditLogsTableAnnotationComposer,
          $$AuditLogsTableCreateCompanionBuilder,
          $$AuditLogsTableUpdateCompanionBuilder,
          (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
          AuditLog,
          PrefetchHooks Function()
        > {
  $$AuditLogsTableTableManager(_$AppDatabase db, $AuditLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AuditLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AuditLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AuditLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                Value<String> action = const Value.absent(),
                Value<String> entity = const Value.absent(),
                Value<int?> entityId = const Value.absent(),
                Value<String?> changesJson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => AuditLogsCompanion(
                id: id,
                userId: userId,
                userName: userName,
                action: action,
                entity: entity,
                entityId: entityId,
                changesJson: changesJson,
                at: at,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<String?> userName = const Value.absent(),
                required String action,
                required String entity,
                Value<int?> entityId = const Value.absent(),
                Value<String?> changesJson = const Value.absent(),
                Value<DateTime> at = const Value.absent(),
              }) => AuditLogsCompanion.insert(
                id: id,
                userId: userId,
                userName: userName,
                action: action,
                entity: entity,
                entityId: entityId,
                changesJson: changesJson,
                at: at,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AuditLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AuditLogsTable,
      AuditLog,
      $$AuditLogsTableFilterComposer,
      $$AuditLogsTableOrderingComposer,
      $$AuditLogsTableAnnotationComposer,
      $$AuditLogsTableCreateCompanionBuilder,
      $$AuditLogsTableUpdateCompanionBuilder,
      (AuditLog, BaseReferences<_$AppDatabase, $AuditLogsTable, AuditLog>),
      AuditLog,
      PrefetchHooks Function()
    >;
typedef $$DevicesTableCreateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> platform,
      required String role,
      Value<int?> userId,
      Value<int?> guardianId,
      required String tokenHash,
      Value<String?> pushToken,
      Value<DateTime> pairedAt,
      Value<DateTime?> lastSeenAt,
      Value<String?> lastIp,
      Value<DateTime?> revokedAt,
    });
typedef $$DevicesTableUpdateCompanionBuilder =
    DevicesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> platform,
      Value<String> role,
      Value<int?> userId,
      Value<int?> guardianId,
      Value<String> tokenHash,
      Value<String?> pushToken,
      Value<DateTime> pairedAt,
      Value<DateTime?> lastSeenAt,
      Value<String?> lastIp,
      Value<DateTime?> revokedAt,
    });

final class $$DevicesTableReferences
    extends BaseReferences<_$AppDatabase, $DevicesTable, Device> {
  $$DevicesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GuardiansTable _guardianIdTable(_$AppDatabase db) =>
      db.guardians.createAlias(
        $_aliasNameGenerator(db.devices.guardianId, db.guardians.id),
      );

  $$GuardiansTableProcessedTableManager? get guardianId {
    final $_column = $_itemColumn<int>('guardian_id');
    if ($_column == null) return null;
    final manager = $$GuardiansTableTableManager(
      $_db,
      $_db.guardians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_guardianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DevicesTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get pushToken => $composableBuilder(
    column: $table.pushToken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastIp => $composableBuilder(
    column: $table.lastIp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GuardiansTableFilterComposer get guardianId {
    final $$GuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableFilterComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevicesTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get platform => $composableBuilder(
    column: $table.platform,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenHash => $composableBuilder(
    column: $table.tokenHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pushToken => $composableBuilder(
    column: $table.pushToken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get pairedAt => $composableBuilder(
    column: $table.pairedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastIp => $composableBuilder(
    column: $table.lastIp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get revokedAt => $composableBuilder(
    column: $table.revokedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GuardiansTableOrderingComposer get guardianId {
    final $$GuardiansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableOrderingComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevicesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTable> {
  $$DevicesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get tokenHash =>
      $composableBuilder(column: $table.tokenHash, builder: (column) => column);

  GeneratedColumn<String> get pushToken =>
      $composableBuilder(column: $table.pushToken, builder: (column) => column);

  GeneratedColumn<DateTime> get pairedAt =>
      $composableBuilder(column: $table.pairedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastSeenAt => $composableBuilder(
    column: $table.lastSeenAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastIp =>
      $composableBuilder(column: $table.lastIp, builder: (column) => column);

  GeneratedColumn<DateTime> get revokedAt =>
      $composableBuilder(column: $table.revokedAt, builder: (column) => column);

  $$GuardiansTableAnnotationComposer get guardianId {
    final $$GuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DevicesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTable,
          Device,
          $$DevicesTableFilterComposer,
          $$DevicesTableOrderingComposer,
          $$DevicesTableAnnotationComposer,
          $$DevicesTableCreateCompanionBuilder,
          $$DevicesTableUpdateCompanionBuilder,
          (Device, $$DevicesTableReferences),
          Device,
          PrefetchHooks Function({bool guardianId})
        > {
  $$DevicesTableTableManager(_$AppDatabase db, $DevicesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> platform = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                Value<String> tokenHash = const Value.absent(),
                Value<String?> pushToken = const Value.absent(),
                Value<DateTime> pairedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<String?> lastIp = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
              }) => DevicesCompanion(
                id: id,
                name: name,
                platform: platform,
                role: role,
                userId: userId,
                guardianId: guardianId,
                tokenHash: tokenHash,
                pushToken: pushToken,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                lastIp: lastIp,
                revokedAt: revokedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> platform = const Value.absent(),
                required String role,
                Value<int?> userId = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                required String tokenHash,
                Value<String?> pushToken = const Value.absent(),
                Value<DateTime> pairedAt = const Value.absent(),
                Value<DateTime?> lastSeenAt = const Value.absent(),
                Value<String?> lastIp = const Value.absent(),
                Value<DateTime?> revokedAt = const Value.absent(),
              }) => DevicesCompanion.insert(
                id: id,
                name: name,
                platform: platform,
                role: role,
                userId: userId,
                guardianId: guardianId,
                tokenHash: tokenHash,
                pushToken: pushToken,
                pairedAt: pairedAt,
                lastSeenAt: lastSeenAt,
                lastIp: lastIp,
                revokedAt: revokedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DevicesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({guardianId = false}) {
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
                    if (guardianId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.guardianId,
                                referencedTable: $$DevicesTableReferences
                                    ._guardianIdTable(db),
                                referencedColumn: $$DevicesTableReferences
                                    ._guardianIdTable(db)
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

typedef $$DevicesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTable,
      Device,
      $$DevicesTableFilterComposer,
      $$DevicesTableOrderingComposer,
      $$DevicesTableAnnotationComposer,
      $$DevicesTableCreateCompanionBuilder,
      $$DevicesTableUpdateCompanionBuilder,
      (Device, $$DevicesTableReferences),
      Device,
      PrefetchHooks Function({bool guardianId})
    >;
typedef $$PairingCodesTableCreateCompanionBuilder =
    PairingCodesCompanion Function({
      Value<int> id,
      required String code,
      required String role,
      Value<int?> userId,
      Value<int?> guardianId,
      required DateTime expiresAt,
      Value<DateTime?> usedAt,
      Value<int?> usedByDeviceId,
      Value<int?> createdByUserId,
      Value<DateTime> createdAt,
    });
typedef $$PairingCodesTableUpdateCompanionBuilder =
    PairingCodesCompanion Function({
      Value<int> id,
      Value<String> code,
      Value<String> role,
      Value<int?> userId,
      Value<int?> guardianId,
      Value<DateTime> expiresAt,
      Value<DateTime?> usedAt,
      Value<int?> usedByDeviceId,
      Value<int?> createdByUserId,
      Value<DateTime> createdAt,
    });

final class $$PairingCodesTableReferences
    extends BaseReferences<_$AppDatabase, $PairingCodesTable, PairingCode> {
  $$PairingCodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GuardiansTable _guardianIdTable(_$AppDatabase db) =>
      db.guardians.createAlias(
        $_aliasNameGenerator(db.pairingCodes.guardianId, db.guardians.id),
      );

  $$GuardiansTableProcessedTableManager? get guardianId {
    final $_column = $_itemColumn<int>('guardian_id');
    if ($_column == null) return null;
    final manager = $$GuardiansTableTableManager(
      $_db,
      $_db.guardians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_guardianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PairingCodesTableFilterComposer
    extends Composer<_$AppDatabase, $PairingCodesTable> {
  $$PairingCodesTableFilterComposer({
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

  ColumnFilters<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usedByDeviceId => $composableBuilder(
    column: $table.usedByDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GuardiansTableFilterComposer get guardianId {
    final $$GuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableFilterComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairingCodesTableOrderingComposer
    extends Composer<_$AppDatabase, $PairingCodesTable> {
  $$PairingCodesTableOrderingComposer({
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

  ColumnOrderings<String> get code => $composableBuilder(
    column: $table.code,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get usedAt => $composableBuilder(
    column: $table.usedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usedByDeviceId => $composableBuilder(
    column: $table.usedByDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GuardiansTableOrderingComposer get guardianId {
    final $$GuardiansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableOrderingComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairingCodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PairingCodesTable> {
  $$PairingCodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<DateTime> get usedAt =>
      $composableBuilder(column: $table.usedAt, builder: (column) => column);

  GeneratedColumn<int> get usedByDeviceId => $composableBuilder(
    column: $table.usedByDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$GuardiansTableAnnotationComposer get guardianId {
    final $$GuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PairingCodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PairingCodesTable,
          PairingCode,
          $$PairingCodesTableFilterComposer,
          $$PairingCodesTableOrderingComposer,
          $$PairingCodesTableAnnotationComposer,
          $$PairingCodesTableCreateCompanionBuilder,
          $$PairingCodesTableUpdateCompanionBuilder,
          (PairingCode, $$PairingCodesTableReferences),
          PairingCode,
          PrefetchHooks Function({bool guardianId})
        > {
  $$PairingCodesTableTableManager(_$AppDatabase db, $PairingCodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PairingCodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PairingCodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PairingCodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> code = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<int?> userId = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<DateTime?> usedAt = const Value.absent(),
                Value<int?> usedByDeviceId = const Value.absent(),
                Value<int?> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PairingCodesCompanion(
                id: id,
                code: code,
                role: role,
                userId: userId,
                guardianId: guardianId,
                expiresAt: expiresAt,
                usedAt: usedAt,
                usedByDeviceId: usedByDeviceId,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String code,
                required String role,
                Value<int?> userId = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                required DateTime expiresAt,
                Value<DateTime?> usedAt = const Value.absent(),
                Value<int?> usedByDeviceId = const Value.absent(),
                Value<int?> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PairingCodesCompanion.insert(
                id: id,
                code: code,
                role: role,
                userId: userId,
                guardianId: guardianId,
                expiresAt: expiresAt,
                usedAt: usedAt,
                usedByDeviceId: usedByDeviceId,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PairingCodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({guardianId = false}) {
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
                    if (guardianId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.guardianId,
                                referencedTable: $$PairingCodesTableReferences
                                    ._guardianIdTable(db),
                                referencedColumn: $$PairingCodesTableReferences
                                    ._guardianIdTable(db)
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

typedef $$PairingCodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PairingCodesTable,
      PairingCode,
      $$PairingCodesTableFilterComposer,
      $$PairingCodesTableOrderingComposer,
      $$PairingCodesTableAnnotationComposer,
      $$PairingCodesTableCreateCompanionBuilder,
      $$PairingCodesTableUpdateCompanionBuilder,
      (PairingCode, $$PairingCodesTableReferences),
      PairingCode,
      PrefetchHooks Function({bool guardianId})
    >;
typedef $$MessageTemplatesTableCreateCompanionBuilder =
    MessageTemplatesCompanion Function({
      Value<int> id,
      required String templateKey,
      required String title,
      required String body,
      Value<String> channel,
      Value<bool> isActive,
      Value<bool> isBuiltIn,
    });
typedef $$MessageTemplatesTableUpdateCompanionBuilder =
    MessageTemplatesCompanion Function({
      Value<int> id,
      Value<String> templateKey,
      Value<String> title,
      Value<String> body,
      Value<String> channel,
      Value<bool> isActive,
      Value<bool> isBuiltIn,
    });

class $$MessageTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $MessageTemplatesTable> {
  $$MessageTemplatesTableFilterComposer({
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

  ColumnFilters<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessageTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessageTemplatesTable> {
  $$MessageTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBuiltIn => $composableBuilder(
    column: $table.isBuiltIn,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessageTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessageTemplatesTable> {
  $$MessageTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get templateKey => $composableBuilder(
    column: $table.templateKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isBuiltIn =>
      $composableBuilder(column: $table.isBuiltIn, builder: (column) => column);
}

class $$MessageTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessageTemplatesTable,
          MessageTemplate,
          $$MessageTemplatesTableFilterComposer,
          $$MessageTemplatesTableOrderingComposer,
          $$MessageTemplatesTableAnnotationComposer,
          $$MessageTemplatesTableCreateCompanionBuilder,
          $$MessageTemplatesTableUpdateCompanionBuilder,
          (
            MessageTemplate,
            BaseReferences<
              _$AppDatabase,
              $MessageTemplatesTable,
              MessageTemplate
            >,
          ),
          MessageTemplate,
          PrefetchHooks Function()
        > {
  $$MessageTemplatesTableTableManager(
    _$AppDatabase db,
    $MessageTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessageTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessageTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessageTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> templateKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
              }) => MessageTemplatesCompanion(
                id: id,
                templateKey: templateKey,
                title: title,
                body: body,
                channel: channel,
                isActive: isActive,
                isBuiltIn: isBuiltIn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String templateKey,
                required String title,
                required String body,
                Value<String> channel = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isBuiltIn = const Value.absent(),
              }) => MessageTemplatesCompanion.insert(
                id: id,
                templateKey: templateKey,
                title: title,
                body: body,
                channel: channel,
                isActive: isActive,
                isBuiltIn: isBuiltIn,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessageTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessageTemplatesTable,
      MessageTemplate,
      $$MessageTemplatesTableFilterComposer,
      $$MessageTemplatesTableOrderingComposer,
      $$MessageTemplatesTableAnnotationComposer,
      $$MessageTemplatesTableCreateCompanionBuilder,
      $$MessageTemplatesTableUpdateCompanionBuilder,
      (
        MessageTemplate,
        BaseReferences<_$AppDatabase, $MessageTemplatesTable, MessageTemplate>,
      ),
      MessageTemplate,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<String?> batchId,
      required String kind,
      Value<int?> studentId,
      Value<int?> guardianId,
      Value<String?> toName,
      Value<String?> toPhone,
      Value<String> channel,
      required String body,
      Value<String> status,
      Value<int> attempts,
      Value<String?> error,
      Value<DateTime?> relatedDate,
      Value<int?> createdByUserId,
      Value<DateTime> createdAt,
      Value<DateTime?> sentAt,
      Value<DateTime?> readAt,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<String?> batchId,
      Value<String> kind,
      Value<int?> studentId,
      Value<int?> guardianId,
      Value<String?> toName,
      Value<String?> toPhone,
      Value<String> channel,
      Value<String> body,
      Value<String> status,
      Value<int> attempts,
      Value<String?> error,
      Value<DateTime?> relatedDate,
      Value<int?> createdByUserId,
      Value<DateTime> createdAt,
      Value<DateTime?> sentAt,
      Value<DateTime?> readAt,
    });

final class $$MessagesTableReferences
    extends BaseReferences<_$AppDatabase, $MessagesTable, Message> {
  $$MessagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $StudentsTable _studentIdTable(_$AppDatabase db) => db.students
      .createAlias($_aliasNameGenerator(db.messages.studentId, db.students.id));

  $$StudentsTableProcessedTableManager? get studentId {
    final $_column = $_itemColumn<int>('student_id');
    if ($_column == null) return null;
    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GuardiansTable _guardianIdTable(_$AppDatabase db) =>
      db.guardians.createAlias(
        $_aliasNameGenerator(db.messages.guardianId, db.guardians.id),
      );

  $$GuardiansTableProcessedTableManager? get guardianId {
    final $_column = $_itemColumn<int>('guardian_id');
    if ($_column == null) return null;
    final manager = $$GuardiansTableTableManager(
      $_db,
      $_db.guardians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_guardianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
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

  ColumnFilters<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toName => $composableBuilder(
    column: $table.toName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toPhone => $composableBuilder(
    column: $table.toPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get relatedDate => $composableBuilder(
    column: $table.relatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GuardiansTableFilterComposer get guardianId {
    final $$GuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableFilterComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
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

  ColumnOrderings<String> get batchId => $composableBuilder(
    column: $table.batchId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toName => $composableBuilder(
    column: $table.toName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toPhone => $composableBuilder(
    column: $table.toPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get relatedDate => $composableBuilder(
    column: $table.relatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get sentAt => $composableBuilder(
    column: $table.sentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GuardiansTableOrderingComposer get guardianId {
    final $$GuardiansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableOrderingComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get batchId =>
      $composableBuilder(column: $table.batchId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get toName =>
      $composableBuilder(column: $table.toName, builder: (column) => column);

  GeneratedColumn<String> get toPhone =>
      $composableBuilder(column: $table.toPhone, builder: (column) => column);

  GeneratedColumn<String> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<DateTime> get relatedDate => $composableBuilder(
    column: $table.relatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdByUserId => $composableBuilder(
    column: $table.createdByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get sentAt =>
      $composableBuilder(column: $table.sentAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GuardiansTableAnnotationComposer get guardianId {
    final $$GuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, $$MessagesTableReferences),
          Message,
          PrefetchHooks Function({bool studentId, bool guardianId})
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> studentId = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                Value<String?> toName = const Value.absent(),
                Value<String?> toPhone = const Value.absent(),
                Value<String> channel = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime?> relatedDate = const Value.absent(),
                Value<int?> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                batchId: batchId,
                kind: kind,
                studentId: studentId,
                guardianId: guardianId,
                toName: toName,
                toPhone: toPhone,
                channel: channel,
                body: body,
                status: status,
                attempts: attempts,
                error: error,
                relatedDate: relatedDate,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                sentAt: sentAt,
                readAt: readAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> batchId = const Value.absent(),
                required String kind,
                Value<int?> studentId = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                Value<String?> toName = const Value.absent(),
                Value<String?> toPhone = const Value.absent(),
                Value<String> channel = const Value.absent(),
                required String body,
                Value<String> status = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<DateTime?> relatedDate = const Value.absent(),
                Value<int?> createdByUserId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> sentAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                batchId: batchId,
                kind: kind,
                studentId: studentId,
                guardianId: guardianId,
                toName: toName,
                toPhone: toPhone,
                channel: channel,
                body: body,
                status: status,
                attempts: attempts,
                error: error,
                relatedDate: relatedDate,
                createdByUserId: createdByUserId,
                createdAt: createdAt,
                sentAt: sentAt,
                readAt: readAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MessagesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({studentId = false, guardianId = false}) {
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
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$MessagesTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._studentIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (guardianId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.guardianId,
                                referencedTable: $$MessagesTableReferences
                                    ._guardianIdTable(db),
                                referencedColumn: $$MessagesTableReferences
                                    ._guardianIdTable(db)
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

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, $$MessagesTableReferences),
      Message,
      PrefetchHooks Function({bool studentId, bool guardianId})
    >;
typedef $$AppNotificationsTableCreateCompanionBuilder =
    AppNotificationsCompanion Function({
      Value<int> id,
      required String kind,
      required String title,
      required String body,
      Value<String?> payloadJson,
      Value<String> audience,
      Value<int?> guardianId,
      Value<String?> dedupeKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> readAt,
      Value<DateTime?> actedAt,
    });
typedef $$AppNotificationsTableUpdateCompanionBuilder =
    AppNotificationsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<String> title,
      Value<String> body,
      Value<String?> payloadJson,
      Value<String> audience,
      Value<int?> guardianId,
      Value<String?> dedupeKey,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> readAt,
      Value<DateTime?> actedAt,
    });

final class $$AppNotificationsTableReferences
    extends
        BaseReferences<_$AppDatabase, $AppNotificationsTable, AppNotification> {
  $$AppNotificationsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GuardiansTable _guardianIdTable(_$AppDatabase db) =>
      db.guardians.createAlias(
        $_aliasNameGenerator(db.appNotifications.guardianId, db.guardians.id),
      );

  $$GuardiansTableProcessedTableManager? get guardianId {
    final $_column = $_itemColumn<int>('guardian_id');
    if ($_column == null) return null;
    final manager = $$GuardiansTableTableManager(
      $_db,
      $_db.guardians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_guardianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AppNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $AppNotificationsTable> {
  $$AppNotificationsTableFilterComposer({
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

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get actedAt => $composableBuilder(
    column: $table.actedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GuardiansTableFilterComposer get guardianId {
    final $$GuardiansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableFilterComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppNotificationsTable> {
  $$AppNotificationsTableOrderingComposer({
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

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audience => $composableBuilder(
    column: $table.audience,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
    column: $table.dedupeKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get readAt => $composableBuilder(
    column: $table.readAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get actedAt => $composableBuilder(
    column: $table.actedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GuardiansTableOrderingComposer get guardianId {
    final $$GuardiansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableOrderingComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppNotificationsTable> {
  $$AppNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audience =>
      $composableBuilder(column: $table.audience, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get readAt =>
      $composableBuilder(column: $table.readAt, builder: (column) => column);

  GeneratedColumn<DateTime> get actedAt =>
      $composableBuilder(column: $table.actedAt, builder: (column) => column);

  $$GuardiansTableAnnotationComposer get guardianId {
    final $$GuardiansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.guardianId,
      referencedTable: $db.guardians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GuardiansTableAnnotationComposer(
            $db: $db,
            $table: $db.guardians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AppNotificationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppNotificationsTable,
          AppNotification,
          $$AppNotificationsTableFilterComposer,
          $$AppNotificationsTableOrderingComposer,
          $$AppNotificationsTableAnnotationComposer,
          $$AppNotificationsTableCreateCompanionBuilder,
          $$AppNotificationsTableUpdateCompanionBuilder,
          (AppNotification, $$AppNotificationsTableReferences),
          AppNotification,
          PrefetchHooks Function({bool guardianId})
        > {
  $$AppNotificationsTableTableManager(
    _$AppDatabase db,
    $AppNotificationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppNotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> payloadJson = const Value.absent(),
                Value<String> audience = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                Value<String?> dedupeKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> actedAt = const Value.absent(),
              }) => AppNotificationsCompanion(
                id: id,
                kind: kind,
                title: title,
                body: body,
                payloadJson: payloadJson,
                audience: audience,
                guardianId: guardianId,
                dedupeKey: dedupeKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                readAt: readAt,
                actedAt: actedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                required String title,
                required String body,
                Value<String?> payloadJson = const Value.absent(),
                Value<String> audience = const Value.absent(),
                Value<int?> guardianId = const Value.absent(),
                Value<String?> dedupeKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> readAt = const Value.absent(),
                Value<DateTime?> actedAt = const Value.absent(),
              }) => AppNotificationsCompanion.insert(
                id: id,
                kind: kind,
                title: title,
                body: body,
                payloadJson: payloadJson,
                audience: audience,
                guardianId: guardianId,
                dedupeKey: dedupeKey,
                createdAt: createdAt,
                updatedAt: updatedAt,
                readAt: readAt,
                actedAt: actedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AppNotificationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({guardianId = false}) {
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
                    if (guardianId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.guardianId,
                                referencedTable:
                                    $$AppNotificationsTableReferences
                                        ._guardianIdTable(db),
                                referencedColumn:
                                    $$AppNotificationsTableReferences
                                        ._guardianIdTable(db)
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

typedef $$AppNotificationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppNotificationsTable,
      AppNotification,
      $$AppNotificationsTableFilterComposer,
      $$AppNotificationsTableOrderingComposer,
      $$AppNotificationsTableAnnotationComposer,
      $$AppNotificationsTableCreateCompanionBuilder,
      $$AppNotificationsTableUpdateCompanionBuilder,
      (AppNotification, $$AppNotificationsTableReferences),
      AppNotification,
      PrefetchHooks Function({bool guardianId})
    >;
typedef $$TimeSlotsTableCreateCompanionBuilder =
    TimeSlotsCompanion Function({
      Value<int> id,
      required String name,
      required String startTime,
      required String endTime,
      Value<bool> isBreak,
      Value<int> sortOrder,
    });
typedef $$TimeSlotsTableUpdateCompanionBuilder =
    TimeSlotsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> startTime,
      Value<String> endTime,
      Value<bool> isBreak,
      Value<int> sortOrder,
    });

final class $$TimeSlotsTableReferences
    extends BaseReferences<_$AppDatabase, $TimeSlotsTable, TimeSlot> {
  $$TimeSlotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TimetableEntriesTable, List<TimetableEntry>>
  _timetableEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.timetableEntries,
    aliasName: $_aliasNameGenerator(
      db.timeSlots.id,
      db.timetableEntries.slotId,
    ),
  );

  $$TimetableEntriesTableProcessedTableManager get timetableEntriesRefs {
    final manager = $$TimetableEntriesTableTableManager(
      $_db,
      $_db.timetableEntries,
    ).filter((f) => f.slotId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _timetableEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TimeSlotsTableFilterComposer
    extends Composer<_$AppDatabase, $TimeSlotsTable> {
  $$TimeSlotsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBreak => $composableBuilder(
    column: $table.isBreak,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> timetableEntriesRefs(
    Expression<bool> Function($$TimetableEntriesTableFilterComposer f) f,
  ) {
    final $$TimetableEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.slotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableFilterComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimeSlotsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimeSlotsTable> {
  $$TimeSlotsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBreak => $composableBuilder(
    column: $table.isBreak,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimeSlotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimeSlotsTable> {
  $$TimeSlotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<String> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<bool> get isBreak =>
      $composableBuilder(column: $table.isBreak, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> timetableEntriesRefs<T extends Object>(
    Expression<T> Function($$TimetableEntriesTableAnnotationComposer a) f,
  ) {
    final $$TimetableEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.timetableEntries,
      getReferencedColumn: (t) => t.slotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimetableEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.timetableEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TimeSlotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimeSlotsTable,
          TimeSlot,
          $$TimeSlotsTableFilterComposer,
          $$TimeSlotsTableOrderingComposer,
          $$TimeSlotsTableAnnotationComposer,
          $$TimeSlotsTableCreateCompanionBuilder,
          $$TimeSlotsTableUpdateCompanionBuilder,
          (TimeSlot, $$TimeSlotsTableReferences),
          TimeSlot,
          PrefetchHooks Function({bool timetableEntriesRefs})
        > {
  $$TimeSlotsTableTableManager(_$AppDatabase db, $TimeSlotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimeSlotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimeSlotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimeSlotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> startTime = const Value.absent(),
                Value<String> endTime = const Value.absent(),
                Value<bool> isBreak = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TimeSlotsCompanion(
                id: id,
                name: name,
                startTime: startTime,
                endTime: endTime,
                isBreak: isBreak,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String startTime,
                required String endTime,
                Value<bool> isBreak = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => TimeSlotsCompanion.insert(
                id: id,
                name: name,
                startTime: startTime,
                endTime: endTime,
                isBreak: isBreak,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimeSlotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({timetableEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (timetableEntriesRefs) db.timetableEntries,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (timetableEntriesRefs)
                    await $_getPrefetchedData<
                      TimeSlot,
                      $TimeSlotsTable,
                      TimetableEntry
                    >(
                      currentTable: table,
                      referencedTable: $$TimeSlotsTableReferences
                          ._timetableEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TimeSlotsTableReferences(
                            db,
                            table,
                            p0,
                          ).timetableEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.slotId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TimeSlotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimeSlotsTable,
      TimeSlot,
      $$TimeSlotsTableFilterComposer,
      $$TimeSlotsTableOrderingComposer,
      $$TimeSlotsTableAnnotationComposer,
      $$TimeSlotsTableCreateCompanionBuilder,
      $$TimeSlotsTableUpdateCompanionBuilder,
      (TimeSlot, $$TimeSlotsTableReferences),
      TimeSlot,
      PrefetchHooks Function({bool timetableEntriesRefs})
    >;
typedef $$TimetableEntriesTableCreateCompanionBuilder =
    TimetableEntriesCompanion Function({
      Value<int> id,
      required int sectionId,
      required int dayOfWeek,
      required int slotId,
      required int subjectId,
      Value<int?> teacherId,
      Value<String?> room,
      Value<DateTime> updatedAt,
    });
typedef $$TimetableEntriesTableUpdateCompanionBuilder =
    TimetableEntriesCompanion Function({
      Value<int> id,
      Value<int> sectionId,
      Value<int> dayOfWeek,
      Value<int> slotId,
      Value<int> subjectId,
      Value<int?> teacherId,
      Value<String?> room,
      Value<DateTime> updatedAt,
    });

final class $$TimetableEntriesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TimetableEntriesTable, TimetableEntry> {
  $$TimetableEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SectionsTable _sectionIdTable(_$AppDatabase db) =>
      db.sections.createAlias(
        $_aliasNameGenerator(db.timetableEntries.sectionId, db.sections.id),
      );

  $$SectionsTableProcessedTableManager get sectionId {
    final $_column = $_itemColumn<int>('section_id')!;

    final manager = $$SectionsTableTableManager(
      $_db,
      $_db.sections,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sectionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TimeSlotsTable _slotIdTable(_$AppDatabase db) =>
      db.timeSlots.createAlias(
        $_aliasNameGenerator(db.timetableEntries.slotId, db.timeSlots.id),
      );

  $$TimeSlotsTableProcessedTableManager get slotId {
    final $_column = $_itemColumn<int>('slot_id')!;

    final manager = $$TimeSlotsTableTableManager(
      $_db,
      $_db.timeSlots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_slotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
        $_aliasNameGenerator(db.timetableEntries.subjectId, db.subjects.id),
      );

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TeachersTable _teacherIdTable(_$AppDatabase db) =>
      db.teachers.createAlias(
        $_aliasNameGenerator(db.timetableEntries.teacherId, db.teachers.id),
      );

  $$TeachersTableProcessedTableManager? get teacherId {
    final $_column = $_itemColumn<int>('teacher_id');
    if ($_column == null) return null;
    final manager = $$TeachersTableTableManager(
      $_db,
      $_db.teachers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_teacherIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TimetableEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableFilterComposer({
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

  ColumnFilters<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SectionsTableFilterComposer get sectionId {
    final $$SectionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableFilterComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeSlotsTableFilterComposer get slotId {
    final $$TimeSlotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.timeSlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeSlotsTableFilterComposer(
            $db: $db,
            $table: $db.timeSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeachersTableFilterComposer get teacherId {
    final $$TeachersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teacherId,
      referencedTable: $db.teachers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeachersTableFilterComposer(
            $db: $db,
            $table: $db.teachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableOrderingComposer({
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

  ColumnOrderings<int> get dayOfWeek => $composableBuilder(
    column: $table.dayOfWeek,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SectionsTableOrderingComposer get sectionId {
    final $$SectionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableOrderingComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeSlotsTableOrderingComposer get slotId {
    final $$TimeSlotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.timeSlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeSlotsTableOrderingComposer(
            $db: $db,
            $table: $db.timeSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeachersTableOrderingComposer get teacherId {
    final $$TeachersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teacherId,
      referencedTable: $db.teachers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeachersTableOrderingComposer(
            $db: $db,
            $table: $db.teachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimetableEntriesTable> {
  $$TimetableEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get dayOfWeek =>
      $composableBuilder(column: $table.dayOfWeek, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$SectionsTableAnnotationComposer get sectionId {
    final $$SectionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sectionId,
      referencedTable: $db.sections,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SectionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sections,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TimeSlotsTableAnnotationComposer get slotId {
    final $$TimeSlotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.slotId,
      referencedTable: $db.timeSlots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TimeSlotsTableAnnotationComposer(
            $db: $db,
            $table: $db.timeSlots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TeachersTableAnnotationComposer get teacherId {
    final $$TeachersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.teacherId,
      referencedTable: $db.teachers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TeachersTableAnnotationComposer(
            $db: $db,
            $table: $db.teachers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TimetableEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimetableEntriesTable,
          TimetableEntry,
          $$TimetableEntriesTableFilterComposer,
          $$TimetableEntriesTableOrderingComposer,
          $$TimetableEntriesTableAnnotationComposer,
          $$TimetableEntriesTableCreateCompanionBuilder,
          $$TimetableEntriesTableUpdateCompanionBuilder,
          (TimetableEntry, $$TimetableEntriesTableReferences),
          TimetableEntry,
          PrefetchHooks Function({
            bool sectionId,
            bool slotId,
            bool subjectId,
            bool teacherId,
          })
        > {
  $$TimetableEntriesTableTableManager(
    _$AppDatabase db,
    $TimetableEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimetableEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimetableEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimetableEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sectionId = const Value.absent(),
                Value<int> dayOfWeek = const Value.absent(),
                Value<int> slotId = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<int?> teacherId = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TimetableEntriesCompanion(
                id: id,
                sectionId: sectionId,
                dayOfWeek: dayOfWeek,
                slotId: slotId,
                subjectId: subjectId,
                teacherId: teacherId,
                room: room,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sectionId,
                required int dayOfWeek,
                required int slotId,
                required int subjectId,
                Value<int?> teacherId = const Value.absent(),
                Value<String?> room = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => TimetableEntriesCompanion.insert(
                id: id,
                sectionId: sectionId,
                dayOfWeek: dayOfWeek,
                slotId: slotId,
                subjectId: subjectId,
                teacherId: teacherId,
                room: room,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TimetableEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                sectionId = false,
                slotId = false,
                subjectId = false,
                teacherId = false,
              }) {
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
                        if (sectionId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.sectionId,
                                    referencedTable:
                                        $$TimetableEntriesTableReferences
                                            ._sectionIdTable(db),
                                    referencedColumn:
                                        $$TimetableEntriesTableReferences
                                            ._sectionIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (slotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.slotId,
                                    referencedTable:
                                        $$TimetableEntriesTableReferences
                                            ._slotIdTable(db),
                                    referencedColumn:
                                        $$TimetableEntriesTableReferences
                                            ._slotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subjectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subjectId,
                                    referencedTable:
                                        $$TimetableEntriesTableReferences
                                            ._subjectIdTable(db),
                                    referencedColumn:
                                        $$TimetableEntriesTableReferences
                                            ._subjectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (teacherId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.teacherId,
                                    referencedTable:
                                        $$TimetableEntriesTableReferences
                                            ._teacherIdTable(db),
                                    referencedColumn:
                                        $$TimetableEntriesTableReferences
                                            ._teacherIdTable(db)
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

typedef $$TimetableEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimetableEntriesTable,
      TimetableEntry,
      $$TimetableEntriesTableFilterComposer,
      $$TimetableEntriesTableOrderingComposer,
      $$TimetableEntriesTableAnnotationComposer,
      $$TimetableEntriesTableCreateCompanionBuilder,
      $$TimetableEntriesTableUpdateCompanionBuilder,
      (TimetableEntry, $$TimetableEntriesTableReferences),
      TimetableEntry,
      PrefetchHooks Function({
        bool sectionId,
        bool slotId,
        bool subjectId,
        bool teacherId,
      })
    >;
typedef $$ExamsTableCreateCompanionBuilder =
    ExamsCompanion Function({
      Value<int> id,
      required String name,
      Value<String> examType,
      required int academicYearId,
      Value<int> term,
      required DateTime startsOn,
      required DateTime endsOn,
      Value<bool> isPublished,
      Value<DateTime?> publishedAt,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });
typedef $$ExamsTableUpdateCompanionBuilder =
    ExamsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> examType,
      Value<int> academicYearId,
      Value<int> term,
      Value<DateTime> startsOn,
      Value<DateTime> endsOn,
      Value<bool> isPublished,
      Value<DateTime?> publishedAt,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });

final class $$ExamsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamsTable, Exam> {
  $$ExamsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $AcademicYearsTable _academicYearIdTable(_$AppDatabase db) =>
      db.academicYears.createAlias(
        $_aliasNameGenerator(db.exams.academicYearId, db.academicYears.id),
      );

  $$AcademicYearsTableProcessedTableManager get academicYearId {
    final $_column = $_itemColumn<int>('academic_year_id')!;

    final manager = $$AcademicYearsTableTableManager(
      $_db,
      $_db.academicYears,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_academicYearIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ExamSubjectsTable, List<ExamSubject>>
  _examSubjectsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.examSubjects,
    aliasName: $_aliasNameGenerator(db.exams.id, db.examSubjects.examId),
  );

  $$ExamSubjectsTableProcessedTableManager get examSubjectsRefs {
    final manager = $$ExamSubjectsTableTableManager(
      $_db,
      $_db.examSubjects,
    ).filter((f) => f.examId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_examSubjectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamsTableFilterComposer extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examType => $composableBuilder(
    column: $table.examType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$AcademicYearsTableFilterComposer get academicYearId {
    final $$AcademicYearsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableFilterComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> examSubjectsRefs(
    Expression<bool> Function($$ExamSubjectsTableFilterComposer f) f,
  ) {
    final $$ExamSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examType => $composableBuilder(
    column: $table.examType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get term => $composableBuilder(
    column: $table.term,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startsOn => $composableBuilder(
    column: $table.startsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsOn => $composableBuilder(
    column: $table.endsOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$AcademicYearsTableOrderingComposer get academicYearId {
    final $$AcademicYearsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableOrderingComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamsTable> {
  $$ExamsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get examType =>
      $composableBuilder(column: $table.examType, builder: (column) => column);

  GeneratedColumn<int> get term =>
      $composableBuilder(column: $table.term, builder: (column) => column);

  GeneratedColumn<DateTime> get startsOn =>
      $composableBuilder(column: $table.startsOn, builder: (column) => column);

  GeneratedColumn<DateTime> get endsOn =>
      $composableBuilder(column: $table.endsOn, builder: (column) => column);

  GeneratedColumn<bool> get isPublished => $composableBuilder(
    column: $table.isPublished,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$AcademicYearsTableAnnotationComposer get academicYearId {
    final $$AcademicYearsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.academicYearId,
      referencedTable: $db.academicYears,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicYearsTableAnnotationComposer(
            $db: $db,
            $table: $db.academicYears,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> examSubjectsRefs<T extends Object>(
    Expression<T> Function($$ExamSubjectsTableAnnotationComposer a) f,
  ) {
    final $$ExamSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.examId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamsTable,
          Exam,
          $$ExamsTableFilterComposer,
          $$ExamsTableOrderingComposer,
          $$ExamsTableAnnotationComposer,
          $$ExamsTableCreateCompanionBuilder,
          $$ExamsTableUpdateCompanionBuilder,
          (Exam, $$ExamsTableReferences),
          Exam,
          PrefetchHooks Function({bool academicYearId, bool examSubjectsRefs})
        > {
  $$ExamsTableTableManager(_$AppDatabase db, $ExamsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> examType = const Value.absent(),
                Value<int> academicYearId = const Value.absent(),
                Value<int> term = const Value.absent(),
                Value<DateTime> startsOn = const Value.absent(),
                Value<DateTime> endsOn = const Value.absent(),
                Value<bool> isPublished = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExamsCompanion(
                id: id,
                name: name,
                examType: examType,
                academicYearId: academicYearId,
                term: term,
                startsOn: startsOn,
                endsOn: endsOn,
                isPublished: isPublished,
                publishedAt: publishedAt,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> examType = const Value.absent(),
                required int academicYearId,
                Value<int> term = const Value.absent(),
                required DateTime startsOn,
                required DateTime endsOn,
                Value<bool> isPublished = const Value.absent(),
                Value<DateTime?> publishedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => ExamsCompanion.insert(
                id: id,
                name: name,
                examType: examType,
                academicYearId: academicYearId,
                term: term,
                startsOn: startsOn,
                endsOn: endsOn,
                isPublished: isPublished,
                publishedAt: publishedAt,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$ExamsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({academicYearId = false, examSubjectsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (examSubjectsRefs) db.examSubjects,
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
                        if (academicYearId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.academicYearId,
                                    referencedTable: $$ExamsTableReferences
                                        ._academicYearIdTable(db),
                                    referencedColumn: $$ExamsTableReferences
                                        ._academicYearIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (examSubjectsRefs)
                        await $_getPrefetchedData<
                          Exam,
                          $ExamsTable,
                          ExamSubject
                        >(
                          currentTable: table,
                          referencedTable: $$ExamsTableReferences
                              ._examSubjectsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamsTableReferences(
                                db,
                                table,
                                p0,
                              ).examSubjectsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examId == item.id,
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

typedef $$ExamsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamsTable,
      Exam,
      $$ExamsTableFilterComposer,
      $$ExamsTableOrderingComposer,
      $$ExamsTableAnnotationComposer,
      $$ExamsTableCreateCompanionBuilder,
      $$ExamsTableUpdateCompanionBuilder,
      (Exam, $$ExamsTableReferences),
      Exam,
      PrefetchHooks Function({bool academicYearId, bool examSubjectsRefs})
    >;
typedef $$ExamSubjectsTableCreateCompanionBuilder =
    ExamSubjectsCompanion Function({
      Value<int> id,
      required int examId,
      required int gradeId,
      required int subjectId,
      Value<int> fullMark,
      Value<int> passMark,
      Value<DateTime?> examDate,
      Value<int> sortOrder,
    });
typedef $$ExamSubjectsTableUpdateCompanionBuilder =
    ExamSubjectsCompanion Function({
      Value<int> id,
      Value<int> examId,
      Value<int> gradeId,
      Value<int> subjectId,
      Value<int> fullMark,
      Value<int> passMark,
      Value<DateTime?> examDate,
      Value<int> sortOrder,
    });

final class $$ExamSubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ExamSubjectsTable, ExamSubject> {
  $$ExamSubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamsTable _examIdTable(_$AppDatabase db) => db.exams.createAlias(
    $_aliasNameGenerator(db.examSubjects.examId, db.exams.id),
  );

  $$ExamsTableProcessedTableManager get examId {
    final $_column = $_itemColumn<int>('exam_id')!;

    final manager = $$ExamsTableTableManager(
      $_db,
      $_db.exams,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GradesTable _gradeIdTable(_$AppDatabase db) => db.grades.createAlias(
    $_aliasNameGenerator(db.examSubjects.gradeId, db.grades.id),
  );

  $$GradesTableProcessedTableManager get gradeId {
    final $_column = $_itemColumn<int>('grade_id')!;

    final manager = $$GradesTableTableManager(
      $_db,
      $_db.grades,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gradeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
        $_aliasNameGenerator(db.examSubjects.subjectId, db.subjects.id),
      );

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<int>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MarksTable, List<Mark>> _marksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.marks,
    aliasName: $_aliasNameGenerator(db.examSubjects.id, db.marks.examSubjectId),
  );

  $$MarksTableProcessedTableManager get marksRefs {
    final manager = $$MarksTableTableManager(
      $_db,
      $_db.marks,
    ).filter((f) => f.examSubjectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_marksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExamSubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ExamSubjectsTable> {
  $$ExamSubjectsTableFilterComposer({
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

  ColumnFilters<int> get fullMark => $composableBuilder(
    column: $table.fullMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get passMark => $composableBuilder(
    column: $table.passMark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamsTableFilterComposer get examId {
    final $$ExamsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableFilterComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GradesTableFilterComposer get gradeId {
    final $$GradesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableFilterComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> marksRefs(
    Expression<bool> Function($$MarksTableFilterComposer f) f,
  ) {
    final $$MarksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.marks,
      getReferencedColumn: (t) => t.examSubjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarksTableFilterComposer(
            $db: $db,
            $table: $db.marks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamSubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExamSubjectsTable> {
  $$ExamSubjectsTableOrderingComposer({
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

  ColumnOrderings<int> get fullMark => $composableBuilder(
    column: $table.fullMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get passMark => $composableBuilder(
    column: $table.passMark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get examDate => $composableBuilder(
    column: $table.examDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamsTableOrderingComposer get examId {
    final $$ExamsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableOrderingComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GradesTableOrderingComposer get gradeId {
    final $$GradesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableOrderingComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExamSubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExamSubjectsTable> {
  $$ExamSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get fullMark =>
      $composableBuilder(column: $table.fullMark, builder: (column) => column);

  GeneratedColumn<int> get passMark =>
      $composableBuilder(column: $table.passMark, builder: (column) => column);

  GeneratedColumn<DateTime> get examDate =>
      $composableBuilder(column: $table.examDate, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$ExamsTableAnnotationComposer get examId {
    final $$ExamsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examId,
      referencedTable: $db.exams,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamsTableAnnotationComposer(
            $db: $db,
            $table: $db.exams,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GradesTableAnnotationComposer get gradeId {
    final $$GradesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gradeId,
      referencedTable: $db.grades,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GradesTableAnnotationComposer(
            $db: $db,
            $table: $db.grades,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> marksRefs<T extends Object>(
    Expression<T> Function($$MarksTableAnnotationComposer a) f,
  ) {
    final $$MarksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.marks,
      getReferencedColumn: (t) => t.examSubjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MarksTableAnnotationComposer(
            $db: $db,
            $table: $db.marks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExamSubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExamSubjectsTable,
          ExamSubject,
          $$ExamSubjectsTableFilterComposer,
          $$ExamSubjectsTableOrderingComposer,
          $$ExamSubjectsTableAnnotationComposer,
          $$ExamSubjectsTableCreateCompanionBuilder,
          $$ExamSubjectsTableUpdateCompanionBuilder,
          (ExamSubject, $$ExamSubjectsTableReferences),
          ExamSubject,
          PrefetchHooks Function({
            bool examId,
            bool gradeId,
            bool subjectId,
            bool marksRefs,
          })
        > {
  $$ExamSubjectsTableTableManager(_$AppDatabase db, $ExamSubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examId = const Value.absent(),
                Value<int> gradeId = const Value.absent(),
                Value<int> subjectId = const Value.absent(),
                Value<int> fullMark = const Value.absent(),
                Value<int> passMark = const Value.absent(),
                Value<DateTime?> examDate = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ExamSubjectsCompanion(
                id: id,
                examId: examId,
                gradeId: gradeId,
                subjectId: subjectId,
                fullMark: fullMark,
                passMark: passMark,
                examDate: examDate,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examId,
                required int gradeId,
                required int subjectId,
                Value<int> fullMark = const Value.absent(),
                Value<int> passMark = const Value.absent(),
                Value<DateTime?> examDate = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => ExamSubjectsCompanion.insert(
                id: id,
                examId: examId,
                gradeId: gradeId,
                subjectId: subjectId,
                fullMark: fullMark,
                passMark: passMark,
                examDate: examDate,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExamSubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                examId = false,
                gradeId = false,
                subjectId = false,
                marksRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (marksRefs) db.marks],
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
                        if (examId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.examId,
                                    referencedTable:
                                        $$ExamSubjectsTableReferences
                                            ._examIdTable(db),
                                    referencedColumn:
                                        $$ExamSubjectsTableReferences
                                            ._examIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (gradeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gradeId,
                                    referencedTable:
                                        $$ExamSubjectsTableReferences
                                            ._gradeIdTable(db),
                                    referencedColumn:
                                        $$ExamSubjectsTableReferences
                                            ._gradeIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (subjectId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.subjectId,
                                    referencedTable:
                                        $$ExamSubjectsTableReferences
                                            ._subjectIdTable(db),
                                    referencedColumn:
                                        $$ExamSubjectsTableReferences
                                            ._subjectIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (marksRefs)
                        await $_getPrefetchedData<
                          ExamSubject,
                          $ExamSubjectsTable,
                          Mark
                        >(
                          currentTable: table,
                          referencedTable: $$ExamSubjectsTableReferences
                              ._marksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExamSubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).marksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.examSubjectId == item.id,
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

typedef $$ExamSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExamSubjectsTable,
      ExamSubject,
      $$ExamSubjectsTableFilterComposer,
      $$ExamSubjectsTableOrderingComposer,
      $$ExamSubjectsTableAnnotationComposer,
      $$ExamSubjectsTableCreateCompanionBuilder,
      $$ExamSubjectsTableUpdateCompanionBuilder,
      (ExamSubject, $$ExamSubjectsTableReferences),
      ExamSubject,
      PrefetchHooks Function({
        bool examId,
        bool gradeId,
        bool subjectId,
        bool marksRefs,
      })
    >;
typedef $$MarksTableCreateCompanionBuilder =
    MarksCompanion Function({
      Value<int> id,
      required int examSubjectId,
      required int studentId,
      Value<double?> obtained,
      Value<bool> isAbsent,
      Value<String?> remarks,
      Value<int?> enteredByUserId,
      Value<DateTime> enteredAt,
    });
typedef $$MarksTableUpdateCompanionBuilder =
    MarksCompanion Function({
      Value<int> id,
      Value<int> examSubjectId,
      Value<int> studentId,
      Value<double?> obtained,
      Value<bool> isAbsent,
      Value<String?> remarks,
      Value<int?> enteredByUserId,
      Value<DateTime> enteredAt,
    });

final class $$MarksTableReferences
    extends BaseReferences<_$AppDatabase, $MarksTable, Mark> {
  $$MarksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ExamSubjectsTable _examSubjectIdTable(_$AppDatabase db) =>
      db.examSubjects.createAlias(
        $_aliasNameGenerator(db.marks.examSubjectId, db.examSubjects.id),
      );

  $$ExamSubjectsTableProcessedTableManager get examSubjectId {
    final $_column = $_itemColumn<int>('exam_subject_id')!;

    final manager = $$ExamSubjectsTableTableManager(
      $_db,
      $_db.examSubjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_examSubjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $StudentsTable _studentIdTable(_$AppDatabase db) => db.students
      .createAlias($_aliasNameGenerator(db.marks.studentId, db.students.id));

  $$StudentsTableProcessedTableManager get studentId {
    final $_column = $_itemColumn<int>('student_id')!;

    final manager = $$StudentsTableTableManager(
      $_db,
      $_db.students,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_studentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MarksTableFilterComposer extends Composer<_$AppDatabase, $MarksTable> {
  $$MarksTableFilterComposer({
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

  ColumnFilters<double> get obtained => $composableBuilder(
    column: $table.obtained,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isAbsent => $composableBuilder(
    column: $table.isAbsent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get enteredByUserId => $composableBuilder(
    column: $table.enteredByUserId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get enteredAt => $composableBuilder(
    column: $table.enteredAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExamSubjectsTableFilterComposer get examSubjectId {
    final $$ExamSubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examSubjectId,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableFilterComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableFilterComposer get studentId {
    final $$StudentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableFilterComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarksTableOrderingComposer
    extends Composer<_$AppDatabase, $MarksTable> {
  $$MarksTableOrderingComposer({
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

  ColumnOrderings<double> get obtained => $composableBuilder(
    column: $table.obtained,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isAbsent => $composableBuilder(
    column: $table.isAbsent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get remarks => $composableBuilder(
    column: $table.remarks,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get enteredByUserId => $composableBuilder(
    column: $table.enteredByUserId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get enteredAt => $composableBuilder(
    column: $table.enteredAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExamSubjectsTableOrderingComposer get examSubjectId {
    final $$ExamSubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examSubjectId,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableOrderingComposer get studentId {
    final $$StudentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableOrderingComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarksTable> {
  $$MarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get obtained =>
      $composableBuilder(column: $table.obtained, builder: (column) => column);

  GeneratedColumn<bool> get isAbsent =>
      $composableBuilder(column: $table.isAbsent, builder: (column) => column);

  GeneratedColumn<String> get remarks =>
      $composableBuilder(column: $table.remarks, builder: (column) => column);

  GeneratedColumn<int> get enteredByUserId => $composableBuilder(
    column: $table.enteredByUserId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get enteredAt =>
      $composableBuilder(column: $table.enteredAt, builder: (column) => column);

  $$ExamSubjectsTableAnnotationComposer get examSubjectId {
    final $$ExamSubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.examSubjectId,
      referencedTable: $db.examSubjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExamSubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.examSubjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$StudentsTableAnnotationComposer get studentId {
    final $$StudentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.studentId,
      referencedTable: $db.students,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StudentsTableAnnotationComposer(
            $db: $db,
            $table: $db.students,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarksTable,
          Mark,
          $$MarksTableFilterComposer,
          $$MarksTableOrderingComposer,
          $$MarksTableAnnotationComposer,
          $$MarksTableCreateCompanionBuilder,
          $$MarksTableUpdateCompanionBuilder,
          (Mark, $$MarksTableReferences),
          Mark,
          PrefetchHooks Function({bool examSubjectId, bool studentId})
        > {
  $$MarksTableTableManager(_$AppDatabase db, $MarksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> examSubjectId = const Value.absent(),
                Value<int> studentId = const Value.absent(),
                Value<double?> obtained = const Value.absent(),
                Value<bool> isAbsent = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<int?> enteredByUserId = const Value.absent(),
                Value<DateTime> enteredAt = const Value.absent(),
              }) => MarksCompanion(
                id: id,
                examSubjectId: examSubjectId,
                studentId: studentId,
                obtained: obtained,
                isAbsent: isAbsent,
                remarks: remarks,
                enteredByUserId: enteredByUserId,
                enteredAt: enteredAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int examSubjectId,
                required int studentId,
                Value<double?> obtained = const Value.absent(),
                Value<bool> isAbsent = const Value.absent(),
                Value<String?> remarks = const Value.absent(),
                Value<int?> enteredByUserId = const Value.absent(),
                Value<DateTime> enteredAt = const Value.absent(),
              }) => MarksCompanion.insert(
                id: id,
                examSubjectId: examSubjectId,
                studentId: studentId,
                obtained: obtained,
                isAbsent: isAbsent,
                remarks: remarks,
                enteredByUserId: enteredByUserId,
                enteredAt: enteredAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$MarksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({examSubjectId = false, studentId = false}) {
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
                    if (examSubjectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.examSubjectId,
                                referencedTable: $$MarksTableReferences
                                    ._examSubjectIdTable(db),
                                referencedColumn: $$MarksTableReferences
                                    ._examSubjectIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (studentId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.studentId,
                                referencedTable: $$MarksTableReferences
                                    ._studentIdTable(db),
                                referencedColumn: $$MarksTableReferences
                                    ._studentIdTable(db)
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

typedef $$MarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarksTable,
      Mark,
      $$MarksTableFilterComposer,
      $$MarksTableOrderingComposer,
      $$MarksTableAnnotationComposer,
      $$MarksTableCreateCompanionBuilder,
      $$MarksTableUpdateCompanionBuilder,
      (Mark, $$MarksTableReferences),
      Mark,
      PrefetchHooks Function({bool examSubjectId, bool studentId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SchoolsTableTableManager get schools =>
      $$SchoolsTableTableManager(_db, _db.schools);
  $$AppUsersTableTableManager get appUsers =>
      $$AppUsersTableTableManager(_db, _db.appUsers);
  $$AcademicYearsTableTableManager get academicYears =>
      $$AcademicYearsTableTableManager(_db, _db.academicYears);
  $$GradesTableTableManager get grades =>
      $$GradesTableTableManager(_db, _db.grades);
  $$SectionsTableTableManager get sections =>
      $$SectionsTableTableManager(_db, _db.sections);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$GuardiansTableTableManager get guardians =>
      $$GuardiansTableTableManager(_db, _db.guardians);
  $$StudentGuardiansTableTableManager get studentGuardians =>
      $$StudentGuardiansTableTableManager(_db, _db.studentGuardians);
  $$TeachersTableTableManager get teachers =>
      $$TeachersTableTableManager(_db, _db.teachers);
  $$StaffMembersTableTableManager get staffMembers =>
      $$StaffMembersTableTableManager(_db, _db.staffMembers);
  $$EnrollmentsTableTableManager get enrollments =>
      $$EnrollmentsTableTableManager(_db, _db.enrollments);
  $$AttendancesTableTableManager get attendances =>
      $$AttendancesTableTableManager(_db, _db.attendances);
  $$LeaveRequestsTableTableManager get leaveRequests =>
      $$LeaveRequestsTableTableManager(_db, _db.leaveRequests);
  $$AuditLogsTableTableManager get auditLogs =>
      $$AuditLogsTableTableManager(_db, _db.auditLogs);
  $$DevicesTableTableManager get devices =>
      $$DevicesTableTableManager(_db, _db.devices);
  $$PairingCodesTableTableManager get pairingCodes =>
      $$PairingCodesTableTableManager(_db, _db.pairingCodes);
  $$MessageTemplatesTableTableManager get messageTemplates =>
      $$MessageTemplatesTableTableManager(_db, _db.messageTemplates);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$AppNotificationsTableTableManager get appNotifications =>
      $$AppNotificationsTableTableManager(_db, _db.appNotifications);
  $$TimeSlotsTableTableManager get timeSlots =>
      $$TimeSlotsTableTableManager(_db, _db.timeSlots);
  $$TimetableEntriesTableTableManager get timetableEntries =>
      $$TimetableEntriesTableTableManager(_db, _db.timetableEntries);
  $$ExamsTableTableManager get exams =>
      $$ExamsTableTableManager(_db, _db.exams);
  $$ExamSubjectsTableTableManager get examSubjects =>
      $$ExamSubjectsTableTableManager(_db, _db.examSubjects);
  $$MarksTableTableManager get marks =>
      $$MarksTableTableManager(_db, _db.marks);
}
