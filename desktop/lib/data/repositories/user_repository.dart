import 'dart:convert';

import 'package:drift/drift.dart';

import '../../core/utils/password.dart';
import '../db/database.dart';

// ═══════════════════════════════════════════════════════════
//  رولونه او اجازې
// ═══════════════════════════════════════════════════════════

/// هغه څه چې یو کارن پر یوه ماډل کولی شي.
enum Perm { view, create, edit, delete }

extension PermLabel on Perm {
  String get key => name;
  String get label => switch (this) {
    Perm.view => 'کتل',
    Perm.create => 'زیاتول',
    Perm.edit => 'سمول',
    Perm.delete => 'ړنګول',
  };
}

/// هغه ماډلونه چې اجازه پرې ټاکل کېږي.
///
/// **دا لیست د سایډبار سره یو دی، خو یو شان نه دی.** سایډبار د
/// لیدو لپاره دی؛ دا د واک لپاره. مثلاً «ډاشبورډ» دلته نشته — هر
/// څوک يې ویني، ځکه چې هغه یوازې د هغو شمېرو لنډیز دی چې کارن يې
/// لا وړاندې لیدلی شي.
const List<({String key, String label})> permModules = [
  (key: 'students', label: 'شاګردان'),
  (key: 'attendance', label: 'حاضري'),
  (key: 'leave', label: 'اجازت‌نامې'),
  (key: 'classes', label: 'ټولګي'),
  (key: 'timetable', label: 'مهالویش'),
  (key: 'exams', label: 'ازموینې'),
  (key: 'teachers', label: 'استادان'),
  (key: 'staff', label: 'کارمندان'),
  (key: 'messages', label: 'پیغامونه'),
  (key: 'fees', label: 'فیس'),
  (key: 'payroll', label: 'معاشونه'),
  (key: 'reports', label: 'رپوټونه'),
  (key: 'users', label: 'کاروونکي'),
  (key: 'settings', label: 'تنظیمات'),
];

/// د هر رول تلوالې اجازې.
///
/// **ولې د رول له مخې، نه د هر کارن لپاره؟** ځکه چې یو ښوونځی
/// ښايي شپږ کاروونکي ولري او مدیر يې د څوارلسو ماډلونو × څلورو
/// کړنو جدول ډکولو ته وخت نه لري. رول ۹۵٪ کار کوي؛ هر کارن بیا
/// خپل استثناوې لري.
const Map<String, Map<String, List<String>>> roleDefaults = {
  'admin': {'*': ['view', 'create', 'edit', 'delete']},
  'deputy': {
    'students': ['view', 'create', 'edit'],
    'attendance': ['view', 'create', 'edit'],
    'leave': ['view', 'create', 'edit'],
    'classes': ['view', 'edit'],
    'timetable': ['view', 'create', 'edit'],
    'exams': ['view', 'create', 'edit'],
    'teachers': ['view'],
    'staff': ['view'],
    'messages': ['view', 'create'],
    'reports': ['view'],
  },
  'teacher': {
    'students': ['view'],
    'attendance': ['view', 'create', 'edit'],
    'leave': ['view'],
    'timetable': ['view'],
    'exams': ['view', 'edit'],
  },
  'accountant': {
    'students': ['view'],
    'fees': ['view', 'create', 'edit'],
    'payroll': ['view', 'create', 'edit'],
    'reports': ['view'],
  },
  'reception': {
    'students': ['view', 'create'],
    'attendance': ['view', 'create'],
    'leave': ['view', 'create'],
    'messages': ['view', 'create'],
    'fees': ['view', 'create'],
  },
};

const List<({String key, String label})> appRoles = [
  (key: 'admin', label: 'مدیر'),
  (key: 'deputy', label: 'مرستیال'),
  (key: 'teacher', label: 'استاد'),
  (key: 'accountant', label: 'محاسب'),
  (key: 'reception', label: 'ریسیپشن'),
];

String roleLabel(String key) =>
    appRoles.where((r) => r.key == key).firstOrNull?.label ?? key;

/// د یوه کارن مؤثرې اجازې — رول + شخصي استثناوې.
class Permissions {
  final String role;
  final Map<String, Set<String>> _explicit;

  Permissions({required this.role, Map<String, Set<String>>? explicit})
    : _explicit = explicit ?? {};

  /// **مدیر تل هرڅه کولی شي.** که د مدیر اجازې د سمولو وړ وای، یو
  /// څوک به پخپله ځان له سیسټمه بند کړ او بیا به يې څوک نه شو
  /// خلاصولی.
  bool can(String module, Perm perm) {
    if (role == 'admin') return true;
    final own = _explicit[module];
    if (own != null) return own.contains(perm.key);
    return roleDefaults[role]?[module]?.contains(perm.key) ?? false;
  }

  bool canView(String module) => can(module, Perm.view);

  /// هغه ماډلونه چې کارن يې لیدلی شي — سایډبار پرې فلټر کېږي.
  Set<String> get visibleModules => {
    for (final m in permModules)
      if (canView(m.key)) m.key,
  };

  static Permissions of(AppUser user) => Permissions(
    role: user.role,
    explicit: decode(user.permissionsJson),
  );

  static Map<String, Set<String>> decode(String? json) {
    if (json == null || json.trim().isEmpty) return {};
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return {
        for (final e in map.entries)
          e.key: (e.value as List).map((v) => v as String).toSet(),
      };
    } catch (_) {
      // خراب JSON نباید کارن له سیسټمه بند کړي — رول ته ورګرځو.
      return {};
    }
  }

  static String? encode(Map<String, Set<String>> perms) {
    if (perms.isEmpty) return null;
    return jsonEncode({
      for (final e in perms.entries) e.key: e.value.toList()..sort(),
    });
  }
}

// ═══════════════════════════════════════════════════════════

class UserRow {
  final AppUser user;
  final Permissions permissions;
  const UserRow({required this.user, required this.permissions});

  bool get isLocked =>
      user.lockedUntil != null && user.lockedUntil!.isAfter(DateTime.now());
}

/// د پېژندنې د سمون پایله — ولې ونه شوه، نه یوازې «ونه شوه».
enum UpdateProfileResult {
  ok,
  emptyName,
  shortUsername,
  usernameTaken;

  String get message => switch (this) {
    UpdateProfileResult.ok => 'وساتل شو.',
    UpdateProfileResult.emptyName => 'نوم نه شي تش پاتې کېدی.',
    UpdateProfileResult.shortUsername => 'کارن‌نوم لږ تر لږه درې توري.',
    UpdateProfileResult.usernameTaken => 'دا کارن‌نوم لا دمخه نیول شوی.',
  };
}

class UserRepository {
  final AppDatabase db;
  UserRepository(this.db);

  Future<List<UserRow>> list({bool includeInactive = true}) async {
    final q = db.select(db.appUsers)
      ..orderBy([
        (u) => OrderingTerm.desc(u.isActive),
        (u) => OrderingTerm.asc(u.fullName),
      ]);
    if (!includeInactive) q.where((u) => u.isActive.equals(true));

    final rows = await q.get();
    return rows
        .map((u) => UserRow(user: u, permissions: Permissions.of(u)))
        .toList();
  }

  Future<bool> usernameTaken(String username, {int? exceptId}) async {
    final q = db.select(db.appUsers)
      ..where((u) => u.username.equals(username.trim()))
      ..limit(1);
    if (exceptId != null) q.where((u) => u.id.isNotValue(exceptId));
    return (await q.getSingleOrNull()) != null;
  }

  Future<int> create({
    required String username,
    required String fullName,
    required String password,
    required String role,
    Map<String, Set<String>>? permissions,
    int? teacherId,
    required int byUserId,
    required String byUserName,
  }) async {
    final salt = Password.newSalt();
    return db.transaction(() async {
      final id = await db
          .into(db.appUsers)
          .insert(
            AppUsersCompanion.insert(
              username: username.trim(),
              fullName: fullName.trim(),
              passwordHash: Password.hash(password: password, salt: salt),
              passwordSalt: salt,
              role: role,
              permissionsJson: Value(Permissions.encode(permissions ?? {})),
              teacherId: Value(teacherId),
            ),
          );
      await _audit('create', id, byUserId, byUserName, {'role': role});
      return id;
    });
  }

  Future<void> updatePermissions({
    required int userId,
    required Map<String, Set<String>> permissions,
    required int byUserId,
    required String byUserName,
  }) async {
    await (db.update(db.appUsers)..where((u) => u.id.equals(userId))).write(
      AppUsersCompanion(
        permissionsJson: Value(Permissions.encode(permissions)),
      ),
    );
    await _audit('update', userId, byUserId, byUserName, {
      'permissions': permissions.length,
    });
  }

  Future<void> setRole({
    required int userId,
    required String role,
    required int byUserId,
    required String byUserName,
  }) async {
    await (db.update(db.appUsers)..where((u) => u.id.equals(userId))).write(
      // رول چې بدل شي، شخصي استثناوې پاکېږي — که نه، د زوړ رول
      // پاتې اجازې به د نوي رول سره ګډې وې او څوک به نه پوهېده
      // چې کارن څه کولی شي.
      AppUsersCompanion(
        role: Value(role),
        permissionsJson: const Value(null),
      ),
    );
    await _audit('update', userId, byUserId, byUserName, {'role': role});
  }

  Future<void> setActive({
    required int userId,
    required bool active,
    required int byUserId,
    required String byUserName,
  }) async {
    await (db.update(db.appUsers)..where((u) => u.id.equals(userId))).write(
      AppUsersCompanion(
        isActive: Value(active),
        // بند شوی حساب چې بیا فعال شي، د ناکامو هڅو شمېر پاکېږي.
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
      ),
    );
    await _audit('update', userId, byUserId, byUserName, {'active': active});
  }

  Future<void> resetPassword({
    required int userId,
    required String newPassword,
    required int byUserId,
    required String byUserName,
  }) async {
    final salt = Password.newSalt();
    await (db.update(db.appUsers)..where((u) => u.id.equals(userId))).write(
      AppUsersCompanion(
        passwordHash: Value(Password.hash(password: newPassword, salt: salt)),
        passwordSalt: Value(salt),
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
      ),
    );
    // **پاسورډ هېڅکله په تفتیش کې نه لیکل کېږي** — یوازې دا چې
    // بدل شو، چا يې بدل کړ، او کله.
    await _audit('update', userId, byUserId, byUserName, {
      'password': 'reset',
    });
  }

  /// **د یوه کارونکي پېژندنه سمول** — نوم، کارن‌نوم.
  ///
  /// **کارن‌نوم ولې سمېږي؟** ځکه چې یو غلط لیکل شوی کارن‌نوم د
  /// ننوتلو خنډ دی، او هغه کس چې ورسره ننوځي، پخپله يې نه شي
  /// سمولی. که یوازې «نوی کارونکی جوړ کړه» لار وه، د هغه ټوله
  /// تاریخچه به ورکه شوې وه.
  Future<UpdateProfileResult> updateProfile({
    required int userId,
    required String fullName,
    required String username,
    required int byUserId,
    required String byUserName,
  }) async {
    final name = fullName.trim();
    final user = username.trim();
    if (name.isEmpty) return UpdateProfileResult.emptyName;
    if (user.length < 3) return UpdateProfileResult.shortUsername;
    if (await usernameTaken(user, exceptId: userId)) {
      return UpdateProfileResult.usernameTaken;
    }

    await (db.update(db.appUsers)..where((u) => u.id.equals(userId))).write(
      AppUsersCompanion(fullName: Value(name), username: Value(user)),
    );
    await _audit('update', userId, byUserId, byUserName, {
      'fullName': name,
      'username': user,
    });
    return UpdateProfileResult.ok;
  }

  /// **خپل پاسورډ بدلول — زوړ پاسورډ پکار دی.**
  ///
  /// دا له `resetPassword` سره توپیر لري: هغه د مدیر کار دی (هغه
  /// چې زوړ پاسورډ نه پېژني). دا د کارونکي خپل کار دی — او که
  /// زوړ پاسورډ نه غوښتل کېده، هر څوک چې یوه خلاصه پرده ومومي،
  /// د حساب خاوند به يې بدل کړ.
  Future<bool> changeOwnPassword({
    required int userId,
    required String oldPassword,
    required String newPassword,
  }) async {
    final u = await (db.select(
      db.appUsers,
    )..where((x) => x.id.equals(userId))).getSingleOrNull();
    if (u == null) return false;

    final ok = Password.verify(
      password: oldPassword,
      salt: u.passwordSalt,
      expectedHash: u.passwordHash,
      iterations: u.passwordIterations,
    );
    if (!ok) return false;

    final salt = Password.newSalt();
    await (db.update(db.appUsers)..where((x) => x.id.equals(userId))).write(
      AppUsersCompanion(
        passwordHash: Value(Password.hash(password: newPassword, salt: salt)),
        passwordSalt: Value(salt),
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
      ),
    );
    await _audit('update', userId, userId, u.username, {'password': 'self'});
    return true;
  }

  /// د بند شوي حساب خلاصول — مخکې له وخته.
  Future<void> unlock(int userId) =>
      (db.update(db.appUsers)..where((u) => u.id.equals(userId))).write(
        const AppUsersCompanion(
          lockedUntil: Value(null),
          failedAttempts: Value(0),
        ),
      );

  /// **وروستی مدیر نه ړنګېږي.**
  ///
  /// که وروستی فعال مدیر بند شي، هېڅوک به بیا سیسټم ته لاره نه
  /// درلوده — او ډیټابیس به یوازې په لاس د سمولو وړ و.
  Future<bool> isLastActiveAdmin(int userId) async {
    final user = await (db.select(
      db.appUsers,
    )..where((u) => u.id.equals(userId))).getSingleOrNull();
    if (user == null || user.role != 'admin' || !user.isActive) return false;

    final row = await db
        .customSelect(
          "SELECT COUNT(*) AS c FROM app_users "
          "WHERE role = 'admin' AND is_active = 1",
          readsFrom: {db.appUsers},
        )
        .getSingle();
    return row.read<int>('c') <= 1;
  }

  Future<List<AuditLog>> recentActivity({int limit = 50}) =>
      (db.select(db.auditLogs)
            ..orderBy([(a) => OrderingTerm.desc(a.at)])
            ..limit(limit))
          .get();

  Future<void> _audit(
    String action,
    int entityId,
    int byUserId,
    String byUserName,
    Map<String, Object?> changes,
  ) {
    return db
        .into(db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            action: action,
            entity: 'app_users',
            entityId: Value(entityId),
            userId: Value(byUserId),
            userName: Value(byUserName),
            changesJson: Value(jsonEncode(changes)),
          ),
        );
  }
}
