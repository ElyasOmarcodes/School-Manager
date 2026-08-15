import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera_platform_interface/camera_platform_interface.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/photo_store.dart';

/// د شاګرد د انځور اخیستل — **له فایل او له کیمرې دواړو**.
///
/// **دا ولې دوه لارې لري؟** ځکه چې دوه بېل حالتونه دي. کله چې مدیر
/// د زاړه ریکارډ انځورونه سکن کړي وي، هغه فایلونه دي. خو کله چې یو
/// نوی شاګرد د دفتر پر مخ ولاړ وي، د کیمرې تڼۍ له فایل موندلو ډېره
/// ګړندۍ ده — یو کلیک، بس.
///
/// دواړه لارې د ډیټابیس پوښۍ ته کاپي کوي؛ هېڅ بهرنی مسیر نه ساتل
/// کېږي.
Future<String?> pickStudentPhoto(
  BuildContext context, {
  required PhotoStore store,
  required String admissionNo,
}) async {
  final choice = await showDialog<String>(
    context: context,
    builder: (ctx) {
      final s = S.of(ctx);
      return SimpleDialog(
        title: Text(
          s.photo,
          style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
        ),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'file'),
            child: Row(
              children: [
                const Icon(Icons.folder_open_rounded, size: 19),
                const SizedBox(width: 11),
                Text(s.fromFile),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'camera'),
            child: Row(
              children: [
                const Icon(Icons.photo_camera_rounded, size: 19),
                const SizedBox(width: 11),
                Text(s.fromCamera),
              ],
            ),
          ),
        ],
      );
    },
  );

  if (choice == 'file') {
    const group = XTypeGroup(
      label: 'انځورونه',
      extensions: ['jpg', 'jpeg', 'png'],
    );
    final file = await openFile(acceptedTypeGroups: [group]);
    if (file == null) return null;
    return store.saveFile(admissionNo, File(file.path));
  }

  if (choice == 'camera' && context.mounted) {
    final bytes = await showDialog<Uint8List>(
      context: context,
      builder: (_) => const _CameraDialog(),
    );
    if (bytes == null) return null;
    return store.saveBytes(admissionNo, bytes);
  }

  return null;
}

// ═══════════════════════════════════════════════════════════
//  د کیمرې ډیالوګ
// ═══════════════════════════════════════════════════════════

class _CameraDialog extends StatefulWidget {
  const _CameraDialog();

  @override
  State<_CameraDialog> createState() => _CameraDialogState();
}

class _CameraDialogState extends State<_CameraDialog> {
  int? _cameraId;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      final cameras = await CameraPlatform.instance.availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'هېڅ کیمره ونه موندل شوه.');
        return;
      }
      final id = await CameraPlatform.instance.createCameraWithSettings(
        cameras.first,
        const MediaSettings(resolutionPreset: ResolutionPreset.high),
      );
      await CameraPlatform.instance.initializeCamera(id);
      if (!mounted) return;
      setState(() => _cameraId = id);
    } catch (e) {
      // **کیمره یوه اسانتیا ده، نه یو شرط.** که سیسټم يې و نه لري
      // یا اجازه ورنکړي، کارن باید بیا هم د فایل له لارې انځور
      // کېښودی شي — نو دلته یوازې پیغام ښیو.
      if (mounted) setState(() => _error = 'کیمره نه پرانیستل کېږي: $e');
    }
  }

  @override
  void dispose() {
    final id = _cameraId;
    if (id != null) {
      unawaited(CameraPlatform.instance.dispose(id));
    }
    super.dispose();
  }

  Future<void> _shoot() async {
    final id = _cameraId;
    if (id == null || _busy) return;
    setState(() => _busy = true);
    try {
      final file = await CameraPlatform.instance.takePicture(id);
      final bytes = await file.readAsBytes();
      if (mounted) Navigator.pop(context, bytes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'انځور وانه خیستل شو: $e';
          _busy = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return AlertDialog(
      title: Text(
        s.fromCamera,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 480,
        height: 340,
        child: _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.videocam_off_rounded,
                      size: 34,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: p.muted),
                    ),
                  ],
                ),
              )
            : _cameraId == null
            ? const Center(child: CircularProgressIndicator())
            : ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                child: CameraPlatform.instance.buildPreview(_cameraId!),
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
        FilledButton.icon(
          onPressed: _cameraId == null || _busy ? null : _shoot,
          icon: const Icon(Icons.camera_rounded, size: 17),
          label: const Text('انځور واخله'),
        ),
      ],
    );
  }
}
