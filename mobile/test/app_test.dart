import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager_mobile/app.dart';
import 'package:school_manager_mobile/core/api_client.dart';
import 'package:school_manager_mobile/core/session_store.dart';

import 'fake_server.dart';

/// **دا ازموینې ولې ریښتینې دي؟** ځکه چې د اپ کوډ هماغه `ApiClient`
/// کاروي چې په تولید کې. یوازې د HTTP اخري ګام جعلي دی — نو د JSON
/// تجزیه، د غلطیو ښودل، او د پردو جریان ټول ریښتیني ازمویل کېږي.
void main() {
  late FakeServer server;

  setUp(() => server = FakeServer());

  Widget app({SchoolSession? saved}) => SchoolManagerMobile(
    store: MemoryStore(saved),
    clientFactory: (s) => ApiClient(
      baseUrl: s.baseUrl,
      token: s.token,
      client: server.client,
    ),
    pairingClientFactory: (url) =>
        ApiClient(baseUrl: url, client: server.client),
  );

  group('تړل', () {
    testWidgets('اپ د تړلو پاڼې سره پیلېږي', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      expect(find.text('ښوونځي ته وصل شئ'), findsOneWidget);
    });

    testWidgets('پته وګوره — د ښوونځي نوم راښیي', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        '192.168.1.14:8787',
      );
      await tester.tap(find.text('وګوره'));
      await tester.pumpAndSettle();

      expect(find.textContaining('د نور لیسه'), findsOneWidget);
    });

    testWidgets('غلطه پته د پښتو پیغام راکوي، نه تخنیکي متن', (tester) async {
      server.reachable = false;
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '10.0.0.9');
      await tester.tap(find.text('وګوره'));
      await tester.pumpAndSettle();

      expect(find.textContaining('اړیکه ونه شوه'), findsOneWidget);
    });

    testWidgets('ناسم کوډ د سرور پیغام ښیي', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '192.168.1.14');
      await tester.enterText(find.byType(TextField).last, 'ZZZZZZ');
      await tester.tap(find.text('وصل شه'));
      await tester.pumpAndSettle();

      expect(find.textContaining('نه پېژندل کېږي'), findsOneWidget);
    });

    testWidgets('سم کوډ مدیر ډاشبورډ ته بیايي', (tester) async {
      await tester.pumpWidget(app());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '192.168.1.14');
      await tester.enterText(find.byType(TextField).last, 'MGR123');
      await tester.tap(find.text('وصل شه'));
      await tester.pumpAndSettle();

      expect(find.text('نن غیرحاضر'), findsWidgets);
      expect(find.text('نن حاضر'), findsWidgets);
    });
  });

  group('د مدیر پرده', () {
    Widget managerApp() => app(
      saved: const SchoolSession(
        baseUrl: 'http://192.168.1.14:8787',
        token: 'manager-token',
        role: 'manager',
        school: 'د نور لیسه',
        deviceName: 'تلیفون',
      ),
    );

    testWidgets('ساتل شوې غونډه سمدلاسه ډاشبورډ پرانیزي', (tester) async {
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      expect(find.text('د نور لیسه'), findsOneWidget);
      // د حاضرۍ شمېره له سرور څخه راغلې.
      expect(find.text('۷۹۵'), findsOneWidget);
      expect(find.text('۴۷'), findsOneWidget);
    });

    testWidgets('د غیرحاضرۍ خبرتیا د لېږلو تڼۍ لري', (tester) async {
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('غیرحاضر دي'), findsWidgets);
      expect(find.text('والدینو ته پیغام واستوه'), findsOneWidget);
    });

    testWidgets('تڼۍ ریښتیا سرور ته غږ کوي', (tester) async {
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('والدینو ته پیغام واستوه'));
      await tester.pumpAndSettle();

      expect(server.notifyCalls, 1);
      expect(find.textContaining('پیغامونه ولېږل شول'), findsOneWidget);
    });

    testWidgets('د غیرحاضرو ټب لیست او د ټاکنې خانې ښیي', (tester) async {
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('نن غیرحاضر').last);
      await tester.pumpAndSettle();

      expect(find.text('احمد ولي'), findsOneWidget);
      expect(find.text('کریم الله'), findsOneWidget);
      expect(find.textContaining('کورونو ته ولېږه'), findsOneWidget);
    });

    testWidgets('د اجازې غوښتنه له تلیفونه منل کېږي', (tester) async {
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('د تصویب په تمه اجازې').last);
      await tester.pumpAndSettle();

      expect(find.text('زرغونه نوري'), findsOneWidget);
      expect(find.text('د والدینو له اپ'), findsOneWidget);

      // دوه غوښتنې دي — لومړۍ يې منو.
      await tester.tap(find.text('ومنه').first);
      await tester.pumpAndSettle();

      expect(server.decidedLeaves, [(3, true)]);
    });

    testWidgets('باطل شوی توکن اپ بېرته تړلو ته بیايي', (tester) async {
      server.tokenRevoked = true;
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      expect(find.text('ښوونځي ته وصل شئ'), findsOneWidget);
    });

    testWidgets('کله چې سرور بند وي، پرده يې څرګنده وايي', (tester) async {
      server.reachable = false;
      await tester.pumpWidget(managerApp());
      await tester.pumpAndSettle();

      expect(find.textContaining('اړیکه ونه شوه'), findsOneWidget);
      expect(find.text('بیا هڅه وکړه'), findsOneWidget);
    });
  });

  group('د والدینو پرده', () {
    Widget parentApp() => app(
      saved: const SchoolSession(
        baseUrl: 'http://192.168.1.14:8787',
        token: 'parent-token',
        role: 'parent',
        school: 'د نور لیسه',
        deviceName: 'تلیفون',
        guardianId: 7,
        guardianName: 'محمود',
      ),
    );

    testWidgets('ماشومان او د میاشتې سلنه ښکاري', (tester) async {
      await tester.pumpWidget(parentApp());
      await tester.pumpAndSettle();

      expect(find.text('احمد ولي'), findsOneWidget);
      expect(find.text('زرغونه ولي'), findsOneWidget);
      // د حاضرۍ کړۍ سلنه ښیي.
      expect(find.text('۹۴'), findsOneWidget);
    });

    testWidgets('د حاضرۍ کلیز د میاشتې ورځې رنګوي', (tester) async {
      await tester.pumpWidget(parentApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('حاضري').last);
      await tester.pumpAndSettle();

      expect(find.text('غیرحاضر'), findsOneWidget);
      expect(find.text('رخصت'), findsOneWidget);
    });

    testWidgets('پیغامونه راځي او لوستل کېږي', (tester) async {
      await tester.pumpWidget(parentApp());
      await tester.pumpAndSettle();

      await tester.tap(find.text('پیغامونه').last);
      await tester.pumpAndSettle();

      expect(find.textContaining('غیرحاضر و'), findsOneWidget);

      await tester.tap(find.textContaining('غیرحاضر و'));
      await tester.pumpAndSettle();
      expect(server.readMessageIds, contains(11));
    });
  });
}

/// د ازموینې لپاره — فایل ته نه لیکي.
class MemoryStore implements SessionStore {
  SchoolSession? _s;
  MemoryStore(this._s);

  @override
  Future<SchoolSession?> load() async => _s;

  @override
  Future<void> save(SchoolSession s) async => _s = s;

  @override
  Future<void> clear() async => _s = null;

  @override
  noSuchMethod(Invocation i) => super.noSuchMethod(i);
}
