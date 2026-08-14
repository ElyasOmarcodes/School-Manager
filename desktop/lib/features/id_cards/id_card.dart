import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/l10n/strings.dart';
import '../../core/utils/numerals.dart';
import '../../core/utils/qr_token.dart';
import '../../data/db/database.dart';

/// هغه معلومات چې پر یوه کارت چاپېږي.
class CardData {
  final String schoolName;
  final String studentName;
  final String fatherName;
  final String admissionNo;
  final String className;
  final String yearLabel;

  /// هغه متن چې په QR کې ځي — لاسلیک شوی، نه خام نمبر.
  final String qrPayload;

  const CardData({
    required this.schoolName,
    required this.studentName,
    required this.fatherName,
    required this.admissionNo,
    required this.className,
    required this.yearLabel,
    required this.qrPayload,
  });

  /// د یوه شاګرد له ریکارډ څخه کارت جوړوي.
  ///
  /// **د پټ کلي په اړه:** هر شاګرد خپل `qrSecret` لري چې د داخلې پر
  /// مهال جوړ شوی. کارت د هغه پر بنسټ لاسلیکېږي، نو د یوه شاګرد
  /// کارت د بل لپاره نه شي جوړېدی حتی که څوک د کوډ بڼه وپېژني.
  factory CardData.forStudent({
    required Student student,
    required String schoolName,
    required String className,
    required String yearLabel,
  }) {
    final secret = student.qrSecret;
    return CardData(
      schoolName: schoolName,
      studentName: [
        student.firstName,
        if (student.lastName != null && student.lastName!.isNotEmpty)
          student.lastName,
      ].join(' '),
      fatherName: student.fatherName,
      admissionNo: student.admissionNo,
      className: className,
      yearLabel: yearLabel,
      // که پټ کلید نه وي (زوړ ریکارډ)، تش QR جوړوو نه چې ناسم
      // لاسلیک — سکینر به يې رد کړي او مدیر به پوه شي چې کارت
      // باید له سره جوړ شي.
      qrPayload: secret == null
          ? ''
          : QrToken.encode(
              admissionNo: student.admissionNo,
              cardVersion: student.cardVersion,
              schoolKey: secret,
            ),
    );
  }
}

/// د آی‌ډي کارت مخ — د پردې د کتنې لپاره.
///
/// اندازه د CR80 معیار ده (۸۵.۶ × ۵۴ ملي‌متره) — هماغه د بانک د
/// کارت اندازه، نو معیاري کارت‌ساتونکي او پرنټرونه ورسره کار کوي.
class IdCardView extends StatelessWidget {
  final CardData data;
  final AppLocale locale;

  /// د پردې پر مخ د کارت پلنوالی. لوړوالی له نسبت څخه راځي.
  final double width;

  const IdCardView({
    super.key,
    required this.data,
    required this.locale,
    this.width = 340,
  });

  /// ۸۵.۶ / ۵۴ = ۱.۵۸۵
  static const double aspect = 85.6 / 54.0;

  @override
  Widget build(BuildContext context) {
    final height = width / aspect;
    final s = width / 340; // د اندازې ضریب

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12 * s),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14 * s,
            offset: Offset(0, 5 * s),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── د ښوونځي کرښه ──────────────────────────────────
          Container(
            height: 42 * s,
            padding: EdgeInsets.symmetric(horizontal: 12 * s),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: AppColors.gradIndigo,
                begin: Alignment.centerRight,
                end: Alignment.centerLeft,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 17 * s,
                ),
                SizedBox(width: 8 * s),
                Expanded(
                  child: Text(
                    data.schoolName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5 * s,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  locale.num(data.yearLabel),
                  style: TextStyle(
                    fontSize: 10 * s,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // ── بدنه ───────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(11 * s),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عکس
                  Container(
                    width: 62 * s,
                    height: 76 * s,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF0F7),
                      borderRadius: BorderRadius.circular(7 * s),
                      border: Border.all(
                        color: const Color(0xFFD9DEEB),
                        width: 1 * s,
                      ),
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 30 * s,
                      color: const Color(0xFFAAB2C6),
                    ),
                  ),
                  SizedBox(width: 11 * s),

                  // نوم او معلومات
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data.studentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14 * s,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF141726),
                          ),
                        ),
                        SizedBox(height: 1 * s),
                        Text(
                          'ولد ${data.fatherName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10.5 * s,
                            color: const Color(0xFF6B7189),
                          ),
                        ),
                        SizedBox(height: 9 * s),
                        _Row(label: 'ټولګی', value: data.className, s: s),
                        SizedBox(height: 3 * s),
                        _Row(
                          label: 'آی‌ډي',
                          value: locale.num(data.admissionNo),
                          s: s,
                          mono: true,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8 * s),

                  // QR
                  Column(
                    children: [
                      Container(
                        width: 64 * s,
                        height: 64 * s,
                        padding: EdgeInsets.all(3 * s),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5 * s),
                          border: Border.all(
                            color: const Color(0xFFE3E6EF),
                            width: 1 * s,
                          ),
                        ),
                        child: data.qrPayload.isEmpty
                            ? Icon(
                                Icons.qr_code_2_rounded,
                                size: 28 * s,
                                color: const Color(0xFFCBD1E0),
                              )
                            : QrImageView(
                                data: data.qrPayload,
                                version: QrVersions.auto,
                                padding: EdgeInsets.zero,
                                gapless: true,
                                // د تېروتنې اصلاح: کارت په جېب کې
                                // خیرن او خښتن کېږي. `M` کچه ~۱۵٪
                                // زیانمنه برخه بیا لوستلی شي.
                                errorCorrectionLevel: QrErrorCorrectLevel.M,
                              ),
                      ),
                      SizedBox(height: 3 * s),
                      Text(
                        'د حاضرۍ کارت',
                        style: TextStyle(
                          fontSize: 7 * s,
                          color: const Color(0xFF9AA0B4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final double s;
  final bool mono;

  const _Row({
    required this.label,
    required this.value,
    required this.s,
    this.mono = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        SizedBox(
          width: 34 * s,
          child: Text(
            label,
            style: TextStyle(fontSize: 9 * s, color: const Color(0xFF9AA0B4)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10.5 * s,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF3D4257),
              fontFeatures: mono ? const [FontFeature.tabularFigures()] : null,
            ),
          ),
        ),
      ],
    );
  }
}
