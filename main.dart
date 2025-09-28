import 'package:flutter/material.dart'; // Flutter ana paket
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase entegrasyonu
import 'package:intl/intl.dart'; // Tarih formatlama
import 'screens/besin_secim_sayfasi.dart'; // Besin seçimi ekranı
import 'screens/profil_sayfasi.dart'; // Profil ekranı
import 'widgets/gun_navigasyonu.dart'; // Gün navigasyonu widget'ı
import 'services/supabase_service.dart'; // Supabase servisleri
import 'services/profil_service.dart'; // Profil servisleri
import 'models/besin.dart'; // Besin veri modeli
import 'models/ogun.dart'; // Öğün veri modeli
import 'models/kullanici_profili.dart'; // Kullanıcı profili veri modeli

// Bu dosya uygulamanın ana giriş noktasıdır.
// Uygulama, Supabase ile backend bağlantısı kurar ve iki ana sayfa sunar: Günlük ve Profil.
// Kullanıcılar günlük olarak öğün ekleyip çıkarabilir, besin seçebilir ve profil bilgilerini yönetebilir.

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Flutter binding başlatılır

  // Supabase'i başlat (proje URL ve anahtar ile)
  // Burada Supabase backend bağlantısı kuruluyor. URL ve anahtar .env veya config dosyasından alınabilir.
  await Supabase.initialize(
    url: 'https://mrofdlhblqmwmcylvsxq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1yb2ZkbGhibHFtd21jeWx2c3hxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTQzMDUwNDksImV4cCI6MjA2OTg4MTA0OX0.O8r5hxisxRtTL1sFq12bMOuA63CgOsXWKtUvVS_K2Hs',
  );

  // Servisler Supabase client ile başlatılıyor. Böylece veri işlemleri için hazır hale geliyor.
  SupabaseService().initialize(Supabase.instance.client);
  ProfilService().initialize(Supabase.instance.client);

  // Uygulamayı başlat
  runApp(KaloriApp());
}

// Ana uygulama widget'ı. Alt menü ile iki ana sayfa arasında geçiş yapılır.
class KaloriApp extends StatefulWidget {
  @override
  _KaloriAppState createState() => _KaloriAppState();
}

class _KaloriAppState extends State<KaloriApp> {
  // Seçili alt menü index'i (0: Günlük, 1: Profil)
  int _secilenIndex = 0;

  // Sayfa listesi (Günlük ve Profil)
  final List<Widget> _sayfalar = [GunlukSayfasi(), ProfilSayfasi()];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kalori Takibi',
      home: Scaffold(
        // Seçili sayfa gösteriliyor
        body: _sayfalar[_secilenIndex],
        // Alt menü (BottomNavigationBar)
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _secilenIndex,
          onTap: (index) {
            setState(() {
              _secilenIndex = index;
            });
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: "Günlük", // Günlük sayfası
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profil"), // Profil sayfası
          ],
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

// Günlük sayfası: Kullanıcı seçili gün için öğünlerini ve besinlerini yönetir.
class GunlukSayfasi extends StatefulWidget {
  @override
  _GunlukSayfasiState createState() => _GunlukSayfasiState();
}

class _GunlukSayfasiState extends State<GunlukSayfasi> {
  // Kullanıcının seçtiği gün
  DateTime secilenTarih = DateTime.now();
  // O günün öğünleri
  List<Ogun> gunlukOgunler = [];
  // Veri yükleniyor mu?
  bool yukleniyor = true;

  // Uygulamada sabit öğün isimleri
  final List<String> ogunIsimleri = [
    'Kahvaltı',
    'Öğle Yemeği',
    'Akşam Yemeği',
    'Atıştırmalık',
  ];

  @override
  void initState() {
    super.initState();
    ogunleriYukle(); // Sayfa açıldığında o günün öğünleri yüklenir
  }

  // Seçili günün öğünlerini Supabase'den çeker
  Future<void> ogunleriYukle() async {
    if (!mounted) return;

    setState(() {
      yukleniyor = true;
    });

    try {
      final ogunler = await SupabaseService().getGunlukOgunler(secilenTarih);
      if (mounted) {
        setState(() {
          gunlukOgunler = ogunler;
          yukleniyor = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          yukleniyor = false;
        });
      }
    }
  }

  // Haftanın gün adını döndürür
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

  // Tarihin yıl içindeki hafta numarasını döndürür
  int getHaftaNumarasi(DateTime tarih) {
    final yilBaslangici = DateTime(tarih.year, 1, 1);
    final hafta =
        ((tarih.difference(yilBaslangici).inDays + yilBaslangici.weekday - 1) /
                7)
            .ceil();
    return hafta;
  }

  // O günün toplam kalorisi
  int getToplamGunlukKalori() {
    return gunlukOgunler.fold(0, (sum, ogun) => sum + ogun.toplamKalori);
  }

  // Öğüne besin ekleme işlemi. Eğer öğün yoksa önce oluşturulur.
  Future<void> oguneBesinEkle(String ogunAdi) async {
    // Önce öğünün var olup olmadığını kontrol et
    Ogun? mevcutOgun = gunlukOgunler.firstWhere(
      (ogun) => ogun.isim == ogunAdi,
      orElse:
          () => Ogun(id: -1, isim: ogunAdi, tarih: secilenTarih, besinler: []),
    );

    int ogunId;
    if (mevcutOgun.id == -1) {
      // Yeni öğün oluştur
      ogunId = await SupabaseService().yeniOgunOlustur(ogunAdi, secilenTarih);
    } else {
      ogunId = mevcutOgun.id;
    }

    if (ogunId != -1) {
      // Besin seçimi ekranına yönlendir
      final secilenBesinler = await Navigator.push<List<Besin>>(
        context,
        MaterialPageRoute(
          builder:
              (context) => BesinSecimSayfasi(ogunAdi: ogunAdi, ogunId: ogunId),
        ),
      );

      if (secilenBesinler != null && secilenBesinler.isNotEmpty) {
        // Seçilen besinleri öğüne ekle
        for (var besin in secilenBesinler) {
          await SupabaseService().oguneBesinEkle(ogunId, besin.id);
        }

        // Sayfayı yenile
        ogunleriYukle();
      }
    }
  }

  // Öğünden besin çıkarma işlemi
  Future<void> ogundenBesinCikar(Ogun ogun, Besin besin) async {
    await SupabaseService().ogundenBesinCikar(ogun.id, besin.id);
    ogunleriYukle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kalori Takibi'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () async {
              // Tarih seçimi için takvim açılır
              final secilen = await showDatePicker(
                context: context,
                initialDate: secilenTarih,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (secilen != null) {
                setState(() {
                  secilenTarih = secilen;
                });
                ogunleriYukle();
              }
            },
          ),
        ],
      ),
      body:
          yukleniyor
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // Gün navigasyonu: Tarih değiştirme
                  GunNavigasyonu(
                    secilenTarih: secilenTarih,
                    onGunDegisti: (yeniTarih) {
                      setState(() {
                        secilenTarih = yeniTarih;
                      });
                      ogunleriYukle();
                    },
                  ),

                  // Ana içerik
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Günlük özet kartı: Toplam kalori, protein, karbonhidrat, yağ
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Günün Özeti",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildOzetKart(
                                        'Kalori',
                                        '${getToplamGunlukKalori()} kcal',
                                        Icons.local_fire_department,
                                      ),
                                      _buildOzetKart(
                                        'Protein',
                                        '${_getToplamProtein()}g',
                                        Icons.fitness_center,
                                      ),
                                      _buildOzetKart(
                                        'Karbonhidrat',
                                        '${_getToplamKarbonhidrat()}g',
                                        Icons.grain,
                                      ),
                                      _buildOzetKart(
                                        'Yağ',
                                        '${_getToplamYag()}g',
                                        Icons.opacity,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Öğünler listesi: Her öğün için besinler ve ekleme/çıkarma işlemleri
                          Text(
                            "Öğünler",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 10),

                          Expanded(
                            child: ListView.builder(
                              itemCount: ogunIsimleri.length,
                              itemBuilder: (context, index) {
                                final ogunAdi = ogunIsimleri[index];
                                final ogun = gunlukOgunler.firstWhere(
                                  (o) => o.isim == ogunAdi,
                                  orElse:
                                      () => Ogun(
                                        id: -1,
                                        isim: ogunAdi,
                                        tarih: secilenTarih,
                                        besinler: [],
                                      ),
                                );

                                return Card(
                                  margin: EdgeInsets.only(bottom: 8),
                                  child: ExpansionTile(
                                    title: Row(
                                      children: [
                                        Text(ogunAdi),
                                        Spacer(),
                                        Text('${ogun.toplamKalori} kcal'),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: Icon(Icons.add_circle_outline),
                                      onPressed: () => oguneBesinEkle(ogunAdi),
                                    ),
                                    children:
                                        ogun.besinler.isEmpty
                                            ? [
                                              Padding(
                                                padding: const EdgeInsets.all(
                                                  16.0,
                                                ),
                                                child: Text(
                                                  'Henüz besin eklenmemiş',
                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                            ]
                                            : ogun.besinler
                                                .map(
                                                  (besin) => ListTile(
                                                    leading: Icon(
                                                      Icons.fastfood,
                                                    ),
                                                    title: Text(besin.isim),
                                                    subtitle: Text(
                                                      '${besin.kalori} kcal',
                                                    ),
                                                    trailing: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          'P:${besin.protein}g K:${besin.karbonhidrat}g Y:${besin.yag}g',
                                                        ),
                                                        IconButton(
                                                          icon: Icon(
                                                            Icons
                                                                .remove_circle_outline,
                                                            color: Colors.red,
                                                          ),
                                                          onPressed:
                                                              () =>
                                                                  ogundenBesinCikar(
                                                                    ogun,
                                                                    besin,
                                                                  ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }

  // Günlük özet kartı widget'ı
  Widget _buildOzetKart(String baslik, String deger, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blueAccent),
        SizedBox(height: 4),
        Text(baslik, style: TextStyle(fontSize: 12)),
        Text(deger, style: TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  // Toplam protein miktarı
  double _getToplamProtein() {
    return gunlukOgunler.fold(0.0, (sum, ogun) => sum + ogun.toplamProtein);
  }

  // Toplam karbonhidrat miktarı
  double _getToplamKarbonhidrat() {
    return gunlukOgunler.fold(
      0.0,
      (sum, ogun) => sum + ogun.toplamKarbonhidrat,
    );
  }

  // Toplam yağ miktarı
  double _getToplamYag() {
    return gunlukOgunler.fold(0.0, (sum, ogun) => sum + ogun.toplamYag);
  }
}
