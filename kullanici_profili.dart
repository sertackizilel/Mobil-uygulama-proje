// Bu dosya KullaniciProfili veri modelini içerir. Kullanıcıya ait profil bilgilerini tutar.
class KullaniciProfili {
  final String id;
  final String isim;
  final double boy; // cm cinsinden
  final double kilo; // kg cinsinden
  final String cinsiyet; // 'Erkek', 'Kadın', 'Diğer'
  final int yas;
  final String aktiviteSeviyesi; // 'Düşük', 'Orta', 'Yüksek'
  final int hedefKalori; // günlük hedef kalori
  final DateTime createdAt;
  final DateTime? updatedAt;

  KullaniciProfili({
    required this.id,
    required this.isim,
    required this.boy,
    required this.kilo,
    required this.cinsiyet,
    required this.yas,
    required this.aktiviteSeviyesi,
    required this.hedefKalori,
    required this.createdAt,
    this.updatedAt,
  });

  // BMI hesaplama
  double get bmi {
    if (boy > 0) {
      return kilo / ((boy / 100) * (boy / 100));
    }
    return 0;
  }

  // BMI kategorisi
  String get bmiKategori {
    if (bmi < 18.5) return 'Zayıf';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Fazla Kilolu';
    return 'Obez';
  }

  // BMR (Bazal Metabolizma Hızı) hesaplama
  double get bmr {
    if (cinsiyet == 'Erkek') {
      return 88.362 + (13.397 * kilo) + (4.799 * boy) - (5.677 * yas);
    } else {
      return 447.593 + (9.247 * kilo) + (3.098 * boy) - (4.330 * yas);
    }
  }

  // Günlük kalori ihtiyacı
  double get gunlukKaloriIhtiyaci {
    double aktiviteKatsayisi = 1.2; // Düşük aktivite
    if (aktiviteSeviyesi == 'Orta') aktiviteKatsayisi = 1.375;
    if (aktiviteSeviyesi == 'Yüksek') aktiviteKatsayisi = 1.55;

    return bmr * aktiviteKatsayisi;
  }

  factory KullaniciProfili.fromJson(Map<String, dynamic> json) {
    return KullaniciProfili(
      id: json['id'] ?? '',
      isim: json['isim'],
      boy: json['boy']?.toDouble() ?? 0.0,
      kilo: json['kilo']?.toDouble() ?? 0.0,
      cinsiyet: json['cinsiyet'] ?? 'Diğer',
      yas: json['yas'] ?? 0,
      aktiviteSeviyesi: json['aktivite_seviyesi'] ?? 'Düşük',
      hedefKalori: json['hedef_kalori'] ?? 2000,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : DateTime.now(),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isim': isim,
      'boy': boy,
      'kilo': kilo,
      'cinsiyet': cinsiyet,
      'yas': yas,
      'aktivite_seviyesi': aktiviteSeviyesi,
      'hedef_kalori': hedefKalori,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  KullaniciProfili copyWith({
    String? id,
    String? isim,
    double? boy,
    double? kilo,
    String? cinsiyet,
    int? yas,
    String? aktiviteSeviyesi,
    int? hedefKalori,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return KullaniciProfili(
      id: id ?? this.id,
      isim: isim ?? this.isim,
      boy: boy ?? this.boy,
      kilo: kilo ?? this.kilo,
      cinsiyet: cinsiyet ?? this.cinsiyet,
      yas: yas ?? this.yas,
      aktiviteSeviyesi: aktiviteSeviyesi ?? this.aktiviteSeviyesi,
      hedefKalori: hedefKalori ?? this.hedefKalori,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
