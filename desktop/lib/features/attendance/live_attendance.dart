import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../../data/db/database.dart';
import '../../data/repositories/attendance_repository.dart';
import '../../data/repositories/attendance_session_repository.dart';

/// **د حاضرۍ شالید ساتونکی** — کله چې د یوې ناستې وخت راشي، سکینر
/// پخپله ژوندی شي، که څه هم مدیر په بله پاڼه کې وي.
///
/// **دا ولې پکار دی؟**
/// د لیلیه شاګردانو حاضري د شپې ۸:۰۰ بجې پیل کېږي. مدیر ښايي د فیس
/// پاڼه پرانیستې وي. که سکینر یوازې د حاضرۍ پر پاڼه کار کاوه، لومړی
/// سکین به ضایع شوی و — او هغه شاګرد به سبا «غیرحاضر» و.
///
/// دا ټولګی د یوه ثانیوي وخت‌سنجر له مخې د ناستو کړکۍ ګوري او هر
/// بدلون خبروي. **پخپله سکین نه کوي** — یوازې وايي «اوس دا ناسته
/// ژوندۍ ده»، او پرده پرې خپله نښه ښيي.
///
/// **د پروګرام له بندېدو وروسته خبرتیا** لا نه ده جوړه شوې — هغه د
/// نصب‌شوې نسخې (نه پورټیبل) پورې اړه لري، نو د پای لپاره پاتې ده.
class LiveAttendance extends ChangeNotifier {
  final AttendanceSessionRepository sessions;
  final AttendanceRepository attendance;

  /// د ازموینې لپاره — چې «اوس» ثابت وي.
  final DateTime Function() clock;

  /// څومره ځله کتل کېږي. **یوه دقیقه بس ده** — د ناستې کړکۍ په
  /// دقیقو کې ټاکل کېږي، نو له دې څخه ګړندی کتل یوازې د CPU ضایع
  /// ده. د لومړي کتنې لپاره خو سمدستي ځغلي.
  final Duration interval;

  LiveAttendance({
    required this.sessions,
    required this.attendance,
    this.clock = DateTime.now,
    this.interval = const Duration(minutes: 1),
  });

  Timer? _timer;
  bool _running = false;

  List<AttendanceSession> _live = const [];
  final Map<int, SessionStatus> _status = {};

  /// هغه ناستې چې همدا اوس روانې دي.
  List<AttendanceSession> get live => List.unmodifiable(_live);

  bool get isLive => _live.isNotEmpty;

  /// د یوې ژوندۍ ناستې پرمختګ — که لا نه وي لوستل شوی، `null`.
  SessionStatus? statusOf(int sessionId) => _status[sessionId];

  /// د ټولو ژوندیو ناستو ټولټال — د ډاشبورډ د نښې لپاره.
  ({int marked, int target}) get totals {
    var marked = 0;
    var target = 0;
    for (final s in _live) {
      final st = _status[s.id];
      if (st == null) continue;
      marked += st.markedCount;
      target += st.targetCount;
    }
    return (marked: marked, target: target);
  }

  Future<void> start() async {
    if (_running) return;
    _running = true;
    await refresh();
    _timer = Timer.periodic(interval, (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _running = false;
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }

  /// د ناستو حال بیا لولي او که څه بدل شوي وي، خبروي.
  ///
  /// **یوازې د بدلون پر مهال خبروي.** که هره دقیقه `notifyListeners`
  /// وهل کېده، ټوله پرده به هره دقیقه له سره رسمېده — او د فیس پاڼه
  /// به د لیکلو پر مهال ټوپ وهه.
  Future<void> refresh() async {
    final now = clock();
    final next = await sessions.liveAt(now);

    final changed =
        next.length != _live.length ||
        !next.every((s) => _live.any((o) => o.id == s.id));

    _live = next;

    var progressChanged = false;
    final seen = <int>{};
    for (final s in next) {
      seen.add(s.id);
      final st = await sessions.status(session: s, now: now);
      final old = _status[s.id];
      if (old == null ||
          old.markedCount != st.markedCount ||
          old.targetCount != st.targetCount) {
        progressChanged = true;
      }
      _status[s.id] = st;
    }
    _status.removeWhere((id, _) => !seen.contains(id));

    if (changed || progressChanged) notifyListeners();
  }

  /// د شالید له لارې یو سکین — د هرې ژوندۍ ناستې لپاره هڅه کوي.
  ///
  /// **ولې د لومړۍ ژوندۍ ناستې پر ځای «هغه چې شاګرد يې هدف دی»؟**
  /// ځکه چې د شپې ۸:۰۰ بجې ښايي دوه ناستې روانې وي — د لیلیه
  /// عمومي حاضري او د یوې درجې ځانګړې. که کوره لومړۍ ټاکل کېده، د
  /// درجې شاګرد به په ناسمه ناسته کې ثبت شوی و.
  Future<CheckInResult?> scan({
    required String input,
    required int byUserId,
  }) async {
    if (_live.isEmpty) return null;
    final now = clock();

    final student = await attendance.findByInput(input);
    for (final s in _live) {
      if (student != null &&
          !await sessions.isTargeted(session: s, studentId: student.id)) {
        continue;
      }
      final result = await attendance.checkIn(
        input: input,
        now: now,
        byUserId: byUserId,
        sessionId: s.storageId,
      );
      await refresh();
      return result;
    }

    // هېڅ ژوندۍ ناسته يې هدف نه ګڼي — دا پخپله یوه پایله ده.
    return null;
  }
}

/// د ژوندۍ حاضرۍ حال ټولې ونې ته رسوي.
class LiveAttendanceScope extends InheritedNotifier<LiveAttendance> {
  const LiveAttendanceScope({
    super.key,
    required LiveAttendance super.notifier,
    required super.child,
  });

  static LiveAttendance? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<LiveAttendanceScope>()
      ?.notifier;
}

/// **د USB سکینر عمومي اورېدونکی.**
///
/// یو USB QR سکینر ځان کیبورډ ښیي: توري ژر ژر لیکي، بیا Enter.
/// پر حاضرۍ پاڼه دا په یوه `TextField` کې ټولېږي — خو مدیر ښايي بله
/// پاڼه پرانیستې وي.
///
/// **دا ولې د تورو د سرعت له مخې پېژندل کېږي؟**
/// ځکه چې د لاس لیکنه او د سکینر لیکنه بېلولو ته بله لار نشته.
/// انسان په یوه ثانیه کې ۵–۸ توري لیکي؛ سکینر ۱۰۰+. نو که د تورو
/// ترمنځ واټن له ۳۵ms کم وي، دا سکینر دی — او هغه متن د حاضرۍ ته
/// ځي، نه هغه خانې ته چې مدیر پکې د شاګرد نوم لیکي.
class GlobalScanListener extends StatefulWidget {
  final Widget child;

  /// چې د سکین متن بشپړ شي (Enter) — دا بلل کېږي.
  final ValueChanged<String> onScan;

  /// ایا اوس اورېدل پکار دي؟ (یوازې کله چې یوه ناسته روانه وي.)
  final bool enabled;

  const GlobalScanListener({
    super.key,
    required this.child,
    required this.onScan,
    this.enabled = true,
  });

  /// له دې څخه ګړندي توري د ماشین ګڼل کېږي.
  static const Duration machineGap = Duration(milliseconds: 35);

  /// له دې څخه لنډ متن سکین نه ګڼل کېږي — د تصادفي کېکاږنو مخنیوی.
  static const int minLength = 4;

  @override
  State<GlobalScanListener> createState() => _GlobalScanListenerState();
}

class _GlobalScanListenerState extends State<GlobalScanListener> {
  final _buffer = StringBuffer();
  DateTime? _lastKey;

  void _reset() {
    _buffer.clear();
    _lastKey = null;
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }

    final now = DateTime.now();
    final gap = _lastKey == null ? null : now.difference(_lastKey!);
    _lastKey = now;

    // ډېر ځنډ — دا نوې لیکنه ده، نه د پخوانۍ دوام.
    if (gap != null && gap > GlobalScanListener.machineGap) _buffer.clear();

    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      final text = _buffer.toString().trim();
      _reset();
      if (text.length >= GlobalScanListener.minLength) {
        widget.onScan(text);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }

    final ch = event.character;
    if (ch != null && ch.isNotEmpty && ch.trim().isNotEmpty) {
      _buffer.write(ch);
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      // **`canRequestFocus: false`** — دا نوډ هېڅکله فوکس نه اخلي،
      // یوازې د ونې تېرېدونکي کلیدونه ګوري. که فوکس يې اخیست،
      // د لیکنې خانې به مات شوې وې.
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: _onKey,
      child: widget.child,
    );
  }
}
