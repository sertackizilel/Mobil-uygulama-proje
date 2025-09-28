import 'besin.dart';

// Bu dosya Ogun veri modelini içerir. Bir öğün ve içindeki besinleri temsil eder.

// Ogun: Bir öğün ve içindeki besinleri temsil eden model.
class Ogun {
  final int id;
  final String isim;
  final DateTime tarih;
  final List<Besin> besinler;

  Ogun({
    required this.id,
    required this.isim,
    required this.tarih,
    required this.besinler,
  });

  int get toplamKalori {
    return besinler.fold(0, (sum, besin) => sum + besin.kalori);
  }

  double get toplamProtein {
    return besinler.fold(0.0, (sum, besin) => sum + besin.protein);
  }

  double get toplamKarbonhidrat {
    return besinler.fold(0.0, (sum, besin) => sum + besin.karbonhidrat);
  }

  double get toplamYag {
    return besinler.fold(0.0, (sum, besin) => sum + besin.yag);
  }

  factory Ogun.fromJson(Map<String, dynamic> json) {
    return Ogun(
      id: json['id'],
      isim: json['isim'],
      tarih: DateTime.parse(json['tarih']),
      besinler: (json['besinler'] as List)
          .map((besinJson) => Besin.fromJson(besinJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isim': isim,
      'tarih': tarih.toIso8601String(),
      'besinler': besinler.map((besin) => besin.toJson()).toList(),
    };
  }
} 