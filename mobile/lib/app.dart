import 'package:flutter/material.dart';

import 'core/api_client.dart';
import 'core/design.dart';
import 'core/session_store.dart';
import 'core/strings.dart';
import 'features/manager_home.dart';
import 'features/pairing_page.dart';
import 'features/parent_home.dart';

/// د اپ درې حالته: بارېدل ← تړل ← کور.
enum _Stage { loading, pairing, ready }

class SchoolManagerMobile extends StatefulWidget {
  /// د ازموینې لپاره — چې د فایل او شبکې پر ځای جعلي ورکړل شي.
  final SessionStore? store;
  final ApiClient Function(SchoolSession)? clientFactory;
  final ApiClient Function(String baseUrl)? pairingClientFactory;

  const SchoolManagerMobile({
    super.key,
    this.store,
    this.clientFactory,
    this.pairingClientFactory,
  });

  @override
  State<SchoolManagerMobile> createState() => _SchoolManagerMobileState();
}

class _SchoolManagerMobileState extends State<SchoolManagerMobile> {
  MLocale _locale = MLocale.ps;
  _Stage _stage = _Stage.loading;

  late final SessionStore _store = widget.store ?? SessionStore();
  SchoolSession? _session;
  ApiClient? _api;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  @override
  void dispose() {
    _api?.close();
    super.dispose();
  }

  /// **ولې توکن نه ازمویو؟** ځکه چې ښوونځی ښايي بند وي — یا کارن
  /// له کوره اپ پرانیزي. که دلته ازموینه ناکامه شي او تړل بیا
  /// وغواړو، هغه به هره ورځ له سره کوډ اخیست. نو توکن ساتو او
  /// پردې پخپله وايي چې اړیکه نشته.
  Future<void> _boot() async {
    final s = await _store.load();
    if (!mounted) return;
    setState(() {
      _session = s;
      _api = s == null ? null : _clientFor(s);
      _stage = s == null ? _Stage.pairing : _Stage.ready;
    });
  }

  ApiClient _clientFor(SchoolSession s) =>
      widget.clientFactory?.call(s) ??
      ApiClient(baseUrl: s.baseUrl, token: s.token);

  Future<void> _onConnected(SchoolSession s) async {
    await _store.save(s);
    if (!mounted) return;
    setState(() {
      _session = s;
      _api = _clientFor(s);
      _stage = _Stage.ready;
    });
  }

  Future<void> _disconnect() async {
    await _store.clear();
    if (!mounted) return;
    setState(() {
      _session = null;
      _api = null;
      _stage = _Stage.pairing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LocaleScope(
      locale: _locale,
      setLocale: (l) => setState(() => _locale = l),
      child: MaterialApp(
        title: 'School Manager',
        debugShowCheckedModeBanner: false,
        theme: buildMobileTheme(Brightness.light),
        darkTheme: buildMobileTheme(Brightness.dark),
        themeMode: ThemeMode.system,
        builder: (context, child) =>
            Directionality(textDirection: _locale.direction, child: child!),
        home: switch (_stage) {
          _Stage.loading => const Scaffold(
            body: Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          ),
          _Stage.pairing => PairingPage(
            onConnected: _onConnected,
            clientFactory: widget.pairingClientFactory,
          ),
          _Stage.ready =>
            _session!.isManager
                ? ManagerHome(
                    session: _session!,
                    api: _api!,
                    onDisconnect: _disconnect,
                  )
                : ParentHome(
                    session: _session!,
                    api: _api!,
                    onDisconnect: _disconnect,
                  ),
        },
      ),
    );
  }
}
