/// د دیني مدرسو رسمي نصاب.
///
/// **سرچینه:** د افغانستان اسلامي امارت، د پوهنې وزارت، د اسلامي
/// زده‌کړو معینیت، د مدارسو او دارالحفاظونو ریاست — «د ټولو دیني
/// مدارسو لپاره نصاب»، ۱۴۴۴ هـ ق / ۱۴۰۱ هـ ش.
///
/// **دا ولې د مکتب له مضامینو بېل دی؟**
/// مدرسه «صنفونه» نه لري، «درجې» لري — او د هرې درجې مضامین
/// (فنون) ټاکل شوي کتابونه لري. یو مکتب «لسم ټولګی، ریاضي» لري؛
/// یوه مدرسه «درجه رابعه، اصول الفقه — اصول الشاشي» لري. که دواړه
/// یوه لیسټ وای، هېڅ یو به سم نه و.
library;

/// د مدرسې یو مضمون — فن او هغه کتاب چې پرې لوستل کېږي.
class MadrasaSubject {
  /// فن — «فقه»، «نحو»، «منطق».
  final String name;

  /// کتاب — «قدوري (صلوة)»، «هدایة النحو».
  final String book;

  const MadrasaSubject(this.name, this.book);
}

/// یوه درجه له خپلو مضامینو سره.
class MadrasaLevel {
  final String name;

  /// ترتیب — ابتدائیه ۱، دورة الحدیث ۱۳.
  final int level;
  final List<MadrasaSubject> subjects;

  const MadrasaLevel({
    required this.name,
    required this.level,
    required this.subjects,
  });
}

/// درې‌ولس درجې، له ابتدائیه څخه تر دورة الحدیث پورې.
const List<MadrasaLevel> madrasaCurriculum = [
  MadrasaLevel(
    name: 'ابتدائیه',
    level: 1,
    subjects: [
      MadrasaSubject('قرآن کریم', 'مشق ربع پاره عم مع حفظ'),
      MadrasaSubject('ادب فارسي', 'پنځ کتاب (بللفظ)'),
      MadrasaSubject('فقه', 'شروط الصلوة'),
      MadrasaSubject('صرف', 'صرف بهایي بعده میزان الصرف'),
      MadrasaSubject('خط', 'خط و کتابت'),
      MadrasaSubject('حساب', 'د اول او دوهم صنف حساب'),
    ],
  ),
  MadrasaLevel(
    name: 'متوسطه',
    level: 2,
    subjects: [
      MadrasaSubject(
        'قرآن کریم و تجوید',
        'جمال القرآن مع مشق و حفظ ثالث ربع پاره عم',
      ),
      MadrasaSubject('فقه', 'قدوري (صلوة)'),
      MadrasaSubject('صرف', 'علم الصرف (ثلاث حصص) بعده زرادي'),
      MadrasaSubject('نحو', 'علم النحو بعده تسهیل النحو'),
      MadrasaSubject('ادب عربي', 'مفید الطالبین بعده تسهیل الادب'),
      MadrasaSubject('خط او حساب', 'خط او د دریم صنف حساب'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه اولی',
    level: 3,
    subjects: [
      MadrasaSubject(
        'قرآن کریم و تجوید',
        'الفوائد المکیه مع حفظ پاره عم نصف اول',
      ),
      MadrasaSubject('فقه و حدیث', 'نورالایضاح بعده زاد الطالبین'),
      MadrasaSubject('صرف', 'ارشاد الصرف بعده زنجاني'),
      MadrasaSubject('نحو', 'نحو میر بعده الشمة'),
      MadrasaSubject('اللغة العربیه', 'الطریقة العصریة (مکمل)'),
      MadrasaSubject('خط او حساب', 'د څلورم صنف حساب'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه ثانیه',
    level: 4,
    subjects: [
      MadrasaSubject('تجوید و اخلاق', 'معلم التجوید بعده تهذیب الاخلاق'),
      MadrasaSubject('فقه', 'کنزالدقائق (اولین)'),
      MadrasaSubject('نحو و ادب فارسي', 'شرح مأته عامل بعده گلستان'),
      MadrasaSubject('صرف', 'مراح الارواح'),
      MadrasaSubject(
        'اللغة العربیه',
        'القرائة الراشده اول بعده معلم الانشاء اول',
      ),
      MadrasaSubject('ادب، عربي و حساب', 'نفحة العرب بعده د پنځم صنف حساب'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه ثالثه',
    level: 5,
    subjects: [
      MadrasaSubject('عقائد', 'الفقه الاکبر بعده ابو المنتهی'),
      MadrasaSubject('فقه', 'شرح الوقایه صلوة'),
      MadrasaSubject('صرف اول لغت عربي', 'فصول اکبري بعده القرائة الراشده ج۲'),
      MadrasaSubject('نحو', 'هدایة النحو'),
      MadrasaSubject('سیرت او انشاء', 'نورالیقین بعده معلم الانشاء ج۲'),
      MadrasaSubject('منطق', 'تیسیر المنطق بعده ایساغوجي بعده مرقات'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه رابعه',
    level: 6,
    subjects: [
      MadrasaSubject(
        'اصول الحدیث و حدیث',
        'خیر الاصول بعده اثار السنن بعده ریاض الصالحین کتاب الادب',
      ),
      MadrasaSubject('فقه', 'شرح الوقایه نکاح'),
      MadrasaSubject('نحو', 'کافیة مکمل'),
      MadrasaSubject('اصول الفقه', 'اصول الشاشي'),
      MadrasaSubject('منطق', 'شرح التهذیب مکمل'),
      MadrasaSubject(
        'ادب عربي و علم العروض',
        'مقامات حریري (عشر مقامات) بعده متن الکافي',
      ),
    ],
  ),
  MadrasaLevel(
    name: 'درجه خامسه',
    level: 7,
    subjects: [
      MadrasaSubject('تفسیر', 'ترجمة القرآن الثلث الاول'),
      MadrasaSubject(
        'حدیث',
        'کتاب الآثار للامام محمد بعده ریاض الصالحین '
            '(من کتاب الجهاد الی آخر کتاب الدعوات)',
      ),
      MadrasaSubject('فقه', 'کنزالدقائق (اخیرین)'),
      MadrasaSubject('اصول الفقه', 'نور الانوار (مکمل)'),
      MadrasaSubject('نحو', 'شرح الجامي (معرب)'),
      MadrasaSubject('علم البلاغة', 'تلخیص المفتاح (مکمل)'),
      MadrasaSubject('منطق', 'بدیع المیزان'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه سادسه',
    level: 8,
    subjects: [
      MadrasaSubject('تفسیر', 'ترجمة القرآن الثلث الثاني'),
      MadrasaSubject(
        'حدیث و تاریخ',
        'مسند الامام الاعظم بعده تاریخ التشریع الاسلامي',
      ),
      MadrasaSubject('فقه', 'هدایة (الصلوة)'),
      MadrasaSubject('اصول الفقه', 'الحسامي'),
      MadrasaSubject('نحو', 'شرح الجامي (مبني)'),
      MadrasaSubject('علم البلاغة', 'مختصر المعاني (مکمل)'),
      MadrasaSubject('منطق', 'القطبي (مکمل)'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه سابعه',
    level: 9,
    subjects: [
      MadrasaSubject(
        'تفسیر و اصول الحدیث',
        'ترجمة القرآن الثلث الاخیر بعده تیسیر مصطلح الحدیث',
      ),
      MadrasaSubject('فقه', 'هدایة النکاح'),
      MadrasaSubject('عقائد', 'شرح العقائد مکمل مع الخیالي'),
      MadrasaSubject('علم البلاغة و علم الهیئة', 'مطول بعده الهیئة الوسطی'),
      MadrasaSubject('منطق', 'سلم العلوم مکمل'),
      MadrasaSubject(
        'حکمت، حساب و هندسة',
        'هدایة الحکمة بعده خلاصة الحساب بعده اوقلیدوس',
      ),
    ],
  ),
  MadrasaLevel(
    name: 'درجه ثامنه',
    level: 10,
    subjects: [
      MadrasaSubject('حدیث', 'اللباب في الجمع بین السنة و الکتاب'),
      MadrasaSubject(
        'اصول الفقه',
        'مسلم الثبوت تا باب ثالث بعده تلویح و توضیح',
      ),
      MadrasaSubject('علم العروض و المناظره', 'محیط الدائره بعده الرشیدیة'),
      MadrasaSubject('صرف', 'شافیة (مکمل)'),
      MadrasaSubject('منطق', 'ملا جلال و میرزاهد'),
      MadrasaSubject('حکمت و علم الهیئة', 'میبذي بعده التصریح'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه تاسعه',
    level: 11,
    subjects: [
      MadrasaSubject(
        'اصول التفسیر و اصول الحدیث',
        'التبیان في علوم القرآن بعده اصول البزدوي',
      ),
      MadrasaSubject('ادب فارسي', 'مثنوي شریف'),
      MadrasaSubject('علم المیراث', 'السراجي بعده الشریفیة'),
      MadrasaSubject('منطق و علم الطب', 'قاضي مبارک بعده قانونچه'),
      MadrasaSubject('منطق و عقائد', 'حمدالله بعده الامور العامة'),
      MadrasaSubject('حکمت و ادب', 'صدرا بعده السبع المعلقات'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه عاشره (موقوف علیه)',
    level: 12,
    subjects: [
      MadrasaSubject('اصول التفسیر و تفسیر', 'الفوز الکبیر و التفسیر البیضاوي'),
      MadrasaSubject('تفسیر', 'جلالین اول'),
      MadrasaSubject('اصول الحدیث و تفسیر', 'شرح نخبة الفکر بعده جلالین ثاني'),
      MadrasaSubject('حدیث (اول)', 'مشکوة اول'),
      MadrasaSubject('حدیث (دوهم)', 'مشکوة ثاني'),
      MadrasaSubject('فقه (اول)', 'هدایة ۳'),
      MadrasaSubject('فقه (دوهم)', 'هدایة ۴'),
    ],
  ),
  MadrasaLevel(
    name: 'درجه حادي عشره (دورة الحدیث)',
    level: 13,
    subjects: [
      MadrasaSubject('حدیث — بخاري', 'صحیح البخاري'),
      MadrasaSubject('حدیث — مسلم', 'صحیح المسلم'),
      MadrasaSubject('حدیث — ترمذي', 'جامع الترمذي'),
      MadrasaSubject('حدیث — ابو داؤد', 'سنن ابي داؤد'),
      MadrasaSubject('حدیث — طحاوي', 'شرح معاني الآثار'),
      MadrasaSubject('حدیث — نسائي و ابن ماجه', 'سنن النسائي و سنن ابن ماجه'),
      MadrasaSubject('حدیث — موطا و شمائل', 'موطائین و شمائل الترمذي'),
    ],
  ),
];

/// د یوې درجې مضامین — د نوم له مخې.
List<MadrasaSubject> madrasaSubjectsOf(String levelName) {
  for (final l in madrasaCurriculum) {
    if (l.name == levelName) return l.subjects;
  }
  return const [];
}

/// د مکتب عام مضامین — د پرتلې لپاره دلته دي.
///
/// **ولې د مدرسې څخه بېل؟** ځکه چې کله د مضمون د زیاتولو پرده
/// پرانیستل شي، هغه وړاندیزونه ښیي چې د دې ښوونځي ډول ته اړوند
/// دي. یو مکتب ته «شرح الوقایه» وړاندیز کول بې‌ګټې دي.
const List<({String name, bool religious})> schoolSubjectSuggestions = [
  (name: 'قرآن کریم', religious: true),
  (name: 'اسلامیات', religious: true),
  (name: 'عربي', religious: true),
  (name: 'حدیث', religious: true),
  (name: 'فقه', religious: true),
  (name: 'پښتو', religious: false),
  (name: 'دري', religious: false),
  (name: 'انګلیسي', religious: false),
  (name: 'ریاضي', religious: false),
  (name: 'فزیک', religious: false),
  (name: 'کیمیا', religious: false),
  (name: 'بیولوژي', religious: false),
  (name: 'تاریخ', religious: false),
  (name: 'جغرافیه', religious: false),
  (name: 'کمپیوټر', religious: false),
  (name: 'ورزش', religious: false),
  (name: 'رسم', religious: false),
  (name: 'مدني زده‌کړې', religious: false),
];
