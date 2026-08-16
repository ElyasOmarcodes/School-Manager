import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/services.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/backup.dart';
import '../../data/db/database.dart';
import '../../core/widgets/panel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/device_repository.dart';
import '../../data/repositories/user_repository.dart' show Perm, roleLabel;
import '../../server/local_server.dart';
import '../auth/auth_service.dart';

/// د تنظیماتو پاڼه.
///
/// **د څلورم پړاو زړه دلته دی:** «اړیکه» برخه. هلته مدیر سرور
/// چالانوي، د تړلو کوډ جوړوي، او ګوري چې کوم تلیفونونه تړل شوي دي.
class SettingsPage extends StatefulWidget {
  final AppDatabase db;
  final DeviceRepository devices;
  final LocalServer server;
  final Session session;
  final AppConfig config;
  final ValueChanged<AppConfig> onConfigChanged;
  final String schoolName;

  /// کومه برخه ښکاري: `general` | `school` | `database` | `network`.
  ///
  /// **ولې له لارې راځي او نه دننه tab؟** ځکه چې فرعي سایډبار لا
  /// دمخه څلور برخې ښيي. که پاڼې خپل tabونه هم لرل، کارن به دوه
  /// ځله ټاکنه کوله — یو ځل کیڼ خوا، بیا پورته — او دواړه به یو
  /// بل سره نه سمېدل.
  final String section;

  /// د ښوونځي معلومات سمول — که `null` وي، یوازې لوستل.
  final AcademicRepository? academic;

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode>? onThemeChanged;

  /// کله چې د ښوونځي نوم بدل شي — چوکاټ يې پورته کرښه تازه کوي.
  final VoidCallback? onSchoolChanged;

  /// د شبکې د پتو لټون. تلواله `LocalServer.lanEndpoints` ده؛
  /// ازموینه يې بدلوي، ځکه چې ریښتیني I/O د ویجیټ ازموینې دننه
  /// نه پای ته رسېږي.
  final Future<List<LanEndpoint>> Function(int port)? lanLookup;

  const SettingsPage({
    super.key,
    required this.db,
    required this.devices,
    required this.server,
    required this.session,
    required this.config,
    required this.onConfigChanged,
    required this.schoolName,
    this.section = 'network',
    this.academic,
    this.themeMode = ThemeMode.light,
    this.onThemeChanged,
    this.onSchoolChanged,
    this.lanLookup,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  List<Device> _devices = const [];
  List<PairingCode> _codes = const [];
  List<LanEndpoint> _endpoints = const [];
  List<Guardian> _guardians = const [];
  List<BackupFile> _backups = const [];
  bool _loading = true;
  bool _busy = false;

  School? _school;
  final _schoolNameCtrl = TextEditingController();
  final _schoolNameEnCtrl = TextEditingController();
  final _schoolAddressCtrl = TextEditingController();
  final _schoolPhoneCtrl = TextEditingController();
  final _schoolEmailCtrl = TextEditingController();
  String? _logoPath;

  @override
  void dispose() {
    for (final c in [
      _schoolNameCtrl,
      _schoolNameEnCtrl,
      _schoolAddressCtrl,
      _schoolPhoneCtrl,
      _schoolEmailCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final devices = await widget.devices.list();
    final codes = await widget.devices.activeCodes();
    final port = widget.server.port ?? LocalServer.defaultPort;
    final endpoints = await (widget.lanLookup == null
        ? LocalServer.lanEndpoints(port: port)
        : widget.lanLookup!(port));
    final guardians =
        await (widget.db.select(widget.db.guardians)..limit(500)).get();
    final backups = widget.config.backupPath == null
        ? const <BackupFile>[]
        : await DatabaseBackup.list(widget.config.backupPath!);
    final school = await widget.academic?.school();

    if (!mounted) return;
    if (school != null) {
      _school = school;
      _schoolNameCtrl.text = school.name;
      _schoolNameEnCtrl.text = school.nameEn ?? '';
      _schoolAddressCtrl.text = school.address ?? '';
      _schoolPhoneCtrl.text = school.phone ?? '';
      _schoolEmailCtrl.text = school.email ?? '';
      _logoPath = school.logoPath;
    }
    setState(() {
      _devices = devices;
      _codes = codes;
      _endpoints = endpoints;
      _guardians = guardians;
      _backups = backups;
      _loading = false;
    });
  }

  /// د ویندوز فایروال قاعده په اداري اجازې سره ځغلوي.
  ///
  /// **ولې پخپله نه؟** ځکه چې دا د سیسټم بدلون دی — کارن باید
  /// د ویندوز پوښتنې (UAC) ته «هو» ووايي. زه يې پرته له پوښتنې
  /// نه کوم.
  Future<void> _addFirewallRule() async {
    if (!Platform.isWindows) return;
    setState(() => _busy = true);
    try {
      final r = await Process.run('powershell', [
        '-NoProfile',
        '-Command',
        "Start-Process cmd -ArgumentList '/c ${widget.server.firewallCommand()}'"
            ' -Verb RunAs -Wait',
      ]);
      if (!mounted) return;
      final ok = r.exitCode == 0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          width: 560,
          backgroundColor: ok ? AppColors.success : AppColors.danger,
          content: Text(
            ok
                ? 'د فایروال قاعده زیاته شوه. اوس په تلیفون کې بیا هڅه وکړئ.'
                : 'قاعده زیاته نه شوه. بلنه کاپي کړئ او په '
                      '«Command Prompt (Administrator)» کې يې وځغلوئ.',
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pickLogo() async {
    const group = XTypeGroup(
      label: 'انځورونه',
      extensions: ['png', 'jpg', 'jpeg'],
    );
    final file = await openFile(acceptedTypeGroups: const [group]);
    if (file == null || !mounted) return;
    setState(() => _logoPath = file.path);
  }

  Future<void> _saveSchool() async {
    final academic = widget.academic;
    final name = _schoolNameCtrl.text.trim();
    if (academic == null || name.isEmpty) {
      _say('نوم نه شي تش پاتې کېدی.', AppColors.warning);
      return;
    }

    setState(() => _busy = true);
    String? nn(TextEditingController c) {
      final v = c.text.trim();
      return v.isEmpty ? null : v;
    }

    await academic.updateSchool(
      name: name,
      nameEn: nn(_schoolNameEnCtrl),
      address: nn(_schoolAddressCtrl),
      // تلیفون تل لاتیني — که ختیځې شمېرې ولیکل شي، د لټون او
      // د SMS لپاره به بې‌ګټې و.
      phone: _schoolPhoneCtrl.text.trim().isEmpty
          ? null
          : Numerals.toLatin(_schoolPhoneCtrl.text.trim()),
      email: nn(_schoolEmailCtrl),
      logoPath: _logoPath,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    await _load();
    widget.onSchoolChanged?.call();
    if (mounted) _say('د ښوونځي معلومات وساتل شول.', AppColors.success);
  }

  /// د بیک‌اپ پوښۍ ټاکل — USB، د شبکې ډرایو، یا هر ځای.
  Future<void> _pickBackupDir() async {
    final dir = await getDirectoryPath();
    if (dir == null || !mounted) return;
    widget.onConfigChanged(widget.config.copyWith(backupPath: dir));
    // د تنظیماتو بدلون د پورته له لارې راځي، نو یوازې لیست تازه کوو.
    final backups = await DatabaseBackup.list(dir);
    if (mounted) setState(() => _backups = backups);
  }

  Future<void> _backupNow() async {
    final dir = widget.config.backupPath;
    final dbPath = widget.config.databasePath;
    if (dir == null || dbPath == null) {
      _say('لومړی د بیک‌اپ ځای وټاکئ.', AppColors.warning);
      return;
    }

    setState(() => _busy = true);
    final result = await DatabaseBackup.create(
      db: widget.db,
      databasePath: dbPath,
      targetDir: dir,
    );
    await DatabaseBackup.prune(dir);
    if (!mounted) return;
    setState(() => _busy = false);
    await _load();
    if (!mounted) return;

    switch (result) {
      case BackupOk(file: final f):
        _say('بیک‌اپ واخیستل شو — ${f.name} (${f.sizeLabel})',
            AppColors.success);
      case BackupFailed(reason: final r):
        _say('بیک‌اپ ونه شو: $r', AppColors.danger);
    }
  }

  void _say(String text, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 560,
        backgroundColor: color,
        content: Text(text),
      ),
    );
  }

  Future<void> _toggleServer() async {
    setState(() => _busy = true);
    try {
      if (widget.server.isRunning) {
        await widget.server.stop();
      } else {
        await widget.server.start();
      }
    } on Object catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: 520,
            backgroundColor: AppColors.danger,
            content: Text('سرور ونه چالانېد: $e'),
          ),
        );
      }
    }
    if (!mounted) return;
    setState(() => _busy = false);
    await _load();
  }

  Future<void> _newCode({required String role, int? guardianId}) async {
    final code = await widget.devices.createCode(
      role: role,
      userId: role == 'manager' ? widget.session.userId : null,
      guardianId: guardianId,
      createdByUserId: widget.session.userId,
    );
    if (!mounted) return;
    await _load();
    if (!mounted) return;
    await _showCode(code);
  }

  Future<void> _showCode(PairingCode code) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final address = _endpoints.isEmpty
        ? 'د شبکې پته ونه موندل شوه'
        : _endpoints.first.url;

    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text(
          'د تړلو کوډ',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 22),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
                child: Center(
                  child: SelectableText(
                    code.code,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 10,
                      color: AppColors.primary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _KeyValue(label: 'د سرور پته', value: address),
              _KeyValue(
                label: 'تر کومه وخته',
                value: locale.num(
                  '${code.expiresAt.hour.toString().padLeft(2, '0')}:'
                  '${code.expiresAt.minute.toString().padLeft(2, '0')}',
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'په تلیفون کې اپ پرانیزئ، دا پته او کوډ ولیکئ. کوډ '
                'یوازې یو ځل کار کوي او ${locale.num(DeviceRepository.codeLifetime.inMinutes)} '
                'دقیقې وروسته ختمېږي.',
                style: TextStyle(fontSize: 12, height: 1.8, color: p.muted),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(
                ClipboardData(text: '$address\n${code.code}'),
              );
              Navigator.pop(context);
            },
            child: const Text('کاپي کړه'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ښه'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: AnimatedSwitcher(
        duration: AppMotion.fast,
        switchInCurve: AppMotion.standard,
        layoutBuilder: (current, previous) => Stack(
          fit: StackFit.expand,
          children: [...previous, if (current != null) current],
        ),
        child: KeyedSubtree(
          key: ValueKey(widget.section),
          child: switch (widget.section) {
            'general' => _buildGeneral(p),
            'school' => _buildSchool(p),
            'database' => _buildDatabase(p),
            _ => _buildConnect(p),
          },
        ),
      ),
    );
  }

  // ── عمومي ───────────────────────────────────────────────

  Widget _buildGeneral(AppPalette p) {
    final scope = LocaleScope.of(context);
    final locale = scope.locale;

    return ListView(
      children: [
        _Card(
          title: 'ژبه',
          hint:
              'د پروګرام ټول متن او د شمېرو بڼه پرې بدلېږي. '
              'ډیټابیس تل لاتیني شمېرې ساتي، نو بدلون پخوانیو '
              'معلوماتو ته زیان نه رسوي.',
          child: SegmentedChoice<AppLocale>(
            value: locale,
            color: AppColors.modSettings,
            options: const [
              (value: AppLocale.ps, label: 'پښتو', icon: null),
              (value: AppLocale.fa, label: 'دري', icon: null),
              (value: AppLocale.en, label: 'English', icon: null),
            ],
            onChanged: scope.setLocale,
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'بڼه',
          hint: 'تیاره حالت د شپې کار لپاره — سترګې لږ ستړې کوي.',
          child: SegmentedChoice<ThemeMode>(
            value: widget.themeMode,
            color: AppColors.modSettings,
            options: const [
              (
                value: ThemeMode.light,
                label: 'روښانه',
                icon: Icons.light_mode_rounded,
              ),
              (
                value: ThemeMode.dark,
                label: 'تیاره',
                icon: Icons.dark_mode_rounded,
              ),
              (
                value: ThemeMode.system,
                label: 'د سیسټم په څېر',
                icon: Icons.computer_rounded,
              ),
            ],
            onChanged: widget.onThemeChanged ?? (_) {},
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'کلیز',
          hint:
              'نېټې پرې ښودل کېږي. په ډیټابیس کې تل میلادي ساتل '
              'کېږي — نو د کلیز بدلول پخوانۍ نېټې نه ګډوډوي.',
          child: SegmentedChoice<String>(
            value: widget.config.calendar,
            color: AppColors.modSettings,
            options: const [
              (value: 'jalali', label: 'هجري شمسي', icon: null),
              (value: 'hijri', label: 'هجري قمري', icon: null),
              (value: 'gregorian', label: 'میلادي', icon: null),
            ],
            onChanged: (v) =>
                widget.onConfigChanged(widget.config.copyWith(calendar: v)),
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'کارن',
          child: Column(
            children: [
              _KeyValue(label: 'نوم', value: widget.session.fullName),
              _KeyValue(label: 'کارن‌نوم', value: widget.session.username),
              _KeyValue(label: 'رول', value: roleLabel(widget.session.role)),
            ],
          ),
        ),
      ],
    );
  }

  // ── ۱: اړیکه ────────────────────────────────────────────

  Widget _buildConnect(AppPalette p) {
    final locale = S.of(context).locale;
    final running = widget.server.isRunning;

    return ListView(
      children: [
        // ── د سرور حالت ──────────────────────────────────
        _Card(
          child: Row(
            children: [
              AnimatedContainer(
                duration: AppMotion.normal,
                curve: AppMotion.standard,
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: running
                        ? AppColors.gradEmerald
                        : [p.surfaceAlt, p.surfaceAlt],
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  running ? Icons.wifi_tethering_rounded : Icons.wifi_off_rounded,
                  size: 25,
                  color: running ? Colors.white : p.faint,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      running ? 'سرور روان دی' : 'سرور ولاړ دی',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      running
                          ? 'تلیفونونه چې د ښوونځي Wi-Fi ته وصل وي، '
                                'کولی شي دې کمپیوټر ته وصل شي.'
                          : 'تر څو چې سرور ولاړ وي، موبایل اپ نه شي '
                                'معلومات راښکلی.',
                      style: TextStyle(fontSize: 12.5, height: 1.7, color: p.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              FilledButton(
                onPressed: _busy ? null : _toggleServer,
                style: FilledButton.styleFrom(
                  backgroundColor: running
                      ? AppColors.danger
                      : AppColors.success,
                  minimumSize: const Size(126, 44),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                child: Text(running ? 'ودروه' : 'چالان کړه'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── پتې ──────────────────────────────────────────
        _Card(
          title: 'د شبکې پتې',
          hint:
              'دا هغه پتې دي چې په تلیفون کې ولیکل شي. که ډېرې وي، '
              'هغه وټاکئ چې د ښوونځي له Wi-Fi سره سمون خوري.',
          child: _endpoints.isEmpty
              ? const Text(
                  'هېڅ شبکه ونه موندل شوه — کمپیوټر Wi-Fi یا کیبل '
                  'ته وصل کړئ.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.warning),
                )
              : Column(
                  children: [
                    for (final e in _endpoints)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.lan_rounded, size: 16, color: p.muted),
                            const SizedBox(width: 10),
                            SelectableText(
                              e.url,
                              style: AppTheme.tabular(
                                TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: p.ink,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              e.interfaceName,
                              style: TextStyle(fontSize: 11.5, color: p.faint),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'کاپي',
                              icon: Icon(
                                Icons.copy_rounded,
                                size: 15,
                                color: p.muted,
                              ),
                              onPressed: () => Clipboard.setData(
                                ClipboardData(text: e.url),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: 14),

        // ── تشخیص ────────────────────────────────────────
        if (running) _buildDiagnostics(p),
        if (running) const SizedBox(height: 14),

        // ── نوی تړاو ─────────────────────────────────────
        _Card(
          title: 'نوې وسیله وتړئ',
          hint:
              'د مدیر لپاره یو کوډ، او د هر کور لپاره جلا کوډ. د '
              'والدینو کوډ يوازې د هغوی د ماشومانو معلومات ښیي.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  FilledButton.icon(
                    onPressed: () => _newCode(role: 'manager'),
                    icon: const Icon(Icons.admin_panel_settings_rounded, size: 17),
                    label: const Text('د مدیر کوډ'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 42),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GuardianPicker(
                      guardians: _guardians,
                      onPicked: (g) =>
                          _newCode(role: 'parent', guardianId: g.id),
                    ),
                  ),
                ],
              ),
              if (_codes.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  'ژوندي کوډونه',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.muted,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final c in _codes)
                      GestureDetector(
                        onTap: () => _showCode(c),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.09),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                c.code,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                c.role == 'manager' ? 'مدیر' : 'والدین',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: p.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // ── تړل شوي وسایل ────────────────────────────────
        _Card(
          title: 'تړل شوي وسایل (${locale.num(_devices.length)})',
          child: _loading
              ? const Center(child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ))
              : _devices.isEmpty
              ? Text(
                  'لا هېڅ تلیفون نه دی تړل شوی.',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                )
              : Column(
                  children: [
                    for (final d in _devices)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color:
                                    (d.role == 'manager'
                                            ? AppColors.primary
                                            : AppColors.modLeave)
                                        .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                d.role == 'manager'
                                    ? Icons.admin_panel_settings_rounded
                                    : Icons.family_restroom_rounded,
                                size: 17,
                                color: d.role == 'manager'
                                    ? AppColors.primary
                                    : AppColors.modLeave,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    d.name,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: p.ink,
                                    ),
                                  ),
                                  Text(
                                    d.lastSeenAt == null
                                        ? 'لا نه دی راغلی'
                                        : 'وروستی ځل: '
                                              '${locale.num(_stamp(d.lastSeenAt!))}'
                                              '${d.lastIp == null ? '' : '  •  ${d.lastIp}'}',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: p.faint,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () async {
                                await widget.devices.revoke(
                                  d.id,
                                  byUserId: widget.session.userId,
                                );
                                await _load();
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.danger,
                              ),
                              child: const Text(
                                'باطل کړه',
                                style: TextStyle(fontSize: 12.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  /// **«سرور روان دی» بس نه دی.**
  ///
  /// دا کارت هغه پوښتنه ځواب کوي چې مدیر يې پوښتي: «ولې زما تلیفون
  /// نه وصلېږي؟» — او لومړی ځواب دا دی چې ایا اصلاً څه راغلي که نه.
  Widget _buildDiagnostics(AppPalette p) {
    final locale = S.of(context).locale;
    final stats = widget.server.stats;
    final silent = stats.silent;

    return _Card(
      title: 'تشخیص',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (silent ? AppColors.warning : AppColors.success)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  silent
                      ? Icons.help_outline_rounded
                      : Icons.check_circle_rounded,
                  size: 19,
                  color: silent ? AppColors.warning : AppColors.success,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      silent
                          ? 'لا هېڅ غوښتنه نه ده راغلې'
                          : '${locale.grouped(stats.requests)} غوښتنې راغلې',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: p.ink,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      silent
                          ? 'د دې معنا دا ده چې تلیفون تر دې کمپیوټر '
                                'پورې نه دی رسېدلی — نه دا چې کوډ غلط دی.'
                          : 'له '
                                '${locale.num(stats.clientIps.length)} '
                                'وسیلو څخه — شبکه کار کوي.',
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.7,
                        color: p.muted,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'بیا وګوره',
                onPressed: () => setState(() {}),
                icon: Icon(Icons.refresh_rounded, size: 18, color: p.muted),
              ),
            ],
          ),

          if (silent) ...[
            const SizedBox(height: 18),
            Divider(color: p.line, height: 1),
            const SizedBox(height: 16),
            Text(
              'دا درې شیان په ترتیب سره وګورئ',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: p.ink,
              ),
            ),
            const SizedBox(height: 12),
            const _Step(
              n: 1,
              title: 'د ویندوز فایروال',
              body:
                  'تر ټولو ډېر ځله همدا لامل دی. ویندوز پرته له '
                  'پوښتنې د بهرنیو اړیکو مخه نیسي. لاندې تڼۍ يې '
                  'حل کوي — ویندوز به یوه پوښتنه وکړي، «هو» ورکړئ.',
            ),
            const _Step(
              n: 2,
              title: 'یوه Wi-Fi، نه دوه',
              body:
                  'کمپیوټر ښايي په کیبل وصل وي او تلیفون په Wi-Fi — '
                  'دا دوه بېلې شبکې دي. پورته پته وګورئ چې د تلیفون '
                  'د Wi-Fi پتې سره سمون خوري (لومړي درې برخې يې یو '
                  'شان وي).',
            ),
            const _Step(
              n: 3,
              title: 'د راوټر جلاوالی',
              body:
                  'ځینې راوټرونه «AP Isolation» یا «Client Isolation» '
                  'لري چې د تلیفونونو خبرې اترې بندوي. په راوټر کې يې '
                  'وګورئ او بند يې کړئ.',
            ),
            const SizedBox(height: 14),

            if (Platform.isWindows)
              FilledButton.icon(
                onPressed: _busy ? null : _addFirewallRule,
                icon: const Icon(Icons.shield_rounded, size: 17),
                label: const Text('د فایروال قاعده زیاته کړه'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  minimumSize: const Size.fromHeight(44),
                  textStyle: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              'یا دا بلنه په «Command Prompt (Administrator)» کې '
              'وځغلوئ:',
              style: TextStyle(fontSize: 11.5, color: p.muted),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(color: p.line),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      widget.server.firewallCommand(),
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontSize: 11.5,
                        height: 1.6,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'کاپي',
                    icon: Icon(
                      Icons.copy_rounded,
                      size: 16,
                      color: p.muted,
                    ),
                    onPressed: () => Clipboard.setData(
                      ClipboardData(text: widget.server.firewallCommand()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── ۲: ښوونځی ───────────────────────────────────────────

  Widget _buildSchool(AppPalette p) {
    final school = _school;
    final canEdit =
        widget.academic != null &&
        widget.session.permissions.can('settings', Perm.edit);

    return ListView(
      children: [
        _Card(
          title: 'د ښوونځي پېژندنه',
          hint: canEdit
              ? 'دا معلومات په رپوټونو، کارټونو او د تصدیق پاڼو کې ښکاري.'
              : 'د سمولو اجازه نه لرئ.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LogoBox(
                    path: _logoPath,
                    onPick: canEdit ? _pickLogo : null,
                    onClear: canEdit && _logoPath != null
                        ? () => setState(() => _logoPath = null)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _schoolNameCtrl,
                                enabled: canEdit,
                                decoration: const InputDecoration(
                                  labelText: 'نوم *',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _schoolNameEnCtrl,
                                enabled: canEdit,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(
                                  labelText: 'انګلیسي نوم',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _schoolAddressCtrl,
                          enabled: canEdit,
                          decoration: const InputDecoration(labelText: 'پته'),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _schoolPhoneCtrl,
                                enabled: canEdit,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(
                                  labelText: 'تلیفون',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _schoolEmailCtrl,
                                enabled: canEdit,
                                textDirection: TextDirection.ltr,
                                decoration: const InputDecoration(
                                  labelText: 'برېښنالیک',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (canEdit) ...[
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    FilledButton.icon(
                      onPressed: _busy ? null : _saveSchool,
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: Text(S.of(context).save),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.modSettings,
                        minimumSize: const Size(0, 42),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),

        // **ډول نه سمېږي — او ولې يې دلیل هم لیکو.**
        //
        // که یوازې یو غیرفعال ډراپ‌ډاون ښودل کېده، کارن به فکر
        // کاوه چې پروګرام مات دی. دلیل يې پکار دی.
        _Card(
          title: 'د ښوونځي ډول',
          hint:
              'ډول نه بدلېږي. په هغه پورې د نصاب جوړښت، د مهالویش '
              'بڼه، د درجو نومونه او د حفظ ماډل تړلي دي — بدلول به '
              'يې هغه معلومات بې‌ځایه کړل چې لا دمخه ثبت شوي دي. '
              'که واقعاً بدلون پکار وي، نوی ډیټابیس جوړ کړئ.',
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.modSettings.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      school?.kind == 'madrasa'
                          ? Icons.mosque_rounded
                          : Icons.account_balance_rounded,
                      size: 17,
                      color: AppColors.modSettings,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      switch (school?.kind) {
                        'madrasa' => 'مدرسه',
                        'both' => 'ښوونځی او مدرسه',
                        _ => 'ښوونځی',
                      },
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.modSettings,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(Icons.lock_rounded, size: 16, color: p.faint),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'د درس وخت',
          hint: 'د حاضرۍ او مهالویش قواعد له دې څخه راځي.',
          child: Column(
            children: [
              _KeyValue(
                label: 'پیل',
                value: S.of(context).locale.num(school?.dayStart ?? '—'),
              ),
              _KeyValue(
                label: 'پای',
                value: S.of(context).locale.num(school?.dayEnd ?? '—'),
              ),
              _KeyValue(
                label: 'د اونۍ رخصتي',
                value: _weekendLabel(school?.weekendDays),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static String _weekendLabel(String? days) {
    if (days == null || days.isEmpty) return '—';
    const names = {
      1: 'دوشنبه',
      2: 'سه‌شنبه',
      3: 'چهارشنبه',
      4: 'پنجشنبه',
      5: 'جمعه',
      6: 'شنبه',
      7: 'یکشنبه',
    };
    return days
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .map((d) => names[d] ?? '$d')
        .join('، ');
  }

  // ── ۳: ډیټابیس ──────────────────────────────────────────

  Widget _buildDatabase(AppPalette p) {
    return ListView(
      children: [
        _Card(
          title: 'د ډیټابیس مسیر',
          hint:
              'دا هغه فایل دی چې ټول معلومات پکې دي. له دې فایل څخه '
              'منظم بیک‌اپ واخلئ — که ورک شي، هېڅ نه پاتې کېږي.',
          child: SelectableText(
            widget.config.databasePath ?? '—',
            style: AppTheme.tabular(
              TextStyle(fontSize: 12.5, color: p.inkSoft),
            ),
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'بیک‌اپ',
          hint:
              'دا هغه یوازینی شی دی چې ستاسو ښوونځی له بشپړ زیان څخه '
              'ژغوري. USB یا د شبکې پوښۍ وټاکئ او هره ورځ يې واخلئ. '
              'وروستي ${_keepLabel()} بیک‌اپونه ساتل کېږي، پاتې پخپله '
              'پاکېږي.',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: AlignmentDirectional.centerStart,
                      decoration: BoxDecoration(
                        color: p.surfaceAlt,
                        borderRadius: BorderRadius.circular(
                          AppTheme.radiusSm,
                        ),
                        border: Border.all(color: p.line),
                      ),
                      child: Text(
                        widget.config.backupPath ?? 'ځای نه دی ټاکل شوی',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.tabular(
                          TextStyle(
                            fontSize: 12.5,
                            color: widget.config.backupPath == null
                                ? AppColors.warning
                                : p.inkSoft,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _pickBackupDir,
                    icon: const Icon(Icons.folder_open_rounded, size: 17),
                    label: const Text('ځای وټاکه'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton.icon(
                    onPressed: _busy ? null : _backupNow,
                    icon: _busy
                        ? const SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.backup_rounded, size: 17),
                    label: const Text('اوس واخله'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.modSettings,
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              ),

              if (_backups.isEmpty) ...[
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(
                      Icons.warning_amber_rounded,
                      size: 16,
                      color: AppColors.warning,
                    ),
                    SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        'لا هېڅ بیک‌اپ نشته. که د کمپیوټر هارډ خراب '
                        'شي، ټول معلومات له منځه ځي.',
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.7,
                          color: AppColors.warning,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                const SizedBox(height: 16),
                Text(
                  'وروستي بیک‌اپونه',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: p.muted,
                  ),
                ),
                const SizedBox(height: 9),
                for (final b in _backups.take(6))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.inventory_2_rounded,
                          size: 15,
                          color: AppColors.success,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            b.name,
                            style: AppTheme.tabular(
                              TextStyle(fontSize: 12, color: p.inkSoft),
                            ),
                          ),
                        ),
                        Text(
                          b.sizeLabel,
                          style: AppTheme.tabular(
                            TextStyle(fontSize: 11.5, color: p.faint),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _keepLabel() => S.of(context).locale.num(30);

  static String _stamp(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}'
      ' ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════

/// د لوګو خانه — انځور، ټاکل، پاکول.
class _LogoBox extends StatelessWidget {
  final String? path;
  final VoidCallback? onPick;
  final VoidCallback? onClear;

  const _LogoBox({this.path, this.onPick, this.onClear});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    // انځور ښايي له ډیسکه ورک شوی وي — نو `errorBuilder` پکار دی،
    // که نه، ټوله پاڼه به سره شوې وه.
    final file = path == null ? null : File(path!);
    final exists = file != null && file.existsSync();

    return Column(
      children: [
        GestureDetector(
          onTap: onPick,
          child: MouseRegion(
            cursor: onPick == null
                ? SystemMouseCursors.basic
                : SystemMouseCursors.click,
            child: Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: p.surfaceAlt,
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(color: p.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: exists
                  ? Image.file(
                      file,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          Icon(Icons.broken_image_rounded, color: p.faint),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 27,
                          color: p.faint,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'لوګو',
                          style: TextStyle(fontSize: 11.5, color: p.faint),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (onClear != null)
          TextButton(
            onPressed: onClear,
            child: const Text(
              'لرې کړه',
              style: TextStyle(fontSize: 11.5, color: AppColors.danger),
            ),
          ),
      ],
    );
  }
}

class _Card extends StatelessWidget {
  final String? title;
  final String? hint;
  final Widget child;

  const _Card({this.title, this.hint, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return FadeSlideIn(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(color: p.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null) ...[
              Text(
                title!,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: p.ink,
                ),
              ),
              const SizedBox(height: 6),
            ],
            if (hint != null) ...[
              Text(
                hint!,
                style: TextStyle(fontSize: 12, height: 1.75, color: p.muted),
              ),
              const SizedBox(height: 14),
            ],
            child,
          ],
        ),
      ),
    );
  }
}

class _KeyValue extends StatelessWidget {
  final String label;
  final String value;
  const _KeyValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 12.5, color: p.muted),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// د یوه سرپرست ټاکل — د والدینو د کوډ لپاره.
class _GuardianPicker extends StatelessWidget {
  final List<Guardian> guardians;
  final ValueChanged<Guardian> onPicked;

  const _GuardianPicker({required this.guardians, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return PopupMenuButton<Guardian>(
      tooltip: '',
      onSelected: onPicked,
      itemBuilder: (_) => [
        for (final g in guardians.take(60))
          PopupMenuItem(
            value: g,
            child: Text(
              '${g.fullName}${g.phone == null ? '' : '  •  ${g.phone}'}',
              style: const TextStyle(fontSize: 12.5),
            ),
          ),
      ],
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: p.line),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.family_restroom_rounded,
              size: 17,
              color: AppColors.modLeave,
            ),
            const SizedBox(width: 9),
            Text(
              guardians.isEmpty
                  ? 'لا هېڅ سرپرست نشته'
                  : 'د یوه کور لپاره کوډ جوړ کړه',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
            const Spacer(),
            Icon(Icons.expand_more_rounded, size: 17, color: p.muted),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final int n;
  final String title;
  final String body;

  const _Step({required this.n, required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: Text(
              locale.num(n),
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: AppColors.warning,
              ),
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.75,
                    color: p.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
