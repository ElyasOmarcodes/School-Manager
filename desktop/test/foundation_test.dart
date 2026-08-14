import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/core/utils/password.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/features/auth/auth_service.dart';

void main() {
  group('پاسورډ', () {
    test('سم پاسورډ تایید کېږي', () {
      final salt = Password.newSalt();
      final hash = Password.hash(password: 'my-secret-123', salt: salt);

      expect(
        Password.verify(
          password: 'my-secret-123',
          salt: salt,
          expectedHash: hash,
        ),
        isTrue,
      );
    });

    test('ناسم پاسورډ ردېږي', () {
      final salt = Password.newSalt();
      final hash = Password.hash(password: 'my-secret-123', salt: salt);

      expect(
        Password.verify(
          password: 'my-secret-124',
          salt: salt,
          expectedHash: hash,
        ),
        isFalse,
      );
    });

    test('یو پاسورډ له دوو مالګو سره دوه بېل هشونه ورکوي', () {
      const pw = 'same-password';
      final a = Password.hash(password: pw, salt: Password.newSalt());
      final b = Password.hash(password: pw, salt: Password.newSalt());
      expect(a, isNot(equals(b)));
    });
  });

  group('ډیټابیس', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase.memory());
    tearDown(() => db.close());

    test('جدولونه جوړېږي او بشپړتیا سمه ده', () async {
      await db.customStatement('SELECT 1');
      expect(await db.integrityOk(), isTrue);
    });

    test('د شاګرد د داخلې نمبر نه تکرارېږي', () async {
      await db
          .into(db.students)
          .insert(
            StudentsCompanion.insert(
              admissionNo: 'S-001',
              firstName: 'احمد',
              fatherName: 'محمود',
              gender: 'male',
            ),
          );

      expect(
        () => db
            .into(db.students)
            .insert(
              StudentsCompanion.insert(
                admissionNo: 'S-001',
                firstName: 'بل څوک',
                fatherName: 'بل پلار',
                gender: 'male',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('د یوې ورځې لپاره د یوه شاګرد یوازې یوه حاضري ثبتېږي', () async {
      final sid = await db
          .into(db.students)
          .insert(
            StudentsCompanion.insert(
              admissionNo: 'S-002',
              firstName: 'کریم',
              fatherName: 'رحیم',
              gender: 'male',
            ),
          );

      final day = DateTime(2026, 3, 21);
      await db
          .into(db.attendances)
          .insert(
            AttendancesCompanion.insert(
              studentId: sid,
              date: day,
              status: 'present',
            ),
          );

      // دویم ځل ثبت باید ونه شي — دا هغه محافظ دی چې د دوه‌ځلي
      // سکین له امله حاضري خرابه نه شي.
      expect(
        () => db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: sid,
                date: day,
                status: 'absent',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('د پردي کیلي (foreign key) قید فعال دی', () async {
      expect(
        () => db
            .into(db.attendances)
            .insert(
              AttendancesCompanion.insert(
                studentId: 9999, // شته نه دی
                date: DateTime(2026, 3, 21),
                status: 'present',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('ننوتل', () {
    late AppDatabase db;
    late AuthService auth;

    setUp(() async {
      db = AppDatabase.memory();
      auth = AuthService(db);
      await auth.createUser(
        username: 'admin',
        fullName: 'مدیر صاحب',
        password: 'strong-pass-99',
        role: 'admin',
      );
    });

    tearDown(() => db.close());

    test('سم معلومات غونډه پرانیزي', () async {
      final r = await auth.signIn('admin', 'strong-pass-99');
      expect(r, isA<SignInOk>());
      expect((r as SignInOk).session.role, 'admin');
    });

    test('ناسم پاسورډ ردېږي', () async {
      expect(await auth.signIn('admin', 'wrong'), isA<SignInWrong>());
    });

    test('نشته کارن ردېږي', () async {
      expect(await auth.signIn('ghost', 'whatever'), isA<SignInWrong>());
    });

    test('له پنځو ناسمو هڅو وروسته حساب بندېږي', () async {
      for (var i = 0; i < 5; i++) {
        await auth.signIn('admin', 'wrong');
      }
      // سم پاسورډ هم اوس نه منل کېږي — قفل کار کوي.
      expect(await auth.signIn('admin', 'strong-pass-99'), isA<SignInLocked>());
    });

    test('بریالی ننوتل په لاګ کې ثبتېږي', () async {
      await auth.signIn('admin', 'strong-pass-99');
      final logs = await (db.select(
        db.auditLogs,
      )..where((l) => l.action.equals('login'))).get();
      expect(logs, hasLength(1));
      expect(logs.first.userName, 'admin');
    });
  });
}
