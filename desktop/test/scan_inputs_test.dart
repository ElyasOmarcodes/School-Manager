import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/features/attendance/camera_scan.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late AttendanceRepository att;
  late StudentRepository students;

  final today = DateTime(2026, 5, 12, 7, 40);

  setUp(() async {
    db = AppDatabase.memory();
    att = AttendanceRepository(db);
    students = StudentRepository(db);
    await db.into(db.schools).insert(SchoolsCompanion.insert(name: 'ازموینه'));
  });

  tearDown(() => db.close());

  Future<Student> admit(
    String no,
    String name, {
    String? fingerprint,
  }) async {
    final id = await students.admit(
      student: StudentsCompanion.insert(
        admissionNo: no,
        firstName: name,
        fatherName: 'پلار',
        gender: 'male',
        fingerprintId: Value(fingerprint),
      ),
      guardians: [
        GuardiansCompanion.insert(fullName: 'پلار', relation: 'father'),
      ],
      byUserId: 1,
      byUserName: 'admin',
    );
    return (db.select(db.students)..where((s) => s.id.equals(id))).getSingle();
  }

  // ═══════════════════════════════════════════════════════
  group('د ګوتې نښه', () {
    test('**هماغې خانې ته ځي چې د داخلې نمبر**', () async {
      await admit('1405-0001', 'احمد', fingerprint: 'FP-0001');

      final r = await att.checkIn(
        input: 'FP-0001',
        now: today,
        byUserId: 1,
      );
      expect(r, isA<CheckInOk>());
      expect((r as CheckInOk).student.firstName, 'احمد');

      // د ثبت لار «finger» ده — نه «qr». د رپوټ لپاره توپیر لري.
      final row = await db.select(db.attendances).getSingle();
      expect(row.method, 'finger');
    });

    test('د داخلې نمبر لومړیتوب لري', () async {
      // یو شاګرد چې د بل د ګوتې پېژندنه يې د داخلې نمبر سره یو شان
      // ده — نمبر باید ګټي، ځکه چې هغه رسمي پېژندنه ده.
      await admit('1405-0001', 'لومړی');
      await admit('1405-0002', 'دویم', fingerprint: '1405-0001');

      final r = await att.checkIn(
        input: '1405-0001',
        now: today,
        byUserId: 1,
      );
      expect((r as CheckInOk).student.firstName, 'لومړی');
    });

    test('ناسمه نښه «ونه پېژندل شو» راګرځوي', () async {
      await admit('1405-0001', 'احمد', fingerprint: 'FP-0001');
      final r = await att.checkIn(
        input: 'FP-9999',
        now: today,
        byUserId: 1,
      );
      expect(r, isA<CheckInUnknown>());
    });

    test('پټ شاګرد د خپلې نښې سره هم نه راځي', () async {
      final s = await admit('1405-0001', 'احمد', fingerprint: 'FP-0001');
      await students.softDelete(s.id, byUserId: 1, byUserName: 'admin');

      expect(await att.findByInput('FP-0001'), isNull);
    });

    test('`findByInput` دواړه لارې پېژني', () async {
      await admit('1405-0001', 'احمد', fingerprint: 'FP-0001');
      expect((await att.findByInput('1405-0001'))!.firstName, 'احمد');
      expect((await att.findByInput('FP-0001'))!.firstName, 'احمد');
      expect(await att.findByInput('   '), isNull);
    });
  });

  // ═══════════════════════════════════════════════════════
  group('د کیمرې QR ډیکوډ', () {
    /// یو ریښتینی QR رسموي او PNG بایټونه راګرځوي — بېخي هغسې چې
    /// کیمره به يې واخلي.
    Future<Uint8List> renderQr(String data, {double size = 400}) async {
      final painter = QrPainter(
        data: data,
        version: QrVersions.auto,
        gapless: true,
        // سپین شالید — که تش وای، ډیکوډر به د تور پر تور لټاوه.
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.square,
          color: Color(0xFF000000),
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.square,
          color: Color(0xFF000000),
        ),
      );

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      // شالید سپین کوو — QR باید تضاد ولري.
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size, size),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      // د څنډې تشه (quiet zone) — پرته له دې ډیکوډر QR نه پیژني.
      const pad = 40.0;
      canvas.translate(pad, pad);
      painter.paint(canvas, Size(size - pad * 2, size - pad * 2));

      final image = await recorder.endRecording().toImage(
        size.toInt(),
        size.toInt(),
      );
      final data0 = await image.toByteData(format: ui.ImageByteFormat.png);
      return data0!.buffer.asUint8List();
    }

    test('**یو رسم شوی QR بېرته لوستل کېږي**', () async {
      final bytes = await renderQr('1405-0423.1.abcdef');
      expect(decodeQrSync(bytes), '1405-0423.1.abcdef');
    });

    test('د یوه ریښتیني کارت QR', () async {
      final s = await admit('1405-0423', 'احمد');
      // د کارت QR هماغه بڼه لري چې سکینر يې لولي.
      final payload = '${s.admissionNo}|${s.cardVersion}';
      final bytes = await renderQr(payload);
      expect(decodeQrSync(bytes), payload);
    });

    test('تش عکس `null` راګرځوي، نه تېروتنه', () async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 100, 100),
        Paint()..color = const Color(0xFFFFFFFF),
      );
      final image = await recorder.endRecording().toImage(100, 100);
      final png = await image.toByteData(format: ui.ImageByteFormat.png);

      expect(decodeQrSync(png!.buffer.asUint8List()), isNull);
    });

    test('خراب بایټونه `null` راګرځوي', () {
      expect(decodeQrSync(Uint8List.fromList([1, 2, 3, 4])), isNull);
    });
  });
}
