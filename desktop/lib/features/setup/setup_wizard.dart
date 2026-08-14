import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../data/db/database.dart';

/// د لومړي ران ویزارډ.
///
/// څلور ګامونه: ژبه ← د ډیټابیس ځای ← د ښوونځي پېژندنه ← د مدیر حساب.
/// د هر ګام تر بشپړېدو مخکې «بل» بند وي — چې کارن نیمګړی مخې ته ولاړ نه شي.
class SetupWizard extends StatefulWidget {
  final AppConfig config;
  final void Function(AppLocale) onLocaleChanged;

  /// کله چې ویزارډ بشپړ شي — د ډیټابیس مسیر او د ښوونځي معلومات راګرځوي.
  final Future<void> Function(SetupResult) onComplete;

  const SetupWizard({
    super.key,
    required this.config,
    required this.onLocaleChanged,
    required this.onComplete,
  });

  @override
  State<SetupWizard> createState() => _SetupWizardState();
}

class SetupResult {
  final String databasePath;
  final bool openedExisting;
  final String schoolName;
  final String schoolKind;
  final String? address;
  final String? phone;
  final String calendar;
  final String dayStart;
  final String dayEnd;
  final int lateAfterMinutes;
  final String adminFullName;
  final String adminUsername;
  final String adminPassword;

  const SetupResult({
    required this.databasePath,
    required this.openedExisting,
    required this.schoolName,
    required this.schoolKind,
    required this.address,
    required this.phone,
    required this.calendar,
    required this.dayStart,
    required this.dayEnd,
    required this.lateAfterMinutes,
    required this.adminFullName,
    required this.adminUsername,
    required this.adminPassword,
  });
}

class _SetupWizardState extends State<SetupWizard> {
  int _step = 0;
  static const int _lastStep = 3;

  // ── ګام ۱: ډیټابیس ──────────────────────────────────────
  String? _folder;
  int? _freeBytes;
  String? _pathError;
  bool _openExisting = false;
  String? _existingFile;
  bool _checking = false;

  // ── ګام ۲: ښوونځی ───────────────────────────────────────
  final _schoolName = TextEditingController();
  final _address = TextEditingController();
  final _phone = TextEditingController();
  String _kind = 'school';
  String _calendar = 'jalali';
  String _dayStart = '07:30';
  String _dayEnd = '12:30';
  int _lateAfter = 15;

  // ── ګام ۳: مدیر ─────────────────────────────────────────
  final _adminName = TextEditingController();
  final _adminUser = TextEditingController(text: 'admin');
  final _adminPass = TextEditingController();
  final _adminPass2 = TextEditingController();
  String? _adminError;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _calendar = widget.config.calendar;
  }

  @override
  void dispose() {
    for (final c in [
      _schoolName,
      _address,
      _phone,
      _adminName,
      _adminUser,
      _adminPass,
      _adminPass2,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  // ═════════════════════════════════════════════════════════

  Future<void> _pickFolder() async {
    final dir = await getDirectoryPath();
    if (dir == null) return;

    setState(() {
      _checking = true;
      _pathError = null;
    });

    final check = await PathCheck.inspect(dir);
    if (!mounted) return;

    setState(() {
      _checking = false;
      if (check.ok) {
        _folder = dir;
        _freeBytes = check.freeBytes;
        _pathError = null;
      } else {
        _folder = null;
        _pathError = check.errorKey;
      }
    });
  }

  Future<void> _pickExistingFile() async {
    const group = XTypeGroup(
      label: 'SQLite',
      extensions: ['db', 'sqlite', 'sqlite3'],
    );
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null) return;

    // مهم: ازمويي چې دا ریښتیا یو SQLite ډیټابیس دی —
    // چې کارن تېروتنې سره کوم بل فایل ونه ټاکي.
    if (!DatabaseFile.isValidSqlite(file.path)) {
      if (!mounted) return;
      setState(() {
        _existingFile = null;
        _pathError = 'notASqliteFile';
      });
      return;
    }

    setState(() {
      _existingFile = file.path;
      _folder = p.dirname(file.path);
      _pathError = null;
    });
  }

  bool get _stepValid => switch (_step) {
        0 => _openExisting ? _existingFile != null : _folder != null,
        1 => _schoolName.text.trim().isNotEmpty,
        2 => _validateAdmin() == null,
        _ => true,
      };

  String? _validateAdmin() {
    final s = S.of(context);
    if (_adminName.text.trim().isEmpty) return s.fieldRequired;
    if (_adminUser.text.trim().length < 3) return s.fieldRequired;
    if (_adminPass.text.length < 8) return s.passwordTooShort;
    if (_adminPass.text != _adminPass2.text) return s.passwordMismatch;
    return null;
  }

  Future<void> _finish() async {
    final err = _validateAdmin();
    if (err != null) {
      setState(() => _adminError = err);
      return;
    }
    setState(() => _submitting = true);

    final dbPath = _openExisting
        ? _existingFile!
        : p.join(_folder!, DatabaseFile.fileName);

    await widget.onComplete(SetupResult(
      databasePath: dbPath,
      openedExisting: _openExisting,
      schoolName: _schoolName.text.trim(),
      schoolKind: _kind,
      address: _address.text.trim().isEmpty ? null : _address.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      calendar: _calendar,
      dayStart: _dayStart,
      dayEnd: _dayEnd,
      lateAfterMinutes: _lateAfter,
      adminFullName: _adminName.text.trim(),
      adminUsername: _adminUser.text.trim(),
      adminPassword: _adminPass.text,
    ));

    if (mounted) setState(() => _submitting = false);
  }

  // ═════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    final pal = context.palette;

    return Scaffold(
      backgroundColor: pal.ground,
      body: Row(
        children: [
          const _WizardSidebar(),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _StepDots(current: _step, total: _lastStep + 1),
                      const SizedBox(height: 28),
                      Flexible(
                        child: SingleChildScrollView(
                          child: AnimatedSwitcher(
                            duration: AppMotion.normal,
                            switchInCurve: AppMotion.standard,
                            transitionBuilder: (child, anim) => FadeTransition(
                              opacity: anim,
                              child: SlideTransition(
                                position: Tween(
                                  begin: const Offset(0.04, 0),
                                  end: Offset.zero,
                                ).animate(anim),
                                child: child,
                              ),
                            ),
                            child: KeyedSubtree(
                              key: ValueKey(_step),
                              child: _buildStep(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      _buildButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
        0 => _dbStep(),
        1 => _schoolStep(),
        2 => _adminStep(),
        _ => _doneStep(),
      };

  Widget _buildButtons() {
    final s = S.of(context);
    if (_step > _lastStep) return const SizedBox.shrink();

    return Row(
      children: [
        if (_step > 0)
          OutlinedButton(
            onPressed: _submitting ? null : () => setState(() => _step--),
            child: Text(s.back),
          ),
        const Spacer(),
        FilledButton(
          onPressed: (!_stepValid || _submitting)
              ? null
              : () {
                  if (_step == 2) {
                    _finish();
                  } else {
                    setState(() => _step++);
                  }
                },
          child: _submitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(_step == 2 ? s.finish : s.next),
        ),
      ],
    );
  }

  // ── ګام ۰: ډیټابیس ──────────────────────────────────────

  Widget _dbStep() {
    final s = S.of(context);
    final pal = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepHeader(title: s.stepDatabase, subtitle: s.stepDatabaseSub),
        const SizedBox(height: 22),
        Row(
          children: [
            Expanded(
              child: _ChoiceTile(
                selected: !_openExisting,
                icon: Icons.create_new_folder_rounded,
                label: s.createNew,
                color: AppColors.primary,
                onTap: () => setState(() {
                  _openExisting = false;
                  _pathError = null;
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceTile(
                selected: _openExisting,
                icon: Icons.folder_open_rounded,
                label: s.openExisting,
                color: AppColors.info,
                onTap: () => setState(() {
                  _openExisting = true;
                  _pathError = null;
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        // د پلنوالي محدودول: مور Column د `stretch` سره ده، نو پرته
        // له دې تڼۍ ټوله کرښه نیسي او نااخته ښکاري.
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: OutlinedButton.icon(
            onPressed: _checking
                ? null
                : (_openExisting ? _pickExistingFile : _pickFolder),
            icon: _checking
                ? const SizedBox(
                    width: 15,
                    height: 15,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.drive_folder_upload_rounded, size: 18),
            label: Text(s.browse),
          ),
        ),
        if (_pathError != null) ...[
          const SizedBox(height: 12),
          _Banner(
            color: AppColors.danger,
            icon: Icons.error_outline_rounded,
            text: _pathError == 'notASqliteFile'
                ? 'دا فایل د SQLite ډیټابیس نه دی.'
                : s.errorFor(_pathError!),
          ),
        ],
        if (_folder != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border:
                  Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 16, color: AppColors.success),
                    const SizedBox(width: 8),
                    Text(
                      _openExisting ? s.openExisting : s.selectedFolder,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    _openExisting
                        ? _existingFile!
                        : p.join(_folder!, DatabaseFile.fileName),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontFamily: 'monospace',
                      color: pal.inkSoft,
                    ),
                  ),
                ),
                if (_freeBytes != null) ...[
                  const SizedBox(height: 5),
                  Text(
                    '${s.freeSpace}: ${_formatBytes(_freeBytes!)}',
                    style: TextStyle(fontSize: 11, color: pal.muted),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }

  // ── ګام ۱: ښوونځی ───────────────────────────────────────

  Widget _schoolStep() {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepHeader(title: s.stepSchool, subtitle: ''),
        const SizedBox(height: 20),
        TextField(
          controller: _schoolName,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(labelText: s.schoolName),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _Dropdown<String>(
                label: s.schoolKind,
                value: _kind,
                items: {
                  'school': s.kindSchool,
                  'madrasa': s.kindMadrasa,
                  'both': s.kindBoth,
                },
                onChanged: (v) => setState(() => _kind = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Dropdown<String>(
                label: s.calendar,
                value: _calendar,
                items: {
                  'jalali': s.calJalali,
                  'gregorian': s.calGregorian,
                },
                onChanged: (v) => setState(() => _calendar = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _address,
          decoration: InputDecoration(labelText: s.address),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _phone,
          decoration: InputDecoration(labelText: s.phone),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: s.dayStart,
                value: _dayStart,
                onChanged: (v) => setState(() => _dayStart = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeField(
                label: s.dayEnd,
                value: _dayEnd,
                onChanged: (v) => setState(() => _dayEnd = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _Dropdown<int>(
                label: s.lateAfter,
                value: _lateAfter,
                items: const {5: '۵', 10: '۱۰', 15: '۱۵', 20: '۲۰', 30: '۳۰'},
                onChanged: (v) => setState(() => _lateAfter = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── ګام ۲: مدیر ─────────────────────────────────────────

  Widget _adminStep() {
    final s = S.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepHeader(title: s.stepAdmin, subtitle: ''),
        const SizedBox(height: 20),
        TextField(
          controller: _adminName,
          onChanged: (_) => setState(() => _adminError = null),
          decoration: InputDecoration(labelText: s.fullName),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminUser,
          onChanged: (_) => setState(() => _adminError = null),
          decoration: InputDecoration(labelText: s.username),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminPass,
          obscureText: true,
          onChanged: (_) => setState(() => _adminError = null),
          decoration: InputDecoration(labelText: s.password),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _adminPass2,
          obscureText: true,
          onChanged: (_) => setState(() => _adminError = null),
          onSubmitted: (_) => _stepValid ? _finish() : null,
          decoration: InputDecoration(labelText: s.passwordAgain),
        ),
        if (_adminError != null) ...[
          const SizedBox(height: 14),
          _Banner(
            color: AppColors.danger,
            icon: Icons.error_outline_rounded,
            text: _adminError!,
          ),
        ],
      ],
    );
  }

  Widget _doneStep() {
    final s = S.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.check_circle_rounded,
            size: 62, color: AppColors.success),
        const SizedBox(height: 18),
        _StepHeader(title: s.setupDone, subtitle: s.setupDoneSub),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د ویزارډ کوچني ټوټې
// ═══════════════════════════════════════════════════════════

String _formatBytes(int b) {
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  var v = b.toDouble();
  var i = 0;
  while (v >= 1024 && i < units.length - 1) {
    v /= 1024;
    i++;
  }
  return '${v.toStringAsFixed(1)} ${units[i]}';
}

class _WizardSidebar extends StatelessWidget {
  const _WizardSidebar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.gradIndigo,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.auto_stories_rounded,
                  color: Colors.white, size: 28),
            ),
            const SizedBox(height: 22),
            Text(
              S.of(context).welcome,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              S.of(context).welcomeSub,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.82),
                fontSize: 13,
                height: 1.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  final int current;
  final int total;
  const _StepDots({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              height: 4,
              decoration: BoxDecoration(
                color: i <= current ? AppColors.primary : p.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 6),
        ],
      ],
    );
  }
}

class _StepHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  const _StepHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: p.ink,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13.5, color: p.muted, height: 1.8),
          ),
        ],
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.selected,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.09) : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: selected ? color : p.line,
            width: selected ? 1.7 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 25, color: selected ? color : p.muted),
            const SizedBox(height: 9),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? color : p.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _Banner({
    required this.color,
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T value;
  final Map<T, String> items;
  final ValueChanged<T> onChanged;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      value: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final e in items.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: (v) => v == null ? null : onChanged(v),
    );
  }
}

class _TimeField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: value,
      decoration: InputDecoration(labelText: label, hintText: 'HH:mm'),
      onChanged: onChanged,
    );
  }
}

/// د ډیټابیس د فایل کاپي — د تنظیماتو د «مسیر بدل کړه» لپاره هم کارېږي.
///
/// ترتیب مهم دی: لومړی checkpoint، بیا کاپي، بیا د بشپړتیا کتنه.
/// که پر منځ کې څه خراب شي، زوړ فایل خپل ځای کې روغ پاتې کېږي.
Future<String> copyDatabase({
  required String fromPath,
  required String toDir,
}) async {
  final target = p.join(toDir, DatabaseFile.fileName);
  if (p.equals(fromPath, target)) return target;

  await File(fromPath).copy(target);

  if (!DatabaseFile.isValidSqlite(target)) {
    await File(target).delete();
    throw const FileSystemException('د کاپي شوي ډیټابیس بشپړتیا سمه نه ده');
  }
  return target;
}
