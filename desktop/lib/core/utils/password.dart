import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

/// د پاسورډ هش کول — PBKDF2-HMAC-SHA256.
///
/// ولې Argon2id نه، چې پلان کې يې یاد و؟ ځکه چې Argon2 په Dart کې
/// native کتابتون ته اړتیا لري، او هغه د ویندوز په ځینو ماشینونو کې
/// د انټي‌ویروس ستونزه جوړوي. PBKDF2 د ۱۲۰,۰۰۰ تکرارونو سره د
/// ښوونځي د ګواښ‌کچې لپاره بشپړ بس دی او خالص Dart دی.
///
/// که وروسته Argon2 وغواړو، یوازې دا فایل بدلېږي — د کاروونکو
/// جدول د `passwordIterations` ستن لري نو زاړه هشونه هم کار کوي.
class Password {
  const Password._();

  static const int defaultIterations = 120000;
  static const int _saltBytes = 16;
  static const int _keyBytes = 32;

  static final Random _rng = Random.secure();

  static String newSalt() {
    final b = Uint8List(_saltBytes);
    for (var i = 0; i < b.length; i++) {
      b[i] = _rng.nextInt(256);
    }
    return base64Encode(b);
  }

  static String hash({
    required String password,
    required String salt,
    int iterations = defaultIterations,
  }) {
    final key = _pbkdf2(
      utf8.encode(password),
      base64Decode(salt),
      iterations,
      _keyBytes,
    );
    return base64Encode(key);
  }

  /// د وخت-ثابت پرتلنه — چې د ځواب له وخته پاسورډ ونه اټکل شي.
  static bool verify({
    required String password,
    required String salt,
    required String expectedHash,
    int iterations = defaultIterations,
  }) {
    final actual = hash(password: password, salt: salt, iterations: iterations);
    return _constantTimeEquals(actual, expectedHash);
  }

  static bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }

  static Uint8List _pbkdf2(
    List<int> password,
    List<int> salt,
    int iterations,
    int keyLength,
  ) {
    final hmac = Hmac(sha256, password);
    final out = Uint8List(keyLength);
    final blockCount = (keyLength / 32).ceil();
    var offset = 0;

    for (var block = 1; block <= blockCount; block++) {
      // U1 = HMAC(password, salt || INT_BE32(block))
      final input = Uint8List(salt.length + 4)
        ..setRange(0, salt.length, salt)
        ..buffer.asByteData().setUint32(salt.length, block, Endian.big);

      var u = Uint8List.fromList(hmac.convert(input).bytes);
      final acc = Uint8List.fromList(u);

      for (var i = 1; i < iterations; i++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var j = 0; j < acc.length; j++) {
          acc[j] ^= u[j];
        }
      }

      final take = (keyLength - offset).clamp(0, acc.length);
      out.setRange(offset, offset + take, acc);
      offset += take;
    }
    return out;
  }
}
