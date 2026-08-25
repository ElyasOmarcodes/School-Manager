import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:school_manager/widgets/data_table_view.dart' show AvatarCell;
import 'package:flutter/material.dart';
import 'package:school_manager/core/theme/app_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/l10n/strings.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/card_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/features/id_cards/card_canvas.dart';
import 'package:school_manager/features/id_cards/card_layout.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CardRepository cards;
  late AcademicRepository academic;
  late StudentRepository students;

  final now = DateTime(2026, 5, 12);

  setUp(() async {
    db = AppDatabase.memory();
    cards = CardRepository(db);
    academic = AcademicRepository(db);
    students = StudentRepository(db);

    await db.into(db.schools).insert(SchoolsCompanion.insert(name: 'ازموینه'));
    await academic.seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026),
      endsOn: DateTime(2026, 12, 21),
      fromLevel: 1,
      toLevel: 2,
      sectionNames: const ['الف'],
    );
  });

  tearDown(() => db.close());

  Future<int> admit(String no, String name) => students.admit(
    student: StudentsCompanion.insert(
      admissionNo: no,
      firstName: name,
      fatherName: 'پلار',
      gender: 'male',
    ),
    guardians: [
      GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
    ],
    byUserId: 1,
    byUserName: 'admin',
  );

  Future<int> addTeacher(String name, String no) => db
      .into(db.teachers)
      .insert(
        TeachersCompanion.insert(
          employeeNo: no,
          fullName: name,
          gender: 'male',
          specialization: const Value('ریاضي'),
        ),
      );

  // ═══════════════════════════════════════════════════════
  group('د کارت اندازه', () {
    test('معیاري اندازه نه بدلېږي', () {
      final s = printSize(widthMm: cr80WidthMm, heightMm: cr80HeightMm);
      expect(s.width, closeTo(cr80WidthMm, 0.001));
      expect(s.height, closeTo(cr80HeightMm, 0.001));
    });

    test('**کوچنی کارت تل پورته کېږي** — نسبت يې نه ماتېږي', () {
      // نیمه اندازه — باید دقیقاً دوه ځله لویه شي.
      final s = printSize(widthMm: 42.8, heightMm: 27.0);
      expect(s.width, closeTo(cr80WidthMm, 0.001));
      expect(s.height, closeTo(cr80HeightMm, 0.001));
      // نسبت هماغه پاتې دی، نو ډیزاین نه ماتېږي.
      expect(s.width / s.height, closeTo(42.8 / 27.0, 0.0001));
    });

    test('یو اړخ که کوچنی وي، دواړه پورته ځي', () {
      // پلنوالی بس دی، لوړوالی نه — نو باید د لوړوالي له مخې لوی شي.
      final s = printSize(widthMm: 100, heightMm: 40);
      expect(s.height, greaterThanOrEqualTo(cr80HeightMm - 0.001));
      expect(s.width, greaterThanOrEqualTo(100));
      expect(s.width / s.height, closeTo(100 / 40, 0.0001));
    });

    test('لوی کارت نه کوچنی کېږي', () {
      final s = printSize(widthMm: 105, heightMm: 74);
      expect(s.width, closeTo(105, 0.001));
      expect(s.height, closeTo(74, 0.001));
    });

    test('بې‌معنا اندازه معیار ته ورګرځي', () {
      final s = printSize(widthMm: 0, heightMm: -5);
      expect(s.width, cr80WidthMm);
      expect(s.height, cr80HeightMm);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('ډیزاین', () {
    test('لیکل او لوستل یو شان پاتې کېږي', () {
      const layout = CardLayout(
        background: 0xFF112233,
        bandColor: 0xFF445566,
        bandHeight: 0.31,
        cornerRadius: 0.05,
        fields: [
          CardField(
            kind: CardFieldKind.fullName,
            x: 0.21,
            y: 0.42,
            fontScale: 0.13,
            bold: true,
            color: 0xFFAABBCC,
            align: 'center',
          ),
          CardField(
            kind: CardFieldKind.text,
            x: 0.1,
            y: 0.9,
            text: 'یو ثابت متن',
            visible: false,
          ),
        ],
      );

      final back = CardLayout.decode(layout.encode());
      expect(back.background, layout.background);
      expect(back.bandHeight, layout.bandHeight);
      expect(back.fields, hasLength(2));
      expect(back.fields[0].kind, CardFieldKind.fullName);
      expect(back.fields[0].bold, isTrue);
      expect(back.fields[0].align, 'center');
      expect(back.fields[1].text, 'یو ثابت متن');
      expect(back.fields[1].visible, isFalse);
    });

    test('**خراب JSON یوه پاڼه نه ماتوي**', () {
      // یو ډیزاین چې له بلې نسخې راغلی — باید تلواله راشي.
      expect(CardLayout.decode('{[').fields, isEmpty);
      expect(CardLayout.decode('').fields, isEmpty);
      expect(CardLayout.decode(null).background, 0xFFFFFFFF);
      // نیمګړې ساحې تلوالې اخلي، نه استثنا.
      final partial = CardLayout.decode('{"fields":[{"kind":"qr"}]}');
      expect(partial.fields.single.kind, CardFieldKind.qr);
      expect(partial.fields.single.visible, isTrue);
      // ناپېژندلی ډول متن ګڼل کېږي، نه یوه تېروتنه.
      final unknown = CardLayout.decode('{"fields":[{"kind":"zzz"}]}');
      expect(unknown.fields.single.kind, CardFieldKind.text);
    });

    test('**د شالید انځور او پرده ساتل کېږي**', () {
      const layout = CardLayout(
        backgroundImage: r'D:\photos\bg.png',
        backgroundFit: 'contain',
        backgroundOpacity: 0.6,
        overlayColor: 0xFF001122,
        overlayOpacity: 0.35,
        bandSide: BandSide.bottom,
        bandColor2: 0xFF445566,
      );

      final back = CardLayout.decode(layout.encode());
      expect(back.backgroundImage, r'D:\photos\bg.png');
      expect(back.backgroundFit, 'contain');
      expect(back.backgroundOpacity, 0.6);
      expect(back.overlayColor, 0xFF001122);
      expect(back.overlayOpacity, 0.35);
      expect(back.bandSide, BandSide.bottom);
      expect(back.bandColor2, 0xFF445566);
    });

    test('انځور لرې کول ریښتیا يې لرې کوي', () {
      const layout = CardLayout(backgroundImage: 'x.png');
      final cleared = layout.copyWith(clearBackgroundImage: true);
      expect(cleared.backgroundImage, isNull);
      // `copyWith` پرته له `clear` يې نه لمسوي.
      expect(layout.copyWith(backgroundOpacity: 0.5).backgroundImage, 'x.png');
    });

    test('ناپېژندلې د کرښې خوا پاسنۍ ګڼل کېږي', () {
      final l = CardLayout.decode('{"bandSide":"diagonal"}');
      expect(l.bandSide, BandSide.top);
    });

    test('**پلنوالی: ټاکل شوی، تش، او بکس**', () {
      const boxSet = CardField(kind: CardFieldKind.qr, x: 0.1, y: 0.1, w: 0.3);
      expect(fieldWidth(boxSet, 100), 30);

      // بکس چې پلنوالی ونه لري — یوه معقوله تلواله، نه صفر.
      const boxUnset = CardField(kind: CardFieldKind.qr, x: 0.1, y: 0.1);
      expect(fieldWidth(boxUnset, 100), 20);

      // متن چې پلنوالی ونه لري — تر کیڼې څنډې پورې.
      const textUnset = CardField(
        kind: CardFieldKind.fullName,
        x: 0.2,
        y: 0.1,
      );
      expect(fieldWidth(textUnset, 100), closeTo(76, 0.001));

      // متن چې پلنوالی ولري — هماغه، نو د QR پر سر نه راځي.
      const textSet = CardField(
        kind: CardFieldKind.fullName,
        x: 0.2,
        y: 0.1,
        w: 0.4,
      );
      expect(fieldWidth(textSet, 100), 40);
    });

    test('د اندازې د بدلولو پیل له اوسني پلنوالي دی', () {
      // که پیل صفر و، لومړی کش به ساحه سمدستي وړه کړې وه.
      const unset = CardField(kind: CardFieldKind.photo, x: 0, y: 0);
      expect(fieldRatioW(unset), greaterThan(0));
      expect(fieldRatioH(unset), greaterThan(0));

      const set = CardField(
        kind: CardFieldKind.photo,
        x: 0,
        y: 0,
        w: 0.33,
        h: 0.44,
      );
      expect(fieldRatioW(set), 0.33);
      expect(fieldRatioH(set), 0.44);
    });

    test('هره ډله خپلې کینډۍ لري، او سره توپیر لري', () {
      final s = builtInCardTemplates('student');
      final t = builtInCardTemplates('teacher');
      final f = builtInCardTemplates('staff');

      expect(s, isNotEmpty);
      expect(t, isNotEmpty);
      expect(f, isNotEmpty);
      expect(s.every((x) => x.audience == 'student'), isTrue);
      expect(t.every((x) => x.audience == 'teacher'), isTrue);

      // **د رنګ توپیر** — دروازې ته د یوه متره پېژندنه.
      expect(s.first.layout.bandColor, isNot(t.first.layout.bandColor));
      expect(t.first.layout.bandColor, isNot(f.first.layout.bandColor));

      // ټولې کینډۍ د پای نېټه لري — هغه څه چې مخکې نه و.
      for (final tpl in [...s, ...t, ...f]) {
        expect(
          tpl.layout.fields.any((x) => x.kind == CardFieldKind.expiry),
          isTrue,
          reason: '${tpl.key} د پای نېټه نه لري',
        );
      }
    });

    test('**کینډۍ په جوړښت سره بېلې دي، نه یوازې په رنګ**', () {
      final all = builtInCardTemplates('student');
      expect(all.length, greaterThanOrEqualTo(5));

      // هره کینډۍ یو بېل «نښان» لري: د کرښې خوا + پنډوالی + د
      // انځور ځای + د QR اندازه. که دوه یو شان وو، یوه يې د بلې
      // رنګ‌بدله کاپي وه.
      String shape(BuiltInTemplate t) {
        final l = t.layout;
        final photo = l.fields.firstWhere(
          (f) => f.kind == CardFieldKind.photo,
          orElse: () => const CardField(kind: CardFieldKind.text, x: -1, y: -1),
        );
        final qr = l.fields.firstWhere(
          (f) => f.kind == CardFieldKind.qr,
          orElse: () => const CardField(kind: CardFieldKind.text, x: -1, y: -1),
        );
        return '${l.bandSide.name}/${l.bandHeight.toStringAsFixed(2)}'
            '/${photo.x.toStringAsFixed(2)},${photo.w.toStringAsFixed(2)}'
            '/${qr.x.toStringAsFixed(2)},${qr.w.toStringAsFixed(2)}'
            '/${t.widthMm.toStringAsFixed(0)}x${t.heightMm.toStringAsFixed(0)}';
      }

      final shapes = all.map(shape).toList();
      expect(
        shapes.toSet().length,
        shapes.length,
        reason: 'دوه کینډۍ یو جوړښت لري: $shapes',
      );

      // **لږ تر لږه یوه عمودي** — د غاړې لاسبند لپاره.
      expect(all.any((t) => t.isPortrait), isTrue);
      // **لږ تر لږه یوه پرته له پورتنۍ کرښې.**
      expect(all.any((t) => t.layout.bandSide != BandSide.top), isTrue);
      // **لږ تر لږه یوه چې انځور يې نیم کارت نیسي.**
      expect(
        all.any(
          (t) => t.layout.fields.any(
            (f) => f.kind == CardFieldKind.photo && f.w >= 0.4,
          ),
        ),
        isTrue,
      );
    });

    test('عمودي کینډۍ ریښتیا عمودي ده', () {
      final portrait = builtInCardTemplates(
        'teacher',
      ).firstWhere((t) => t.isPortrait);
      expect(portrait.heightMm, greaterThan(portrait.widthMm));
      // او د چاپ تضمین يې نه ماتوي.
      final s = printSize(
        widthMm: portrait.widthMm,
        heightMm: portrait.heightMm,
      );
      expect(s.width, greaterThanOrEqualTo(portrait.widthMm - 0.001));
    });
  });

  // ═══════════════════════════════════════════════════════
  group('کینډۍ ذخیره', () {
    test('ساتل، فعالول او یوازې یوه فعاله', () async {
      final a = await cards.saveTemplate(
        name: 'لومړی',
        audience: 'student',
        layoutJson: const CardLayout().encode(),
        activate: true,
      );
      final b = await cards.saveTemplate(
        name: 'دویم',
        audience: 'student',
        layoutJson: const CardLayout().encode(),
        activate: true,
      );

      final all = await cards.templates('student');
      expect(all, hasLength(2));
      expect(all.where((t) => t.isActive), hasLength(1));
      expect((await cards.active('student'))!.id, b);
      expect(a, isNot(b));
    });

    test('د یوې ډلې فعالول بلې ته زیان نه رسوي', () async {
      await cards.saveTemplate(
        name: 'د شاګرد',
        audience: 'student',
        layoutJson: const CardLayout().encode(),
        activate: true,
      );
      await cards.saveTemplate(
        name: 'د استاد',
        audience: 'teacher',
        layoutJson: const CardLayout().encode(),
        activate: true,
      );

      expect((await cards.active('student'))!.name, 'د شاګرد');
      expect((await cards.active('teacher'))!.name, 'د استاد');
    });

    test('**فعاله کینډۍ نه ړنګېږي**', () async {
      final id = await cards.saveTemplate(
        name: 'فعاله',
        audience: 'student',
        layoutJson: const CardLayout().encode(),
        activate: true,
      );
      // که ړنګه شوې وای، چاپ به بې‌ډیزاینه پاتې و.
      expect(await cards.removeTemplate(id), isFalse);
      expect(await cards.templates('student'), hasLength(1));

      final other = await cards.saveTemplate(
        name: 'بله',
        audience: 'student',
        layoutJson: const CardLayout().encode(),
      );
      expect(await cards.removeTemplate(other), isTrue);
      expect(await cards.templates('student'), hasLength(1));
    });

    test('کاپي کول نوی ریکارډ جوړوي، زوړ نه لمسوي', () async {
      final id = await cards.saveTemplate(
        name: 'اصلي',
        audience: 'student',
        layoutJson: const CardLayout(bandColor: 0xFF123456).encode(),
        widthMm: 90,
        heightMm: 60,
      );
      final copy = await cards.duplicate(id, 'کاپي');

      final all = await cards.templates('student');
      expect(all, hasLength(2));
      final c = all.firstWhere((t) => t.id == copy);
      expect(c.name, 'کاپي');
      expect(c.widthMm, 90);
      expect(CardLayout.decode(c.layoutJson).bandColor, 0xFF123456);
      expect(c.isActive, isFalse);
    });

    test('سمون نوې کینډۍ نه جوړوي', () async {
      final id = await cards.saveTemplate(
        name: 'اصلي',
        audience: 'student',
        layoutJson: const CardLayout().encode(),
      );
      await cards.saveTemplate(
        id: id,
        name: 'بدل شوی',
        audience: 'student',
        layoutJson: const CardLayout(bandColor: 0xFF999999).encode(),
      );

      final all = await cards.templates('student');
      expect(all, hasLength(1));
      expect(all.single.name, 'بدل شوی');
      expect(CardLayout.decode(all.single.layoutJson).bandColor, 0xFF999999);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('خاوندان او د پای نېټه', () {
    test('درې ډلې بېل لیستونه راوړي', () async {
      await admit('1405-0001', 'زلمی');
      await addTeacher('استاد احمد', 'T-0001');
      await db
          .into(db.staffMembers)
          .insert(
            StaffMembersCompanion.insert(
              employeeNo: 'S-0001',
              fullName: 'عبدالغفار',
              jobTitle: 'محاسب',
              gender: 'male',
            ),
          );

      expect(await cards.holders(audience: 'student', now: now), hasLength(1));
      final t = await cards.holders(audience: 'teacher', now: now);
      expect(t.single.subtitle, 'ریاضي');
      final f = await cards.holders(audience: 'staff', now: now);
      expect(f.single.subtitle, 'محاسب');
    });

    test('پلټنه په نوم او نمبر دواړو', () async {
      await admit('1405-0001', 'زلمی');
      await admit('1405-0002', 'احمد');

      expect(
        await cards.holders(audience: 'student', now: now, query: 'احمد'),
        hasLength(1),
      );
      expect(
        await cards.holders(audience: 'student', now: now, query: '0002'),
        hasLength(1),
      );
      // ختیځې شمېرې هم — کارن يې په کیبورډ لیکي.
      expect(
        await cards.holders(audience: 'student', now: now, query: '۰۰۰۲'),
        hasLength(1),
      );
    });

    test('**د کارت حال** — نه لري، روان، نژدې پای، باطل', () async {
      final id = await admit('1405-0001', 'زلمی');

      var h = (await cards.holders(audience: 'student', now: now)).single;
      expect(h.stateAt(now), 'none');
      expect(h.hasCard, isFalse);

      await cards.issue(
        audience: 'student',
        ids: [id],
        expiresOn: DateTime(2026, 12, 21),
      );
      h = (await cards.holders(audience: 'student', now: now)).single;
      expect(h.stateAt(now), 'valid');

      // دېرش ورځې پاتې — «نژدې پای».
      expect(h.stateAt(DateTime(2026, 12, 1)), 'soon');
      // وخت تېر — «باطل».
      expect(h.stateAt(DateTime(2027, 1, 1)), 'expired');
      expect(h.expiredAt(DateTime(2027, 1, 1)), isTrue);
    });

    test('د حال فلټر', () async {
      final a = await admit('1405-0001', 'لري');
      await admit('1405-0002', 'نه لري');
      await cards.issue(
        audience: 'student',
        ids: [a],
        expiresOn: DateTime(2026, 12, 21),
      );

      final none = await cards.holders(
        audience: 'student',
        now: now,
        state: 'none',
      );
      expect(none.single.fullName, 'نه لري');

      final valid = await cards.holders(
        audience: 'student',
        now: now,
        state: 'valid',
      );
      expect(valid.single.fullName, 'لري');
    });

    test('تلواله نېټه د درسي کال پای دی', () async {
      expect(await cards.defaultExpiry(now), DateTime(2026, 12, 21));
    });

    test('که کال تېر شوی وي، یو کال له نن څخه', () async {
      // د کال پای تېر شوی — نو یوه تېره نېټه کارت ته نه ورکوو.
      final late = DateTime(2027, 3, 1);
      final expiry = await cards.defaultExpiry(late);
      expect(expiry.isAfter(late), isTrue);
      expect(expiry.year, 2028);
    });

    test('**د استادانو نېټه د شاګردانو نه لمسوي**', () async {
      final s = await admit('1405-0001', 'زلمی');
      final t = await addTeacher('استاد احمد', 'T-0001');

      await cards.issue(
        audience: 'teacher',
        ids: [t],
        expiresOn: DateTime(2026, 12, 21),
      );

      expect(
        (await cards.holders(audience: 'student', now: now)).single.hasCard,
        isFalse,
      );
      expect(
        (await cards.holders(audience: 'teacher', now: now)).single.hasCard,
        isTrue,
      );
      expect(s, isNotNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د کارت ارزښتونه', () {
    const locale = AppLocale.ps;

    const values = CardValues(
      schoolName: 'د نور لیسه',
      fullName: 'احمد ولي',
      fatherName: 'محمود',
      idNo: '1405-0042',
      className: 'لسم — الف',
      yearLabel: '1405',
    );

    test('نمبر ختیځې شمېرې ښیي، خو ډیټابیس لاتیني ساتي', () {
      expect(values.textFor(CardFieldKind.idNo, locale), '۱۴۰۵-۰۰۴۲');
      expect(values.idNo, '1405-0042');
    });

    test('تش پلار نوم تشه کرښه راوړي، نه «ولد »', () {
      expect(values.textFor(CardFieldKind.fatherName, locale), 'ولد محمود');
      const noFather = CardValues(schoolName: 'x', fullName: 'y', idNo: 'z');
      expect(noFather.textFor(CardFieldKind.fatherName, locale), '');
    });

    test('پرته له نېټې د پای کرښه تشه ده', () {
      expect(values.textFor(CardFieldKind.expiry, locale), '');
      expect(values.expiredAt(DateTime(2030)), isFalse);

      final withDate = CardValues(
        schoolName: 'x',
        fullName: 'y',
        idNo: 'z',
        expiresOn: DateTime(2026, 12, 21),
      );
      expect(
        withDate.textFor(CardFieldKind.expiry, locale),
        contains('۲۰۲۶-۱۲-۲۱'),
      );
    });
  });

  // ═══════════════════════════════════════════════════════
  group('په لیستونو کې انځور', () {
    /// یو ریښتینی ۱×۱ PNG — چې `existsSync` او ډیکوډ دواړه کار وکړي.
    ///
    /// **ولې یو خام بایټ لیست او نه د `image` کتابتون؟** ځکه چې د
    /// هغه کتابتون راوړل د دې ازموینې د جوړولو وخت په دقیقو کې
    /// زیاتوي — د یوه اته‌پکسله انځور لپاره.
    const pngBase64 =
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGM4'
        'UWEDAAOIAX3sK7CeAAAAAElFTkSuQmCC';

    // **هرڅه هم‌مهاله (sync) دي — او دا قصداً دی.**
    //
    // د `testWidgets` دننه یو ریښتینی `await` پر فایل I/O هېڅکله نه
    // بشپړېږي: هلته یوه جعلي ساعت‌کړۍ ځغلي چې د I/O بشپړېدنې نه
    // پروسس کوي. ازموینه به ځړېدلې وه — نه ماته، چې بدتره ده.
    String makePhoto(Directory dir, String name) {
      final file = File('${dir.path}/$name.png')
        ..writeAsBytesSync(base64Decode(pngBase64));
      return file.path;
    }

    test('شته انځور ښکاري، ورک يې نه', () {
      final dir = Directory.systemTemp.createTempSync('sm-avatar');
      addTearDown(() => dir.deleteSync(recursive: true));

      expect(AvatarCell.showsPhoto(makePhoto(dir, 'a')), isTrue);
      expect(AvatarCell.showsPhoto('${dir.path}/gone.png'), isFalse);
      expect(AvatarCell.showsPhoto(null), isFalse);
      expect(AvatarCell.showsPhoto(''), isFalse);
    });

    testWidgets('**پرته له انځوره، لومړی توری ښکاري**', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: AvatarCell(name: 'احمد', photoPath: '/nowhere/gone.png'),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Image), findsNothing);
      expect(find.text('ا'), findsOneWidget);
    });

    test('**درې واړه لیستونه انځور راوړي**', () async {
      final dir = Directory.systemTemp.createTempSync('sm-list');
      addTearDown(() => dir.deleteSync(recursive: true));

      final sId = await admit('1405-0001', 'زلمی');
      await (db.update(db.students)..where((x) => x.id.equals(sId))).write(
        StudentsCompanion(photoPath: Value(makePhoto(dir, 's'))),
      );

      final tId = await addTeacher('استاد احمد', 'T-0001');
      await (db.update(db.teachers)..where((x) => x.id.equals(tId))).write(
        TeachersCompanion(photoPath: Value(makePhoto(dir, 't'))),
      );

      final fId = await db
          .into(db.staffMembers)
          .insert(
            StaffMembersCompanion.insert(
              employeeNo: 'S-0001',
              fullName: 'عبدالغفار',
              jobTitle: 'محاسب',
              gender: 'male',
              photoPath: Value(makePhoto(dir, 'f')),
            ),
          );
      expect(fId, isPositive);

      // د کارتونو ذخیره يې درې واړو ته راوړي — دا هغه لار ده چې
      // لیستونه او کارتونه دواړه پرې انځور اخلي.
      for (final audience in const ['student', 'teacher', 'staff']) {
        final rows = await cards.holders(audience: audience, now: now);
        expect(rows.single.photoPath, isNotNull, reason: audience);
        expect(File(rows.single.photoPath!).existsSync(), isTrue);
      }
    });
  });

  // ═══════════════════════════════════════════════════════
  group('رسمول', () {
    testWidgets('کارت له ډیزاینه رسمېږي', (tester) async {
      await tester.pumpWidget(
        LocaleScope(
          locale: AppLocale.ps,
          setLocale: (_) {},
          child: MaterialApp(
            theme: AppTheme.build(Brightness.light),
            home: const Directionality(
              textDirection: TextDirection.rtl,
              child: Center(
                child: CardCanvas(
                  layout: CardLayout(
                    fields: [
                      CardField(kind: CardFieldKind.fullName, x: 0.1, y: 0.3),
                      CardField(kind: CardFieldKind.idNo, x: 0.1, y: 0.5),
                      // پټه ساحه — باید ونه رسمېږي.
                      CardField(
                        kind: CardFieldKind.className,
                        x: 0.1,
                        y: 0.7,
                        visible: false,
                      ),
                    ],
                  ),
                  values: CardValues(
                    schoolName: 'د نور لیسه',
                    fullName: 'احمد ولي',
                    idNo: '1405-0042',
                    className: 'لسم — الف',
                  ),
                  locale: AppLocale.ps,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('احمد ولي'), findsOneWidget);
      expect(find.text('۱۴۰۵-۰۰۴۲'), findsOneWidget);
      expect(find.text('لسم — الف'), findsNothing);
    });
  });
}
