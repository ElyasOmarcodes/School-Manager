import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager_mobile/app.dart';
import 'package:school_manager_mobile/core/strings.dart';

void main() {
  testWidgets('اپ د تړلو پاڼې سره پیلېږي', (tester) async {
    await tester.pumpWidget(const SchoolManagerMobile());
    await tester.pumpAndSettle();

    expect(find.text('ښوونځي ته وصل شئ'), findsOneWidget);
    // د تړلو تڼۍ تر هغې بنده ده چې کوډ ولیکل شي.
    final connect = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(connect.onPressed, isNull);
  });

  testWidgets('د مدیر نمونه حالت ډاشبورډ ښیي', (tester) async {
    await tester.pumpWidget(const SchoolManagerMobile());
    await tester.pumpAndSettle();

    await tester.tap(find.text('زه مدیر یم'));
    await tester.pumpAndSettle();

    expect(find.text('نن غیرحاضر'), findsWidgets);
    expect(find.text('والدینو ته پیغام واستوه'), findsOneWidget);
    // د نمونې نښه ښکاري — چې کارن پوه شي دا ریښتینې ډیټا نه ده.
    expect(find.text('نمونه'), findsOneWidget);
  });

  testWidgets('د والدینو نمونه حالت ماشومان ښیي', (tester) async {
    await tester.pumpWidget(const SchoolManagerMobile());
    await tester.pumpAndSettle();

    await tester.tap(find.text('زه والدین یم'));
    await tester.pumpAndSettle();

    expect(find.text('احمد ولي'), findsOneWidget);
    expect(find.text('زرغونه ولي'), findsOneWidget);
  });

  testWidgets('وتل بېرته تړلو پاڼې ته راولي', (tester) async {
    await tester.pumpWidget(const SchoolManagerMobile());
    await tester.pumpAndSettle();

    await tester.tap(find.text('زه مدیر یم'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('ښوونځي ته وصل شئ'), findsOneWidget);
  });

  test('ختیځې شمېرې یوازې د پښتو/دري لپاره', () {
    expect(num_(842, MLocale.ps), '۸۴۲');
    expect(num_(842, MLocale.fa), '۸۴۲');
    // انګلیسي لاتیني ساتي.
    expect(num_(842, MLocale.en), '842');
  });
}
