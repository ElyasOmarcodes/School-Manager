import 'package:drift/drift.dart';

import 'core_tables.dart';

// ═══════════════════════════════════════════════════════════
//  تړل شوي وسایل — د مدیر او والدینو تلیفونونه
// ═══════════════════════════════════════════════════════════

/// یو تلیفون چې د ښوونځي سیسټم سره تړل شوی.
///
/// **ولې توکن hash کوو؟** که ډیټابیس چا ته ورسېږي (USB ورک شي)،
/// د خام توکن سره به هغه د ښوونځي ټول معلومات لوستلی شول. له
/// SHA-256 وروسته، هغه څه چې ساتل کېږي بېرته توکن ته نه اوړي.
class Devices extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// «د مدیر Samsung» — کارن يې پخپله ولیکي.
  TextColumn get name => text()();
  TextColumn get platform => text().withDefault(const Constant('android'))();

  /// `manager` | `parent`
  TextColumn get role => text()();

  /// که مدیر وي — کوم کارن ته تړلی.
  IntColumn get userId => integer().nullable()();

  /// که والدین وي — کوم سرپرست ته تړلی.
  IntColumn get guardianId => integer().nullable().references(Guardians, #id)();

  /// د bearer توکن SHA-256.
  TextColumn get tokenHash => text()();

  /// د FCM/پش لپاره — اوس یوازې ساتل کېږي، په اوږد مهال کې کارېږي.
  TextColumn get pushToken => text().nullable()();

  DateTimeColumn get pairedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastSeenAt => dateTime().nullable()();
  TextColumn get lastIp => text().nullable()();
  DateTimeColumn get revokedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {tokenHash},
  ];
}

/// د تړلو یوځلي کوډ — مدیر يې جوړوي، تلیفون يې مصرفوي.
///
/// **ولې لنډ عمر لري؟** کوډ یوازې شپږ توري دی چې کارن يې په لاس
/// ولیکلی شي. که تل ژوندی وای، د اټکل وړ کېده. پنځلس دقیقې بس دي
/// چې مدیر يې یوه چا ته ورکړي.
class PairingCodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get code => text()();

  /// `manager` | `parent`
  TextColumn get role => text()();
  IntColumn get userId => integer().nullable()();
  IntColumn get guardianId => integer().nullable().references(Guardians, #id)();

  DateTimeColumn get expiresAt => dateTime()();
  DateTimeColumn get usedAt => dateTime().nullable()();
  IntColumn get usedByDeviceId => integer().nullable()();

  IntColumn get createdByUserId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {code},
  ];
}

// ═══════════════════════════════════════════════════════════
//  پیغامونه
// ═══════════════════════════════════════════════════════════

/// د پیغام کینډۍ — چې مدیر هر ځل له سره ونه لیکي.
///
/// د متن دننه ځای‌نیوونکي: `{student}` `{class}` `{date}`
/// `{school}` `{count}` `{guardian}`
class MessageTemplates extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `absence` | `absence_repeat` | `leave_approved` | `leave_rejected`
  /// | `fee_due` | `announcement`
  TextColumn get templateKey => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  /// `sms` | `app` | `any`
  TextColumn get channel => text().withDefault(const Constant('any'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get isBuiltIn => boolean().withDefault(const Constant(false))();

  @override
  List<Set<Column>> get uniqueKeys => [
    {templateKey},
  ];
}

/// د وتلي پیغام ریکارډ.
///
/// **دا جدول ولې پکار دی؟** له دې پرته، «ایا د احمد پلار ته پیغام
/// ورغی؟» ځواب نه لري. د حاضرۍ کرښه یوازې `parent_notified` بولین
/// لري — دا وايي چې څه ولېږل شو، چا ته، په کوم کانال، او ایا ورسېد.
class Messages extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// یوه ډله چې یو ځای ولېږل شوه — «نن ۴۷ غیرحاضر».
  TextColumn get batchId => text().nullable()();

  /// `absence` | `leave` | `announcement` | `fee` | `custom`
  TextColumn get kind => text()();

  IntColumn get studentId => integer().nullable().references(Students, #id)();
  IntColumn get guardianId => integer().nullable().references(Guardians, #id)();

  TextColumn get toName => text().nullable()();
  TextColumn get toPhone => text().nullable()();

  /// `app` | `sms` | `whatsapp`
  TextColumn get channel => text().withDefault(const Constant('app'))();

  TextColumn get body => text()();

  /// `queued` | `sent` | `failed` | `read`
  TextColumn get status => text().withDefault(const Constant('queued'))();
  IntColumn get attempts => integer().withDefault(const Constant(0))();
  TextColumn get error => text().nullable()();

  /// کومې ورځې پورې اړه لري — د غیرحاضرۍ نېټه.
  DateTimeColumn get relatedDate => dateTime().nullable()();

  IntColumn get createdByUserId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get sentAt => dateTime().nullable()();
  DateTimeColumn get readAt => dateTime().nullable()();
}

// ═══════════════════════════════════════════════════════════
//  د اپ خبرتیاوې
// ═══════════════════════════════════════════════════════════

/// هغه خبرتیا چې د مدیر (یا والدینو) اپ ته ځي.
///
/// دا **د پیغام څخه بېله ده**. پیغام والدینو ته ځي — خبرتیا مدیر
/// ته ځي چې «۴۷ تنه نن غیرحاضر دي، ایا غواړې پیغام ولېږې؟». نو
/// خبرتیا یو پرېکړې ته بلنه ده، نه یو تللی پیغام.
class AppNotifications extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// `absence_digest` | `leave_request` | `chronic_absence` | `system`
  TextColumn get kind => text()();
  TextColumn get title => text()();
  TextColumn get body => text()();

  /// د تڼۍ لپاره ډیټا — {"date":"2026-08-14","studentIds":[…]}
  TextColumn get payloadJson => text().nullable()();

  /// `manager` | `parent`
  TextColumn get audience => text().withDefault(const Constant('manager'))();
  IntColumn get guardianId => integer().nullable().references(Guardians, #id)();

  /// د دوه‌ځلي مخنیوي کلی — «absence_digest:2026-08-14».
  /// یوه ورځ یوازې یوه خبرتیا لري، خو شمېره يې تازه کېږي.
  TextColumn get dedupeKey => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get readAt => dateTime().nullable()();
  DateTimeColumn get actedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {dedupeKey},
  ];
}
