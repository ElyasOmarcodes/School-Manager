import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// د پروګرام تنظیمات چې **له ډیټابیس څخه بهر** ساتل کېږي.
///
/// ولې بهر؟ ځکه چې د ډیټابیس مسیر پخپله دلته دی — که دننه وای،
/// پروګرام به يې د لوستلو لپاره لومړی ډیټابیس ته اړتیا درلوده.
///
/// ځای: د عامل سیسټم د تنظیماتو پوښۍ —
///   Windows: %APPDATA%\school_manager\config.json
///   Linux:   ~/.config/school_manager/config.json
///   macOS:   ~/Library/Application Support/school_manager/config.json
class AppConfig {
  /// د SQLite فایل بشپړ مسیر. که `null` وي، لومړی ران دی.
  final String? databasePath;

  /// د بیک‌اپ دویم ځای (USB یا شبکه) — اختیاري.
  final String? backupPath;

  /// `ps` | `fa` | `en`
  final String locale;

  /// `system` | `light` | `dark`
  final String themeMode;

  /// `jalali` | `gregorian` | `hijri`
  final String calendar;

  /// ایا د لومړي ران ویزارډ بشپړ شوی؟
  final bool setupComplete;

  const AppConfig({
    this.databasePath,
    this.backupPath,
    this.locale = 'ps',
    this.themeMode = 'system',
    this.calendar = 'jalali',
    this.setupComplete = false,
  });

  AppConfig copyWith({
    String? databasePath,
    String? backupPath,
    String? locale,
    String? themeMode,
    String? calendar,
    bool? setupComplete,
  }) {
    return AppConfig(
      databasePath: databasePath ?? this.databasePath,
      backupPath: backupPath ?? this.backupPath,
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      calendar: calendar ?? this.calendar,
      setupComplete: setupComplete ?? this.setupComplete,
    );
  }

  Map<String, dynamic> toJson() => {
    'databasePath': databasePath,
    'backupPath': backupPath,
    'locale': locale,
    'themeMode': themeMode,
    'calendar': calendar,
    'setupComplete': setupComplete,
  };

  factory AppConfig.fromJson(Map<String, dynamic> j) => AppConfig(
    databasePath: j['databasePath'] as String?,
    backupPath: j['backupPath'] as String?,
    locale: j['locale'] as String? ?? 'ps',
    themeMode: j['themeMode'] as String? ?? 'system',
    calendar: j['calendar'] as String? ?? 'jalali',
    setupComplete: j['setupComplete'] as bool? ?? false,
  );
}

/// د تنظیماتو د فایل لوستل او لیکل.
class ConfigStore {
  static const _fileName = 'config.json';
  static const _appDirName = 'school_manager';

  File? _cached;

  Future<File> _file() async {
    if (_cached != null) return _cached!;
    final base = await getApplicationSupportDirectory();
    final dir = Directory(p.join(base.path, _appDirName));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return _cached = File(p.join(dir.path, _fileName));
  }

  /// د تنظیماتو د فایل مسیر — د تنظیماتو په پاڼه کې ښودل کېږي.
  Future<String> configFilePath() async => (await _file()).path;

  Future<AppConfig> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return const AppConfig();
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return const AppConfig();
      return AppConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      // خراب فایل نباید پروګرام ودروي — له سره پیل کوو.
      return const AppConfig();
    }
  }

  Future<void> save(AppConfig cfg) async {
    final f = await _file();
    // لومړی موقت فایل ته لیکو بیا يې بدلوو — چې د برېښنا په تللو
    // سره تنظیمات نیم‌لیکل شوي پاتې نه شي.
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(
      const JsonEncoder.withIndent('  ').convert(cfg.toJson()),
      flush: true,
    );
    await tmp.rename(f.path);
  }
}

/// د یوې ټاکل شوې پوښۍ ازموینه — مخکې له دې چې کارن مخې ته ولاړ شي.
class PathCheck {
  final bool ok;
  final String? errorKey;
  final int? freeBytes;

  const PathCheck._(this.ok, this.errorKey, this.freeBytes);

  const PathCheck.ok(int? free) : this._(true, null, free);
  const PathCheck.fail(String key) : this._(false, key, null);

  /// ازمويي چې پوښۍ شته، د لیکلو وړ ده، او بس‌بس ځای لري.
  static Future<PathCheck> inspect(String dirPath) async {
    final dir = Directory(dirPath);

    if (!await dir.exists()) {
      try {
        await dir.create(recursive: true);
      } catch (_) {
        return const PathCheck.fail('pathCannotCreate');
      }
    }

    // د لیکلو ریښتینې ازموینه — د اجازو په پوښتلو باور نه کوو،
    // ځکه چې په ویندوز کې د شبکې ډرایو دروغ وايي.
    final probe = File(p.join(dirPath, '.sm_write_test'));
    try {
      await probe.writeAsString('ok', flush: true);
      await probe.delete();
    } catch (_) {
      return const PathCheck.fail('pathNotWritable');
    }

    return PathCheck.ok(await _freeSpace(dirPath));
  }

  /// د پاتې ځای اټکل. که ونه شي، `null` راګرځوي — دا کږه نه ده،
  /// یوازې د معلوماتو لپاره ده.
  static Future<int?> _freeSpace(String dirPath) async {
    try {
      if (Platform.isWindows) {
        final r = await Process.run('cmd', ['/c', 'dir', '/-c', dirPath]);
        final m = RegExp(r'(\d+)\s+bytes free').firstMatch(r.stdout.toString());
        return m == null ? null : int.tryParse(m.group(1)!);
      }
      final r = await Process.run('df', ['-kP', dirPath]);
      final lines = r.stdout.toString().trim().split('\n');
      if (lines.length < 2) return null;
      final cols = lines[1].split(RegExp(r'\s+'));
      if (cols.length < 4) return null;
      final kb = int.tryParse(cols[3]);
      return kb == null ? null : kb * 1024;
    } catch (_) {
      return null;
    }
  }
}
