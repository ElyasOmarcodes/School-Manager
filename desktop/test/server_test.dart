import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:school_manager/data/db/database.dart';
import 'package:school_manager/data/repositories/academic_repository.dart';
import 'package:school_manager/data/repositories/attendance_repository.dart';
import 'package:school_manager/data/repositories/exam_repository.dart';
import 'package:school_manager/data/repositories/device_repository.dart';
import 'package:school_manager/data/repositories/message_repository.dart';
import 'package:school_manager/data/repositories/notification_repository.dart';
import 'package:school_manager/data/repositories/student_repository.dart';
import 'package:school_manager/server/api_router.dart';
import 'package:school_manager/server/local_server.dart';
import 'package:shelf/shelf.dart';

/// د محلي سرور ازموینې.
///
/// **پورټ نه نیسو.** `buildApi` یو ساده `Handler` راګرځوي — نو
/// ازموینه پخپله `Request` جوړوي. دا په CI کې چټک دی او د شبکې د
/// محدودیت له امله نه ماتېږي.
void main() {
  late AppDatabase db;
  late ApiDeps deps;
  late Handler api;
  late StudentRepository students;
  late AttendanceRepository att;

  final today = DateTime(2026, 5, 12);

  setUp(() async {
    db = AppDatabase.memory();
    students = StudentRepository(db);
    att = AttendanceRepository(db);
    deps = ApiDeps.of(db, schoolName: () => 'د نور لیسه');
    api = buildApi(deps);
    await deps.messages.ensureDefaultTemplates();
    // ټولګي پکار دي — `markRoster` د بخش پر شتون تکیه کوي.
    await AcademicRepository(db).seedDefaults(
      yearLabel: '1405',
      startsOn: DateTime(2026, 1, 1),
      endsOn: DateTime(2026, 12, 31),
    );
  });

  tearDown(() => db.close());

  // ── مرستندویه ───────────────────────────────────────────

  Future<Response> get(String path, {String? token}) async => api(
    Request(
      'GET',
      Uri.parse('http://x$path'),
      headers: {if (token != null) 'authorization': 'Bearer $token'},
    ),
  );

  Future<Response> post(String path, Object body, {String? token}) async =>
      api(
    Request(
      'POST',
      Uri.parse('http://x$path'),
      headers: {
        'content-type': 'application/json',
        if (token != null) 'authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    ),
  );

  Future<Map<String, dynamic>> jsonOf(Response r) async =>
      jsonDecode(await r.readAsString()) as Map<String, dynamic>;

  Future<int> admit(String no, String name, {String? guardianPhone}) {
    return students.admit(
      student: StudentsCompanion.insert(
        admissionNo: no,
        firstName: name,
        fatherName: 'پلار',
        gender: 'male',
      ),
      guardians: [
        GuardiansCompanion.insert(
          fullName: 'د $name پلار',
          relation: 'father',
          phone: Value(guardianPhone),
          preferredChannel: const Value('app'),
        ),
      ],
      byUserId: 1,
      byUserName: 'admin',
    );
  }

  /// شاګرد په لومړي بخش کې ثبتوي — د ازموینې پایلې ورته پکار دي.
  Future<void> enroll(int studentId) async {
    final academic = AcademicRepository(db);
    final section = (await academic.sections()).first;
    final year = (await academic.currentYear())!;
    await db
        .into(db.enrollments)
        .insert(
          EnrollmentsCompanion.insert(
            studentId: studentId,
            sectionId: section.sectionId,
            academicYearId: year.id,
          ),
        );
  }

  Future<String> pairManager() async {
    final code = await deps.devices.createCode(role: 'manager', userId: 1);
    final r = await post('/api/pair', {
      'code': code.code,
      'deviceName': 'د مدیر تلیفون',
    });
    return (await jsonOf(r))['token'] as String;
  }

  Future<({String token, int guardianId})> pairParent(int studentId) async {
    final link = await (db.select(
      db.studentGuardians,
    )..where((sg) => sg.studentId.equals(studentId))).getSingle();

    final code = await deps.devices.createCode(
      role: 'parent',
      guardianId: link.guardianId,
    );
    final r = await post('/api/pair', {
      'code': code.code,
      'deviceName': 'د پلار تلیفون',
    });
    return (
      token: (await jsonOf(r))['token'] as String,
      guardianId: link.guardianId,
    );
  }

  // ═════════════════════════════════════════════════════════

  group('عامه لارې', () {
    test('ping د ښوونځي نوم راګرځوي — د اپ د پیدا کولو لپاره', () async {
      final r = await get('/api/ping');
      expect(r.statusCode, 200);
      final j = await jsonOf(r);
      expect(j['ok'], true);
      expect(j['school'], 'د نور لیسه');
      expect(j['api'], apiVersion);
    });

    test('نه‌پېژندل شوې لاره JSON غلطي راګرځوي، نه HTML', () async {
      final r = await get('/api/nothing-here');
      expect(r.statusCode, 404);
      expect(r.headers['content-type'], contains('application/json'));
      expect((await jsonOf(r))['error'], isNotNull);
    });
  });

  group('تړل', () {
    test('سم کوډ توکن راکوي او دویم ځل نه کارېږي', () async {
      final code = await deps.devices.createCode(role: 'manager', userId: 1);

      final first = await post('/api/pair', {
        'code': code.code,
        'deviceName': 'تلیفون',
      });
      expect(first.statusCode, 200);
      final token = (await jsonOf(first))['token'] as String;
      expect(token, isNotEmpty);

      // یوځلي دی — دویم تلیفون هماغه کوډ نه شي کارولی.
      final second = await post('/api/pair', {
        'code': code.code,
        'deviceName': 'بل تلیفون',
      });
      expect(second.statusCode, 404);
    });

    test('خام توکن په ډیټابیس کې نه ساتل کېږي', () async {
      final token = await pairManager();
      final device = await db.select(db.devices).getSingle();

      expect(device.tokenHash, isNot(token));
      expect(device.tokenHash, DeviceRepository.hashToken(token));
    });

    test('ختم شوی کوډ روښانه ځواب راکوي', () async {
      final past = DateTime.now().subtract(const Duration(hours: 2));
      final code = await deps.devices.createCode(
        role: 'manager',
        userId: 1,
        now: past,
      );
      final r = await post('/api/pair', {
        'code': code.code,
        'deviceName': 'تلیفون',
      });
      expect(r.statusCode, 410);
    });

    test('کوډ د واړو تورو او تشو سره هم منل کېږي', () async {
      final code = await deps.devices.createCode(role: 'manager', userId: 1);
      final r = await post('/api/pair', {
        'code': ' ${code.code.toLowerCase()} ',
        'deviceName': 'تلیفون',
      });
      expect(r.statusCode, 200);
    });

    test('باطل شوې وسیله بیا نه پېژندل کېږي', () async {
      final token = await pairManager();
      expect((await get('/api/device/me', token: token)).statusCode, 200);

      final device = await db.select(db.devices).getSingle();
      await deps.devices.revoke(device.id);

      expect((await get('/api/device/me', token: token)).statusCode, 401);
    });
  });

  group('اجازې', () {
    test('پرته له توکنه ۴۰۱', () async {
      expect((await get('/api/manager/summary')).statusCode, 401);
      expect((await get('/api/parent/children')).statusCode, 401);
    });

    test('د والدینو توکن د مدیر لارو ته نه ورځي', () async {
      final sid = await admit('0001', 'احمد');
      final p = await pairParent(sid);

      final r = await get('/api/manager/absentees', token: p.token);
      expect(r.statusCode, 403);
    });

    test('د مدیر توکن د والدینو لارو ته نه ورځي', () async {
      final token = await pairManager();
      expect((await get('/api/parent/children', token: token)).statusCode, 403);
    });

    test('یو سرپرست د بل کور شاګرد نه شي لیدلی', () async {
      final mine = await admit('0001', 'احمد');
      final other = await admit('0002', 'کریم');
      final p = await pairParent(mine);

      final ok = await get(
        '/api/parent/children/$mine/attendance',
        token: p.token,
      );
      expect(ok.statusCode, 200);

      final denied = await get(
        '/api/parent/children/$other/attendance',
        token: p.token,
      );
      expect(denied.statusCode, 403);
    });
  });

  group('د مدیر لارې', () {
    test('لنډیز د ورځې شمېرې راکوي', () async {
      final a = await admit('0001', 'احمد');
      await admit('0002', 'کریم');
      await att.markRoster(
        sectionId: 1,
        date: today,
        statusByStudentId: {a: 'present'},
        byUserId: 1,
      );

      final token = await pairManager();
      final j = await jsonOf(
        await get('/api/manager/summary?date=2026-05-12', token: token),
      );

      expect(j['total'], 2);
      expect(j['present'], 1);
      expect(j['unmarked'], 1);
    });

    test('د ورځې تړل غیرحاضران جوړوي او خبرتیا راپیدا کېږي', () async {
      await admit('0001', 'احمد');
      await admit('0002', 'کریم');
      await att.lockDay(date: today, byUserId: 1);

      final token = await pairManager();
      final j = await jsonOf(
        await get('/api/manager/summary?date=2026-05-12', token: token),
      );
      expect(j['absent'], 2);
      expect(j['unnotifiedAbsent'], 2);

      final inbox = await jsonOf(
        await get('/api/manager/notifications', token: token),
      );
      final items = inbox['items'] as List;
      expect(items, hasLength(1));
      expect(items.first['kind'], 'absence_digest');
      expect(items.first['title'], contains('2'));
    });
  });

  group('د غیرحاضرۍ پیغام — د پروژې اصلي جریان', () {
    test('«ټولو ته ولېږه» د هر غیرحاضر کور ته پیغام ورکوي', () async {
      final a = await admit('0001', 'احمد');
      final k = await admit('0002', 'کریم');
      await att.lockDay(date: today, byUserId: 1);

      // د دواړو کورونو اپ تړل شوی دی، نو `app` کانال کار کوي.
      await pairParent(a);
      await pairParent(k);

      final token = await pairManager();
      final j = await jsonOf(
        await post('/api/manager/notify', {'date': '2026-05-12'}, token: token),
      );

      expect(j['queued'], 2);
      expect(j['sent'], 2);
      expect(j['failed'], 0);

      // د حاضرۍ کرښې اوس «خبر شوي» دي.
      final again = await jsonOf(
        await get('/api/manager/summary?date=2026-05-12', token: token),
      );
      expect(again['unnotifiedAbsent'], 0);
    });

    test('یوازې یو شاګرد — نور نه‌خبر پاتې کېږي', () async {
      final a = await admit('0001', 'احمد');
      final k = await admit('0002', 'کریم');
      await att.lockDay(date: today, byUserId: 1);
      await pairParent(a);
      await pairParent(k);

      final token = await pairManager();
      await post('/api/manager/notify', {
        'date': '2026-05-12',
        'studentIds': [a],
      }, token: token);

      final left = await att.absentees(today, onlyUnnotified: true);
      expect(left.map((e) => e.student.id), [k]);
    });

    test('دوه ځله لېږل دویم ځل هېڅ نه لېږي', () async {
      final a = await admit('0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);
      await pairParent(a);

      final token = await pairManager();
      await post('/api/manager/notify', {'date': '2026-05-12'}, token: token);
      final second = await jsonOf(
        await post('/api/manager/notify', {'date': '2026-05-12'}, token: token),
      );

      expect(second['queued'], 0);
      expect(second['sent'], 0);
    });

    test('که د کور اپ نه وي تړل شوی، پیغام د روښانه لامل سره ناکامېږي', () async {
      final a = await admit('0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);

      final token = await pairManager();
      final j = await jsonOf(
        await post('/api/manager/notify', {'date': '2026-05-12'}, token: token),
      );

      expect(j['sent'], 0);
      expect(j['failed'], 1);

      final msg = await db.select(db.messages).getSingle();
      expect(msg.status, 'failed');
      expect(msg.error, isNotNull);

      // **مهمه:** ناکام پیغام باید حاضري «خبر شوې» نه کړي — سبا
      // بیا هڅه کېږي.
      final att2 = await (db.select(
        db.attendances,
      )..where((x) => x.studentId.equals(a))).getSingle();
      expect(att2.parentNotified, isFalse);
    });

    test('د پیغام متن د شاګرد نوم، ټولګی او نېټه لري', () async {
      final a = await admit('0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);
      await pairParent(a);

      final token = await pairManager();
      await post('/api/manager/notify', {'date': '2026-05-12'}, token: token);

      final msg = await db.select(db.messages).getSingle();
      expect(msg.body, contains('احمد'));
      expect(msg.body, contains('2026-05-12'));
      expect(msg.body, contains('د نور لیسه'));
      // هېڅ نه‌ډک شوی ځای‌نیوونکی پاتې نه شي.
      expect(msg.body, isNot(contains('{student}')));
      expect(msg.body, isNot(contains('{school}')));
    });
  });

  group('د والدینو لارې', () {
    test('ماشومان او د میاشتې سلنه', () async {
      final a = await admit('0001', 'احمد');
      await att.markRoster(
        sectionId: 1,
        date: DateTime.now(),
        statusByStudentId: {a: 'present'},
        byUserId: 1,
      );

      final p = await pairParent(a);
      final j = await jsonOf(await get('/api/parent/children', token: p.token));
      final items = j['items'] as List;

      expect(items, hasLength(1));
      expect(items.first['name'], 'احمد');
      expect(items.first['monthPresent'], 1);
      expect(items.first['attendancePercent'], 100);
    });

    test('د صندوق پیغامونه یوازې د خپل کور دي', () async {
      final a = await admit('0001', 'احمد');
      final k = await admit('0002', 'کریم');
      await att.lockDay(date: today, byUserId: 1);
      final pa = await pairParent(a);
      await pairParent(k);

      final token = await pairManager();
      await post('/api/manager/notify', {'date': '2026-05-12'}, token: token);

      final j = await jsonOf(await get('/api/parent/messages', token: pa.token));
      final items = j['items'] as List;
      expect(items, hasLength(1));
      expect(items.first['body'], contains('احمد'));
    });

    test('د والدینو د اجازې غوښتنه مدیر ته خبرتیا جوړوي', () async {
      final a = await admit('0001', 'احمد');
      final p = await pairParent(a);

      final r = await post('/api/parent/leave', {
        'studentId': a,
        'reasonType': 'sick',
        'reasonText': 'تبه لري',
        'fromDate': '2026-05-12',
        'toDate': '2026-05-14',
      }, token: p.token);

      expect(r.statusCode, 200);

      final token = await pairManager();
      final inbox = await jsonOf(
        await get('/api/manager/notifications', token: token),
      );
      final kinds = (inbox['items'] as List).map((e) => e['kind']);
      expect(kinds, contains('leave_request'));

      // مدیر يې له تلیفونه منلی شي.
      final leaveId = (await jsonOf(r))['id'];
      final decide = await post(
        '/api/manager/leave/$leaveId/decide',
        {'approve': true},
        token: token,
      );
      expect(decide.statusCode, 200);

      final saved = await db.select(db.leaveRequests).getSingle();
      expect(saved.status, 'approved');
      expect(saved.requestedVia, 'parent_app');
    });

    test('منل شوې اجازه د غیرحاضرۍ پیغام مخه نیسي', () async {
      final a = await admit('0001', 'احمد');
      final p = await pairParent(a);

      await post('/api/parent/leave', {
        'studentId': a,
        'reasonType': 'sick',
        'fromDate': '2026-05-12',
        'toDate': '2026-05-12',
      }, token: p.token);

      final token = await pairManager();
      final leave = await db.select(db.leaveRequests).getSingle();
      await post(
        '/api/manager/leave/${leave.id}/decide',
        {'approve': true},
        token: token,
      );

      // اوس ورځ تړو — دا شاګرد باید «رخصت» شي، نه غیرحاضر.
      await att.lockDay(date: today, byUserId: 1);

      final j = await jsonOf(
        await get('/api/manager/summary?date=2026-05-12', token: token),
      );
      expect(j['absent'], 0);
      expect(j['onLeave'], 1);
      expect(j['unnotifiedAbsent'], 0);
    });

    test('د پیغام لوستل حالت بدلوي', () async {
      final a = await admit('0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);
      final p = await pairParent(a);

      final token = await pairManager();
      await post('/api/manager/notify', {'date': '2026-05-12'}, token: token);

      final msg = await db.select(db.messages).getSingle();
      await post('/api/parent/messages/read', {
        'ids': [msg.id],
      }, token: p.token);

      final after = await db.select(db.messages).getSingle();
      expect(after.status, 'read');
      expect(after.readAt, isNotNull);
    });
  });

  group('د خپرو شویو نمرو لار', () {
    /// یوه ازموینه له نمرو سره جوړوي او ازموینه‌کوونکي ته يې ورکوي.
    Future<int> seedExam(int studentId, {required bool published}) async {
      final academic = AcademicRepository(db);
      final exams = ExamRepository(db);
      await academic.seedDefaultSubjects();

      final year = (await academic.currentYear())!;
      final section = (await academic.sections()).first;
      final subjects = await academic.subjects();

      final examId = await exams.create(
        name: 'د ربعې ازموینه',
        examType: 'midterm',
        academicYearId: year.id,
        startsOn: DateTime(2026, 5, 10),
        endsOn: DateTime(2026, 5, 20),
      );
      await exams.addSubjects(
        examId: examId,
        gradeId: section.gradeId,
        subjectIds: [
          subjects.firstWhere((s) => s.name == 'ریاضي').id,
          subjects.firstWhere((s) => s.name == 'پښتو').id,
        ],
      );

      final subs = await exams.subjectsOf(examId, gradeId: section.gradeId);
      for (final (i, sub) in subs.indexed) {
        await exams.saveMarks(
          examSubjectId: sub.examSubject.id,
          byStudent: {
            studentId: (obtained: i == 0 ? 92.0 : 78.0, isAbsent: false),
          },
          byUserId: 1,
        );
      }

      if (published) await exams.publish(examId, published: true);
      return examId;
    }

    test('نه‌خپرې شوې پایله والدینو ته نه ښکاري', () async {
      final a = await admit('0001', 'احمد');
      await enroll(a);
      await seedExam(a, published: false);

      final p = await pairParent(a);
      final j = await jsonOf(
        await get('/api/parent/children/$a/results', token: p.token),
      );
      expect(j['items'], isEmpty);
    });

    test('خپره شوې پایله له مضمونونو، درجې او مقام سره راځي', () async {
      final a = await admit('0001', 'احمد');
      await enroll(a);
      await seedExam(a, published: true);

      final p = await pairParent(a);
      final j = await jsonOf(
        await get('/api/parent/children/$a/results', token: p.token),
      );
      final items = j['items'] as List;

      expect(items, hasLength(1));
      final r = items.first as Map<String, dynamic>;
      expect(r['exam'], 'د ربعې ازموینه');
      expect(r['obtained'], 170);
      expect(r['full'], 200);
      expect(r['percent'], 85);
      expect(r['grade'], 'A');
      expect(r['passed'], true);
      expect((r['subjects'] as List), hasLength(2));
    });

    test('یو سرپرست د بل کور پایله نه شي لیدلی', () async {
      final mine = await admit('0001', 'احمد');
      final other = await admit('0002', 'کریم');
      await enroll(mine);
      await enroll(other);
      await seedExam(other, published: true);

      final p = await pairParent(mine);
      final r = await get(
        '/api/parent/children/$other/results',
        token: p.token,
      );
      expect(r.statusCode, 403);
    });
  });

  group('خبرتیاوې', () {
    test('د یوې ورځې لپاره یوازې یوه خبرتیا جوړېږي، خو شمېره تازه کېږي', () async {
      final notif = NotificationRepository(db);
      await admit('0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);

      final first = await notif.syncAbsenceDigest(date: today);
      expect(first!.total, 1);

      await admit('0002', 'کریم');
      await att.lockDay(date: today, byUserId: 1);
      final second = await notif.syncAbsenceDigest(date: today);

      expect(second!.total, 2);
      expect(second.notification.id, first.notification.id);
      expect(await db.select(db.appNotifications).get(), hasLength(1));
    });

    test('کله چې ټولو ته پیغام ولاړ، خبرتیا «شوې» نښه کېږي', () async {
      final a = await admit('0001', 'احمد');
      await att.lockDay(date: today, byUserId: 1);
      await pairParent(a);

      final token = await pairManager();
      await get('/api/manager/summary?date=2026-05-12', token: token);
      await post('/api/manager/notify', {'date': '2026-05-12'}, token: token);

      final n = await db.select(db.appNotifications).getSingle();
      expect(n.actedAt, isNotNull);
    });
  });

  group('ریښتینې سوکټ', () {
    /// **دا ازموینه ولې پکار ده؟** ځکه چې پاتې ازموینې یوازې
    /// `Handler` بلي — هغه نه ښيي چې سرور واقعاً یوه دروازه
    /// پرانیزي او د شبکې له لارې ځواب ورکوي. دا يې ازمويي.
    test('سرور ریښتیني پورټ نیسي او د شبکې له لارې ځواب ورکوي', () async {
      final server = LocalServer(deps);
      // پورټ صفر = عامل سیسټم يې پخپله ټاکي، نو د CI سره ټکر نه کوي.
      final port = await server.start(port: 0);
      addTearDown(server.stop);

      expect(port, greaterThan(0));
      expect(server.isRunning, isTrue);

      final client = HttpClient();
      addTearDown(client.close);

      final req = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/api/ping'),
      );
      final res = await req.close();
      final body =
          jsonDecode(await res.transform(utf8.decoder).join())
              as Map<String, dynamic>;

      expect(res.statusCode, 200);
      expect(body['school'], 'د نور لیسه');
    });

    test('راغلې غوښتنې شمېرل کېږي — د فایروال د تشخیص لپاره', () async {
      final server = LocalServer(deps);
      final port = await server.start(port: 0);
      addTearDown(server.stop);

      expect(server.stats.silent, isTrue);

      final client = HttpClient();
      addTearDown(client.close);
      final req = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/api/ping'),
      );
      await (await req.close()).drain<void>();

      expect(server.stats.requests, 1);
      expect(server.stats.silent, isFalse);
      expect(server.stats.clientIps, isNotEmpty);
    });

    test('ناسم توکن هم شمېرل کېږي — شبکه خو کار کوي', () async {
      final server = LocalServer(deps);
      final port = await server.start(port: 0);
      addTearDown(server.stop);

      final client = HttpClient();
      addTearDown(client.close);
      final req = await client.getUrl(
        Uri.parse('http://127.0.0.1:$port/api/manager/summary'),
      );
      req.headers.set('authorization', 'Bearer wrong');
      final res = await req.close();
      await res.drain<void>();

      expect(res.statusCode, 401);
      expect(server.stats.requests, 1);
    });

    test('د فایروال بلنه پورټ او ټول پروفایلونه لري', () {
      final server = LocalServer(deps);
      final cmd = server.firewallCommand(port: 8787);
      expect(cmd, contains('localport=8787'));
      // ویندوز ځینې Wi-Fi «Public» ګڼي — نو باید ټول پروفایلونه.
      expect(cmd, contains('profile=any'));
      expect(cmd, contains('dir=in'));
    });
  });

  group('کینډۍ', () {
    test('نه‌پېژندل شوی ځای‌نیوونکی پاتې کېږي — چې تېروتنه ښکاره شي', () {
      expect(
        renderTemplate('سلام {name}، {unknown} ته راشئ', {'name': 'احمد'}),
        'سلام احمد، {unknown} ته راشئ',
      );
    });

    test('تلوالې کینډۍ یوازې یو ځل جوړېږي', () async {
      await deps.messages.ensureDefaultTemplates();
      await deps.messages.ensureDefaultTemplates();
      final all = await deps.messages.templates();
      expect(all, hasLength(builtInTemplates.length));
    });
  });
}
