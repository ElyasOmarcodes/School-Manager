@Tags(['screenshots'])
library;

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager_mobile/app.dart';
import 'package:school_manager_mobile/core/api_client.dart';
import 'package:school_manager_mobile/core/session_store.dart';

import 'app_test.dart' show MemoryStore;
import 'fake_server.dart';

/// د موبایل اپ سکرین‌شاټونه.
///
/// چلول:  flutter test test/screenshots_test.dart --update-goldens
void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await _loadFonts();
  });

  const manager = SchoolSession(
    baseUrl: 'http://192.168.1.14:8787',
    token: 'manager-token',
    role: 'manager',
    school: 'د نور لیسه',
    deviceName: 'د مدیر Samsung',
  );

  const parent = SchoolSession(
    baseUrl: 'http://192.168.1.14:8787',
    token: 'parent-token',
    role: 'parent',
    school: 'د نور لیسه',
    deviceName: 'Infinix',
    guardianId: 7,
    guardianName: 'محمود',
  );

  testWidgets('m1 — د تړلو پاڼه', (tester) async {
    await _shoot(tester, name: 'm1-pairing');
  });

  testWidgets('m2 — د مدیر ډاشبورډ او خبرتیا', (tester) async {
    await _shoot(tester, name: 'm2-manager-home', session: manager);
  });

  testWidgets('m3 — د مدیر ډاشبورډ (تیاره)', (tester) async {
    await _shoot(
      tester,
      name: 'm3-manager-dark',
      session: manager,
      brightness: Brightness.dark,
    );
  });

  testWidgets('m4 — نن غیرحاضر', (tester) async {
    await _shoot(
      tester,
      name: 'm4-manager-absentees',
      session: manager,
      after: (t) async {
        await t.tap(find.text('نن غیرحاضر').last);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('m5 — د اجازې غوښتنې', (tester) async {
    await _shoot(
      tester,
      name: 'm5-manager-leave',
      session: manager,
      after: (t) async {
        await t.tap(find.text('د تصویب په تمه اجازې').last);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('m6 — د والدینو کور', (tester) async {
    await _shoot(tester, name: 'm6-parent-home', session: parent);
  });

  testWidgets('m7 — د میاشتې حاضري', (tester) async {
    await _shoot(
      tester,
      name: 'm7-parent-attendance',
      session: parent,
      after: (t) async {
        await t.tap(find.text('حاضري').last);
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('m9 — د والدینو نمرې', (tester) async {
    await _shoot(
      tester,
      name: 'm9-parent-results',
      session: parent,
      after: (t) async {
        await t.tap(find.text('حاضري').last);
        await t.pumpAndSettle();
        await t.tap(find.text('نمرې').last);
        await t.pumpAndSettle();
        await t.tap(find.text('د لومړۍ ربعې ازموینه'));
        await t.pumpAndSettle();
      },
    );
  });

  testWidgets('m8 — د والدینو پیغامونه', (tester) async {
    await _shoot(
      tester,
      name: 'm8-parent-messages',
      session: parent,
      after: (t) async {
        await t.tap(find.text('پیغامونه').last);
        await t.pumpAndSettle();
      },
    );
  });
}

/// د یوه معیاري اندروید تلیفون اندازه.
const Size _phone = Size(412, 892);

Future<void> _shoot(
  WidgetTester tester, {
  required String name,
  SchoolSession? session,
  Brightness brightness = Brightness.light,
  Future<void> Function(WidgetTester)? after,
}) async {
  final server = FakeServer();
  await tester.binding.setSurfaceSize(_phone);
  addTearDown(() => tester.binding.setSurfaceSize(null));

  tester.platformDispatcher.platformBrightnessTestValue = brightness;
  addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);

  await tester.pumpWidget(
    SchoolManagerMobile(
      store: MemoryStore(session),
      clientFactory: (s) => ApiClient(
        baseUrl: s.baseUrl,
        token: s.token,
        client: server.client,
      ),
      pairingClientFactory: (url) =>
          ApiClient(baseUrl: url, client: server.client),
    ),
  );
  await tester.pumpAndSettle(const Duration(milliseconds: 60));
  await after?.call(tester);

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('screenshots/$name.png'),
  );
}

Future<void> _loadFonts() async {
  await _load('Vazirmatn', [
    'assets/fonts/Vazirmatn-Regular.ttf',
    'assets/fonts/Vazirmatn-Medium.ttf',
    'assets/fonts/Vazirmatn-SemiBold.ttf',
    'assets/fonts/Vazirmatn-Bold.ttf',
  ]);
  final icons = _findMaterialIcons();
  if (icons != null) await _load('MaterialIcons', [icons]);
}

Future<void> _load(String family, List<String> paths) async {
  final loader = FontLoader(family);
  var any = false;
  for (final path in paths) {
    final f = File(path);
    if (!f.existsSync()) continue;
    loader.addFont(
      f.readAsBytes().then((b) => ByteData.view(b.buffer)),
    );
    any = true;
  }
  if (any) await loader.load();
}

/// د Flutter SDK له کیش څخه د Material نښو فونټ پیدا کوي.
String? _findMaterialIcons() {
  var dir = Directory(File(Platform.resolvedExecutable).parent.path);
  for (var i = 0; i < 8; i++) {
    final candidate = File(
      '${dir.path}/artifacts/material_fonts/MaterialIcons-Regular.otf',
    );
    if (candidate.existsSync()) return candidate.path;
    final cache = File(
      '${dir.path}/bin/cache/artifacts/material_fonts/'
      'MaterialIcons-Regular.otf',
    );
    if (cache.existsSync()) return cache.path;
    final parent = dir.parent;
    if (parent.path == dir.path) break;
    dir = parent;
  }
  return null;
}
