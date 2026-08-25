import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/api_client.dart';
import '../core/design.dart';
import '../core/session_store.dart';
import '../core/strings.dart';

/// څوک دی؟ اپ یو دی، خو دوه څېرې لري.
enum AppRole { manager, parent }

/// د ښوونځي سره د تړلو پاڼه — د اپ لومړی پرده.
///
/// **جریان:** مدیر په ډیسکټاپ کې «نوې وسیله وتړئ» کېکاږي او یو
/// شپږ‌توری کوډ ورسره یوه پته راځي. کارن دواړه دلته لیکي. اپ لومړی
/// پته ازمويي (`/api/ping`) چې پوه شي ښوونځی هلته دی، بیا کوډ
/// مصرفوي او دایمي توکن اخلي.
///
/// **ولې دوه ګامه؟** ځکه چې د پتې تېروتنه (یو عدد غلط) او د کوډ
/// تېروتنه دوه بېل شیان دي. که یوه پیغام کې سره ګډ شي، کارن به
/// ونه پوهېږي کوم يې سم کړي.
class PairingPage extends StatefulWidget {
  final ValueChanged<SchoolSession> onConnected;
  final void Function(AppRole role)? onDemo;

  /// د ازموینې لپاره — ریښتینی HTTP نه کاروو.
  final ApiClient Function(String baseUrl)? clientFactory;

  const PairingPage({
    super.key,
    required this.onConnected,
    this.onDemo,
    this.clientFactory,
  });

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final _address = TextEditingController(text: 'http://192.168.1.');
  final _code = TextEditingController();

  bool _busy = false;
  String? _error;

  /// کله چې پته وازمویل شي، د ښوونځي نوم دلته راځي — کارن پوهېږي
  /// چې سم ځای ته وصل کېږي.
  String? _foundSchool;

  @override
  void dispose() {
    _address.dispose();
    _code.dispose();
    super.dispose();
  }

  ApiClient _client(String baseUrl) =>
      widget.clientFactory?.call(baseUrl) ?? ApiClient(baseUrl: baseUrl);

  String get _url {
    var v = _address.text.trim();
    if (v.isEmpty) return v;
    if (!v.startsWith('http://') && !v.startsWith('https://')) {
      v = 'http://$v';
    }
    // که پورټ نه وي لیکل شوی، تلواله ورزیاتوو — کارن باید د
    // «۸۷۸۷» یادولو ته اړ نه وي.
    final uri = Uri.tryParse(v);
    if (uri != null && !uri.hasPort) v = '$v:8787';
    return v;
  }

  Future<void> _check() async {
    if (_url.isEmpty) {
      setState(() => _error = 'لومړی د سرور پته ولیکئ.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
      _foundSchool = null;
    });

    final client = _client(_url);
    try {
      final info = await client.ping();
      if (!mounted) return;
      setState(() => _foundSchool = info.school.isEmpty ? '—' : info.school);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _connect() async {
    final code = _code.text.trim();
    if (code.length < 4) {
      setState(() => _error = 'کوډ شپږ توري دی — بشپړ يې ولیکئ.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });

    final client = _client(_url);
    try {
      final r = await client.pair(
        code: code,
        deviceName: await _deviceLabel(),
      );
      if (!mounted) return;
      widget.onConnected(
        SchoolSession(
          baseUrl: _url,
          token: r.token,
          role: r.role,
          school: r.school,
          deviceName: r.deviceName,
          guardianId: r.guardianId,
          guardianName: r.guardianName,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// د وسیلې نوم — مدیر يې په ډیسکټاپ کې ویني، نو باید د پېژندلو
  /// وړ وي.
  Future<String> _deviceLabel() async => 'اندروید وسیله';

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = context.pal;
    final connected = _foundSchool != null;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── نښان ─────────────────────────────────
                  Center(
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: M.gradIndigo),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: M.primary.withValues(alpha: 0.28),
                            blurRadius: 26,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.school_rounded,
                        size: 37,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Text(
                    t.connectTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.connectSub,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.75,
                      color: p.muted,
                    ),
                  ),
                  const SizedBox(height: 26),

                  // ── ګام ۱: پته ────────────────────────────
                  _StepLabel(
                    number: 1,
                    label: 'د ښوونځي پته',
                    done: connected,
                  ),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _address,
                    enabled: !_busy,
                    keyboardType: TextInputType.url,
                    textDirection: TextDirection.ltr,
                    onChanged: (_) {
                      if (_foundSchool != null) {
                        setState(() => _foundSchool = null);
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'http://192.168.1.14:8787',
                      hintTextDirection: TextDirection.ltr,
                      prefixIcon: const Icon(Icons.lan_rounded, size: 19),
                      suffixIcon: TextButton(
                        onPressed: _busy ? null : _check,
                        child: const Text(
                          'وګوره',
                          style: TextStyle(fontSize: 12.5),
                        ),
                      ),
                    ),
                  ),

                  // د موندل شوي ښوونځي تایید
                  AnimatedSize(
                    duration: M.normal,
                    curve: M.ease,
                    child: connected
                        ? Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 17,
                                  color: M.success,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'موندل شو: $_foundSchool',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: M.success,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),

                  // ── ګام ۲: کوډ ────────────────────────────
                  _StepLabel(number: 2, label: t.pairCode, done: false),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _code,
                    enabled: !_busy,
                    textCapitalization: TextCapitalization.characters,
                    textAlign: TextAlign.center,
                    maxLength: 8,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp('[a-zA-Z0-9]'),
                      ),
                      TextInputFormatter.withFunction(
                        (_, next) => next.copyWith(
                          text: next.text.toUpperCase(),
                        ),
                      ),
                    ],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 9,
                    ),
                    decoration: const InputDecoration(
                      counterText: '',
                      hintText: 'ABC123',
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── غلطي ─────────────────────────────────
                  AnimatedSize(
                    duration: M.normal,
                    curve: M.ease,
                    child: _error == null
                        ? const SizedBox.shrink()
                        : Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: M.danger.withValues(alpha: 0.09),
                              borderRadius: BorderRadius.circular(M.radius),
                              border: Border.all(
                                color: M.danger.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline_rounded,
                                  size: 18,
                                  color: M.danger,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _error!,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      height: 1.7,
                                      color: M.danger,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),

                  FilledButton(
                    onPressed: _busy ? null : _connect,
                    child: _busy
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : Text(t.connect),
                  ),

                  if (widget.onDemo != null) ...[
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => widget.onDemo!(AppRole.manager),
                            child: Text(t.iAmManager),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => widget.onDemo!(AppRole.parent),
                            child: Text(t.iAmParent),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'د نمونې حالت — ریښتیني معلومات نه ښیي.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.5, color: p.faint),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepLabel extends StatelessWidget {
  final int number;
  final String label;
  final bool done;

  const _StepLabel({
    required this.number,
    required this.label,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return Row(
      children: [
        AnimatedContainer(
          duration: M.normal,
          curve: M.ease,
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: done ? M.success : M.primary.withValues(alpha: 0.13),
            shape: BoxShape.circle,
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : Center(
                  child: Text(
                    num_(number, T.of(context).locale),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: M.primary,
                    ),
                  ),
                ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: p.inkSoft,
          ),
        ),
      ],
    );
  }
}
