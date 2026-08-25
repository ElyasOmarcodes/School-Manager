import 'package:flutter/material.dart';

import '../../core/l10n/strings.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// **د سوالیه پاڼو جوړول — لا د تعریف په تمه.**
///
/// دا توکی په سایډبار کې دی ځکه چې ځای يې ټاکل شوی، خو څه چې پکې
/// کېږي لا نه دي ټاکل شوي. یوه تشه پاڼه چې څه نه وايي، له دې بدتره
/// ده — نو دلته څرګنده لیکل شوي چې څه به راځي او څه لا پکار دي.
class QuestionPapersPage extends StatelessWidget {
  const QuestionPapersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = context.palette;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.modExams.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.description_rounded,
                size: 30,
                color: AppColors.modExams,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              s.questionPapers,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: p.ink,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'دا برخه لا نه ده جوړه شوې — د هغې تفصیل لا نه دی ټاکل شوی.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: p.muted),
            ),
            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: p.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'کله چې تفصیل يې ووایاست، دا شیان تیار دي:',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: p.inkSoft,
                    ),
                  ),
                  const SizedBox(height: 10),
                  for (final line in const [
                    'د هرې ازموینې مضامین او د هغو بشپړې نمرې',
                    'د هرې درجې/ټولګي نصاب او کتابونه',
                    'د ښوونځي نوم، لوګو او د چاپ چوکاټ',
                    'د PDF جوړولو او چاپ ماشین',
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              line,
                              style: TextStyle(fontSize: 12.5, color: p.muted),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
