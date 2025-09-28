import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/kullanici_profili.dart';

// Bu dosya kullanıcı profil işlemlerini yöneten servisleri içerir.

// ProfilService: Kullanıcı profilini Supabase üzerinden yönetir.
class ProfilService {
  String? _localUserId;

  Future<String> getUserId() async {
    // Sabit bir kullanıcı ID'si kullan (aynı cihaz için)
    return 'device-user-12345';
  }

  static final ProfilService _instance = ProfilService._internal();
  factory ProfilService() => _instance;
  ProfilService._internal();

  late SupabaseClient _client;

  void initialize(SupabaseClient client) {
    _client = client;
  }

  // Kullanıcı profilini getir
  Future<KullaniciProfili?> getKullaniciProfili() async {
    try {
      final userId = await getUserId();
      print('Kullanıcı ID: $userId');
      final response = await _client
          .from('kullanici_profilleri')
          .select()
          .eq('local_user_id', userId);
      print('Profil response: $response');
      if (response.isNotEmpty) {
        return KullaniciProfili.fromJson(response.first);
      }
      return null;
    } catch (e) {
      print('Profil getirilirken hata: $e');
      return null;
    }
  }

  // Kullanıcı profilini güncelle
  Future<bool> updateKullaniciProfili(KullaniciProfili profil) async {
    try {
      final userId = await getUserId();
      print('Güncelleme için kullanıcı ID: $userId');
      final data = {
        'isim': profil.isim,
        'boy': profil.boy,
        'kilo': profil.kilo,
        'cinsiyet': profil.cinsiyet,
        'yas': profil.yas,
        'aktivite_seviyesi': profil.aktiviteSeviyesi,
        'hedef_kalori': profil.hedefKalori,
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('Güncellenecek veri: $data');
      await _client
          .from('kullanici_profilleri')
          .update(data)
          .eq('local_user_id', userId);
      return true;
    } catch (e) {
      print('Profil güncellenirken hata: $e');
      return false;
    }
  }

  // Yeni profil oluştur
  Future<bool> createKullaniciProfili(KullaniciProfili profil) async {
    try {
      final userId = await getUserId();
      print('Oluşturma için kullanıcı ID: $userId');
      final data = {
        'local_user_id': userId,
        'isim': profil.isim,
        'boy': profil.boy,
        'kilo': profil.kilo,
        'cinsiyet': profil.cinsiyet,
        'yas': profil.yas,
        'aktivite_seviyesi': profil.aktiviteSeviyesi,
        'hedef_kalori': profil.hedefKalori,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      print('Oluşturulacak veri: $data');
      await _client.from('kullanici_profilleri').insert(data);
      return true;
    } catch (e) {
      print('Profil oluşturulurken hata: $e');
      return false;
    }
  }

  // Profil var mı kontrol et
  Future<bool> profilVarMi() async {
    try {
      final userId = await getUserId();
      final response = await _client
          .from('kullanici_profilleri')
          .select('id')
          .eq('local_user_id', userId);
      return response.isNotEmpty;
    } catch (e) {
      print('Profil kontrolü sırasında hata: $e');
      return false;
    }
  }
}
