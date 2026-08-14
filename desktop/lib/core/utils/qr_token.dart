import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// د آی‌ډي کارت د QR کوډ جوړول او پېژندل.
///
/// **ولې خام آی‌ډي نمبر نه لیکو؟**
/// که کارت یوازې «S-0423» ولیکي، هر څوک په کور کې د بل شاګرد کارت
/// جوړولی شي — او حاضري بې‌اعتباره کېږي. نو کارت یو لنډ لاسلیک وړي
/// چې یوازې د ښوونځي په پټ کلي جوړېدی شي.
///
/// **بڼه:** `SM1.<admissionNo>.<cardVersion>.<sig>`
///   - `SM1` — نسخه، چې راتلونکې کې بڼه بدلولی شو
///   - `sig` — د لومړیو دریو برخو HMAC-SHA256، ۱۰ تورو ته لنډ شوی
///
/// **ولې ۱۰ توري بس دي؟** دا ~۶۰ بټه ده. د ښوونځي په دروازه کې
/// څوک نه شي کولی میلیونونه کوډونه وازمويي — سکینر یو په یو دی.
/// او که کارت ورک شي، `cardVersion` یو زیاتېږي او زوړ باطلېږي.
class QrToken {
  const QrToken._();

  static const String _prefix = 'SM1';
  static const int _sigLength = 10;

  /// د ښوونځي پټ کلید — په لومړي ران کې جوړېږي او په
  /// `schools` جدول کې ساتل کېږي. هېڅکله چاپ نه شي.
  static String newSchoolKey() {
    final rng = Random.secure();
    final bytes = Uint8List(32);
    for (var i = 0; i < bytes.length; i++) {
      bytes[i] = rng.nextInt(256);
    }
    return base64Url.encode(bytes);
  }

  /// هغه متن چې په QR کې چاپېږي.
  static String encode({
    required String admissionNo,
    required int cardVersion,
    required String schoolKey,
  }) {
    final payload = '$_prefix.$admissionNo.$cardVersion';
    return '$payload.${_sign(payload, schoolKey)}';
  }

  /// د سکین شوي متن پېژندل.
  ///
  /// د حاضرۍ پاڼه دا بلي. که `null` راشي، کوډ جعلي یا خراب دی.
  static QrScan? decode(String raw, String schoolKey) {
    final text = raw.trim();
    final parts = text.split('.');
    if (parts.length != 4) return null;
    if (parts[0] != _prefix) return null;

    final version = int.tryParse(parts[2]);
    if (version == null) return null;

    final payload = '${parts[0]}.${parts[1]}.${parts[2]}';
    if (!_constantTimeEquals(_sign(payload, schoolKey), parts[3])) {
      return null;
    }

    return QrScan(admissionNo: parts[1], cardVersion: version);
  }

  /// ایا دا متن اصلاً د زموږ د کارت بڼه لري؟
  ///
  /// د حاضرۍ پاڼه پرې پوهېږي چې کارن QR سکین کړ که آی‌ډي نمبر
  /// يې په لاس ولیکه — دواړه یوې خانې ته ځي.
  static bool looksLikeToken(String raw) => raw.trim().startsWith('$_prefix.');

  static String _sign(String payload, String key) {
    final mac = Hmac(sha256, utf8.encode(key)).convert(utf8.encode(payload));
    return base64Url
        .encode(mac.bytes)
        .replaceAll('=', '')
        .substring(0, _sigLength);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}

class QrScan {
  final String admissionNo;
  final int cardVersion;
  const QrScan({required this.admissionNo, required this.cardVersion});
}
