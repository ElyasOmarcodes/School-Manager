import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/widgets/panel.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../auth/auth_service.dart';
import 'admission_wizard.dart';
import 'bulk_enroll_page.dart';

/// «نوې نوم لیکنه» — دوه لارې، یو ځای.
///
/// **ولې دوه؟** ځکه چې دوه بېل حالتونه دي، نه دوه ذوقونه. کله چې یو
/// شاګرد د کال په منځ کې راځي، وخت شته چې ټول معلومات ولیکل شي —
/// **فردي**. کله چې د کال په پیل کې دوه سوه کسان په دروازه ولاړ وي،
/// وخت نشته — **ډله ایز**، درې خانې، پاتې يې وروسته.
class EnrollPage extends StatefulWidget {
  final StudentRepository students;
  final AcademicRepository academic;
  final Session session;
  final String? databasePath;

  /// د بشپړېدو وروسته — د شاګردانو لیست ته ورګرځي.
  final void Function({String? message}) onDone;

  const EnrollPage({
    super.key,
    required this.students,
    required this.academic,
    required this.session,
    required this.onDone,
    this.databasePath,
  });

  @override
  State<EnrollPage> createState() => _EnrollPageState();
}

class _EnrollPageState extends State<EnrollPage> {
  String _mode = 'single';

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
          decoration: BoxDecoration(
            color: p.surface,
            border: Border(bottom: BorderSide(color: p.line)),
          ),
          child: Row(
            children: [
              SegmentedChoice<String>(
                value: _mode,
                color: AppColors.modStudents,
                options: [
                  (
                    value: 'single',
                    label: s.individual,
                    icon: Icons.person_rounded,
                  ),
                  (
                    value: 'bulk',
                    label: s.bulk,
                    icon: Icons.groups_rounded,
                  ),
                ],
                onChanged: (v) => setState(() => _mode = v),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  _mode == 'single'
                      ? 'بشپړه دوسیه — پېژندنه، سکونت، سرپرست، انځور او ټولګی.'
                      : 'یوازې نوم، د پلار نوم او درجه. پاتې يې وروسته '
                            'د پروفایل له لارې بشپړېږي.',
                  style: TextStyle(fontSize: 12.5, color: p.muted),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.normal,
            switchInCurve: AppMotion.standard,
            layoutBuilder: (current, previous) => Stack(
              fit: StackFit.expand,
              children: [...previous, if (current != null) current],
            ),
            child: _mode == 'single'
                ? AdmissionWizard(
                    key: const ValueKey('single'),
                    students: widget.students,
                    academic: widget.academic,
                    session: widget.session,
                    databasePath: widget.databasePath,
                    onCancel: widget.onDone,
                    onAdmitted: (_, admissionNo) => widget.onDone(
                      message: 'شاګرد ثبت شو — د داخلې نمبر $admissionNo',
                    ),
                  )
                : BulkEnrollPage(
                    key: const ValueKey('bulk'),
                    students: widget.students,
                    academic: widget.academic,
                    session: widget.session,
                    onDone: widget.onDone,
                  ),
          ),
        ),
      ],
    );
  }
}
