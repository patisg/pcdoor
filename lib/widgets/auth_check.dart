import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../pages/estabelecimento_home_page.dart';
import '../pages/home_page.dart';
import '../pages/login_page.dart';
import '../services/auth_service.dart';

class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  bool? _isEstabelecimento;
  String? _ultimoUid;

  Future<void> _checarTipo(AuthService auth) async {
    final uid = auth.usuario!.uid;
    final resultado = await auth.verificaTipo();
    if (mounted) {
      setState(() {
        _isEstabelecimento = resultado;
        _ultimoUid = uid;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();

    if (auth.isLoading) {
      return _loading();
    }

    if (auth.usuario == null) {
      _isEstabelecimento = null;
      _ultimoUid = null;
      return const LoginPage();
    }

    if (_ultimoUid != auth.usuario!.uid) {
      _isEstabelecimento = null;
      _checarTipo(auth);
    }

    if (_isEstabelecimento == null) {
      return _loading();
    }

    return _isEstabelecimento! ? const EstabelecimentoHomePage() : const HomePage();
  }

  Widget _loading() {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}