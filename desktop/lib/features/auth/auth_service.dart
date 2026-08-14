import 'package:drift/drift.dart';

import '../../core/utils/password.dart';
import '../../data/db/database.dart';

/// د ننوتلې غونډې (session) معلومات.
class Session {
  final int userId;
  final String username;
  final String fullName;
  final String role;

  const Session({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.role,
  });

  bool get isAdmin => role == 'admin';
}

sealed class SignInResult {
  const SignInResult();
}

class SignInOk extends SignInResult {
  final Session session;
  const SignInOk(this.session);
}

class SignInWrong extends SignInResult {
  const SignInWrong();
}

class SignInLocked extends SignInResult {
  final DateTime until;
  const SignInLocked(this.until);
}

class AuthService {
  final AppDatabase db;
  AuthService(this.db);

  /// له څو ناسمو هڅو وروسته حساب لنډ مهال بندېږي —
  /// چې څوک پاسورډ په ازموینه ونه مومي.
  static const int _maxAttempts = 5;
  static const Duration _lockFor = Duration(minutes: 10);

  Future<SignInResult> signIn(String username, String password) async {
    final user =
        await (db.select(db.appUsers)
              ..where((u) => u.username.equals(username.trim()))
              ..where((u) => u.isActive.equals(true))
              ..limit(1))
            .getSingleOrNull();

    if (user == null) {
      // د وخت هماغه لګښت چې د موجود کارن لپاره لګېږي — چې د ځواب
      // له چټکتیا معلومه نه شي چې دا کارن نوم شته که نه.
      Password.hash(password: password, salt: Password.newSalt());
      return const SignInWrong();
    }

    final locked = user.lockedUntil;
    if (locked != null && locked.isAfter(DateTime.now())) {
      return SignInLocked(locked);
    }

    final ok = Password.verify(
      password: password,
      salt: user.passwordSalt,
      expectedHash: user.passwordHash,
      iterations: user.passwordIterations,
    );

    if (!ok) {
      final attempts = user.failedAttempts + 1;
      await (db.update(db.appUsers)..where((u) => u.id.equals(user.id))).write(
        AppUsersCompanion(
          failedAttempts: Value(attempts),
          lockedUntil: Value(
            attempts >= _maxAttempts ? DateTime.now().add(_lockFor) : null,
          ),
        ),
      );
      return const SignInWrong();
    }

    await (db.update(db.appUsers)..where((u) => u.id.equals(user.id))).write(
      AppUsersCompanion(
        failedAttempts: const Value(0),
        lockedUntil: const Value(null),
        lastLoginAt: Value(DateTime.now()),
      ),
    );

    await db
        .into(db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            action: 'login',
            entity: 'app_users',
            userId: Value(user.id),
            userName: Value(user.username),
            entityId: Value(user.id),
          ),
        );

    return SignInOk(
      Session(
        userId: user.id,
        username: user.username,
        fullName: user.fullName,
        role: user.role,
      ),
    );
  }

  Future<void> signOut(Session s) async {
    await db
        .into(db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            action: 'logout',
            entity: 'app_users',
            userId: Value(s.userId),
            userName: Value(s.username),
            entityId: Value(s.userId),
          ),
        );
  }

  /// د لومړي مدیر جوړول — یوازې د ویزارډ له خوا بلل کېږي.
  Future<int> createUser({
    required String username,
    required String fullName,
    required String password,
    required String role,
  }) async {
    final salt = Password.newSalt();
    return db
        .into(db.appUsers)
        .insert(
          AppUsersCompanion.insert(
            username: username,
            fullName: fullName,
            passwordHash: Password.hash(password: password, salt: salt),
            passwordSalt: salt,
            role: role,
          ),
        );
  }
}
