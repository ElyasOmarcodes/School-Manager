import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/l10n/strings.dart';
import 'package:school_manager/core/utils/qr_token.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/features/id_cards/id_card.dart';
import 'package:school_manager/features/id_cards/id_card_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late StudentRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = StudentRepository(db);
  });

  tearDown(() => db.close());

  Future<Student> admitOne() async {
    final id = await repo.admit(
      student: StudentsCompanion.insert(
        admissionNo: '1405-0423',
        firstName: 'احمد',
        lastName: const Value('ولي'),
        fatherName: 'محمود',
        gender: 'male',
      ),
      guardians: [
        GuardiansCompanion.insert(fullName: 'محمود', relation: 'father'),
      ],
      byUserId: 1,
      byUserName: 'admin',
    );
    return (db.select(db.students)..where((s) => s.id.equals(id))).getSingle();
  }

  group('د کارت ډیټا', () {
    test('QR لاسلیک شوی دی او بېرته لوستل کېږي', () async {
      final student = await admitOne();

      final card = CardData.forStudent(
        student: student,
        schoolName: 'د نور لیسه',
        className: 'لسم — الف',
        yearLabel: '۱۴۰۵',
      );

      expect(card.studentName, 'احمد ولي');
      expect(card.qrPayload, isNotEmpty);

      // هغه څه چې سکینر به يې ولولي — باید د همدې شاګرد وي.
      final scan = QrToken.decode(card.qrPayload, student.qrSecret!);
      expect(scan, isNotNull);
      expect(scan!.admissionNo, '1405-0423');
      expect(scan.cardVersion, 1);
    });

    test('د یوه شاګرد کارت د بل لپاره نه شي کارېدلی', () async {
      final a = await admitOne();
      final bId = await repo.admit(
        student: StudentsCompanion.insert(
          admissionNo: '1405-0424',
          firstName: 'کریم',
          fatherName: 'رحیم',
          gender: 'male',
        ),
        guardians: [
          GuardiansCompanion.insert(fullName: 'رحیم', relation: 'father'),
        ],
        byUserId: 1,
        byUserName: 'admin',
      );
      final b = await (db.select(
        db.students,
      )..where((s) => s.id.equals(bId))).getSingle();

      final cardA = CardData.forStudent(
        student: a,
        schoolName: 'س',
        className: 'ک',
        yearLabel: '۱۴۰۵',
      );

      // هر شاګرد خپل پټ کلید لري، نو د A کارت د B په کلي نه لوستل کېږي.
      expect(a.qrSecret, isNot(equals(b.qrSecret)));
      expect(QrToken.decode(cardA.qrPayload, b.qrSecret!), isNull);
    });

    test('پرته له پټ کلي، QR تش پاتې کېږي نه ناسم', () {
      // زوړ ریکارډ چې د دې خاصیت له راتګ مخکې ثبت شوی.
      final legacy = Student(
        id: 1,
        admissionNo: '1404-0001',
        firstName: 'زوړ',
        fatherName: 'شاګرد',
        gender: 'male',
        admittedOn: DateTime(2025),
        status: 'active',
        cardVersion: 1,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      final card = CardData.forStudent(
        student: legacy,
        schoolName: 'س',
        className: 'ک',
        yearLabel: '۱۴۰۴',
      );

      // تش — نه ناسم لاسلیک. سکینر به ناسم لاسلیک رد کړي او مدیر به
      // ونه پوهېږي چې ولې؛ تش QR سمدستي وايي «کارت له سره جوړ کړه».
      expect(card.qrPayload, isEmpty);
    });
  });

  group('د پټ کلي بیا-ډکول', () {
    test('یوازې هغو ته ورکوي چې نه يې لري، او هر یو ته جلا', () async {
      // د زاړه سیسټم د واردولو په څېر — مستقیم ثبت، پرته له کلي.
      for (var i = 1; i <= 3; i++) {
        await db
            .into(db.students)
            .insert(
              StudentsCompanion.insert(
                admissionNo: '1404-000$i',
                firstName: 'زوړ$i',
                fatherName: 'پلار',
                gender: 'male',
              ),
            );
      }
      // یو نوی چې کلید لري.
      final fresh = await admitOne();

      final n = await repo.backfillQrSecrets();
      expect(n, 3, reason: 'یوازې هغه درې چې کلید يې نه درلود');

      final all = await db.select(db.students).get();
      expect(all.every((s) => s.qrSecret != null), isTrue);

      // د نوي کلید نه دی بدل شوی — که بدل شوی وای، چاپ شوی کارت
      // به يې باطل شوی و.
      final after = all.firstWhere((s) => s.id == fresh.id);
      expect(after.qrSecret, fresh.qrSecret);

      // هر شاګرد خپل کلید — نه یو ګډ.
      final keys = all.map((s) => s.qrSecret).toSet();
      expect(keys, hasLength(all.length));
    });

    test('که ټولو کلي ولري، هېڅ نه بدلوي', () async {
      await admitOne();
      expect(await repo.backfillQrSecrets(), 0);
    });

    test('پټ شوي شاګردان نه شاملېږي', () async {
      final id = await db
          .into(db.students)
          .insert(
            StudentsCompanion.insert(
              admissionNo: '1404-0009',
              firstName: 'پټ',
              fatherName: 'پلار',
              gender: 'male',
              deletedAt: Value(DateTime(2026)),
            ),
          );
      expect(await repo.backfillQrSecrets(), 0);

      final s = await (db.select(
        db.students,
      )..where((t) => t.id.equals(id))).getSingle();
      expect(s.qrSecret, isNull);
    });
  });

  group('د چاپ PDF', () {
    test('یوه پاڼه جوړوي او PDF بڼه لري', () async {
      final student = await admitOne();
      final card = CardData.forStudent(
        student: student,
        schoolName: 'د نور لیسه',
        className: 'لسم — الف',
        yearLabel: '۱۴۰۵',
      );

      final bytes = await IdCardPdf.build(cards: [card], locale: AppLocale.ps);

      expect(bytes.length, greaterThan(1000));
      // د PDF لاسلیک: %PDF
      expect(String.fromCharCodes(bytes.take(4)), '%PDF');
    });

    test('۲۵ کارتونه درې پاڼې نیسي (۱۰ په هره پاڼه)', () async {
      final student = await admitOne();
      final one = CardData.forStudent(
        student: student,
        schoolName: 'د نور لیسه',
        className: 'لسم — الف',
        yearLabel: '۱۴۰۵',
      );

      final bytes = await IdCardPdf.build(
        cards: List.filled(25, one),
        locale: AppLocale.ps,
      );

      // د پاڼو شمېر په PDF کې د `/Type /Page` په شمار معلومېږي.
      final text = String.fromCharCodes(bytes);
      final pages = RegExp(r'/Type\s*/Page[^s]').allMatches(text).length;
      expect(pages, 3, reason: '۲۵ کارتونه ÷ ۱۰ = ۳ پاڼې');
    });

    test('په یوه پاڼه کې لس کارتونه ځایېږي', () {
      expect(IdCardPdf.perPage, 10);
      // د CR80 معیار — چې معیاري کارت‌ساتونکي ورسره برابر وي.
      expect(IdCardPdf.cardW / IdCardPdf.cardH, closeTo(85.6 / 54.0, 0.001));
    });
  });
}
