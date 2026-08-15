import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';

import '../../core/data/afghanistan.dart';
import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_motion.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/photo_store.dart';
import '../../core/widgets/panel.dart';
import '../../core/widgets/typeahead_field.dart';
import '../../data/db/database.dart';
import '../../data/repositories/academic_repository.dart';
import '../../data/repositories/student_repository.dart';
import '../../data/repositories/user_repository.dart';
import '../auth/auth_service.dart';
import 'photo_picker.dart';

/// د یوه شاګرد بشپړه دوسیه.
///
/// **دا ولې یوه ځانګړې پاڼه ده او نه یو ډیالوګ؟**
/// ځکه چې دلته درې بېل کارونه کېږي: کتل، سمول، او د حاضرۍ کتنه.
/// یو ډیالوګ به دې درې واړو ته تنګ و — او د میاشتې د حاضرۍ جدول
/// يې هېڅ نه ځایېده.
class StudentProfilePage extends StatefulWidget {
  final int studentId;
  final StudentRepository students;
  final AcademicRepository academic;
  final Session session;
  final String? databasePath;
  final VoidCallback onBack;

  /// د ازموینې لپاره — چې «نن» ثابته وي.
  final DateTime Function() clock;

  const StudentProfilePage({
    super.key,
    required this.studentId,
    required this.students,
    required this.academic,
    required this.session,
    required this.onBack,
    this.databasePath,
    this.clock = DateTime.now,
  });

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  StudentProfile? _profile;
  bool _loading = true;
  bool _editing = false;
  List<SectionOption> _sections = const [];

  /// د حاضرۍ د جدول میاشت — د لومړي بار پر مهال د وروستي ریکارډ
  /// میاشت، نه «نن».
  DateTime _month = DateTime(2000);

  Map<int, String> _grid = const {};

  /// `month` یا `year` — د حاضرۍ د کتنې کچه.
  String _span = 'month';
  List<({int month, int present, int absent, int leave})> _year = const [];

  // ── د سمون خانې ────────────────────────────────────────
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _father = TextEditingController();
  final _grandFather = TextEditingController();
  final _phone = TextEditingController();
  final _nationalId = TextEditingController();
  final _village = TextEditingController();
  final _guardianName = TextEditingController();
  final _guardianPhone = TextEditingController();
  final _fingerprint = TextEditingController();
  final _birth = TextEditingController();

  String _gender = 'male';
  String _residency = 'day';
  String _status = 'active';
  String? _province;
  String? _district;
  int? _sectionId;
  String? _photoPath;

  bool get _canEdit => widget.session.permissions.can('students', Perm.edit);

  /// **د حاضرۍ سمون هر چا ته نه دی.** یو استاد چې د یوه شاګرد
  /// دوسیه ګوري، باید د تېرې میاشتې غیرحاضري ونه بدلوي — که نه،
  /// د حاضرۍ ټول ریکارډ به بې‌اعتباره و.
  bool get _canEditAttendance =>
      widget.session.permissions.can('attendance', Perm.edit);

  @override
  void initState() {
    super.initState();
    final now = widget.clock();
    _month = DateTime(now.year, now.month);
    _load();
  }

  @override
  void dispose() {
    for (final c in [
      _first,
      _last,
      _father,
      _grandFather,
      _phone,
      _nationalId,
      _village,
      _guardianName,
      _guardianPhone,
      _fingerprint,
      _birth,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final profile = await widget.students.profile(widget.studentId);
    final sections = await widget.academic.sections();
    if (!mounted || profile == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }

    // که د حاضرۍ هېڅ ریکارډ نه وي، د روانې میاشتې تش جدول ښیو —
    // نه یوه تشه پاڼه چې کارن ونه پوهېږي ولې.
    final month =
        await widget.students.latestAttendanceMonth(widget.studentId) ?? _month;
    final grid = await widget.students.attendanceGrid(
      studentId: widget.studentId,
      month: month,
    );
    final year = await widget.students.yearlyRollup(
      studentId: widget.studentId,
      year: month.year,
    );

    final st = profile.student;
    _first.text = st.firstName;
    _last.text = st.lastName ?? '';
    _father.text = st.fatherName;
    _grandFather.text = st.grandFatherName ?? '';
    _phone.text = st.phone ?? '';
    _nationalId.text = st.nationalId ?? '';
    _village.text = st.village ?? '';
    _fingerprint.text = st.fingerprintId ?? '';
    _birth.text = st.birthDate == null
        ? ''
        : '${st.birthDate!.year}-${st.birthDate!.month.toString().padLeft(2, '0')}'
              '-${st.birthDate!.day.toString().padLeft(2, '0')}';
    _guardianName.text = profile.primaryGuardian?.fullName ?? '';
    _guardianPhone.text = profile.primaryGuardian?.phone ?? '';

    setState(() {
      _profile = profile;
      _sections = sections;
      _month = month;
      _grid = grid;
      _year = year;
      _gender = st.gender;
      _residency = st.residency;
      _status = st.status;
      _province = st.province;
      _district = st.district;
      _photoPath = st.photoPath;
      _sectionId = profile.sectionId;
      _loading = false;
    });
  }

  Future<void> _loadGrid() async {
    final grid = await widget.students.attendanceGrid(
      studentId: widget.studentId,
      month: _month,
    );
    final year = await widget.students.yearlyRollup(
      studentId: widget.studentId,
      year: _month.year,
    );
    if (!mounted) return;
    setState(() {
      _grid = grid;
      _year = year;
    });
  }

  Future<void> _save() async {
    final p = _profile;
    if (p == null) return;

    DateTime? birth;
    final raw = Numerals.toLatin(_birth.text.trim());
    if (raw.isNotEmpty) birth = DateTime.tryParse(raw);

    await widget.students.updateProfile(
      id: p.student.id,
      byUserId: widget.session.userId,
      byUserName: widget.session.fullName,
      changesJson: '{"profile":"edited"}',
      patch: StudentsCompanion(
        firstName: Value(_first.text.trim()),
        lastName: Value(_last.text.trim().isEmpty ? null : _last.text.trim()),
        fatherName: Value(_father.text.trim()),
        grandFatherName: Value(
          _grandFather.text.trim().isEmpty ? null : _grandFather.text.trim(),
        ),
        gender: Value(_gender),
        residency: Value(_residency),
        status: Value(_status),
        birthDate: Value(birth),
        phone: Value(_phone.text.trim().isEmpty ? null : _phone.text.trim()),
        nationalId: Value(
          _nationalId.text.trim().isEmpty ? null : _nationalId.text.trim(),
        ),
        province: Value(_province),
        district: Value(_district),
        village: Value(
          _village.text.trim().isEmpty ? null : _village.text.trim(),
        ),
        photoPath: Value(_photoPath),
        fingerprintId: Value(
          _fingerprint.text.trim().isEmpty ? null : _fingerprint.text.trim(),
        ),
      ),
    );

    if (_guardianName.text.trim().isNotEmpty) {
      await widget.students.upsertPrimaryGuardian(
        studentId: p.student.id,
        fullName: _guardianName.text.trim(),
        relation: p.primaryGuardian?.relation ?? 'father',
        phone: _guardianPhone.text.trim().isEmpty
            ? null
            : _guardianPhone.text.trim(),
      );
    }

    // د بخش بدلون یوازې هغه وخت چې واقعاً بدل شوی وي — که نه، هره
    // ثبتونه به یوه نوې «لېږد» کرښه جوړوله او تاریخچه به ککړه شوه.
    if (_sectionId != null && _sectionId != p.sectionId) {
      final year = await widget.academic.currentYear();
      if (year != null) {
        await widget.students.transferSection(
          studentId: p.student.id,
          sectionId: _sectionId!,
          academicYearId: year.id,
        );
      }
    }

    if (!mounted) return;
    setState(() => _editing = false);
    await _load();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        width: 380,
        backgroundColor: AppColors.success,
        content: Text('پروفایل ثبت شو.'),
      ),
    );
  }

  Future<void> _pickPhoto() async {
    final p = _profile;
    if (p == null || widget.databasePath == null) return;
    final path = await pickStudentPhoto(
      context,
      store: PhotoStore(widget.databasePath!),
      admissionNo: p.student.admissionNo,
    );
    if (path != null && mounted) setState(() => _photoPath = path);
  }

  Future<void> _editDay(int day) async {
    if (!_canEditAttendance) return;
    final date = DateTime(_month.year, _month.month, day);
    // راتلونکې ورځ حاضري نه لري — یوه غلطه کېکاږنه به يې «غیرحاضر»
    // ثبت کړې وه او سبا به يې سکین بې‌ګټې و.
    if (date.isAfter(widget.clock())) return;

    final status = await showDialog<String>(
      context: context,
      builder: (ctx) => _DayStatusDialog(
        date: date,
        current: _grid[day],
      ),
    );
    if (status == null) return;

    await widget.students.setAttendance(
      studentId: widget.studentId,
      date: date,
      status: status,
      byUserId: widget.session.userId,
    );
    await _loadGrid();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final p = _profile;
    if (p == null) {
      return EmptyState(
        icon: Icons.person_off_rounded,
        text: 'دا شاګرد ونه موندل شو.',
        action: TextButton(
          onPressed: widget.onBack,
          child: const Text('بېرته'),
        ),
      );
    }

    return Column(
      children: [
        _Header(
          profile: p,
          editing: _editing,
          canEdit: _canEdit,
          photoPath: _photoPath,
          onBack: widget.onBack,
          onEdit: () => setState(() => _editing = true),
          onCancel: () {
            setState(() => _editing = false);
            _load();
          },
          onSave: _save,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 6, 24, 30),
            children: [
              AnimatedSwitcher(
                duration: AppMotion.normal,
                switchInCurve: AppMotion.standard,
                child: _editing
                    ? _buildEditor(p)
                    : KeyedSubtree(
                        key: const ValueKey('view'),
                        child: _buildOverview(p),
                      ),
              ),
              const SizedBox(height: 16),
              _AttendanceCard(
                month: _month,
                grid: _grid,
                year: _year,
                span: _span,
                canEdit: _canEditAttendance,
                onSpan: (v) => setState(() => _span = v),
                onMonth: (m) {
                  setState(() => _month = m);
                  _loadGrid();
                },
                onDay: _editDay,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── کتنه ────────────────────────────────────────────────

  Widget _buildOverview(StudentProfile p) {
    final s = S.of(context);
    final locale = s.locale;
    final st = p.student;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!p.isComplete)
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _MissingBanner(
              missing: p.missingFields,
              onFix: _canEdit ? () => setState(() => _editing = true) : null,
            ),
          ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Panel(
                title: 'پېژندنه',
                icon: Icons.badge_rounded,
                color: AppColors.modStudents,
                child: Column(
                  children: [
                    _Field('د داخلې نمبر', locale.num(st.admissionNo)),
                    _Field(s.fullName, p.fullName),
                    _Field('د پلار نوم', st.fatherName),
                    if (st.grandFatherName != null)
                      _Field('د نیکه نوم', st.grandFatherName!),
                    _Field('جنس', st.gender == 'female' ? 'نجلۍ' : 'هلک'),
                    _Field(
                      'د زېږېدو نېټه',
                      st.birthDate == null
                          ? '—'
                          : locale.num(
                              '${st.birthDate!.year}-${st.birthDate!.month}'
                              '-${st.birthDate!.day}',
                            ),
                    ),
                    _Field(
                      'تذکره',
                      st.nationalId == null ? '—' : locale.num(st.nationalId!),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Panel(
                title: 'اړیکه او سکونت',
                icon: Icons.place_rounded,
                color: AppColors.modLeave,
                child: Column(
                  children: [
                    _Field(
                      s.phone,
                      st.phone == null ? '—' : locale.num(st.phone!),
                    ),
                    _Field(
                      'سرپرست',
                      p.primaryGuardian?.fullName ?? '—',
                    ),
                    _Field(
                      'د سرپرست ټیلیفون',
                      p.primaryGuardian?.phone == null
                          ? '—'
                          : locale.num(p.primaryGuardian!.phone!),
                    ),
                    _Field(s.province, st.province ?? '—'),
                    _Field(s.district, st.district ?? '—'),
                    _Field(s.village, st.village ?? '—'),
                    _Field(
                      s.residency,
                      st.residency == 'boarding' ? s.boarder : s.dayScholar,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Panel(
                title: 'اکاډمیک',
                icon: Icons.school_rounded,
                color: AppColors.modClasses,
                child: Column(
                  children: [
                    _Field('ټولګی', p.className),
                    _Field(
                      'د حاضرۍ نمبر',
                      p.rollNo == null ? '—' : locale.num(p.rollNo!),
                    ),
                    _Field(
                      'د داخلې نېټه',
                      locale.num(
                        '${st.admittedOn.year}-${st.admittedOn.month}'
                        '-${st.admittedOn.day}',
                      ),
                    ),
                    _Field('حالت', _statusLabel(st.status)),
                    _Field(
                      s.fingerprint,
                      st.fingerprintId == null ? 'نه دی ثبت شوی' : 'ثبت شوی',
                    ),
                    _Field('د کارت نسخه', locale.num(st.cardVersion)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── سمون ────────────────────────────────────────────────

  Widget _buildEditor(StudentProfile p) {
    final s = S.of(context);

    return KeyedSubtree(
      key: const ValueKey('edit'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Panel(
            title: 'پېژندنه',
            icon: Icons.badge_rounded,
            color: AppColors.modStudents,
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _box(TextField(
                  controller: _first,
                  decoration: const InputDecoration(
                    labelText: 'نوم',
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _last,
                  decoration: const InputDecoration(
                    labelText: 'تخلص',
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _father,
                  decoration: const InputDecoration(
                    labelText: 'د پلار نوم',
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _grandFather,
                  decoration: const InputDecoration(
                    labelText: 'د نیکه نوم',
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _birth,
                  decoration: const InputDecoration(
                    labelText: 'د زېږېدو نېټه',
                    hintText: '2012-05-14',
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _nationalId,
                  decoration: const InputDecoration(
                    labelText: 'د تذکرې نمبر',
                    isDense: true,
                  ),
                )),
                _box(SegmentedChoice<String>(
                  value: _gender,
                  options: const [
                    (value: 'male', label: 'هلک', icon: null),
                    (value: 'female', label: 'نجلۍ', icon: null),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                )),
                _box(SegmentedChoice<String>(
                  value: _residency,
                  color: AppColors.modHostel,
                  options: [
                    (
                      value: 'day',
                      label: s.dayScholar,
                      icon: Icons.wb_sunny_rounded,
                    ),
                    (
                      value: 'boarding',
                      label: s.boarder,
                      icon: Icons.night_shelter_rounded,
                    ),
                  ],
                  onChanged: (v) => setState(() => _residency = v),
                )),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Panel(
            title: 'اړیکه او سکونت',
            icon: Icons.place_rounded,
            color: AppColors.modLeave,
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _box(TextField(
                  controller: _phone,
                  decoration: InputDecoration(
                    labelText: s.phone,
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _guardianName,
                  decoration: const InputDecoration(
                    labelText: 'د سرپرست نوم',
                    isDense: true,
                  ),
                )),
                _box(TextField(
                  controller: _guardianPhone,
                  decoration: const InputDecoration(
                    labelText: 'د سرپرست ټیلیفون',
                    isDense: true,
                  ),
                )),
                _box(TypeAheadField(
                  label: s.province,
                  icon: Icons.map_rounded,
                  value: _province,
                  options: provinceNames,
                  onChanged: (v) => setState(() {
                    _province = v;
                    _district = null;
                  }),
                )),
                _box(TypeAheadField(
                  label: s.district,
                  icon: Icons.place_rounded,
                  enabled: _province != null,
                  value: _district,
                  options: districtsOf(_province),
                  onChanged: (v) => setState(() => _district = v),
                )),
                _box(TextField(
                  controller: _village,
                  decoration: InputDecoration(
                    labelText: s.village,
                    isDense: true,
                  ),
                )),
              ],
            ),
          ),
          const SizedBox(height: 14),

          Panel(
            title: 'اکاډمیک او نور',
            icon: Icons.school_rounded,
            color: AppColors.modClasses,
            child: Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                _box(DropdownButtonFormField<int?>(
                  initialValue: _sectionId,
                  isDense: true,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'ټولګی — بخش',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('—')),
                    for (final sec in _sections)
                      DropdownMenuItem(
                        value: sec.sectionId,
                        child: Text(sec.label, overflow: TextOverflow.ellipsis),
                      ),
                  ],
                  onChanged: (v) => setState(() => _sectionId = v),
                )),
                _box(DropdownButtonFormField<String>(
                  initialValue: _status,
                  isDense: true,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'حالت',
                    isDense: true,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('فعال')),
                    DropdownMenuItem(value: 'graduated', child: Text('فارغ')),
                    DropdownMenuItem(
                      value: 'transferred',
                      child: Text('لېږدېدلی'),
                    ),
                    DropdownMenuItem(value: 'dropped', child: Text('پرېښی')),
                    DropdownMenuItem(
                      value: 'suspended',
                      child: Text('ځنډول شوی'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? 'active'),
                )),
                _box(TextField(
                  controller: _fingerprint,
                  decoration: InputDecoration(
                    labelText: '${s.fingerprint} — اختیاري',
                    hintText: 'د سکینر پېژندنه',
                    isDense: true,
                  ),
                )),
                if (widget.databasePath != null)
                  _box(OutlinedButton.icon(
                    onPressed: _pickPhoto,
                    icon: const Icon(Icons.photo_camera_rounded, size: 17),
                    label: Text(
                      _photoPath == null ? s.photo : 'انځور بدل کړه',
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _box(Widget child) => SizedBox(width: 232, child: child);

  static String _statusLabel(String status) => switch (status) {
    'active' => 'فعال',
    'graduated' => 'فارغ',
    'transferred' => 'لېږدېدلی',
    'dropped' => 'پرېښی',
    'suspended' => 'ځنډول شوی',
    _ => status,
  };
}

// ═══════════════════════════════════════════════════════════
//  سرلیک
// ═══════════════════════════════════════════════════════════

class _Header extends StatelessWidget {
  final StudentProfile profile;
  final bool editing;
  final bool canEdit;
  final String? photoPath;
  final VoidCallback onBack;
  final VoidCallback onEdit;
  final VoidCallback onCancel;
  final VoidCallback onSave;

  const _Header({
    required this.profile,
    required this.editing,
    required this.canEdit,
    required this.photoPath,
    required this.onBack,
    required this.onEdit,
    required this.onCancel,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;
    final st = profile.student;
    final color = st.gender == 'female'
        ? AppColors.modTeachers
        : AppColors.modStudents;

    final file = photoPath == null ? null : File(photoPath!);
    final hasPhoto = file != null && file.existsSync();

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: BoxDecoration(
        color: p.surface,
        border: Border(bottom: BorderSide(color: p.line)),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: 'بېرته',
            onPressed: onBack,
            icon: const Icon(Icons.arrow_forward_rounded, size: 19),
          ),
          const SizedBox(width: 6),

          // انځور — که نه وي، د نوم لومړی توری.
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(15),
              image: hasPhoto
                  ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: hasPhoto
                ? null
                : Text(
                    profile.fullName.characters.first,
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    profile.fullName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Pill(
                    color: profile.isComplete
                        ? AppColors.success
                        : AppColors.warning,
                    text: profile.isComplete
                        ? s.completeProfile
                        : s.incompleteProfile,
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                'ولد ${st.fatherName}  ·  ${profile.className}  ·  '
                '${s.locale.num(st.admissionNo)}',
                style: TextStyle(fontSize: 12.5, color: p.muted),
              ),
            ],
          ),
          const Spacer(),

          if (editing) ...[
            TextButton(onPressed: onCancel, child: Text(s.cancel)),
            const SizedBox(width: 8),
            FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.check_rounded, size: 17),
              label: Text(s.save),
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            ),
          ] else if (canEdit)
            FilledButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: Text(s.edit),
              style: FilledButton.styleFrom(backgroundColor: color),
            ),
        ],
      ),
    );
  }
}

class _MissingBanner extends StatelessWidget {
  final List<String> missing;
  final VoidCallback? onFix;

  const _MissingBanner({required this.missing, this.onFix});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.report_problem_rounded,
            size: 18,
            color: AppColors.warning,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              'دا پروفایل نیمګړی دی — ${missing.join('، ')} لا نه دي ډک شوي.',
              style: TextStyle(fontSize: 12.5, color: p.inkSoft),
            ),
          ),
          if (onFix != null)
            TextButton(onPressed: onFix, child: const Text('اوس يې ډک کړه')),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final String value;
  const _Field(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 118,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: p.faint),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: p.inkSoft,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د میاشتې د حاضرۍ جدول
// ═══════════════════════════════════════════════════════════

/// د حالت رنګ — یو ځای، چې جدول او لنډیز یو شان وښيي.
Color statusColor(String? status) => switch (status) {
  'present' => AppColors.success,
  'late' => AppColors.warning,
  'absent' => AppColors.danger,
  'leave' => AppColors.info,
  'holiday' => AppColors.modSettings,
  _ => Colors.transparent,
};

String statusLabelOf(String? status, S s) => switch (status) {
  'present' => s.present,
  'late' => s.late,
  'absent' => s.absent,
  'leave' => s.onLeave,
  'holiday' => 'رخصتي',
  _ => s.unmarked,
};

class _AttendanceCard extends StatelessWidget {
  final DateTime month;
  final Map<int, String> grid;
  final List<({int month, int present, int absent, int leave})> year;
  final String span;
  final bool canEdit;
  final ValueChanged<String> onSpan;
  final ValueChanged<DateTime> onMonth;
  final ValueChanged<int> onDay;

  const _AttendanceCard({
    required this.month,
    required this.grid,
    required this.year,
    required this.span,
    required this.canEdit,
    required this.onSpan,
    required this.onMonth,
    required this.onDay,
  });

  bool get _yearly => span == 'year';

  @override
  Widget build(BuildContext context) {
    final locale = S.of(context).locale;

    return Panel(
      title: _yearly
          ? 'حاضري — د ${locale.num(month.year)} کال'
          : 'حاضري — ${locale.num(month.year)}/${locale.num(month.month)}',
      subtitle: _yearly
          ? 'میاشت‌په‌میاشت لنډیز. پر یوه میاشت کېکاږئ چې ورځې يې وګورئ.'
          : (canEdit
                ? 'پر یوه ورځ کېکاږئ چې حالت يې بدل کړئ.'
                : 'د بدلولو اجازه نه لرئ.'),
      icon: Icons.calendar_month_rounded,
      color: AppColors.modAttendance,
      actions: [
        SegmentedChoice<String>(
          value: span,
          color: AppColors.modAttendance,
          options: const [
            (value: 'month', label: 'میاشت', icon: null),
            (value: 'year', label: 'کال', icon: null),
          ],
          onChanged: onSpan,
        ),
        const SizedBox(width: 8),
        IconButton(
          tooltip: _yearly ? 'تېر کال' : 'تېره میاشت',
          onPressed: () => onMonth(
            _yearly
                ? DateTime(month.year - 1, month.month)
                : DateTime(month.year, month.month - 1),
          ),
          icon: const Icon(Icons.chevron_right_rounded, size: 20),
        ),
        IconButton(
          tooltip: _yearly ? 'راتلونکی کال' : 'راتلونکې میاشت',
          onPressed: () => onMonth(
            _yearly
                ? DateTime(month.year + 1, month.month)
                : DateTime(month.year, month.month + 1),
          ),
          icon: const Icon(Icons.chevron_left_rounded, size: 20),
        ),
      ],
      child: AnimatedSize(
        duration: AppMotion.normal,
        curve: AppMotion.standard,
        alignment: Alignment.topCenter,
        child: _yearly
            ? _YearView(year: year, locale: locale, onMonth: onMonth, base: month)
            : _MonthView(
                month: month,
                grid: grid,
                canEdit: canEdit,
                onDay: onDay,
              ),
      ),
    );
  }
}

class _MonthView extends StatelessWidget {
  final DateTime month;
  final Map<int, String> grid;
  final bool canEdit;
  final ValueChanged<int> onDay;

  const _MonthView({
    required this.month,
    required this.grid,
    required this.canEdit,
    required this.onDay,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;
    final p = context.palette;
    final days = DateTime(month.year, month.month + 1, 0).day;

    final counts = <String, int>{};
    for (final v in grid.values) {
      counts[v] = (counts[v] ?? 0) + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (var d = 1; d <= days; d++)
              _DayCell(
                day: d,
                status: grid[d],
                locale: locale,
                onTap: canEdit ? () => onDay(d) : null,
              ),
          ],
        ),
        const SizedBox(height: 16),
        Divider(height: 1, color: p.line),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final key in const ['present', 'late', 'absent', 'leave'])
              Pill(
                color: statusColor(key),
                text:
                    '${statusLabelOf(key, s)}: ${locale.num(counts[key] ?? 0)}',
              ),
            Pill(
              color: p.faint,
              text: '${s.unmarked}: ${locale.num(days - grid.length)}',
            ),
          ],
        ),
      ],
    );
  }
}

/// **د کال کتنه** — دوولس کرښې، هره یوه یوه میاشت.
///
/// **ولې کرښې او نه یو چارټ؟** ځکه چې دلته پوښتنه «څو ورځې» ده، نه
/// «څومره ښه شوی». یوه کرښه چې «۱۸ حاضر، ۲ غیرحاضر، ۱ رخصت» وايي،
/// د یوه چارټ له کتلو ژر لوستل کېږي — او د والدینو سره د خبرو پر
/// مهال هماغه شمېرې پکار دي.
class _YearView extends StatelessWidget {
  final List<({int month, int present, int absent, int leave})> year;
  final AppLocale locale;
  final DateTime base;
  final ValueChanged<DateTime> onMonth;

  const _YearView({
    required this.year,
    required this.locale,
    required this.base,
    required this.onMonth,
  });

  static const _names = [
    'جنوري',
    'فبروري',
    'مارچ',
    'اپریل',
    'می',
    'جون',
    'جولای',
    'اګست',
    'سپتمبر',
    'اکتوبر',
    'نومبر',
    'دسمبر',
  ];

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    if (year.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 26),
        child: Center(
          child: Text(
            'د ${locale.num(base.year)} کال هېڅ حاضري نشته.',
            style: TextStyle(fontSize: 12.5, color: p.muted),
          ),
        ),
      );
    }

    final byMonth = {for (final r in year) r.month: r};
    final totalP = year.fold(0, (a, r) => a + r.present);
    final totalA = year.fold(0, (a, r) => a + r.absent);
    final totalL = year.fold(0, (a, r) => a + r.leave);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var m = 1; m <= 12; m++)
          _YearRow(
            label: _names[m - 1],
            row: byMonth[m],
            locale: locale,
            onTap: byMonth[m] == null
                ? null
                : () => onMonth(DateTime(base.year, m)),
          ),
        const SizedBox(height: 14),
        Divider(height: 1, color: p.line),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          children: [
            Pill(
              color: AppColors.success,
              text: '${s.present}: ${locale.num(totalP)}',
            ),
            Pill(
              color: AppColors.danger,
              text: '${s.absent}: ${locale.num(totalA)}',
            ),
            Pill(
              color: AppColors.info,
              text: '${s.onLeave}: ${locale.num(totalL)}',
            ),
            Pill(
              color: AppColors.modReports,
              text: totalP + totalA == 0
                  ? '—'
                  : 'سلنه: '
                        '${locale.num((totalP * 100 / (totalP + totalA)).round())}٪',
            ),
          ],
        ),
      ],
    );
  }
}

class _YearRow extends StatelessWidget {
  final String label;
  final ({int month, int present, int absent, int leave})? row;
  final AppLocale locale;
  final VoidCallback? onTap;

  const _YearRow({
    required this.label,
    required this.row,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final r = row;
    final total = r == null ? 0 : r.present + r.absent + r.leave;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 78,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: r == null ? FontWeight.w400 : FontWeight.w600,
                  color: r == null ? p.faint : p.inkSoft,
                ),
              ),
            ),
            // د تناسب کرښه — د میاشتې حالتونه په یوه کتار کې.
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: SizedBox(
                  height: 10,
                  child: total == 0
                      ? Container(color: p.surfaceAlt)
                      : Row(
                          children: [
                            Expanded(
                              flex: r!.present,
                              child: Container(color: AppColors.success),
                            ),
                            Expanded(
                              flex: r.leave,
                              child: Container(color: AppColors.info),
                            ),
                            Expanded(
                              flex: r.absent,
                              child: Container(color: AppColors.danger),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // **شمېرې د کرښې په رنګ رنګ شوې دي.** یو خړ «۲۰/۵/۲»
            // به لوستونکی د ترتیب په اړه اټکل ته اړ کړ؛ رنګ يې
            // مستقیم د بار له برخو سره تړي.
            SizedBox(
              width: 150,
              child: r == null
                  ? Text(
                      '—',
                      textAlign: TextAlign.end,
                      style: TextStyle(fontSize: 11.5, color: p.faint),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        for (final (value, color) in [
                          (r.present, AppColors.success),
                          (r.leave, AppColors.info),
                          (r.absent, AppColors.danger),
                        ]) ...[
                          Text(
                            locale.num(value),
                            style: AppTheme.tabular(
                              TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: value == 0 ? p.faint : color,
                              ),
                            ),
                          ),
                          if (color != AppColors.danger)
                            Text(
                              ' · ',
                              style: TextStyle(fontSize: 11, color: p.faint),
                            ),
                        ],
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final String? status;
  final AppLocale locale;
  final VoidCallback? onTap;

  const _DayCell({
    required this.day,
    required this.status,
    required this.locale,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final c = statusColor(status);
    final marked = status != null;

    return Tooltip(
      message: '${locale.num(day)} — ${statusLabelOf(status, S.of(context))}',
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: onTap == null
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          child: Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: marked ? c.withValues(alpha: 0.15) : p.surfaceAlt,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: marked ? c.withValues(alpha: 0.45) : Colors.transparent,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              locale.num(day),
              style: AppTheme.tabular(
                TextStyle(
                  fontSize: 11.5,
                  fontWeight: marked ? FontWeight.w700 : FontWeight.w500,
                  color: marked ? c : p.faint,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DayStatusDialog extends StatelessWidget {
  final DateTime date;
  final String? current;

  const _DayStatusDialog({required this.date, this.current});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final locale = s.locale;

    return AlertDialog(
      title: Text(
        '${locale.num(date.year)}/${locale.num(date.month)}/'
        '${locale.num(date.day)}',
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700),
      ),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final key in const [
              'present',
              'late',
              'absent',
              'leave',
              'holiday',
            ])
              ListTile(
                dense: true,
                leading: Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor(key),
                    shape: BoxShape.circle,
                  ),
                ),
                title: Text(
                  statusLabelOf(key, s),
                  style: const TextStyle(fontSize: 13),
                ),
                trailing: current == key
                    ? const Icon(
                        Icons.check_rounded,
                        size: 17,
                        color: AppColors.success,
                      )
                    : null,
                onTap: () => Navigator.pop(context, key),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(s.cancel),
        ),
      ],
    );
  }
}
