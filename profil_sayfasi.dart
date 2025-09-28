import 'package:flutter/material.dart';
import '../models/kullanici_profili.dart';
import '../services/profil_service.dart';

// Bu dosya ProfilSayfasi ekranını içerir. Kullanıcı profilini görüntüleme ve düzenleme işlemleri yapılır.

// ProfilSayfasi: Kullanıcı profil ekranı.
class ProfilSayfasi extends StatefulWidget {
  @override
  _ProfilSayfasiState createState() => _ProfilSayfasiState();
}

class _ProfilSayfasiState extends State<ProfilSayfasi> {
  KullaniciProfili? profil;
  bool yukleniyor = true;
  bool duzenlemeModu = false;

  final _formKey = GlobalKey<FormState>();
  final _isimController = TextEditingController();
  final _boyController = TextEditingController();
  final _kiloController = TextEditingController();
  final _yasController = TextEditingController();
  final _hedefKaloriController = TextEditingController();

  String secilenCinsiyet = 'Erkek';
  String secilenAktiviteSeviyesi = 'Orta';

  @override
  void initState() {
    super.initState();
    profilYukle();
  }

  Future<void> profilYukle() async {
    if (!mounted) return;

    setState(() {
      yukleniyor = true;
    });

    try {
      final yuklenenProfil = await ProfilService().getKullaniciProfili();
      if (mounted) {
        setState(() {
          profil = yuklenenProfil;
          yukleniyor = false;
        });

        if (profil != null) {
          _formControllerlariDoldur();
        }
      }
    } catch (e) {
      print('Profil yükleme hatası: $e');
      if (mounted) {
        setState(() {
          yukleniyor = false;
        });
      }
    }
  }

  void _formControllerlariDoldur() {
    if (profil != null) {
      _isimController.text = profil!.isim;
      _boyController.text = profil!.boy.toString();
      _kiloController.text = profil!.kilo.toString();
      _yasController.text = profil!.yas.toString();
      _hedefKaloriController.text = profil!.hedefKalori.toString();
      secilenCinsiyet = profil!.cinsiyet;
      secilenAktiviteSeviyesi = profil!.aktiviteSeviyesi;
    }
  }

  Future<void> profilKaydet() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final yeniProfil = KullaniciProfili(
        id: profil?.id ?? '',
        isim: _isimController.text,
        boy: double.parse(_boyController.text),
        kilo: double.parse(_kiloController.text),
        cinsiyet: secilenCinsiyet,
        yas: int.parse(_yasController.text),
        aktiviteSeviyesi: secilenAktiviteSeviyesi,
        hedefKalori: int.parse(_hedefKaloriController.text),
        createdAt: profil?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('Kaydedilecek profil: ${yeniProfil.toJson()}');

      bool basarili;
      if (profil == null) {
        print('Yeni profil oluşturuluyor...');
        basarili = await ProfilService().createKullaniciProfili(yeniProfil);
      } else {
        print('Mevcut profil güncelleniyor...');
        basarili = await ProfilService().updateKullaniciProfili(yeniProfil);
      }

      if (basarili) {
        // Profili yeniden yükle
        await profilYukle();
        setState(() {
          duzenlemeModu = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Profil başarıyla kaydedildi!')));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil kaydedilirken hata oluştu!')),
        );
      }
    } catch (e) {
      print('Profil kaydetme hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profil kaydedilirken hata oluştu: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (!duzenlemeModu)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  duzenlemeModu = true;
                });
              },
            ),
        ],
      ),
      body:
          yukleniyor
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profil kartı
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blueAccent,
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            if (profil != null) ...[
                              Text(
                                profil!.isim,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '${profil!.yas} yaşında, ${profil!.cinsiyet}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ] else ...[
                              Text(
                                'Profil henüz oluşturulmamış',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Form veya bilgi kartları
                    if (duzenlemeModu)
                      _buildProfilFormu()
                    else
                      _buildProfilBilgileri(),
                  ],
                ),
              ),
    );
  }

  Widget _buildProfilFormu() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kişisel Bilgiler',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),

          // İsim
          TextFormField(
            controller: _isimController,
            decoration: InputDecoration(
              labelText: 'İsim',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'İsim gerekli';
              }
              // Rakam kontrolü
              if (RegExp(r'[0-9]').hasMatch(value)) {
                return 'İsim rakam içeremez';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Boy ve Kilo
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _boyController,
                  decoration: InputDecoration(
                    labelText: 'Boy (cm)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Boy gerekli';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    double boy = double.parse(value);
                    if (boy < 50 || boy > 300) {
                      return 'Boy 50-300 cm arası olmalı';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _kiloController,
                  decoration: InputDecoration(
                    labelText: 'Kilo (kg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kilo gerekli';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Geçerli bir sayı girin';
                    }
                    double kilo = double.parse(value);
                    if (kilo < 10 || kilo > 500) {
                      return 'Kilo 10-500 kg arası olmalı';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),

          // Yaş
          TextFormField(
            controller: _yasController,
            decoration: InputDecoration(
              labelText: 'Yaş',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Yaş gerekli';
              }
              if (int.tryParse(value) == null) {
                return 'Geçerli bir sayı girin';
              }
              int yas = int.parse(value);
              if (yas < 1 || yas > 150) {
                return 'Yaş 1-150 arası olmalı';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Cinsiyet
          DropdownButtonFormField<String>(
            value: secilenCinsiyet,
            decoration: InputDecoration(
              labelText: 'Cinsiyet',
              border: OutlineInputBorder(),
            ),
            items:
                ['Erkek', 'Kadın', 'Diğer'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                secilenCinsiyet = newValue!;
              });
            },
          ),
          SizedBox(height: 16),

          // Aktivite Seviyesi
          DropdownButtonFormField<String>(
            value: secilenAktiviteSeviyesi,
            decoration: InputDecoration(
              labelText: 'Aktivite Seviyesi',
              border: OutlineInputBorder(),
            ),
            items:
                ['Düşük', 'Orta', 'Yüksek'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                secilenAktiviteSeviyesi = newValue!;
              });
            },
          ),
          SizedBox(height: 16),

          // Hedef Kalori
          TextFormField(
            controller: _hedefKaloriController,
            decoration: InputDecoration(
              labelText: 'Günlük Hedef Kalori',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Hedef kalori gerekli';
              }
              if (int.tryParse(value) == null) {
                return 'Geçerli bir sayı girin';
              }
              int hedefKalori = int.parse(value);
              if (hedefKalori < 500 || hedefKalori > 10000) {
                return 'Hedef kalori 500-10000 arası olmalı';
              }
              return null;
            },
          ),
          SizedBox(height: 24),

          // Butonlar
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: profilKaydet,
                  child: Text('Kaydet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      duzenlemeModu = false;
                      _formControllerlariDoldur();
                    });
                  },
                  child: Text('İptal'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilBilgileri() {
    if (profil == null) {
      return Center(
        child: Column(
          children: [
            Icon(Icons.person_add, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Henüz profil oluşturmadınız',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  duzenlemeModu = true;
                });
              },
              child: Text('Profil Oluştur'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BMI Kartı
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vücut Kitle İndeksi (BMI)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('BMI: ${profil!.bmi.toStringAsFixed(1)}'),
                    Text(
                      profil!.bmiKategori,
                      style: TextStyle(
                        color: _getBmiRenk(profil!.bmi),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Fiziksel Bilgiler
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fiziksel Bilgiler',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildBilgiSatiri('Boy', '${profil!.boy} cm'),
                _buildBilgiSatiri('Kilo', '${profil!.kilo} kg'),
                _buildBilgiSatiri('Yaş', '${profil!.yas}'),
                _buildBilgiSatiri('Cinsiyet', profil!.cinsiyet),
                _buildBilgiSatiri(
                  'Aktivite Seviyesi',
                  profil!.aktiviteSeviyesi,
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 16),

        // Metabolizma Bilgileri
        Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Metabolizma Bilgileri',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                _buildBilgiSatiri(
                  'BMR',
                  '${profil!.bmr.toStringAsFixed(0)} kcal/gün',
                ),
                _buildBilgiSatiri(
                  'Günlük İhtiyaç',
                  '${profil!.gunlukKaloriIhtiyaci.toStringAsFixed(0)} kcal/gün',
                ),
                _buildBilgiSatiri(
                  'Hedef Kalori',
                  '${profil!.hedefKalori} kcal/gün',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBilgiSatiri(String baslik, String deger) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(baslik, style: TextStyle(color: Colors.grey[600])),
          Text(deger, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getBmiRenk(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _isimController.dispose();
    _boyController.dispose();
    _kiloController.dispose();
    _yasController.dispose();
    _hedefKaloriController.dispose();
    super.dispose();
  }
}
