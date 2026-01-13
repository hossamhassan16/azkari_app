class NawawiHadithModel {
  static const List<String> hadithTitles = [
    'الأعمال بالنيات',
    'مراتب الدين (الإسلام، الإيمان، الإحسان)',
    'أركان الإسلام',
    'مراحل خلق الإنسان وخاتمة عمله',
    'رد البدع والمحدثات',
    'الحلال بيّن والحرام بيّن',
    'الدين النصيحة',
    'حرمة دم المسلم وماله',
    'النهي عن كثرة السؤال والتشدد',
    'إن الله طيب لا يقبل إلا طيبًا',
    'دع ما يريبك إلى ما لا يريبك',
    'من حسن إسلام المرء تركه ما لا يعنيه',
    'لا يؤمن أحدكم حتى يحب لأخيه ما يحب لنفسه',
    'حرمة دم المسلم إلا بإحدى ثلاث',
    'من كان يؤمن بالله واليوم الآخر فليقل خيرًا أو ليصمت',
    'لا تغضب',
    'الإحسان في كل شيء',
    'اتق الله حيثما كنت',
    'احفظ الله يحفظك',
    'إذا لم تستح فاصنع ما شئت',
    'قل آمنت بالله ثم استقم',
    'دخول الجنة بفعل الفرائض',
    'الطهور شطر الإيمان',
    'تحريم الظلم',
    'فضل الذكر والصدقة',
    " السلامى وفضل الأعمال اليومية",
    "البر حسن الخلق",
    "التمسك بالسنة والتحذير من البدع",
    "أبواب الخير",
    "حدود الله والسكوت عما عفا عنه",
    "الزهد في الدنيا",
    "لا ضرر ولا ضرار",
    "البينة على المدعي",
    "تغيير المنكر",
    "الأخوة الإسلامية",
    "قضاء حوائج المسلمين",
    "تضاعف الحسنات وفضل الله",
    "الولاية ومحبة الله",
    "التجاوز عن الخطأ والنسيان",
    "كن في الدنيا كأنك غريب",
    "اتباع الهوى تبعًا لما جاء به النبي ﷺ",
    "سعة مغفرة الله",
  ];

  final int number;
  final String title;
  final String hadithText;
  final String description;

  NawawiHadithModel({
    required this.number,
    required this.title,
    required this.hadithText,
    required this.description,
  });

  factory NawawiHadithModel.fromJson(Map<String, dynamic> json, int index) {
    final hadithText = json['hadith'] ?? '';
    final description = json['description'] ?? '';

    // Use predefined title from the list
    String title = index < hadithTitles.length
        ? hadithTitles[index]
        : 'الحديث ${index + 1}';

    return NawawiHadithModel(
      number: index + 1,
      title: title,
      hadithText: hadithText,
      description: description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'title': title,
      'hadithText': hadithText,
      'description': description,
    };
  }
}
