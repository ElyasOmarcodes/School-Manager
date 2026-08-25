import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// د تړل شوي ښوونځي معلومات — د اپ په حافظه کې پاتې کېږي.
///
/// **ولې فایل، نه ډیټابیس؟** دا شپږ ساحې دي چې یوازې د پیل پر مهال
/// لوستل کېږي. یو SQLite جدول به يې لپاره ډېر و. کله چې بې‌انټرنټه
/// کیش راشي (د حاضرۍ تاریخچه، پیغامونه)، هغه به drift ته ځي — خو
/// توکن به همدلته پاتې وي.
class SchoolSession {
  /// «http://192.168.1.14:8787»
  final String baseUrl;
  final String token;

  /// `manager` | `parent`
  final String role;
  final String school;
  final String deviceName;
  final int? guardianId;
  final String? guardianName;

  const SchoolSession({
    required this.baseUrl,
    required this.token,
    required this.role,
    required this.school,
    required this.deviceName,
    this.guardianId,
    this.guardianName,
  });

  bool get isManager => role == 'manager';
  bool get isParent => role == 'parent';

  Map<String, dynamic> toJson() => {
    'baseUrl': baseUrl,
    'token': token,
    'role': role,
    'school': school,
    'deviceName': deviceName,
    'guardianId': guardianId,
    'guardianName': guardianName,
  };

  factory SchoolSession.fromJson(Map<String, dynamic> j) => SchoolSession(
    baseUrl: j['baseUrl'] as String,
    token: j['token'] as String,
    role: j['role'] as String,
    school: j['school'] as String? ?? '',
    deviceName: j['deviceName'] as String? ?? '',
    guardianId: (j['guardianId'] as num?)?.toInt(),
    guardianName: j['guardianName'] as String?,
  );
}

class SessionStore {
  static const _fileName = 'session.json';
  File? _cached;

  Future<File> _file() async {
    if (_cached != null) return _cached!;
    final dir = await getApplicationSupportDirectory();
    if (!await dir.exists()) await dir.create(recursive: true);
    return _cached = File(p.join(dir.path, _fileName));
  }

  Future<SchoolSession?> load() async {
    try {
      final f = await _file();
      if (!await f.exists()) return null;
      final raw = await f.readAsString();
      if (raw.trim().isEmpty) return null;
      return SchoolSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      // خراب فایل نباید اپ ودروي — له سره تړل کوو.
      return null;
    }
  }

  Future<void> save(SchoolSession s) async {
    final f = await _file();
    final tmp = File('${f.path}.tmp');
    await tmp.writeAsString(jsonEncode(s.toJson()), flush: true);
    await tmp.rename(f.path);
  }

  Future<void> clear() async {
    final f = await _file();
    if (await f.exists()) await f.delete();
  }
}
