import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'api_router.dart';

/// د سرور ژوندی حساب — څومره غوښتنې راغلې او له کومو پتو څخه.
///
/// **دا ولې پکار دی؟** ځکه چې «سرور روان دی» یوازې دا معنا لري چې
/// پروګرام یوه دروازه پرانیسته. که د ویندوز فایروال مخې ته ولاړ وي،
/// دروازه پرانیستې ده خو څوک ورڅخه نه شي راتلای — او پروګرام يې
/// نه پوهېږي. یوازې د **راغلو غوښتنو شمېر** دا توپیر ښیي:
/// صفر = هېڅ چا لاس نه دی رسولی.
class ServerStats {
  int requests = 0;
  DateTime? lastRequestAt;
  final Set<String> clientIps = {};

  void record(String? ip) {
    requests++;
    lastRequestAt = DateTime.now();
    if (ip != null) clientIps.add(ip);
  }

  void reset() {
    requests = 0;
    lastRequestAt = null;
    clientIps.clear();
  }

  /// سرور روان دی خو هېڅوک نه دی راغلی — تر ټولو ډېر ځله فایروال.
  bool get silent => requests == 0;
}

/// د محلي شبکې یوه پته چې تلیفون ورسره وصل کېدی شي.
class LanEndpoint {
  final String interfaceName;
  final String address;
  final int port;

  const LanEndpoint({
    required this.interfaceName,
    required this.address,
    required this.port,
  });

  String get url => 'http://$address:$port';
}

/// د ښوونځي محلي سرور.
///
/// **دا سرور څه دی او څه نه دی.**
/// دا **کلاوډ نه دی**. دا هماغه کمپیوټر دی چې پروګرام پرې ځغلي —
/// د ښوونځي په Wi-Fi پورې تړلی. د مدیر تلیفون هماغه Wi-Fi ته
/// وصل کېږي او دې پتې ته غږ کوي. نو:
///   • انټرنټ ته اړتیا نشته
///   • د ډیټا مصرف صفر دی
///   • ډیټا له ښوونځي بهر نه ځي
///
/// کله چې ښوونځی وغواړي چې والدین له کوره وګوري، هماغه API به
/// یو کلاوډ سرور ته ولېږدول شي — د اپ کوډ به بدلون ته اړتیا ونه
/// لري، یوازې پته به بدله شي.
class LocalServer {
  final ApiDeps deps;

  /// **ولې ۸۷۸۷؟** د عامو پورټونو (۸۰، ۸۰۸۰، ۳۰۰۰) څخه لرې دی،
  /// نو د ښوونځي په کمپیوټر کې د بل پروګرام سره نه ټکر کېږي.
  static const int defaultPort = 8787;

  HttpServer? _http;
  LocalServer(this.deps);

  ServerStats get stats => deps.stats;

  bool get isRunning => _http != null;
  int? get port => _http?.port;

  /// **د ویندوز فایروال قاعده.**
  ///
  /// دا هغه یوه بلنه ده چې تر ټولو ډېر ځله ستونزه حلوي. مدیر يې
  /// کاپي کوي او په «Command Prompt (Administrator)» کې يې ځغلوي.
  ///
  /// `profile=any` ولې؟ ځکه چې ویندوز ځینې Wi-Fi شبکې «Public»
  /// ګڼي. که قاعده یوازې د «Private» لپاره وي، په هغو شبکو کې به
  /// بې‌کاره وه — او مدیر به يې لامل نه موند.
  String firewallCommand({int? port}) {
    final p = port ?? this.port ?? defaultPort;
    return 'netsh advfirewall firewall add rule '
        'name="School Manager ($p)" dir=in action=allow '
        'protocol=TCP localport=$p profile=any';
  }

  Future<int> start({int port = defaultPort}) async {
    if (_http != null) return _http!.port;

    // `anyIPv4` = د شبکې ټولې پتې. که یوازې localhost وای، د
    // ښوونځي تلیفون به ورسره نه شو وصلېدی — او دا خو ټول موخه ده.
    deps.stats.reset();
    final server = await shelf_io.serve(
      buildApi(deps),
      InternetAddress.anyIPv4,
      port,
      shared: true,
    );
    server.autoCompress = true;
    _http = server;
    return server.port;
  }

  Future<void> stop() async {
    final s = _http;
    _http = null;
    await s?.close(force: true);
  }

  /// هغه پتې چې مدیر يې تلیفون ته ورکوي.
  ///
  /// د loopback او د Docker/VirtualBox جوړې شوې پتې پرېږدو — هغه
  /// د ښوونځي په Wi-Fi کې کار نه کوي او یوازې مدیر ګمراه کوي.
  static Future<List<LanEndpoint>> lanEndpoints({
    int port = defaultPort,
  }) async {
    final out = <LanEndpoint>[];
    try {
      // **وخت‌محدودیت ولې؟** په ځینو ویندوز کمپیوټرونو کې چې د
      // VPN یا مړ شبکې اډاپټر ولري، دا بلنه اوږده ځنډېږي. د
      // تنظیماتو پاڼه باید ودرېږي نه.
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        type: InternetAddressType.IPv4,
      ).timeout(const Duration(seconds: 3), onTimeout: () => const []);
      for (final i in interfaces) {
        for (final a in i.addresses) {
          if (a.address.startsWith('169.254.')) continue; // link-local
          out.add(
            LanEndpoint(
              interfaceName: i.name,
              address: a.address,
              port: port,
            ),
          );
        }
      }
    } on SocketException {
      // په ځینو ویندوز چاپېریالونو کې د شبکې لیست بند وي — دا د
      // پروګرام د درېدو لامل نه دی.
    }
    return out;
  }
}
