import 'package:supabase_flutter/supabase_flutter.dart';

// Bu dosya Supabase ile kimlik doğrulama işlemlerini yönetir.

// AuthService: Kullanıcı giriş/çıkış işlemleri için servis.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  late SupabaseClient _client;

  void initialize(SupabaseClient client) {
    _client = client;
  }

  // Anonim kullanıcı oluştur
  Future<bool> anonimGirisYap() async {
    try {
      final response = await _client.auth.signUp(
        email: '${DateTime.now().millisecondsSinceEpoch}@temp.com',
        password: 'temp123456',
      );

      if (response.user != null) {
        print('Anonim kullanıcı oluşturuldu: ${response.user!.id}');
        return true;
      }
      return false;
    } catch (e) {
      print('Anonim giriş hatası: $e');
      return false;
    }
  }

  // Mevcut kullanıcıyı kontrol et
  User? getMevcutKullanici() {
    return _client.auth.currentUser;
  }

  // Kullanıcı giriş yapmış mı kontrol et
  bool kullaniciGirisYapmisMi() {
    return _client.auth.currentUser != null;
  }

  // Çıkış yap
  Future<void> cikisYap() async {
    await _client.auth.signOut();
  }
}
