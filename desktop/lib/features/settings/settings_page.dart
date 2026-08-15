import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/device_repository.dart';
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
    this.lanLookup,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _tab = 0;

  List<Device> _devices = const [];
  List<PairingCode> _codes = const [];
  List<LanEndpoint> _endpoints = const [];
  List<Guardian> _guardians = const [];
  bool _loading = true;
  bool _busy = false;

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

    if (!mounted) return;
    setState(() {
      _devices = devices;
      _codes = codes;
      _endpoints = endpoints;
      _guardians = guardians;
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                for (final t in const [
                  (0, 'اړیکه او وسایل'),
                  (1, 'ښوونځی'),
                  (2, 'ډیټابیس'),
                ]) ...[
                  _Tab(
                    label: t.$2,
                    selected: _tab == t.$1,
                    onTap: () => setState(() => _tab = t.$1),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          Expanded(
            child: AnimatedSwitcher(
              duration: AppMotion.fast,
              switchInCurve: AppMotion.standard,
              layoutBuilder: (current, previous) => Stack(
                fit: StackFit.expand,
                children: [...previous, if (current != null) current],
              ),
              child: KeyedSubtree(
                key: ValueKey(_tab),
                child: switch (_tab) {
                  0 => _buildConnect(p),
                  1 => _buildSchool(p),
                  _ => _buildDatabase(p),
                },
              ),
            ),
          ),
        ],
      ),
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
    return ListView(
      children: [
        _Card(
          title: 'د ښوونځي پېژندنه',
          child: Column(
            children: [
              _KeyValue(label: 'نوم', value: widget.schoolName),
              _KeyValue(
                label: 'کارن',
                value: '${widget.session.fullName} (${widget.session.role})',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _Card(
          title: 'ژبه او بڼه',
          hint: 'ژبه او تیاره/روښانه حالت د پورتنۍ کرښې څخه بدلېږي.',
          child: _KeyValue(
            label: 'کلیز',
            value: switch (widget.config.calendar) {
              'gregorian' => 'میلادي',
              'hijri' => 'هجري قمري',
              _ => 'هجري شمسي',
            },
          ),
        ),
      ],
    );
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
          title: 'د بیک‌اپ دویم ځای',
          hint: 'USB یا د شبکې پوښۍ — د اونۍ په پای کې کاپي هلته ځي.',
          child: SelectableText(
            widget.config.backupPath ?? 'نه دی ټاکل شوی',
            style: AppTheme.tabular(
              TextStyle(fontSize: 12.5, color: p.inkSoft),
            ),
          ),
        ),
      ],
    );
  }

  static String _stamp(DateTime t) =>
      '${t.month.toString().padLeft(2, '0')}/${t.day.toString().padLeft(2, '0')}'
      ' ${t.hour.toString().padLeft(2, '0')}:'
      '${t.minute.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════

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

class _Tab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Tab({
    required this.label,
    required this.selected,
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
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.modSettings.withValues(alpha: 0.11)
              : p.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(color: selected ? AppColors.modSettings : p.line),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.modSettings : p.inkSoft,
          ),
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
