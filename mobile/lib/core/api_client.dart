import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// د ښوونځي سرور سره اړیکه.
///
/// **دا سرور چېرې دی؟** د ښوونځي په کمپیوټر کې — هماغه چې مدیریتي
/// پروګرام پرې ځغلي. اپ د ښوونځي Wi-Fi ته وصلېږي او دې پتې ته غږ
/// کوي. انټرنټ ته اړتیا نشته.
///
/// **د غلطیو اصل:** هره ناکامي یو **د پښتو پیغام** لري چې کارن يې
/// پوه شي — نه «SocketException: errno 111». د ښوونځي کارکوونکی د
/// انګلیسي تخنیکي متن څخه هېڅ نه اخلي.
class ApiException implements Exception {
  final String message;
  final int? status;
  const ApiException(this.message, {this.status});

  /// آیا دا هغه ډول ناکامي ده چې توکن يې باطل شوی؟
  bool get isUnauthorized => status == 401 || status == 403;

  @override
  String toString() => message;
}

class ApiClient {
  /// «http://192.168.1.14:8787»
  final String baseUrl;
  final String? token;
  final http.Client _http;

  /// **ولې لنډ؟** که د ښوونځي کمپیوټر بند وي، کارن باید په څو
  /// ثانیو کې پوه شي — نه دا چې پرده دېرش ثانیې وځړېږي.
  static const Duration timeout = Duration(seconds: 8);

  ApiClient({required this.baseUrl, this.token, http.Client? client})
    : _http = client ?? http.Client();

  ApiClient withToken(String t) =>
      ApiClient(baseUrl: baseUrl, token: t, client: _http);

  void close() => _http.close();

  Map<String, String> get _headers => {
    'content-type': 'application/json',
    if (token != null) 'authorization': 'Bearer $token',
  };

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = baseUrl.trim().replaceAll(RegExp(r'/+$'), '');
    return Uri.parse(
      '$base$path',
    ).replace(queryParameters: query?.isEmpty ?? true ? null : query);
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() call,
  ) async {
    late http.Response res;
    try {
      res = await call().timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'ښوونځي ځواب ورنکړ. ډاډه شئ چې د ښوونځي Wi-Fi ته وصل یاست '
        'او پروګرام په کمپیوټر کې روان دی.',
      );
    } on SocketException {
      // **دا پیغام باید یو کار وښيي، نه یوازې یوه ستونزه.** د
      // ښوونځي کارکوونکی «Connection refused» نه پېژني — خو
      // پوهېږي چې فایروال څه شی دی کله چې ورته ووایو.
      throw const ApiException(
        'له سرور سره اړیکه ونه شوه.\n'
        '۱. پته وګورئ چې سمه ده.\n'
        '۲. ډاډه شئ چې تاسو او کمپیوټر دواړه پر **یوه** Wi-Fi یاست.\n'
        '۳. له مدیر وغواړئ چې په پروګرام کې «تنظیمات ← اړیکه» '
        'وګوري — هلته د ویندوز د فایروال تڼۍ ده.',
      );
    } on http.ClientException {
      throw const ApiException('د شبکې اړیکه پرې شوه. بیا هڅه وکړئ.');
    }

    Map<String, dynamic> body;
    try {
      final decoded = jsonDecode(utf8.decode(res.bodyBytes));
      body = decoded is Map<String, dynamic> ? decoded : {};
    } on FormatException {
      throw ApiException(
        'له سرور څخه نه‌پېژندل شوی ځواب راغی. ښايي پته سمه نه وي.',
        status: res.statusCode,
      );
    }

    if (res.statusCode >= 400) {
      throw ApiException(
        body['error'] as String? ?? 'تېروتنه (${res.statusCode})',
        status: res.statusCode,
      );
    }
    return body;
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? query,
  ]) => _send(() => _http.get(_uri(path, query), headers: _headers));

  Future<Map<String, dynamic>> _post(String path, [Object? body]) => _send(
    () => _http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? const {}),
    ),
  );

  // ── عامه ────────────────────────────────────────────────

  /// آیا په دې پته کې ریښتیا زموږ ښوونځی دی؟
  Future<PingInfo> ping() async {
    final j = await _get('/api/ping');
    if (j['app'] != 'school-manager') {
      throw const ApiException(
        'دا پته د ښوونځي سیسټم نه دی. بله پته وازمویئ.',
      );
    }
    return PingInfo(
      school: j['school'] as String? ?? '',
      api: j['api'] as String? ?? '',
    );
  }

  Future<PairResponse> pair({
    required String code,
    required String deviceName,
    String platform = 'android',
  }) async {
    final j = await _post('/api/pair', {
      'code': code,
      'deviceName': deviceName,
      'platform': platform,
    });
    return PairResponse(
      token: j['token'] as String,
      role: j['role'] as String,
      school: j['school'] as String? ?? '',
      deviceName: j['deviceName'] as String? ?? deviceName,
      guardianId: (j['guardianId'] as num?)?.toInt(),
      guardianName: j['guardianName'] as String?,
    );
  }

  // ── مدیر ────────────────────────────────────────────────

  Future<ManagerSummary> summary({DateTime? date}) async {
    final j = await _get('/api/manager/summary', {
      if (date != null) 'date': _iso(date),
    });
    return ManagerSummary.fromJson(j);
  }

  Future<List<AbsenteeInfo>> absentees({
    DateTime? date,
    bool onlyUnnotified = true,
  }) async {
    final j = await _get('/api/manager/absentees', {
      if (date != null) 'date': _iso(date),
      if (onlyUnnotified) 'onlyUnnotified': '1',
    });
    return [
      for (final e in (j['items'] as List? ?? const []))
        AbsenteeInfo.fromJson(e as Map<String, dynamic>),
    ];
  }

  /// **د اپ اصلي تڼۍ.** که `studentIds` تش وي، ټولو ته ځي.
  Future<NotifyResult> notifyParents({
    DateTime? date,
    List<int> studentIds = const [],
    String templateKey = 'absence',
  }) async {
    final j = await _post('/api/manager/notify', {
      if (date != null) 'date': _iso(date),
      'studentIds': studentIds,
      'templateKey': templateKey,
    });
    return NotifyResult(
      sent: (j['sent'] as num?)?.toInt() ?? 0,
      failed: (j['failed'] as num?)?.toInt() ?? 0,
      queued: (j['queued'] as num?)?.toInt() ?? 0,
    );
  }

  Future<List<NotificationInfo>> notifications() async {
    final j = await _get('/api/manager/notifications');
    return [
      for (final e in (j['items'] as List? ?? const []))
        NotificationInfo.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> markNotificationRead(int id) =>
      _post('/api/manager/notifications/$id/read');

  Future<List<LeaveInfo>> leaveRequests({String status = 'pending'}) async {
    final j = await _get('/api/manager/leave', {'status': status});
    return [
      for (final e in (j['items'] as List? ?? const []))
        LeaveInfo.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> decideLeave(int id, {required bool approve, String? note}) =>
      _post('/api/manager/leave/$id/decide', {
        'approve': approve,
        if (note != null) 'note': note,
      });

  // ── والدین ──────────────────────────────────────────────

  Future<List<ChildInfo>> children() async {
    final j = await _get('/api/parent/children');
    return [
      for (final e in (j['items'] as List? ?? const []))
        ChildInfo.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<ChildAttendance> childAttendance(int id, {DateTime? month}) async {
    final j = await _get('/api/parent/children/$id/attendance', {
      if (month != null)
        'month': '${month.year}-${month.month.toString().padLeft(2, '0')}',
    });
    return ChildAttendance.fromJson(j);
  }

  Future<List<ExamResultInfo>> childResults(int id) async {
    final j = await _get('/api/parent/children/$id/results');
    return [
      for (final e in (j['items'] as List? ?? const []))
        ExamResultInfo.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<List<ParentMessage>> messages() async {
    final j = await _get('/api/parent/messages');
    return [
      for (final e in (j['items'] as List? ?? const []))
        ParentMessage.fromJson(e as Map<String, dynamic>),
    ];
  }

  Future<void> markMessagesRead(List<int> ids) =>
      _post('/api/parent/messages/read', {'ids': ids});

  Future<void> requestLeave({
    required int studentId,
    required String reasonType,
    String? reasonText,
    required DateTime fromDate,
    required DateTime toDate,
  }) => _post('/api/parent/leave', {
    'studentId': studentId,
    'reasonType': reasonType,
    if (reasonText != null) 'reasonText': reasonText,
    'fromDate': _iso(fromDate),
    'toDate': _iso(toDate),
  });

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}

// ═══════════════════════════════════════════════════════════
//  ماډلونه
// ═══════════════════════════════════════════════════════════

class PingInfo {
  final String school;
  final String api;
  const PingInfo({required this.school, required this.api});
}

class PairResponse {
  final String token;
  final String role;
  final String school;
  final String deviceName;
  final int? guardianId;
  final String? guardianName;

  const PairResponse({
    required this.token,
    required this.role,
    required this.school,
    required this.deviceName,
    this.guardianId,
    this.guardianName,
  });
}

class ManagerSummary {
  final String date;
  final int total;
  final int present;
  final int late;
  final int absent;
  final int onLeave;
  final int unmarked;
  final int presentPercent;
  final int pendingLeave;
  final int unnotifiedAbsent;
  final int unreadNotifications;

  const ManagerSummary({
    required this.date,
    required this.total,
    required this.present,
    required this.late,
    required this.absent,
    required this.onLeave,
    required this.unmarked,
    required this.presentPercent,
    required this.pendingLeave,
    required this.unnotifiedAbsent,
    required this.unreadNotifications,
  });

  static int _i(Object? v) => (v as num?)?.toInt() ?? 0;

  factory ManagerSummary.fromJson(Map<String, dynamic> j) => ManagerSummary(
    date: j['date'] as String? ?? '',
    total: _i(j['total']),
    present: _i(j['present']),
    late: _i(j['late']),
    absent: _i(j['absent']),
    onLeave: _i(j['onLeave']),
    unmarked: _i(j['unmarked']),
    presentPercent: _i(j['presentPercent']),
    pendingLeave: _i(j['pendingLeave']),
    unnotifiedAbsent: _i(j['unnotifiedAbsent']),
    unreadNotifications: _i(j['unreadNotifications']),
  );
}

class AbsenteeInfo {
  final int studentId;
  final String name;
  final String? className;
  final String? fatherName;
  final int monthlyAbsences;

  const AbsenteeInfo({
    required this.studentId,
    required this.name,
    this.className,
    this.fatherName,
    this.monthlyAbsences = 0,
  });

  factory AbsenteeInfo.fromJson(Map<String, dynamic> j) => AbsenteeInfo(
    studentId: (j['studentId'] as num).toInt(),
    name: j['name'] as String? ?? '',
    className: j['class'] as String?,
    fatherName: j['fatherName'] as String?,
    monthlyAbsences: (j['monthlyAbsences'] as num?)?.toInt() ?? 0,
  );
}

class NotifyResult {
  final int sent;
  final int failed;
  final int queued;
  const NotifyResult({
    required this.sent,
    required this.failed,
    required this.queued,
  });
}

class NotificationInfo {
  final int id;
  final String kind;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  final bool read;
  final bool acted;
  final DateTime createdAt;

  const NotificationInfo({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.createdAt,
    this.payload,
    this.read = false,
    this.acted = false,
  });

  factory NotificationInfo.fromJson(Map<String, dynamic> j) =>
      NotificationInfo(
        id: (j['id'] as num).toInt(),
        kind: j['kind'] as String? ?? '',
        title: j['title'] as String? ?? '',
        body: j['body'] as String? ?? '',
        payload: j['payload'] as Map<String, dynamic>?,
        read: j['read'] == true,
        acted: j['acted'] == true,
        createdAt:
            DateTime.tryParse(j['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  /// د غیرحاضرۍ خبرتیا ده چې تڼۍ ورسره ځي؟
  bool get isAbsenceDigest => kind == 'absence_digest';

  String? get relatedDate => payload?['date'] as String?;
  int get count => (payload?['count'] as num?)?.toInt() ?? 0;
}

class LeaveInfo {
  final int id;
  final String student;
  final String? className;
  final String reasonType;
  final String? reasonText;
  final String fromDate;
  final String toDate;
  final int days;
  final String status;
  final String via;

  const LeaveInfo({
    required this.id,
    required this.student,
    required this.reasonType,
    required this.fromDate,
    required this.toDate,
    required this.days,
    required this.status,
    required this.via,
    this.className,
    this.reasonText,
  });

  factory LeaveInfo.fromJson(Map<String, dynamic> j) => LeaveInfo(
    id: (j['id'] as num).toInt(),
    student: j['student'] as String? ?? '',
    className: j['class'] as String?,
    reasonType: j['reasonType'] as String? ?? 'other',
    reasonText: j['reasonText'] as String?,
    fromDate: j['fromDate'] as String? ?? '',
    toDate: j['toDate'] as String? ?? '',
    days: (j['days'] as num?)?.toInt() ?? 1,
    status: j['status'] as String? ?? 'pending',
    via: j['via'] as String? ?? 'reception',
  );
}

class ChildInfo {
  final int id;
  final String name;
  final String admissionNo;
  final String? className;
  final int monthPresent;
  final int monthAbsent;
  final int monthLeave;
  final int attendancePercent;

  const ChildInfo({
    required this.id,
    required this.name,
    required this.admissionNo,
    this.className,
    this.monthPresent = 0,
    this.monthAbsent = 0,
    this.monthLeave = 0,
    this.attendancePercent = 100,
  });

  factory ChildInfo.fromJson(Map<String, dynamic> j) => ChildInfo(
    id: (j['id'] as num).toInt(),
    name: j['name'] as String? ?? '',
    admissionNo: j['admissionNo'] as String? ?? '',
    className: j['class'] as String?,
    monthPresent: (j['monthPresent'] as num?)?.toInt() ?? 0,
    monthAbsent: (j['monthAbsent'] as num?)?.toInt() ?? 0,
    monthLeave: (j['monthLeave'] as num?)?.toInt() ?? 0,
    attendancePercent: (j['attendancePercent'] as num?)?.toInt() ?? 100,
  );
}

class ChildAttendance {
  final String month;
  final Map<String, int> summary;

  /// «2026-05-12» → «absent»
  final Map<String, String> byDate;

  const ChildAttendance({
    required this.month,
    required this.summary,
    required this.byDate,
  });

  factory ChildAttendance.fromJson(Map<String, dynamic> j) {
    final days = <String, String>{};
    for (final e in (j['days'] as List? ?? const [])) {
      final m = e as Map<String, dynamic>;
      days[m['date'] as String] = m['status'] as String;
    }
    return ChildAttendance(
      month: j['month'] as String? ?? '',
      summary: {
        for (final e in (j['summary'] as Map? ?? const {}).entries)
          e.key as String: (e.value as num).toInt(),
      },
      byDate: days,
    );
  }
}

class ParentMessage {
  final int id;
  final String kind;
  final String body;
  final String channel;
  final bool read;
  final DateTime createdAt;

  const ParentMessage({
    required this.id,
    required this.kind,
    required this.body,
    required this.channel,
    required this.read,
    required this.createdAt,
  });

  factory ParentMessage.fromJson(Map<String, dynamic> j) => ParentMessage(
    id: (j['id'] as num).toInt(),
    kind: j['kind'] as String? ?? '',
    body: j['body'] as String? ?? '',
    channel: j['channel'] as String? ?? 'app',
    read: j['read'] == true,
    createdAt:
        DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// د یوې خپرې شوې ازموینې پایله — د والدینو اپ لپاره.
class ExamResultInfo {
  final int examId;
  final String exam;
  final String examType;
  final String date;
  final double obtained;
  final int full;
  final int percent;
  final String grade;
  final String gradeLabel;
  final int rank;
  final int outOf;
  final bool passed;
  final List<SubjectMark> subjects;

  const ExamResultInfo({
    required this.examId,
    required this.exam,
    required this.examType,
    required this.date,
    required this.obtained,
    required this.full,
    required this.percent,
    required this.grade,
    required this.gradeLabel,
    required this.rank,
    required this.outOf,
    required this.passed,
    required this.subjects,
  });

  factory ExamResultInfo.fromJson(Map<String, dynamic> j) => ExamResultInfo(
    examId: (j['examId'] as num).toInt(),
    exam: j['exam'] as String? ?? '',
    examType: j['examType'] as String? ?? '',
    date: j['date'] as String? ?? '',
    obtained: (j['obtained'] as num?)?.toDouble() ?? 0,
    full: (j['full'] as num?)?.toInt() ?? 0,
    percent: (j['percent'] as num?)?.toInt() ?? 0,
    grade: j['grade'] as String? ?? '',
    gradeLabel: j['gradeLabel'] as String? ?? '',
    rank: (j['rank'] as num?)?.toInt() ?? 0,
    outOf: (j['outOf'] as num?)?.toInt() ?? 0,
    passed: j['passed'] == true,
    subjects: [
      for (final s in (j['subjects'] as List? ?? const []))
        SubjectMark.fromJson(s as Map<String, dynamic>),
    ],
  );
}

class SubjectMark {
  final String name;
  final double? obtained;
  final int full;
  final int pass;
  final bool absent;
  final bool passed;

  const SubjectMark({
    required this.name,
    required this.full,
    required this.pass,
    required this.absent,
    required this.passed,
    this.obtained,
  });

  factory SubjectMark.fromJson(Map<String, dynamic> j) => SubjectMark(
    name: j['name'] as String? ?? '',
    obtained: (j['obtained'] as num?)?.toDouble(),
    full: (j['full'] as num?)?.toInt() ?? 100,
    pass: (j['pass'] as num?)?.toInt() ?? 40,
    absent: j['absent'] == true,
    passed: j['passed'] == true,
  );
}
