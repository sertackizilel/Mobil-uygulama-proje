import 'package:flutter/material.dart';

// Bu dosya kullanıcı giriş/kayıt ekranını içerir.
import 'package:supabase_flutter/supabase_flutter.dart';

// AuthPage: Kullanıcı giriş ve kayıt ekranı.
class AuthPage extends StatefulWidget {
  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> signIn() async {
    setState(() => isLoading = true);
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() => isLoading = false);
    if (response.user != null) {
      Navigator.pushReplacementNamed(context, '/');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Giriş başarısız!')),
      );
    }
  }

  Future<void> signUp() async {
    setState(() => isLoading = true);
    final response = await Supabase.instance.client.auth.signUp(
      email: _emailController.text,
      password: _passwordController.text,
    );
    setState(() => isLoading = false);
    if (response.user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarılı! Lütfen giriş yapın.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt başarısız!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Giriş / Kayıt')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: 'Şifre'), obscureText: true),
            SizedBox(height: 16),
            if (isLoading) CircularProgressIndicator(),
            if (!isLoading) ...[
              ElevatedButton(onPressed: signIn, child: Text('Giriş Yap')),
              ElevatedButton(onPressed: signUp, child: Text('Kayıt Ol')),
            ]
          ],
        ),
      ),
    );
  }
}
