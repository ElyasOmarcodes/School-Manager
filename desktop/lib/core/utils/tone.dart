import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/services.dart';

/// د حاضرۍ غږونه — **د دروازې پر مخ اورېدل، نه لیدل**.
///
/// **دا ولې پکار دي؟** شاګرد کارت وهي او ژر تېرېږي؛ هغه سکرین ته
/// نه ګوري. که یوازې رنګ بدل شي، د غلط کارت خاوند به پوه نه شي چې
/// حاضري يې ثبت نه شوه او سبا به يې «غیرحاضر» ولیدل. یو لنډ غږ
/// همدا ستونزه حلوي — د منلو لپاره دوه لوړېدونکي نوټونه، د تېروتنې
/// لپاره یو ټیټ اوږد غږ.
///
/// **څنګه؟ پرته له کومې نوې کڅوړې.** وینډوز په `kernel32.dll` کې
/// `Beep(frequency, duration)` لري — یوه ساده سیسټم بلنه. د غږ د
/// یوې کڅوړې (audioplayers او داسې نور) زیاتول به يې د build
/// درنښت زیات کړی و، هغه هم د دوو غږونو لپاره.
typedef _BeepC = Int32 Function(Uint32 freq, Uint32 ms);
typedef _BeepDart = int Function(int freq, int ms);

/// یو نوټ — فریکونسي (هرتز) او اوږدوالی (ملي‌ثانیه).
typedef Note = ({int hz, int ms});

class Tone {
  Tone._();

  /// ثبت شو — دوه لوړېدونکي نوټونه، خوشحاله او لنډ.
  static const List<Note> accept = [(hz: 1180, ms: 70), (hz: 1560, ms: 90)];

  /// تېروتنه — یو ټیټ اوږد غږ. له منلو سره هېڅ ورته والی نه لري،
  /// نو له لرې هم توپیر يې معلومېږي.
  static const List<Note> error = [(hz: 320, ms: 260)];

  /// خبرداری — «مخکې ثبت شوی» یا «رخصت دی». نه ښه، نه بد.
  static const List<Note> warn = [(hz: 760, ms: 80), (hz: 620, ms: 110)];

  /// که کارن غږونه بند کړي وي، دا `false` ګرځي.
  static bool enabled = true;

  /// **دا هېڅکله نه غورځوي.** د غږ نه وتل د حاضرۍ د بندېدو ارزښت
  /// نه لري — که سپیکر نه وي یا سیسټم بل وي، پروګرام خپل کار کوي.
  static Future<void> play(List<Note> notes) async {
    if (!enabled) return;

    if (Platform.isWindows) {
      try {
        // په جلا isolate کې، ځکه چې `Beep` ځنډېدونکې بلنه ده — که
        // په اصلي thread کې وای، د هر سکین سره به UI ټک ټک کاوه.
        await Isolate.run(() => _beepAll(notes));
        return;
      } catch (_) {
        // ffi ناکام شو — لاندې عام غږ ته ورځو.
      }
    }

    try {
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      /* غږ نشته — پروا نه لري */
    }
  }

  static void _beepAll(List<Note> notes) {
    final lib = DynamicLibrary.open('kernel32.dll');
    final beep = lib.lookupFunction<_BeepC, _BeepDart>('Beep');
    for (final n in notes) {
      beep(n.hz, n.ms);
    }
  }
}
