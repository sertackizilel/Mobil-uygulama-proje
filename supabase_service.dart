import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/besin.dart';
import '../models/ogun.dart';

// Bu dosya Supabase ile veri işlemlerini yöneten servisleri içerir.

// SupabaseService: Besin ve öğün işlemlerini Supabase üzerinden yönetir.
class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  late SupabaseClient _client;

  void initialize(SupabaseClient client) {
    _client = client;
  }

  // Besin veritabanından tüm besinleri getir
  Future<List<Besin>> getTumBesinler() async {
    try {
      final response = await _client.from('besinler').select().order('isim');

      return response.map((json) => Besin.fromJson(json)).toList();
    } catch (e) {
      print('Besinler getirilirken hata: $e');
      return [];
    }
  }

  // Kategoriye göre besinleri getir
  Future<List<Besin>> getBesinlerByKategori(String kategori) async {
    try {
      final response = await _client
          .from('besinler')
          .select()
          .eq('kategori', kategori)
          .order('isim');

      return response.map((json) => Besin.fromJson(json)).toList();
    } catch (e) {
      print('Kategori besinleri getirilirken hata: $e');
      return [];
    }
  }

  // Günlük öğünleri getir - düzeltilmiş versiyon
  Future<List<Ogun>> getGunlukOgunler(DateTime tarih) async {
    try {
      // Önce öğünleri getir
      final ogunlerResponse = await _client
          .from('ogunler')
          .select()
          .eq('tarih', tarih.toIso8601String().split('T')[0])
          .order('id');

      List<Ogun> ogunler = [];

      for (var ogunJson in ogunlerResponse) {
        // Her öğün için besinleri getir
        final besinlerResponse = await _client
            .from('ogun_besin')
            .select('besin_id')
            .eq('ogun_id', ogunJson['id']);

        List<Besin> besinler = [];
        for (var besinRef in besinlerResponse) {
          final besinResponse =
              await _client
                  .from('besinler')
                  .select()
                  .eq('id', besinRef['besin_id'])
                  .single();

          besinler.add(Besin.fromJson(besinResponse));
        }

        ogunler.add(
          Ogun(
            id: ogunJson['id'],
            isim: ogunJson['isim'],
            tarih: DateTime.parse(ogunJson['tarih']),
            besinler: besinler,
          ),
        );
      }

      return ogunler;
    } catch (e) {
      print('Günlük öğünler getirilirken hata: $e');
      return [];
    }
  }

  // Öğüne besin ekle
  Future<void> oguneBesinEkle(int ogunId, int besinId) async {
    try {
      await _client.from('ogun_besin').insert({
        'ogun_id': ogunId,
        'besin_id': besinId,
      });
    } catch (e) {
      print('Besin eklenirken hata: $e');
    }
  }

  // Öğünden besin çıkar
  Future<void> ogundenBesinCikar(int ogunId, int besinId) async {
    try {
      await _client
          .from('ogun_besin')
          .delete()
          .eq('ogun_id', ogunId)
          .eq('besin_id', besinId);
    } catch (e) {
      print('Besin çıkarılırken hata: $e');
    }
  }

  // Yeni öğün oluştur
  Future<int> yeniOgunOlustur(String isim, DateTime tarih) async {
    try {
      final response =
          await _client
              .from('ogunler')
              .insert({
                'isim': isim,
                'tarih': tarih.toIso8601String().split('T')[0],
              })
              .select()
              .single();

      return response['id'];
    } catch (e) {
      print('Öğün oluşturulurken hata: $e');
      return -1;
    }
  }
}
