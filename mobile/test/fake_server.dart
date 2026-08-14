import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// د ښوونځي د سرور جعلي بدل.
///
/// **ولې د ریښتیني `desktop` سرور پر ځای؟** ځکه چې موبایل پروژه
/// جلا پیکج دی — د ډیسکټاپ پر کوډ يې تکیه به دواړه سره وتړل او د
/// اندروید build به يې درنده کړه. دلته یوازې د **قرارداد** ازموینه
/// کوو: هغه JSON چې سرور لېږي، اپ يې سم لولي.
///
/// د دواړو خواوو د سمون ساتنه د `desktop/test/server_test.dart` په
/// غاړه ده — هغه ریښتینی سرور ازمويي.
class FakeServer {
  /// که `false` وي، هره بلنه د شبکې غلطي راګرځوي.
  bool reachable = true;

  /// که `true` وي، هر توکن ۴۰۱ اخلي.
  bool tokenRevoked = false;

  int notifyCalls = 0;
  final List<(int, bool)> decidedLeaves = [];
  final List<int> readMessageIds = [];

  late final MockClient client = MockClient(_handle);

  Future<http.Response> _handle(http.Request req) async {
    if (!reachable) {
      throw const SocketException('unreachable');
    }

    final path = req.url.path;
    final auth = req.headers['authorization'] ?? '';

    // ── عامه ──────────────────────────────────────────────
    if (path == '/api/ping') {
      return _json({
        'ok': true,
        'app': 'school-manager',
        'api': '1',
        'school': 'د نور لیسه',
      });
    }

    if (path == '/api/pair') {
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      final code = body['code'] as String;
      if (code == 'MGR123') {
        return _json({
          'token': 'manager-token',
          'role': 'manager',
          'school': 'د نور لیسه',
          'deviceName': body['deviceName'],
        });
      }
      if (code == 'PAR123') {
        return _json({
          'token': 'parent-token',
          'role': 'parent',
          'school': 'د نور لیسه',
          'deviceName': body['deviceName'],
          'guardianId': 7,
          'guardianName': 'محمود',
        });
      }
      return _json({'error': 'دا کوډ نه پېژندل کېږي یا کارول شوی'}, 404);
    }

    // ── له دې وروسته توکن پکار دی ─────────────────────────
    if (tokenRevoked || !auth.startsWith('Bearer ')) {
      return _json({'error': 'توکن نه دی سم یا باطل شوی'}, 401);
    }

    // ── مدیر ──────────────────────────────────────────────
    if (path == '/api/manager/summary') {
      return _json({
        'date': '2026-05-12',
        'total': 842,
        'present': 795,
        'late': 12,
        'absent': 47,
        'onLeave': 5,
        'unmarked': 0,
        'presentPercent': 96,
        'pendingLeave': 2,
        'unnotifiedAbsent': 3,
        'unreadNotifications': 1,
      });
    }

    if (path == '/api/manager/notifications') {
      return _json({
        'items': [
          {
            'id': 1,
            'kind': 'absence_digest',
            'title': '۳ تنه نن غیرحاضر دي',
            'body':
                'احمد ولي، کریم الله، بلال خان غیرحاضر دي. '
                'ایا غواړئ والدینو ته پیغام ولېږئ؟',
            'payload': {
              'date': '2026-05-12',
              'count': 3,
              'studentIds': [1, 3, 5],
            },
            'createdAt': '2026-05-12T09:05:00.000',
            'read': false,
            'acted': false,
          },
        ],
      });
    }

    if (path == '/api/manager/absentees') {
      return _json({
        'date': '2026-05-12',
        'items': [
          {
            'studentId': 1,
            'admissionNo': '1405-0001',
            'name': 'احمد ولي',
            'fatherName': 'محمود',
            'class': '۱۰ — الف',
            'monthlyAbsences': 3,
          },
          {
            'studentId': 3,
            'admissionNo': '1405-0003',
            'name': 'کریم الله',
            'fatherName': 'رحیم',
            'class': '۸ — ب',
            'monthlyAbsences': 1,
          },
          {
            'studentId': 5,
            'admissionNo': '1405-0005',
            'name': 'بلال خان',
            'fatherName': 'شیرخان',
            'class': '۱۱ — ب',
            'monthlyAbsences': 2,
          },
        ],
      });
    }

    if (path == '/api/manager/notify') {
      notifyCalls++;
      return _json({
        'batchId': 'b1',
        'queued': 3,
        'sent': 3,
        'failed': 0,
        'notified': [1, 3, 5],
      });
    }

    if (path == '/api/manager/leave') {
      return _json({
        'total': 2,
        'items': [
          {
            'id': 3,
            'studentId': 2,
            'student': 'زرغونه نوري',
            'class': '۹ — الف',
            'reasonType': 'sick',
            'reasonText': 'تبه لري',
            'fromDate': '2026-05-12',
            'toDate': '2026-05-14',
            'days': 3,
            'status': 'pending',
            'via': 'parent_app',
          },
          {
            'id': 4,
            'studentId': 6,
            'student': 'حبیبه صافي',
            'class': '۱۱ — ب',
            'reasonType': 'family',
            'fromDate': '2026-05-13',
            'toDate': '2026-05-13',
            'days': 1,
            'status': 'pending',
            'via': 'reception',
          },
        ],
      });
    }

    final decide = RegExp(r'^/api/manager/leave/(\d+)/decide').firstMatch(path);
    if (decide != null) {
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      decidedLeaves.add((int.parse(decide.group(1)!), body['approve'] == true));
      return _json({'ok': true});
    }

    if (path.startsWith('/api/manager/notifications/')) {
      return _json({'ok': true});
    }

    // ── والدین ────────────────────────────────────────────
    if (path == '/api/parent/children') {
      return _json({
        'items': [
          {
            'id': 1,
            'admissionNo': '1405-0001',
            'name': 'احمد ولي',
            'fatherName': 'محمود',
            'class': '۱۰ — الف',
            'monthPresent': 16,
            'monthAbsent': 1,
            'monthLeave': 0,
            'attendancePercent': 94,
          },
          {
            'id': 4,
            'admissionNo': '1405-0004',
            'name': 'زرغونه ولي',
            'fatherName': 'محمود',
            'class': '۷ — ب',
            'monthPresent': 17,
            'monthAbsent': 0,
            'monthLeave': 1,
            'attendancePercent': 100,
          },
        ],
      });
    }

    if (RegExp(r'^/api/parent/children/\d+/attendance').hasMatch(path)) {
      return _json({
        'month': '2026-05',
        'summary': {'present': 16, 'absent': 1, 'leave': 0},
        'days': [
          {'date': '2026-05-04', 'status': 'present'},
          {'date': '2026-05-05', 'status': 'present'},
          {'date': '2026-05-06', 'status': 'late'},
          {'date': '2026-05-07', 'status': 'absent'},
          {'date': '2026-05-10', 'status': 'leave'},
          {'date': '2026-05-11', 'status': 'present'},
          {'date': '2026-05-12', 'status': 'present'},
        ],
      });
    }

    if (path == '/api/parent/messages') {
      return _json({
        'items': [
          {
            'id': 11,
            'kind': 'absence',
            'body':
                'ښاغلی محمود، درناوی!\n'
                'ستاسو زوی احمد ولي (۱۰ — الف) نن غیرحاضر و.',
            'channel': 'app',
            'status': 'sent',
            'createdAt': '2026-05-07T09:10:00.000',
            'read': false,
          },
        ],
      });
    }

    if (path == '/api/parent/messages/read') {
      final body = jsonDecode(req.body) as Map<String, dynamic>;
      readMessageIds.addAll(
        (body['ids'] as List).cast<num>().map((e) => e.toInt()),
      );
      return _json({'updated': readMessageIds.length});
    }

    if (path == '/api/parent/leave') {
      return _json({'ok': true, 'id': 9, 'status': 'pending'});
    }

    return _json({'error': 'دا لار نشته'}, 404);
  }

  http.Response _json(Object body, [int status = 200]) => http.Response(
    jsonEncode(body),
    status,
    headers: {'content-type': 'application/json; charset=utf-8'},
  );
}
