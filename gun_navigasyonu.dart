import 'package:flutter/material.dart';

// Bu dosya gün navigasyonu widget'ını içerir.
// Kullanıcı bir gün seçtiğinde, önceki ve sonraki günlere geçiş sağlar.

// GünNavigasyonu: Tarih seçimi ve günler arası geçiş için kullanılır.
class GunNavigasyonu extends StatelessWidget {
  final DateTime secilenTarih;
  final Function(DateTime) onGunDegisti;

  const GunNavigasyonu({
    Key? key,
    required this.secilenTarih,
    required this.onGunDegisti,
  }) : super(key: key);

  String getGunAdi(DateTime tarih) {
    final gunler = [
      'Pazartesi',
      'Salı',
      'Çarşamba',
      'Perşembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];
    return gunler[tarih.weekday - 1];
  }

  String getAyAdi(DateTime tarih) {
    final aylar = [
      'Ocak',
      'Şubat',
      'Mart',
      'Nisan',
      'Mayıs',
      'Haziran',
      'Temmuz',
      'Ağustos',
      'Eylül',
      'Ekim',
      'Kasım',
      'Aralık',
    ];
    return aylar[tarih.month - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Sol ok - önceki gün
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.blueAccent),
            onPressed: () {
              onGunDegisti(secilenTarih.subtract(Duration(days: 1)));
            },
          ),

          // Gün bilgisi
          Expanded(
            child: Column(
              children: [
                Text(
                  getGunAdi(secilenTarih),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                Text(
                  '${secilenTarih.day} ${getAyAdi(secilenTarih)} ${secilenTarih.year}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Sağ ok - sonraki gün
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent),
            onPressed: () {
              onGunDegisti(secilenTarih.add(Duration(days: 1)));
            },
          ),
        ],
      ),
    );
  }
}
