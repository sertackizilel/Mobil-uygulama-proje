// Bu dosya Besin veri modelini içerir. Bir besinin tüm besin değerlerini tutar.
class Besin {
  final int id;
  final String isim;
  final int kalori;
  final double protein;
  final double karbonhidrat;
  final double yag;
  final double fiber;
  final String kategori;

  Besin({
    required this.id,
    required this.isim,
    required this.kalori,
    required this.protein,
    required this.karbonhidrat,
    required this.yag,
    required this.fiber,
    required this.kategori,
  });

  factory Besin.fromJson(Map<String, dynamic> json) {
    return Besin(
      id: json['id'],
      isim: json['isim'],
      kalori: json['kalori'],
      protein: json['protein'].toDouble(),
      karbonhidrat: json['karbonhidrat'].toDouble(),
      yag: json['yag'].toDouble(),
      fiber: json['fiber'].toDouble(),
      kategori: json['kategori'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'isim': isim,
      'kalori': kalori,
      'protein': protein,
      'karbonhidrat': karbonhidrat,
      'yag': yag,
      'fiber': fiber,
      'kategori': kategori,
    };
  }
} 