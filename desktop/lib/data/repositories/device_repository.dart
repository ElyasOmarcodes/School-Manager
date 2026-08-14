import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';

import '../db/database.dart';

/// د تړل شوي وسیلې پېژندنه — چې API ته ورکړل شوې غوښتنه چا کړې.
class DeviceIdentity {
  final Device device;
  final String role;
  final int? userId;
  final int? guardianId;

  const DeviceIdentity({
    required this.device,
    required this.role,
    this.userId,
    this.guardianId,
  });

  bool get isManager => role == 'manager';
  bool get isParent => role == 'parent';
}

/// د تړلو پایله — هغه څه چې تلیفون ته ورکول کېږي.
class PairResult {
  /// خام توکن — **یوازې همدا یو ځل ښکاري.** په ډیټابیس کې يې
  /// hash پاتې کېږي.
  final String token;
  final Device device;
  final String? guardianName;

  const PairResult({
    required this.token,
    required this.device,
    this.guardianName,
  });
}

sealed class RedeemResult {
  const RedeemResult();
}

class RedeemOk extends RedeemResult {
  final PairResult pair;
  const RedeemOk(this.pair);
}

/// کوډ نشته یا مخکې کارول شوی.
class RedeemUnknown extends RedeemResult {
  const RedeemUnknown();
}

class RedeemExpired extends RedeemResult {
  final DateTime expiredAt;
  const RedeemExpired(this.expiredAt);
}

/// د تلیفونونو، کوډونو او توکنونو مدیریت.
class DeviceRepository {
  final AppDatabase db;
  DeviceRepository(this.db);

  /// **ولې دا توري؟** `0/O`، `1/I/L` او `8/B` په لاس‌لیکل شوي کوډ
  /// کې سره ګډېږي. مدیر کوډ په کاغذ لیکي یا يې په تلیفون وايي —
  /// نو هغه توري چې غلط اورېدل کېږي، له سره نه کاروو.
  static const String _alphabet = 'ACDEFGHJKMNPQRTUVWXY2346789';

  static const Duration codeLifetime = Duration(minutes: 15);

  final Random _rng = Random.secure();

  // ── کوډونه ──────────────────────────────────────────────

  /// د تړلو نوی کوډ جوړوي.
  ///
  /// د یوه سرپرست لپاره یوازې یو ژوندی کوډ پاتې کېږي — که مدیر
  /// دوه ځله کېکاږي، زوړ باطلېږي. دا د دې مخنیوی کوي چې د یوه
  /// کور دوه بېل کوډونه په لاس کې وي او څوک ونه پوهېږي کوم يې کار کوي.
  Future<PairingCode> createCode({
    required String role,
    int? userId,
    int? guardianId,
    int? createdByUserId,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();

    await (db.update(db.pairingCodes)
          ..where((c) => c.usedAt.isNull())
          ..where(
            (c) => guardianId != null
                ? c.guardianId.equals(guardianId)
                : c.userId.equals(userId ?? -1),
          ))
        .write(PairingCodesCompanion(expiresAt: Value(at)));

    // د ټکر امکان ډېر لږ دی، خو صفر نه دی — نو تر لسو ځله هڅه.
    for (var attempt = 0; attempt < 10; attempt++) {
      final code = _newCode();
      final clash =
          await (db.select(db.pairingCodes)
                ..where((c) => c.code.equals(code))
                ..limit(1))
              .getSingleOrNull();
      if (clash != null) continue;

      final id = await db
          .into(db.pairingCodes)
          .insert(
            PairingCodesCompanion.insert(
              code: code,
              role: role,
              userId: Value(userId),
              guardianId: Value(guardianId),
              expiresAt: at.add(codeLifetime),
              createdByUserId: Value(createdByUserId),
            ),
          );
      return (db.select(db.pairingCodes)..where((c) => c.id.equals(id)))
          .getSingle();
    }
    throw StateError('د تړلو کوډ ونه جوړېد — ډېر ټکرونه.');
  }

  String _newCode() {
    final b = StringBuffer();
    for (var i = 0; i < 6; i++) {
      b.write(_alphabet[_rng.nextInt(_alphabet.length)]);
    }
    return b.toString();
  }

  /// د کوډ مصرفول — تلیفون يې لېږي، دایمي توکن اخلي.
  Future<RedeemResult> redeem({
    required String code,
    required String deviceName,
    String platform = 'android',
    String? pushToken,
    String? ip,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final normalized = code.trim().toUpperCase().replaceAll(
      RegExp(r'[\s\-]'),
      '',
    );

    final row =
        await (db.select(db.pairingCodes)
              ..where((c) => c.code.equals(normalized))
              ..limit(1))
            .getSingleOrNull();

    if (row == null || row.usedAt != null) return const RedeemUnknown();
    if (row.expiresAt.isBefore(at)) return RedeemExpired(row.expiresAt);

    final token = newToken();
    final device = await db.transaction(() async {
      final id = await db
          .into(db.devices)
          .insert(
            DevicesCompanion.insert(
              name: deviceName.trim().isEmpty ? 'وسیله' : deviceName.trim(),
              platform: Value(platform),
              role: row.role,
              userId: Value(row.userId),
              guardianId: Value(row.guardianId),
              tokenHash: hashToken(token),
              pushToken: Value(pushToken),
              pairedAt: Value(at),
              lastSeenAt: Value(at),
              lastIp: Value(ip),
            ),
          );

      await (db.update(db.pairingCodes)..where((c) => c.id.equals(row.id)))
          .write(
            PairingCodesCompanion(
              usedAt: Value(at),
              usedByDeviceId: Value(id),
            ),
          );

      await db
          .into(db.auditLogs)
          .insert(
            AuditLogsCompanion.insert(
              action: 'create',
              entity: 'devices',
              entityId: Value(id),
              userId: Value(row.createdByUserId),
              changesJson: Value(
                jsonEncode({'role': row.role, 'name': deviceName}),
              ),
            ),
          );

      return (db.select(db.devices)..where((d) => d.id.equals(id))).getSingle();
    });

    String? guardianName;
    if (device.guardianId != null) {
      final g =
          await (db.select(db.guardians)
                ..where((g) => g.id.equals(device.guardianId!)))
              .getSingleOrNull();
      guardianName = g?.fullName;
    }

    return RedeemOk(
      PairResult(token: token, device: device, guardianName: guardianName),
    );
  }

  // ── توکنونه ─────────────────────────────────────────────

  static String newToken() {
    final rng = Random.secure();
    final bytes = Uint8List(32);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  static String hashToken(String token) =>
      sha256.convert(utf8.encode(token)).toString();

  /// د غوښتنې توکن پېژني. که باطل، ورک، یا ناسم وي — `null`.
  ///
  /// **د وخت نښه هم دلته تازه کېږي** خو یوازې که تر یوې دقیقې
  /// زړه وي. که هره غوښتنه لیکل ترسره کړي، د تلیفون هر پنځه ثانیې
  /// polling به ډیټابیس ته بې‌ځایه لیکنه واړوي.
  Future<DeviceIdentity?> authenticate(
    String? token, {
    String? ip,
    DateTime? now,
  }) async {
    if (token == null || token.isEmpty) return null;
    final at = now ?? DateTime.now();

    final device =
        await (db.select(db.devices)
              ..where((d) => d.tokenHash.equals(hashToken(token)))
              ..where((d) => d.revokedAt.isNull())
              ..limit(1))
            .getSingleOrNull();

    if (device == null) return null;

    final seen = device.lastSeenAt;
    if (seen == null || at.difference(seen).inSeconds > 60) {
      await (db.update(db.devices)..where((d) => d.id.equals(device.id))).write(
        DevicesCompanion(lastSeenAt: Value(at), lastIp: Value(ip)),
      );
    }

    return DeviceIdentity(
      device: device,
      role: device.role,
      userId: device.userId,
      guardianId: device.guardianId,
    );
  }

  // ── مدیریت ──────────────────────────────────────────────

  Future<List<Device>> list({bool includeRevoked = false}) {
    final q = db.select(db.devices)
      ..orderBy([(d) => OrderingTerm.desc(d.pairedAt)]);
    if (!includeRevoked) q.where((d) => d.revokedAt.isNull());
    return q.get();
  }

  Future<void> revoke(int deviceId, {int? byUserId}) async {
    await (db.update(db.devices)..where((d) => d.id.equals(deviceId))).write(
      DevicesCompanion(revokedAt: Value(DateTime.now())),
    );
    await db
        .into(db.auditLogs)
        .insert(
          AuditLogsCompanion.insert(
            action: 'delete',
            entity: 'devices',
            entityId: Value(deviceId),
            userId: Value(byUserId),
          ),
        );
  }

  Future<void> setPushToken(int deviceId, String pushToken) {
    return (db.update(db.devices)..where((d) => d.id.equals(deviceId))).write(
      DevicesCompanion(pushToken: Value(pushToken)),
    );
  }

  /// هغه ژوندي کوډونه چې لا نه دي کارول شوي — د تنظیماتو پاڼه يې ښیي.
  Future<List<PairingCode>> activeCodes({DateTime? now}) {
    final at = now ?? DateTime.now();
    return (db.select(db.pairingCodes)
          ..where((c) => c.usedAt.isNull())
          ..where((c) => c.expiresAt.isBiggerThanValue(at))
          ..orderBy([(c) => OrderingTerm.desc(c.createdAt)]))
        .get();
  }
}
