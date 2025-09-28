import 'package:flutter/material.dart';
import '../models/besin.dart';
import '../services/supabase_service.dart';

// Bu dosya, kullanıcının bir öğüne besin eklemesini sağlayan ekranı içerir.
// Kullanıcı, kategorilere göre besinleri filtreleyebilir, birden fazla besin seçebilir ve seçtiklerini öğüne ekleyebilir.

/// BesinSecimSayfasi: Bir öğüne besin eklemek için kullanılan ekran.
/// [ogunAdi]: Eklenecek öğünün adı.
/// [ogunId]: Eklenecek öğünün veritabanı ID'si.
class BesinSecimSayfasi extends StatefulWidget {
  /// Eklenecek öğünün adı
  final String ogunAdi;
  /// Eklenecek öğünün veritabanı ID'si
  final int ogunId;

  /// Yapıcı metot, gerekli parametrelerle ekranı başlatır
  const BesinSecimSayfasi({
    Key? key,
    required this.ogunAdi,
    required this.ogunId,
  }) : super(key: key);

  @override
  _BesinSecimSayfasiState createState() => _BesinSecimSayfasiState();
}

/// Ekranın state'i. Besin listesi, seçilen besinler ve kategori filtreleme burada yönetilir.
class _BesinSecimSayfasiState extends State<BesinSecimSayfasi> {
  /// Veritabanından çekilen tüm besinler
  List<Besin> tumBesinler = [];
  /// Kullanıcının seçtiği besinler
  List<Besin> secilenBesinler = [];
  /// Seçili kategori (filtreleme için)
  String secilenKategori = 'Tümü';
  /// Besinler yükleniyor mu?
  bool yukleniyor = true;

  /// Uygulamada kullanılan besin kategorileri
  final List<String> kategoriler = [
    'Tümü',
    'Kahvaltılık',
    'Ana Yemek',
    'Meyve',
    'Sebze',
    'Atıştırmalık',
    'İçecek',
  ];

  /// Sayfa açıldığında besinleri veritabanından çeker
  @override
  void initState() {
    super.initState();
    besinleriYukle();
  }

  /// Supabase'den tüm besinleri çeker ve ekrana yükler
  Future<void> besinleriYukle() async {
    setState(() {
      yukleniyor = true;
    });

    try {
      final besinler = await SupabaseService().getTumBesinler();
      setState(() {
        tumBesinler = besinler;
        yukleniyor = false;
      });
    } catch (e) {
      setState(() {
        yukleniyor = false;
      });
    }
  }

  /// Seçili kategoriye göre besinleri filtreler
  List<Besin> getFiltrelenmisBesinler() {
    if (secilenKategori == 'Tümü') {
      return tumBesinler;
    }
    return tumBesinler.where((besin) => besin.kategori == secilenKategori).toList();
  }

  /// Ekranın ana arayüzü. Kategori filtreleme, besin seçimi ve ekleme işlemleri burada yapılır.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Ekran başlığı, seçilen öğün adı ile birlikte gösterilir
        title: Text('${widget.ogunAdi} - Besin Seç'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          // Kategori filtreleme alanı. Kullanıcı besinleri kategoriye göre filtreleyebilir.
          Container(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: kategoriler.length,
              itemBuilder: (context, index) {
                final kategori = kategoriler[index];
                final secili = kategori == secilenKategori;

                // Her kategori için bir FilterChip oluşturulur
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: FilterChip(
                    label: Text(kategori),
                    selected: secili,
                    onSelected: (selected) {
                      // Kategori seçildiğinde filtre güncellenir
                      setState(() {
                        secilenKategori = kategori;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: Colors.blueAccent,
                    labelStyle: TextStyle(
                      color: secili ? Colors.white : Colors.black,
                    ),
                  ),
                );
              },
            ),
          ),

          // Seçilen besinler alanı. Kullanıcı seçtiği besinleri görebilir ve çıkarabilir.
          if (secilenBesinler.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seçilen Besinler:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: secilenBesinler.map((besin) {
                      // Her seçilen besin için bir Chip gösterilir
                      return Chip(
                        label: Text(besin.isim),
                        deleteIcon: Icon(Icons.close, size: 18),
                        onDeleted: () {
                          // Besin çıkarma işlemi
                          setState(() {
                            secilenBesinler.remove(besin);
                          });
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

          // Besin listesi alanı. Filtrelenmiş besinler listelenir ve seçilebilir.
          Expanded(
            child: yukleniyor
                ? Center(child: CircularProgressIndicator()) // Besinler yükleniyorsa gösterilir
                : ListView.builder(
                    itemCount: getFiltrelenmisBesinler().length,
                    itemBuilder: (context, index) {
                      final besin = getFiltrelenmisBesinler()[index];
                      final secili = secilenBesinler.contains(besin);

                      // Her besin için bir ListTile oluşturulur
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: secili ? Colors.blueAccent : Colors.grey[300],
                          child: Icon(
                            secili ? Icons.check : Icons.add,
                            color: secili ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        title: Text(besin.isim), // Besin adı
                        subtitle: Text('${besin.kalori} kcal'), // Kalori bilgisi
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('P: ${besin.protein}g'), // Protein
                            Text('K: ${besin.karbonhidrat}g'), // Karbonhidrat
                            Text('Y: ${besin.yag}g'), // Yağ
                          ],
                        ),
                        onTap: () {
                          // Besin seçme/çıkarma işlemi
                          setState(() {
                            if (secili) {
                              secilenBesinler.remove(besin);
                            } else {
                              secilenBesinler.add(besin);
                            }
                          });
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
      // Alt kısımda seçilen besinleri ekleme butonu
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          // En az bir besin seçildiyse ekleme aktif olur
          onPressed: secilenBesinler.isNotEmpty
              ? () {
                  // Seçilen besinler ana ekrana geri gönderilir
                  Navigator.pop(context, secilenBesinler);
                }
              : null,
          child: Text('Seçilen Besinleri Ekle (${secilenBesinler.length})'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}