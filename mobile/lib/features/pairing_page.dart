import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/design.dart';
import '../core/strings.dart';

/// څوک دی؟ اپ یو دی، خو دوه څېرې لري.
enum AppRole { manager, parent }

/// د ښوونځي سره د تړلو پاڼه — د اپ لومړی پرده.
///
/// **څنګه به کار کوي (څلورم پړاو):** مدیر په ډیسکټاپ کې د یوه کارن
/// لپاره د تړلو کوډ جوړوي. کوډ د ښوونځي د محلي سرور پته او یو
/// یوځلي توکن لري. اپ ورسره وصل کېږي، خپل دایمي توکن اخلي، او له
/// هغې وروسته پخپله همغږي کوي.
///
/// **اوس:** کوډ لا هېڅ ځای ته نه ځي — سرور په څلورم پړاو کې جوړېږي.
/// نو د «نمونې حالت» تڼۍ شته چې UI او جریان وکتل شي.
class PairingPage extends StatefulWidget {
  final void Function(AppRole role, {required bool demo}) onConnected;

  const PairingPage({super.key, required this.onConnected});

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  final _code = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    // د سرور اړیکه لا نشته — دا د څلورم پړاو کار دی. د دروغجن
    // «بریالیتوب» پر ځای کارن ته ریښتیا وایو.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error =
          'د ښوونځي سرور لا نه دی چمتو (څلورم پړاو). '
          'تر هغې د نمونې حالت وکاروئ.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = T.of(context);
    final p = context.pal;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 78,
                    height: 78,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: M.gradIndigo,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: M.primary.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 37,
                    ),
                  ),
                ),
                const SizedBox(height: 26),
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
                  style: TextStyle(fontSize: 13.5, height: 1.8, color: p.muted),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: _code,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.ltr,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9-]')),
                    LengthLimitingTextInputFormatter(14),
                  ],
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 3,
                  ),
                  decoration: InputDecoration(
                    hintText: 'ABCD-1234',
                    labelText: t.pairCode,
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: M.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(M.radius),
                      border: Border.all(
                        color: M.warning.withValues(alpha: 0.32),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 17,
                          color: M.warning,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.7,
                              color: M.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: _busy || _code.text.trim().length < 4
                      ? null
                      : _connect,
                  child: _busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(t.connect),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () {},
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 19),
                  label: Text(t.scanQr),
                ),
                const SizedBox(height: 26),
                Divider(color: p.line),
                const SizedBox(height: 18),
                Text(
                  t.demoMode,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: p.muted,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleButton(
                        icon: Icons.admin_panel_settings_rounded,
                        label: t.iAmManager,
                        color: M.primary,
                        onTap: () =>
                            widget.onConnected(AppRole.manager, demo: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleButton(
                        icon: Icons.family_restroom_rounded,
                        label: t.iAmParent,
                        color: M.info,
                        onTap: () =>
                            widget.onConnected(AppRole.parent, demo: true),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.pal;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(M.radius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(M.radius),
          border: Border.all(color: p.line),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.13),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 21, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
