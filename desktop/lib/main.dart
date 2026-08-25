import 'dart:io';

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/config/app_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // د ډیسکټاپ وینډو تنظیم — چې د یوه ریښتیني سافټویر په څېر
  // پرانیستل شي، نه د یوې کوچنۍ ازمویښتي کړکۍ.
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    const opts = WindowOptions(
      size: Size(1440, 900),
      minimumSize: Size(1100, 700),
      center: true,
      title: 'School Manager',
      titleBarStyle: TitleBarStyle.normal,
    );
    await windowManager.waitUntilReadyToShow(opts, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // تنظیمات مخکې له UI لوستل کېږي — چې پوه شو ویزارډ ښکاره کړو
  // که مستقیم ننوتلو ته ولاړ شو.
  final store = ConfigStore();
  final config = await store.load();

  runApp(SchoolManagerApp(store: store, initialConfig: config));
}
