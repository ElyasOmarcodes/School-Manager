import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/teacher_repository.dart';

/// د ټولګیو او بخشونو اداره.
///
/// هر بخش یو کارت دی چې ډک‌والی او مشر استاد ښیي. د ډک‌والي کرښه
/// هغه څه ده چې مدیر يې د داخلې پر مهال ګوري — «کوم بخش لا ځای لري؟»
class ClassesPage extends StatefulWidget {
  final AcademicRepository academic;
  final TeacherRepository teachers;

  const ClassesPage({
    super.key,
    required this.academic,
    required this.teachers,
  });

  @override
  State<ClassesPage> createState() => _ClassesPageState();
}

class _ClassesPageState extends State<ClassesPage> {
  List<SectionOption> _sections = const [];
  List<Teacher> _teacherList = const [];
  Map<int, int?> _homeroom = {};
  bool _loading = true;
  String _yearLabel = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final year = await widget.academic.currentYear();
    final sections = await widget.academic.sections();
    final teachers = await widget.teachers.activeTeachers();

    // د هر بخش مشر استاد — له `sections` جدول څخه مستقیم.
    final rows = await widget.academic.db
        .select(widget.academic.db.sections)
        .get();
    final map = {for (final r in rows) r.id: r.headTeacherId};

    if (!mounted) return;
    setState(() {
      _yearLabel = year?.label ?? '';
      _sections = sections;
      _teacherList = teachers;
      _homeroom = map;
      _loading = false;
    });
  }

  Future<void> _assign(int sectionId, int? teacherId) async {
    await widget.teachers.assignHomeroom(
      sectionId: sectionId,
      teacherId: teacherId,
    );
    setState(() => _homeroom[sectionId] = teacherId);
  }

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;
    final p = context.palette;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // د ټولګي په کچه ډله‌بندي — چې «لسم» او بخشونه يې یو ځای ښکاره شي.
    final byGrade = <String, List<SectionOption>>{};
    for (final s in _sections) {
      byGrade.putIfAbsent(s.gradeName, () => []).add(s);
    }

    final totalSeats = _sections.fold<int>(0, (a, s) => a + s.capacity);
    final taken = _sections.fold<int>(0, (a, s) => a + s.enrolledCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            child: Row(
              children: [
                Text(
                  'د زده‌کړې کال ${locale.num(_yearLabel)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
                const Spacer(),
                _Pill(
                  icon: Icons.meeting_room_rounded,
                  color: AppColors.modClasses,
                  text: '${locale.num(_sections.length)} بخشونه',
                ),
                const SizedBox(width: 8),
                _Pill(
                  icon: Icons.event_seat_rounded,
                  color: taken >= totalSeats
                      ? AppColors.danger
                      : AppColors.success,
                  text:
                      '${locale.num(taken)} له ${locale.num(totalSeats)} ځایونو',
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          if (_sections.isEmpty)
            const _Empty(text: 'لا هېڅ ټولګی نه دی جوړ شوی.')
          else
            for (final entry in byGrade.entries) ...[
              FadeSlideIn(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10, top: 4),
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.muted,
                    ),
                  ),
                ),
              ),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final s in entry.value)
                    _SectionCard(
                      option: s,
                      locale: locale,
                      teachers: _teacherList,
                      headTeacherId: _homeroom[s.sectionId],
                      onAssign: (id) => _assign(s.sectionId, id),
                    ),
                ],
              ),
              const SizedBox(height: 20),
            ],
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final SectionOption option;
  final AppLocale locale;
  final List<Teacher> teachers;
  final int? headTeacherId;
  final ValueChanged<int?> onAssign;

  const _SectionCard({
    required this.option,
    required this.locale,
    required this.teachers,
    required this.headTeacherId,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final ratio = option.capacity == 0
        ? 0.0
        : option.enrolledCount / option.capacity;
    final color = ratio >= 1
        ? AppColors.danger
        : ratio >= 0.85
        ? AppColors.warning
        : AppColors.success;

    return Container(
      width: 268,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.modClasses.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  option.sectionName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.modClasses,
                  ),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: p.ink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // د ډک‌والي کرښه
          Row(
            children: [
              Text(
                '${locale.num(option.enrolledCount)} / ${locale.num(option.capacity)}',
                style: AppTheme.tabular(
                  TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                option.isFull ? 'ډک' : '${locale.num(option.freeSeats)} خالي',
                style: TextStyle(fontSize: 11.5, color: p.muted),
              ),
            ],
          ),
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: ratio.clamp(0.0, 1.0)),
              duration: AppMotion.slow,
              curve: AppMotion.emphasized,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 6,
                backgroundColor: p.surfaceAlt,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // مشر استاد
          DropdownButtonFormField<int?>(
            initialValue: headTeacherId,
            isExpanded: true,
            isDense: true,
            decoration: const InputDecoration(
              labelText: 'مشر استاد',
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: null,
                child: Text('نه دی ټاکل شوی'),
              ),
              for (final t in teachers)
                DropdownMenuItem(
                  value: t.id,
                  child: Text(t.fullName, overflow: TextOverflow.ellipsis),
                ),
            ],
            onChanged: onAssign,
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _Pill({required this.icon, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  final String text;
  const _Empty({required this.text});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.meeting_room_rounded, size: 40, color: p.faint),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(fontSize: 13, color: p.muted)),
        ],
      ),
    );
  }
}
