class QuranJuz {
  final int juzNumber;
  final List<QuranHizb> hizbs;

  QuranJuz({required this.juzNumber, required this.hizbs});

  String get displayName => 'الجزء $juzNumber';
}

class QuranHizb {
  final int hizbNumber;
  final List<QuranThumn> thumns;

  QuranHizb({required this.hizbNumber, required this.thumns});

  String get displayName => 'الحزب $hizbNumber';
  int get globalHizbNumber => hizbNumber;
}

class QuranThumn {
  final int thumnNumber;
  final int hizbNumber;

  QuranThumn({required this.thumnNumber, required this.hizbNumber});

  String get displayName => 'الثمن $thumnNumber من الحزب $hizbNumber';
  int get globalThumnNumber => (hizbNumber - 1) * 8 + thumnNumber;
}

class QuranStructure {
  static List<QuranJuz> generateQuranStructure() {
    final List<QuranJuz> juzs = [];

    for (int juzNumber = 1; juzNumber <= 30; juzNumber++) {
      final List<QuranHizb> hizbs = [];

      for (int hizbIndex = 0; hizbIndex < 2; hizbIndex++) {
        final int hizbNumber = (juzNumber - 1) * 2 + hizbIndex + 1;
        final List<QuranThumn> thumns = [];

        for (int thumnNumber = 1; thumnNumber <= 8; thumnNumber++) {
          thumns.add(
            QuranThumn(thumnNumber: thumnNumber, hizbNumber: hizbNumber),
          );
        }

        hizbs.add(QuranHizb(hizbNumber: hizbNumber, thumns: thumns));
      }

      juzs.add(QuranJuz(juzNumber: juzNumber, hizbs: hizbs));
    }

    return juzs;
  }
}
