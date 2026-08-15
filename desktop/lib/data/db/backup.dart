import 'dart:io';

import 'package:path/path.dart' as p;

import 'database.dart';

/// یو ساتل شوی بیک‌اپ فایل.
class BackupFile {
  final String path;
  final DateTime takenAt;
  final int bytes;

  const BackupFile({
    required this.path,
    required this.takenAt,
    required this.bytes,
  });

  String get name => p.basename(path);

  String get sizeLabel {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

sealed class BackupResult {
  const BackupResult();
}

class BackupOk extends BackupResult {
  final BackupFile file;
  const BackupOk(this.file);
}

class BackupFailed extends BackupResult {
  final String reason;
  const BackupFailed(this.reason);
}

/// د ډیټابیس بیک‌اپ او بیرته راوستل.
///
/// **دا ولې یوه ساده فایل کاپي نه ده؟**
///
/// ډیټابیس **WAL** حالت کاروي — نو وروستي بدلونونه ښايي لا هم په
/// `school.db-wal` کې وي، نه په `school.db` کې. که یوازې اصلي فایل
/// کاپي شي، د نن ورځې حاضري به پکې نه وه — او څوک به پرې نه پوهېده
/// ترڅو چې ورته اړتیا پیدا شي.
///
/// نو مخکې له کاپي کولو `wal_checkpoint(TRUNCATE)` ځغلوو، چې ټول
/// بدلونونه اصلي فایل ته ولېږدېږي.
class DatabaseBackup {
  const DatabaseBackup._();

  static const String prefix = 'school-backup-';

  /// یو بیک‌اپ اخلي او مسیر يې راګرځوي.
  static Future<BackupResult> create({
    required AppDatabase db,
    required String databasePath,
    required String targetDir,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();

    try {
      final source = File(databasePath);
      if (!await source.exists()) {
        return const BackupFailed('د ډیټابیس فایل ونه موندل شو.');
      }

      // **تر ټولو مهم ګام.** پرته له دې، وروستي بدلونونه له
      // بیک‌اپ څخه بهر پاتې کېږي.
      await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');

      final dir = Directory(targetDir);
      if (!await dir.exists()) await dir.create(recursive: true);

      final stamp =
          '${at.year}${_pad(at.month)}${_pad(at.day)}-'
          '${_pad(at.hour)}${_pad(at.minute)}${_pad(at.second)}';
      final target = p.join(dir.path, '$prefix$stamp.db');

      await source.copy(target);

      // **کاپي پخپله بس نه ده.** یوه نیمګړې کاپي (ډیسک ډک شو،
      // USB وایستل شو) به یو خراب فایل پرېښود چې مدیر به يې
      // بیک‌اپ ګاڼه. نو دلته يې ازمویو.
      if (!DatabaseFile.isValidSqlite(target)) {
        await File(target).delete();
        return const BackupFailed(
          'کاپي نیمګړې وه — ښايي ځای نه وي یا ډرایو وایستل شوی.',
        );
      }

      final stat = await File(target).stat();
      return BackupOk(
        BackupFile(path: target, takenAt: at, bytes: stat.size),
      );
    } on FileSystemException catch (e) {
      return BackupFailed('لیکل ونه شول: ${e.osError?.message ?? e.message}');
    } on Object catch (e) {
      return BackupFailed('$e');
    }
  }

  /// د یوې پوښۍ بیک‌اپونه — نوی مخکې.
  static Future<List<BackupFile>> list(String dir) async {
    final d = Directory(dir);
    if (!await d.exists()) return const [];

    final out = <BackupFile>[];
    await for (final e in d.list()) {
      if (e is! File) continue;
      final name = p.basename(e.path);
      if (!name.startsWith(prefix) || !name.endsWith('.db')) continue;

      final stat = await e.stat();
      out.add(
        BackupFile(
          path: e.path,
          takenAt: stat.modified,
          bytes: stat.size,
        ),
      );
    }
    out.sort((a, b) => b.takenAt.compareTo(a.takenAt));
    return out;
  }

  /// زاړه بیک‌اپونه پاکوي — یوازې وروستي `keep` پاتې کېږي.
  ///
  /// **ولې پخپله؟** ځکه چې د ورځې یو بیک‌اپ په یوه کال کې ۳۶۵
  /// فایلونه دي. یو مدیر يې نه پاکوي — بیا USB ډکېږي او بیک‌اپ
  /// غلی درېږي.
  static Future<int> prune(String dir, {int keep = 30}) async {
    final all = await list(dir);
    if (all.length <= keep) return 0;

    var removed = 0;
    for (final f in all.skip(keep)) {
      try {
        await File(f.path).delete();
        removed++;
      } on FileSystemException {
        // یو قفل شوی فایل نباید پاکول ودروي.
      }
    }
    return removed;
  }

  static String _pad(int v) => v.toString().padLeft(2, '0');
}
