import 'dart:async';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/tone.dart';

/// **د کیمرې له لارې د QR لوستل.**
///
/// **دا ولې د USB سکینر تر څنګ پکار ده؟**
/// یو USB سکینر ~۱۵۰۰ افغانۍ دی، خو هر ښوونځی يې نه لري — او کله
/// چې خراب شي، حاضري نه دریږي. هر لپټاپ کیمره لري. دا لار ورو ده
/// (هر لوستل یو کلیک)، خو د اړتیا پر مهال کار کوي.
///
/// **ولې دوامداره سکین نه؟** ځکه چې `camera_windows` د تصویر
/// جریان (image stream) نه ورکوي — یوازې `takePicture`. نو د هرې
/// څو ثانیو یو عکس اخلو او هغه ډیکوډ کوو. دا په یوه isolate کې
/// کېږي، نو پرده نه ټکېږي.
class CameraScanPanel extends StatefulWidget {
  /// کله چې یو QR ولوستل شي — متن يې راځي.
  final ValueChanged<String> onCode;

  /// د دوو لوستلو ترمنځ لږ تر لږه واټن — چې یو کارت دوه ځله ونه
  /// لوستل شي.
  final Duration cooldown;

  const CameraScanPanel({
    super.key,
    required this.onCode,
    this.cooldown = const Duration(seconds: 3),
  });

  @override
  State<CameraScanPanel> createState() => _CameraScanPanelState();
}

class _CameraScanPanelState extends State<CameraScanPanel> {
  int? _cameraId;
  String? _error;
  Timer? _loop;
  bool _busy = false;

  String? _lastCode;
  DateTime? _lastAt;

  /// څو ځله يې تر اوسه لوستلي — د پردې لپاره یوه وړه نښه.
  int _reads = 0;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void dispose() {
    _loop?.cancel();
    final id = _cameraId;
    if (id != null) unawaited(CameraPlatform.instance.dispose(id));
    super.dispose();
  }

  Future<void> _start() async {
    try {
      final cams = await CameraPlatform.instance.availableCameras();
      if (cams.isEmpty) {
        if (mounted) setState(() => _error = 'هېڅ کیمره ونه موندل شوه.');
        return;
      }
      final id = await CameraPlatform.instance.createCameraWithSettings(
        cams.first,
        const MediaSettings(resolutionPreset: ResolutionPreset.high),
      );
      await CameraPlatform.instance.initializeCamera(id);
      if (!mounted) return;
      setState(() => _cameraId = id);

      // **دوه ځله په ثانیه کې.** له دې څخه ګړندی، ډیکوډ به له
      // عکس اخیستلو وروسته نه و بشپړ شوی او کتار به جوړ شوی و.
      _loop = Timer.periodic(const Duration(milliseconds: 500), (_) => _tick());
    } catch (e) {
      if (mounted) setState(() => _error = 'کیمره نه پرانیستل کېږي: $e');
    }
  }

  Future<void> _tick() async {
    final id = _cameraId;
    if (id == null || _busy || !mounted) return;
    _busy = true;
    try {
      final file = await CameraPlatform.instance.takePicture(id);
      final bytes = await file.readAsBytes();
      final code = await decodeQrFromImage(bytes);
      if (code != null) _accept(code);
    } catch (_) {
      // یو ناکام چوکاټ ستونزه نه ده — راتلونکی به يې ونیسي.
    } finally {
      _busy = false;
    }
  }

  void _accept(String code) {
    final now = DateTime.now();
    // هماغه کارت چې لا د سړېدو په وخت کې وي — پرېږده.
    if (_lastCode == code &&
        _lastAt != null &&
        now.difference(_lastAt!) < widget.cooldown) {
      return;
    }
    _lastCode = code;
    _lastAt = now;
    if (mounted) setState(() => _reads++);
    unawaited(Tone.play(Tone.accept));
    widget.onCode(code);
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final s = S.of(context);

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.warning.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              size: 20,
              color: AppColors.warning,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$_error\nد USB سکینر یا لاسي آی‌ډي لا هم کار کوي.',
                style: TextStyle(fontSize: 12.5, color: p.muted),
              ),
            ),
          ],
        ),
      );
    }

    if (_cameraId == null) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: CameraPlatform.instance.buildPreview(_cameraId!),
          ),
          // د نښې چوکاټ — چې کارن پوه شي کارت چېرې ونیسي.
          IgnorePointer(
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.8),
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 10,
            start: 10,
            child: AnimatedContainer(
              duration: AppMotion.fast,
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _reads == 0
                    ? 'کارت د چوکاټ مخې ته ونیسئ'
                    : '${s.locale.num(_reads)} لوستل شوي',
                style: const TextStyle(fontSize: 11.5, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// یو عکس ډیکوډ کوي — که QR پکې وي، متن يې راګرځوي.
///
/// **دا ولې پر جلا isolate کې ځغلي؟** ځکه چې د ۱۲۸۰×۹۶۰ عکس ډیکوډ
/// کول ~۸۰ms نیسي. که په اصلي thread کې وای، پرده به هرې نیمې
/// ثانیې ټکېده — او هغه هم په هغه پاڼه کې چې د یوې ثانیې دننه
/// څو سکینه مني.
Future<String?> decodeQrFromImage(Uint8List bytes) async {
  try {
    return await Isolate.run(() => decodeQrSync(bytes));
  } catch (_) {
    return null;
  }
}

/// د ډیکوډ همغږې برخه — **د ازموینې لپاره عامه ده**.
///
/// له کیمرې پرته يې هم پرتله کولی شو: یو QR جوړوو، عکس ترې اخلو،
/// او دلته يې بېرته لولو. که یوازې د `Isolate.run` تر شا وای،
/// ازموینه به يې نه شوه کولی.
String? decodeQrSync(Uint8List bytes) {
  // **د خرابو بایټونو څخه ساتنه.** د کیمرې یو نیمګړی چوکاټ (یا یو
  // فایل چې لا په لیکلو کې دی) د `image` کڅوړې دننه استثنا غورځوي.
  // یو ناکام چوکاټ د حاضرۍ د درېدو ارزښت نه لري.
  final img.Image? decoded;
  try {
    decoded = img.decodeImage(bytes);
  } catch (_) {
    return null;
  }
  if (decoded == null) return null;

  // ZXing د ARGB ints لیست غواړي، نه د `image` کڅوړې پیکسل.
  final pixels = Int32List(decoded.width * decoded.height);
  var i = 0;
  for (var y = 0; y < decoded.height; y++) {
    for (var x = 0; x < decoded.width; x++) {
      final p = decoded.getPixel(x, y);
      pixels[i++] =
          (0xFF << 24) |
          (p.r.toInt() << 16) |
          (p.g.toInt() << 8) |
          p.b.toInt();
    }
  }

  final source = RGBLuminanceSource(decoded.width, decoded.height, pixels);
  final bitmap = BinaryBitmap(HybridBinarizer(source));
  try {
    return QRCodeReader().decode(bitmap).text;
  } catch (_) {
    // هېڅ QR نشته — دا یوه عادي پایله ده، نه تېروتنه.
    return null;
  }
}
