import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
import '../auth/auth_service.dart';
import 'photo_picker.dart';

/// د داخلې نمبر مختاړی د زده‌کړې کال له نښې څخه.
///
/// **پام:** کال ښايي «۱۴۰۵» په ختیځو شمېرو ولیکل شي — او دا تلواله
/// حالت دی، ځکه چې د پروګرام ژبه پښتو ده. که مستقیم `[^0-9]` سره
/// پاک شي، ختیځې شمېرې هم غورځي او مختاړی تش پاتې کېږي، نو هر
/// شاګرد به `0000-xxxx` نمبر واخلي — د کلونو ترمنځ به سره ولګېږي.
/// نو لومړی لاتینو ته اړوو.
String admissionPrefix(String? yearLabel) {
  if (yearLabel == null) return '0000';
  final digits = Numerals.toLatin(yearLabel).replaceAll(RegExp(r'[^0-9]'), '');
  return digits.isEmpty ? '0000' : digits;
}

/// د نوي شاګرد د داخلې ویزارډ — پنځه ګامونه.
///
/// ولې ویزارډ او نه یوه اوږده فورمه؟ د داخلې فورمه ~۲۵ خانې لري.
/// په یوه پاڼه کې يې ښودل د ریسیپشن کارکوونکی ستړی کوي او تېروتنې
/// زیاتوي. پنځه کوچني ګامونه، هر یو له خپلې کتنې سره.
class AdmissionWizard extends StatefulWidget {
  final StudentRepository students;
  final AcademicRepository academic;
  final Session session;

  /// د انځورونو د ذخیره کولو لپاره — که `null` وي، د انځور ګام
  /// یوازې پرته له عکسه ښکاري.
  final String? databasePath;

  /// د بریالۍ داخلې وروسته د نوي شاګرد آی‌ډي راګرځوي.
  final void Function(int studentId, String admissionNo) onAdmitted;
  final VoidCallback onCancel;

  const AdmissionWizard({
    super.key,
    required this.students,
    required this.academic,
    required this.session,
    required this.onAdmitted,
    required this.onCancel,
    this.databasePath,
  });

  @override
  State<AdmissionWizard> createState() => _AdmissionWizardState();
}

class _AdmissionWizardState extends State<AdmissionWizard> {
  /// پنځه ګامونه: شاګرد ← سکونت او انځور ← سرپرست ← ټولګی ← بیاکتنه.
  ///
  /// **سکونت ولې خپل ګام لري؟** ځکه چې دری ساحې (ولایت، ولسوالۍ،
  /// کلی) او د انځور اخیستل په یوه اوږده کرښه کې ګډ شوي وای، لومړی
  /// ګام به دومره اوږد و چې کارن به يې نیمایي نه لیدل.
  static const int _steps = 5;
  int _step = 0;

  // ── ګام ۰: شاګرد ────────────────────────────────────────
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _fatherName = TextEditingController();
  final _grandFather = TextEditingController();
  final _birthPlace = TextEditingController();
  final _nationalId = TextEditingController();
  String _gender = 'male';
  DateTime? _birthDate;

  // ── ګام ۱: سکونت، استوګنه او انځور ──────────────────────
  final _village = TextEditingController();
  final _fingerprint = TextEditingController();
  String? _province;
  String? _district;
  String _residency = 'day';
  String? _photoPath;

  // ── ګام ۲: سرپرست ───────────────────────────────────────
  final _guardianName = TextEditingController();
  final _guardianPhone = TextEditingController();
  final _guardianAltPhone = TextEditingController();
  final _guardianJob = TextEditingController();
  final _address = TextEditingController();
  String _relation = 'father';
  String _channel = 'sms';

  // ── ګام ۳: ټولګی ────────────────────────────────────────
  List<SectionOption> _sections = const [];
  int? _sectionId;
  bool _loadingSections = true;

  // ── ګام ۴: ثبت ──────────────────────────────────────────
  String? _admissionNo;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSections();
    _loadAdmissionNo();
    // د پلار نوم د سرپرست نوم ته پخپله ډکېږي — ډېری وخت یو دي.
    _fatherName.addListener(_syncGuardianName);
  }

  @override
  void dispose() {
    _fatherName.removeListener(_syncGuardianName);
    for (final c in [
      _firstName,
      _lastName,
      _fatherName,
      _grandFather,
      _birthPlace,
      _nationalId,
      _guardianName,
      _guardianPhone,
      _guardianAltPhone,
      _guardianJob,
      _address,
      _village,
      _fingerprint,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// که کارن لا د سرپرست نوم په لاس نه وي لیکلی، د پلار نوم ورته
  /// وړاندیز کوو. کله چې يې په لاس بدل کړ، نور نه ورګډېږو.
  bool _guardianNameTouched = false;
  void _syncGuardianName() {
    if (_guardianNameTouched) return;
    if (_relation != 'father') return;
    _guardianName.text = _fatherName.text;
  }

  Future<void> _loadSections() async {
    final list = await widget.academic.sections();
    if (!mounted) return;
    setState(() {
      _sections = list;
      _loadingSections = false;
    });
  }

  Future<void> _loadAdmissionNo() async {
    final year = await widget.academic.currentYear();
    if (!mounted) return;
    final no = await widget.students.nextAdmissionNo(
      admissionPrefix(year?.label),
    );
    if (!mounted) return;
    setState(() => _admissionNo = no);
  }

  bool get _stepValid => switch (_step) {
    0 =>
      _firstName.text.trim().isNotEmpty && _fatherName.text.trim().isNotEmpty,
    // سکونت اختیاري دی — ډېر وخت د داخلې پر مهال نه معلومېږي.
    1 => true,
    2 => _guardianName.text.trim().isNotEmpty,
    3 => true, // ټولګی اختیاري دی — شاګرد د ټولګي پرته هم ثبتېدی شي
    _ => true,
  };

  Future<void> _submit() async {
    if (_admissionNo == null) return;
    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final year = await widget.academic.currentYear();
      final rollNo = _sectionId == null
          ? null
          : await widget.academic.nextRollNo(_sectionId!);

      final id = await widget.students.admit(
        student: StudentsCompanion.insert(
          admissionNo: _admissionNo!,
          firstName: _firstName.text.trim(),
          lastName: Value(_text(_lastName)),
          fatherName: _fatherName.text.trim(),
          grandFatherName: Value(_text(_grandFather)),
          gender: _gender,
          birthDate: Value(_birthDate),
          birthPlace: Value(_text(_birthPlace)),
          nationalId: Value(_text(_nationalId)),
          phone: Value(_digits(_guardianPhone)),
          address: Value(_text(_address)),
          province: Value(_province),
          district: Value(_district),
          village: Value(_text(_village)),
          residency: Value(_residency),
          photoPath: Value(_photoPath),
          fingerprintId: Value(_text(_fingerprint)),
        ),
        guardians: [
          GuardiansCompanion.insert(
            fullName: _guardianName.text.trim(),
            relation: _relation,
            phone: Value(_digits(_guardianPhone)),
            altPhone: Value(_digits(_guardianAltPhone)),
            occupation: Value(_text(_guardianJob)),
            address: Value(_text(_address)),
            preferredChannel: Value(_channel),
          ),
        ],
        sectionId: _sectionId,
        academicYearId: _sectionId == null ? null : year?.id,
        rollNo: rollNo,
        byUserId: widget.session.userId,
        byUserName: widget.session.username,
      );

      if (!mounted) return;
      widget.onAdmitted(id, _admissionNo!);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        // د داخلې نمبر ښايي پر منځ کې بل چا ونیولی وي.
        _error = e.toString().contains('UNIQUE')
            ? 'دا د داخلې نمبر لا نیول شوی. پاڼه بیا پرانیزئ.'
            : 'ثبت ونه شو: $e';
      });
    }
  }

  String? _text(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  /// تلیفون تل لاتیني ساتو — که کارن «۰۷۰…» ولیکي، اړوو يې.
  /// له دې پرته به لټون او SMS لیږل مات شي.
  String? _digits(TextEditingController c) {
    final v = Numerals.toLatin(c.text.trim());
    return v.isEmpty ? null : v;
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(
            step: _step,
            total: _steps,
            admissionNo: _admissionNo,
            onCancel: widget.onCancel,
          ),
          const SizedBox(height: 18),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: p.line),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(26),
                child: AnimatedSwitcher(
                  duration: AppMotion.normal,
                  switchInCurve: AppMotion.standard,
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: SlideTransition(
                      position: Tween(
                        begin: const Offset(0.03, 0),
                        end: Offset.zero,
                      ).animate(anim),
                      child: child,
                    ),
                  ),
                  child: KeyedSubtree(
                    key: ValueKey(_step),
                    child: _buildStep(),
                  ),
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 14),
            _ErrorBanner(text: _error!),
          ],
          const SizedBox(height: 18),
          _Footer(
            step: _step,
            total: _steps,
            valid: _stepValid,
            submitting: _submitting,
            onBack: () => setState(() => _step--),
            onNext: () => setState(() => _step++),
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildStep() => switch (_step) {
    0 => _studentStep(),
    1 => _residenceStep(),
    2 => _guardianStep(),
    3 => _classStep(),
    _ => _reviewStep(),
  };

  // ── ګام ۱: سکونت، استوګنه، انځور ────────────────────────

  Widget _residenceStep() {
    final s = S.of(context);
    final p = context.palette;

    return _StepBody(
      title: 'سکونت او انځور',
      subtitle: 'ټول اختیاري دي — وروسته له پروفایل څخه هم ډکېدی شي.',
      children: [
        _Row2(
          left: TypeAheadField(
            label: s.province,
            icon: Icons.map_rounded,
            value: _province,
            options: provinceNames,
            // د ولایت بدلون ولسوالۍ پاکوي — که نه، د کندهار
            // ولسوالۍ به د هرات سره پاتې وه.
            onChanged: (v) => setState(() {
              _province = v;
              _district = null;
            }),
          ),
          right: TypeAheadField(
            label: s.district,
            icon: Icons.place_rounded,
            enabled: _province != null,
            hint: _province == null ? 'لومړی ولایت وټاکئ' : null,
            value: _district,
            options: districtsOf(_province),
            onChanged: (v) => setState(() => _district = v),
          ),
        ),
        _Row2(
          left: _Field(label: s.village, controller: _village),
          right: _Field(
            label: '${s.fingerprint} — اختیاري',
            controller: _fingerprint,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          s.residency,
          style: TextStyle(fontSize: 12, color: p.faint),
        ),
        const SizedBox(height: 7),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: SegmentedChoice<String>(
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
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _PhotoBox(path: _photoPath),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.photo,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: p.ink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'انځور د ډیټابیس تر څنګ ساتل کېږي، نو د بیک‌اپ سره ځي.',
                    style: TextStyle(fontSize: 11.5, color: p.muted),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: widget.databasePath == null || _admissionNo == null
                            ? null
                            : _pickPhoto,
                        icon: const Icon(
                          Icons.add_a_photo_rounded,
                          size: 16,
                        ),
                        label: Text(
                          _photoPath == null ? s.photo : 'بدل کړه',
                        ),
                      ),
                      if (_photoPath != null) ...[
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => setState(() => _photoPath = null),
                          child: Text(s.delete),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickPhoto() async {
    final db = widget.databasePath;
    final no = _admissionNo;
    if (db == null || no == null) return;
    final path = await pickStudentPhoto(
      context,
      store: PhotoStore(db),
      admissionNo: no,
    );
    if (path != null && mounted) setState(() => _photoPath = path);
  }

  // ── ګام ۰ ───────────────────────────────────────────────

  Widget _studentStep() {
    return _StepBody(
      title: 'د شاګرد معلومات',
      subtitle: 'ستوري لرونکې خانې اړینې دي.',
      children: [
        _Row2(
          left: _Field(
            label: 'نوم *',
            controller: _firstName,
            onChanged: (_) => setState(() {}),
            autofocus: true,
          ),
          right: _Field(label: 'تخلص', controller: _lastName),
        ),
        _Row2(
          left: _Field(
            label: 'د پلار نوم *',
            controller: _fatherName,
            onChanged: (_) => setState(() {}),
          ),
          right: _Field(label: 'د نیکه نوم', controller: _grandFather),
        ),
        _Row2(
          left: _Choice(
            label: 'جنس',
            value: _gender,
            options: const {'male': 'زلمی', 'female': 'نجلۍ'},
            onChanged: (v) => setState(() => _gender = v),
          ),
          right: _DateField(
            label: 'د زېږېدنې نېټه',
            value: _birthDate,
            onChanged: (d) => setState(() => _birthDate = d),
          ),
        ),
        _Row2(
          left: _Field(label: 'د زېږېدنې ځای', controller: _birthPlace),
          right: _Field(
            label: 'د تذکرې نمبر',
            controller: _nationalId,
            digitsOnly: true,
          ),
        ),
      ],
    );
  }

  // ── ګام ۲ ───────────────────────────────────────────────

  Widget _guardianStep() {
    return _StepBody(
      title: 'سرپرست',
      subtitle: 'د غیرحاضرۍ او فیس خبرتیاوې دې شمېرې ته ځي.',
      children: [
        _Row2(
          left: _Field(
            label: 'بشپړ نوم *',
            controller: _guardianName,
            onChanged: (_) {
              _guardianNameTouched = true;
              setState(() {});
            },
          ),
          right: _Choice(
            label: 'اړیکه',
            value: _relation,
            options: const {
              'father': 'پلار',
              'mother': 'مور',
              'brother': 'ورور',
              'uncle': 'تره / ماما',
              'other': 'بل',
            },
            onChanged: (v) => setState(() => _relation = v),
          ),
        ),
        _Row2(
          left: _Field(
            label: 'تلیفون',
            controller: _guardianPhone,
            digitsOnly: true,
            hint: '07XXXXXXXX',
          ),
          right: _Field(
            label: 'بل تلیفون',
            controller: _guardianAltPhone,
            digitsOnly: true,
          ),
        ),
        _Row2(
          left: _Field(label: 'دنده', controller: _guardianJob),
          right: _Choice(
            label: 'د پیغام لار',
            value: _channel,
            options: const {
              'sms': 'SMS',
              'app': 'د والدینو اپ',
              'whatsapp': 'واټس‌اپ',
              'none': 'هېڅ',
            },
            onChanged: (v) => setState(() => _channel = v),
          ),
        ),
        _Field(label: 'پته', controller: _address, maxLines: 2),
      ],
    );
  }

  // ── ګام ۳ ───────────────────────────────────────────────

  Widget _classStep() {
    final p = context.palette;

    if (_loadingSections) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_sections.isEmpty) {
      return const _StepBody(
        title: 'ټولګی',
        subtitle: '',
        children: [
          _Note(
            color: AppColors.warning,
            icon: Icons.info_outline_rounded,
            text:
                'لا هېڅ ټولګی نه دی جوړ شوی. شاګرد اوس هم ثبتېدی شي — '
                'وروسته يې له تنظیماتو څخه ټولګي ته اضافه کولی شئ.',
          ),
        ],
      );
    }

    return _StepBody(
      title: 'ټولګی او بخش',
      subtitle: 'اختیاري — وروسته هم بدلېدی شي.',
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final s in _sections)
              _SectionTile(
                option: s,
                selected: _sectionId == s.sectionId,
                onTap: s.isFull && _sectionId != s.sectionId
                    ? null
                    : () => setState(
                        () => _sectionId = _sectionId == s.sectionId
                            ? null
                            : s.sectionId,
                      ),
              ),
          ],
        ),
        if (_sectionId == null)
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child: Text(
              'هېڅ ټولګی نه دی ټاکل شوی — شاګرد به «بې‌ټولګي» ثبت شي.',
              style: TextStyle(fontSize: 12.5, color: p.muted),
            ),
          ),
      ],
    );
  }

  // ── ګام ۴ ───────────────────────────────────────────────

  Widget _reviewStep() {
    final s = S.of(context);
    final section = _sections
        .where((x) => x.sectionId == _sectionId)
        .firstOrNull;

    return _StepBody(
      title: 'بیاکتنه',
      subtitle: 'وګورئ چې هر څه سم دي، بیا «ثبت کړه» ووهئ.',
      children: [
        _ReviewGroup(
          title: 'شاګرد',
          rows: {
            'د داخلې نمبر': _admissionNo == null
                ? '…'
                : s.locale.num(_admissionNo!),
            'نوم': [
              _firstName.text.trim(),
              _lastName.text.trim(),
            ].where((e) => e.isNotEmpty).join(' '),
            'د پلار نوم': _fatherName.text.trim(),
            'جنس': _gender == 'male' ? 'زلمی' : 'نجلۍ',
            if (_birthDate != null)
              'د زېږېدنې نېټه': s.locale.num(
                '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
              ),
          },
        ),
        _ReviewGroup(
          title: 'سرپرست',
          rows: {
            'نوم': _guardianName.text.trim(),
            'اړیکه': switch (_relation) {
              'father' => 'پلار',
              'mother' => 'مور',
              'brother' => 'ورور',
              'uncle' => 'تره / ماما',
              _ => 'بل',
            },
            'تلیفون': _guardianPhone.text.trim().isEmpty
                ? '—'
                : s.locale.num(_digits(_guardianPhone) ?? ''),
            'د پیغام لار': switch (_channel) {
              'sms' => 'SMS',
              'app' => 'د والدینو اپ',
              'whatsapp' => 'واټس‌اپ',
              _ => 'هېڅ',
            },
          },
        ),
        _ReviewGroup(
          title: 'سکونت',
          rows: {
            s.province: _province ?? '—',
            s.district: _district ?? '—',
            s.village: _village.text.trim().isEmpty
                ? '—'
                : _village.text.trim(),
            s.residency: _residency == 'boarding' ? s.boarder : s.dayScholar,
            s.photo: _photoPath == null ? 'نشته' : 'ثبت شوی',
          },
        ),
        _ReviewGroup(
          title: 'ټولګی',
          rows: {'بخش': section?.label ?? 'نه دی ټاکل شوی'},
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════
//  د ویزارډ ټوټې
// ═══════════════════════════════════════════════════════════

/// د انځور کوچنی مخکتنی چوکاټ.
class _PhotoBox extends StatelessWidget {
  final String? path;
  const _PhotoBox({required this.path});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final file = path == null ? null : File(path!);
    final ok = file != null && file.existsSync();

    return Container(
      width: 88,
      height: 106,
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: p.line),
        image: ok
            ? DecorationImage(image: FileImage(file), fit: BoxFit.cover)
            : null,
      ),
      child: ok
          ? null
          : Icon(Icons.person_rounded, size: 34, color: p.faint),
    );
  }
}

class _Header extends StatelessWidget {
  final int step;
  final int total;
  final String? admissionNo;
  final VoidCallback onCancel;

  const _Header({
    required this.step,
    required this.total,
    required this.admissionNo,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;

    return Row(
      children: [
        IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.arrow_forward_rounded, size: 20),
          tooltip: 'بېرته لیست ته',
        ),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'نوی شاګرد',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: p.ink,
              ),
            ),
            Text(
              'ګام ${locale.num(step + 1)} له ${locale.num(total)} څخه',
              style: TextStyle(fontSize: 12, color: p.muted),
            ),
          ],
        ),
        const Spacer(),
        if (admissionNo != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.09),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.badge_rounded,
                  size: 15,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 7),
                Text(
                  locale.num(admissionNo!),
                  style: AppTheme.tabular(
                    const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 14),
        SizedBox(
          width: 190,
          child: _Progress(step: step, total: total),
        ),
      ],
    );
  }
}

class _Progress extends StatelessWidget {
  final int step;
  final int total;
  const _Progress({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: AppMotion.normal,
              curve: AppMotion.standard,
              height: 4,
              decoration: BoxDecoration(
                color: i <= step ? AppColors.primary : p.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          if (i < total - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

class _Footer extends StatelessWidget {
  final int step;
  final int total;
  final bool valid;
  final bool submitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  final VoidCallback onSubmit;

  const _Footer({
    required this.step,
    required this.total,
    required this.valid,
    required this.submitting,
    required this.onBack,
    required this.onNext,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final isLast = step == total - 1;

    return Row(
      children: [
        if (step > 0)
          OutlinedButton.icon(
            onPressed: submitting ? null : onBack,
            icon: const Icon(Icons.chevron_right_rounded, size: 18),
            label: Text(s.back),
          ),
        const Spacer(),
        FilledButton.icon(
          onPressed: (!valid || submitting)
              ? null
              : (isLast ? onSubmit : onNext),
          icon: submitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  isLast ? Icons.check_rounded : Icons.chevron_left_rounded,
                  size: 18,
                ),
          label: Text(isLast ? 'ثبت کړه' : s.next),
        ),
      ],
    );
  }
}

class _StepBody extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _StepBody({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: p.ink,
          ),
        ),
        if (subtitle.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(subtitle, style: TextStyle(fontSize: 12.5, color: p.muted)),
        ],
        const SizedBox(height: 22),
        for (var i = 0; i < children.length; i++)
          FadeSlideIn.staggered(
            index: i,
            offsetY: 6,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: children[i],
            ),
          ),
      ],
    );
  }
}

class _Row2 extends StatelessWidget {
  final Widget left;
  final Widget right;
  const _Row2({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 520) {
          return Column(children: [left, const SizedBox(height: 16), right]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Expanded(child: right),
          ],
        );
      },
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool digitsOnly;
  final String? hint;
  final int maxLines;

  const _Field({
    required this.label,
    required this.controller,
    this.onChanged,
    this.autofocus = false,
    this.digitsOnly = false,
    this.hint,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      autofocus: autofocus,
      maxLines: maxLines,
      // شمېرې تل لاتیني ولیکل شي — د تلیفون او تذکرې لپاره.
      // که ختیځې ولیکل شي، لټون او SMS به مات شي.
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9۰-۹٠-٩+\- ]'))]
          : null,
      textDirection: digitsOnly ? TextDirection.ltr : null,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }
}

class _Choice extends StatelessWidget {
  final String label;
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  const _Choice({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(labelText: label),
      items: [
        for (final e in options.entries)
          DropdownMenuItem(value: e.key, child: Text(e.value)),
      ],
      onChanged: (v) => v == null ? null : onChanged(v),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final text = value == null
        ? ''
        : locale.num(
            '${value!.year}-${value!.month.toString().padLeft(2, '0')}'
            '-${value!.day.toString().padLeft(2, '0')}',
          );

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime(now.year - 10),
          firstDate: DateTime(now.year - 40),
          lastDate: now,
        );
        if (picked != null) onChanged(picked);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.event_rounded, size: 18),
        ),
        child: Text(
          text.isEmpty ? '—' : text,
          style: TextStyle(fontSize: 14, color: text.isEmpty ? p.faint : p.ink),
        ),
      ),
    );
  }
}

class _SectionTile extends StatelessWidget {
  final SectionOption option;
  final bool selected;
  final VoidCallback? onTap;

  const _SectionTile({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final locale = S.of(context).locale;
    final disabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        curve: AppMotion.standard,
        width: 150,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.09)
              : p.surfaceAlt,
          borderRadius: BorderRadius.circular(AppTheme.radius),
          border: Border.all(
            color: selected ? AppColors.primary : p.line,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              option.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: disabled
                    ? p.faint
                    : selected
                    ? AppColors.primary
                    : p.ink,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              option.isFull
                  ? 'ډک دی'
                  : '${locale.num(option.freeSeats)} ځایونه خالي',
              style: TextStyle(
                fontSize: 11.5,
                color: option.isFull ? AppColors.danger : p.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewGroup extends StatelessWidget {
  final String title;
  final Map<String, String> rows;
  const _ReviewGroup({required this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: p.surfaceAlt,
        borderRadius: BorderRadius.circular(AppTheme.radius),
        border: Border.all(color: p.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: p.muted,
            ),
          ),
          const SizedBox(height: 10),
          for (final e in rows.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 130,
                    child: Text(
                      e.key,
                      style: TextStyle(fontSize: 12.5, color: p.muted),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      e.value.isEmpty ? '—' : e.value,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: p.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Note extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String text;
  const _Note({required this.color, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 12.5, color: color, height: 1.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String text;
  const _ErrorBanner({required this.text});

  @override
  Widget build(BuildContext context) => _Note(
    color: AppColors.danger,
    icon: Icons.error_outline_rounded,
    text: text,
  );
}
