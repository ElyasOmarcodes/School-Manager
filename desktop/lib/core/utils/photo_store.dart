import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// د شاګردانو د انځورونو ذخیره — **د ډیټابیس تر څنګ**.
///
/// **ولې انځور په ډیټابیس کې نه ساتو؟**
/// د ۸۵۰ شاګردانو انځورونه ~۱۵۰MB دي. که په SQLite کې وای، هر
/// بیک‌اپ به ۱۵۰MB و، هر لوستل به يې حافظې ته راووړ، او د WAL
/// فایل به لوی شوی و. د فایل مسیر یوازې څو بایټه دی؛ فایل خپله د
/// ډیټابیس تر څنګ په یوه پوښۍ کې پروت دی، نو بیک‌اپ او کاپي کول
/// دواړه ساده دي.
///
/// جوړښت:
/// ```
/// <د ډیټابیس پوښۍ>/photos/students/1405-0423.jpg
/// ```
/// نوم د داخلې نمبر دی، نه د ډیټابیس id — نو که چا په لاس پوښۍ
/// پرانیسته، پوهېږي چې کوم انځور د چا دی.
class PhotoStore {
  /// د ډیټابیس د فایل مسیر — پوښۍ ترې اخیستل کېږي.
  final String databasePath;

  const PhotoStore(this.databasePath);

  Directory get root =>
      Directory(p.join(p.dirname(databasePath), 'photos', 'students'));

  /// د یوه شاګرد د انځور مسیر — که وي.
  File? find(String admissionNo) {
    if (!root.existsSync()) return null;
    for (final ext in const ['jpg', 'jpeg', 'png']) {
      final f = File(p.join(root.path, '$admissionNo.$ext'));
      if (f.existsSync()) return f;
    }
    return null;
  }

  /// یو بهرنی فایل د ډیټابیس پوښۍ ته کاپي کوي او نوی مسیر راګرځوي.
  ///
  /// **کاپي، نه تړاو.** که يې یوازې مسیر ساتلی وای، کارن به د خپل
  /// ډیسکټاپ انځور غوره کړی و او سبا يې چې ړنګ کړ، پروفایل به تش
  /// شوی و. کاپي کول دا ډاډ ورکوي چې ډیټابیس بشپړ دی.
  Future<String> saveFile(String admissionNo, File source) async {
    final ext = p.extension(source.path).toLowerCase().replaceFirst('.', '');
    final safe = const {'jpg', 'jpeg', 'png'}.contains(ext) ? ext : 'jpg';
    return _write(admissionNo, safe, await source.readAsBytes());
  }

  /// د کیمرې څخه راغلي خام بایټونه ساتي.
  Future<String> saveBytes(
    String admissionNo,
    Uint8List bytes, {
    String ext = 'jpg',
  }) => _write(admissionNo, ext, bytes);

  Future<String> _write(String admissionNo, String ext, List<int> bytes) async {
    await root.create(recursive: true);

    // زاړه بڼې پاکوو — که نه، یو شاګرد به دوه انځوره درلودل
    // (`.png` او `.jpg`) او `find()` به تل لومړی موندلی.
    for (final old in const ['jpg', 'jpeg', 'png']) {
      if (old == ext) continue;
      final f = File(p.join(root.path, '$admissionNo.$old'));
      if (f.existsSync()) await f.delete();
    }

    final target = File(p.join(root.path, '$admissionNo.$ext'));
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  Future<void> remove(String admissionNo) async {
    final f = find(admissionNo);
    if (f != null) await f.delete();
  }

  /// کله چې د داخلې نمبر بدل شي، انځور هم ورسره ځي.
  Future<String?> rename(String from, String to) async {
    final f = find(from);
    if (f == null) return null;
    final target = p.join(root.path, '$to${p.extension(f.path)}');
    final moved = await f.rename(target);
    return moved.path;
  }
}
