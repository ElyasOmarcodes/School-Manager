import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf_io.dart' as shelf_io;

import 'api_router.dart';

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

  bool get isRunning => _http != null;
  int? get port => _http?.port;

  Future<int> start({int port = defaultPort}) async {
    if (_http != null) return _http!.port;

    // `anyIPv4` = د شبکې ټولې پتې. که یوازې localhost وای، د
    // ښوونځي تلیفون به ورسره نه شو وصلېدی — او دا خو ټول موخه ده.
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
