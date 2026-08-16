import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/l10n/strings.dart';
import '../../core/utils/numerals.dart';
import 'card_layout.dart';

/// هغه ارزښتونه چې پر یوه کارت لیکل کېږي.
///
/// **ولې یو ګډ ټولګی د درې واړو ډلو لپاره؟** ځکه چې د کارت ډیزاین
/// د کس ډول نه پېژني — یوازې ساحې پېژني. که د شاګرد، استاد او
/// کارمند لپاره درې بېل ټولګي وو، هره کینډۍ به درې ځله لیکل کېده.
class CardValues {
  final String schoolName;
  final String fullName;
  final String fatherName;
  final String idNo;
  final String className;
  final String jobTitle;
  final String yearLabel;
  final String? phone;
  final String? photoPath;
  final String? logoPath;
  final DateTime? expiresOn;
  final String qrPayload;

  const CardValues({
    required this.schoolName,
    required this.fullName,
    required this.idNo,
    this.fatherName = '',
    this.className = '',
    this.jobTitle = '',
    this.yearLabel = '',
    this.phone,
    this.photoPath,
    this.logoPath,
    this.expiresOn,
    this.qrPayload = '',
  });

  /// **کارت باطل شوی؟** د دروازې ساتونکي لپاره یوه ساده پوښتنه.
  bool expiredAt(DateTime now) =>
      expiresOn != null && now.isAfter(expiresOn!);

  String textFor(CardFieldKind kind, AppLocale locale, {String? staticText}) =>
      switch (kind) {
        CardFieldKind.schoolName => schoolName,
        CardFieldKind.fullName => fullName,
        CardFieldKind.fatherName => fatherName.isEmpty
            ? ''
            : 'ولد $fatherName',
        CardFieldKind.idNo => locale.num(idNo),
        CardFieldKind.className => className,
        CardFieldKind.jobTitle => jobTitle,
        CardFieldKind.year => locale.num(yearLabel),
        CardFieldKind.phone => phone == null ? '' : locale.num(phone!),
        CardFieldKind.expiry => expiresOn == null
            ? ''
            : 'تر ${locale.num(_iso(expiresOn!))} پورې',
        CardFieldKind.text => staticText ?? '',
        _ => '',
      };

  static String _iso(DateTime t) =>
      '${t.year}-${t.month.toString().padLeft(2, '0')}'
      '-${t.day.toString().padLeft(2, '0')}';
}

/// **یو کارت رسموي — له ډیزاینه، نه له ټینګ کوډه.**
///
/// هماغه ویجیټ د لیست، مخکتنې او ډیزاینر لپاره کارېږي. که هر یوه
/// خپل رسمول لرل، یو بدلون به يې درې ځایه غوښت — او یو ځای به تل
/// هېر شو، نو مخکتنه به له چاپه توپیر لاره.
class CardCanvas extends StatelessWidget {
  final CardLayout layout;
  final CardValues values;
  final AppLocale locale;
  final double width;

  /// د کارت نسبت — له کینډۍ راځي (پلنوالی ÷ لوړوالی).
  final double aspect;

  /// کومه ساحه ټاکل شوې — یوازې په ډیزاینر کې.
  final int? selectedIndex;

  /// که ریښتینی وي، د هرې ساحې څنډه ښکاري (د ډیزاینر لپاره).
  final bool showGuides;

  const CardCanvas({
    super.key,
    required this.layout,
    required this.values,
    required this.locale,
    this.width = 340,
    this.aspect = cr80WidthMm / cr80HeightMm,
    this.selectedIndex,
    this.showGuides = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = width / aspect;

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Color(layout.background),
        borderRadius: BorderRadius.circular(layout.cornerRadius * height),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.13),
            blurRadius: 0.09 * height,
            offset: Offset(0, 0.03 * height),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (layout.bandHeight > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: layout.bandHeight * height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(layout.bandColor),
                      Color(layout.bandColor).withValues(alpha: 0.82),
                    ],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
              ),
            ),
          for (var i = 0; i < layout.fields.length; i++)
            if (layout.fields[i].visible)
              _positioned(context, layout.fields[i], i, width, height),
        ],
      ),
    );
  }

  Widget _positioned(
    BuildContext context,
    CardField f,
    int index,
    double w,
    double h,
  ) {
    final selected = selectedIndex == index;
    final child = _content(f, w, h);

    // **ځای د ښي خوا څخه** — کارت RTL دی، نو `x = 0` ښي څنډه ده.
    return Positioned(
      right: f.x * w,
      top: f.y * h,
      width: fieldWidth(f, w),
      height: f.kind.isBox ? fieldHeight(f, h) : null,
      child: showGuides
          ? Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected
                      ? const Color(0xFF4C5FD5)
                      : const Color(0x334C5FD5),
                  width: selected ? 1.6 : 0.8,
                ),
              ),
              child: child,
            )
          : child,
    );
  }

  Widget _content(CardField f, double w, double h) {
    switch (f.kind) {
      case CardFieldKind.box:
        return DecoratedBox(decoration: BoxDecoration(color: Color(f.color)));

      case CardFieldKind.qr:
        // تش payload یعنې کلید نشته — یو خالي چوکاټ ښیو، نه یو
        // QR چې سکینر يې رد کړي او هېڅوک پوه نه شي ولې.
        if (values.qrPayload.isEmpty) {
          return DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0x33000000)),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2_rounded, color: Color(0x44000000)),
            ),
          );
        }
        return QrImageView(
          data: values.qrPayload,
          version: QrVersions.auto,
          padding: EdgeInsets.zero,
          backgroundColor: Colors.white,
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(f.color),
          ),
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(f.color),
          ),
        );

      case CardFieldKind.photo:
        return _Image(
          path: values.photoPath,
          fallback: Icons.person_rounded,
          radius: 0.05 * h,
        );

      case CardFieldKind.logo:
        return _Image(
          path: values.logoPath,
          fallback: Icons.account_balance_rounded,
          radius: 0,
          fit: BoxFit.contain,
        );

      default:
        final text = values.textFor(f.kind, locale, staticText: f.text);
        if (text.isEmpty) return const SizedBox.shrink();
        return Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: switch (f.align) {
            'center' => TextAlign.center,
            'end' => TextAlign.end,
            _ => TextAlign.start,
          },
          style: TextStyle(
            fontSize: f.fontScale * h,
            fontWeight: f.bold ? FontWeight.w800 : FontWeight.w500,
            color: Color(f.color),
            height: 1.15,
          ),
        );
    }
  }
}

class _Image extends StatelessWidget {
  final String? path;
  final IconData fallback;
  final double radius;
  final BoxFit fit;

  const _Image({
    required this.path,
    required this.fallback,
    required this.radius,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final p = path;
    // **له ډیسکه ورک انځور یوه نښه ښیي، نه یوه ماته پاڼه.** د
    // شاګرد انځور ښايي یوه USB کې و چې اوس نه شته.
    final file = p == null || p.isEmpty ? null : File(p);
    final ok = file != null && file.existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: const Color(0x11000000),
        child: ok
            ? Image.file(
                file,
                fit: fit,
                errorBuilder: (_, _, _) =>
                    Center(child: Icon(fallback, color: const Color(0x44000000))),
              )
            : LayoutBuilder(
                builder: (context, c) => Center(
                  child: Icon(
                    fallback,
                    size: c.maxHeight * 0.45,
                    color: const Color(0x33000000),
                  ),
                ),
              ),
      ),
    );
  }
}
