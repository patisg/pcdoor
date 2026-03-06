import 'package:flutter/material.dart';
import 'package:pcdoor/main.dart';
import 'package:pcdoor/pages/estabelecimento_home_page.dart';
import 'package:pcdoor/pages/home_page.dart';
import 'package:pcdoor/pages/perfil_estabelecimento_page.dart';
import 'package:pcdoor/pages/perfil_usuario_page.dart';
import 'pages/cadastro_usuario_page.dart';
import 'pages/cadastro_estabelecimento_page.dart';
import 'pages/login_page.dart';
import 'pages/tipo_conta_page.dart';
import 'pages/comentario_page.dart';
import 'widgets/auth_check.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      routes: {
        '/': (context) => const AuthCheck(),
        '/homepage': (context) => const HomePage(),
        '/login': (context) => const LoginPage(),
        '/tipoConta': (context) => const TipoContaPage(),
        '/cadastroUsuario': (context) => const CadastroUsuarioPage(),
        '/cadastroEstabelecimento': (context) => const CadastroEstabelecimentoPage(),
        '/perfilUsuario': (context) => const PerfilUsuario(),
        '/comentario': (context) => const Comentario(),
        '/homepageEstabelecimento': (context) => const EstabelecimentoHomePage(),
        '/perfilEstabelecimento': (context) => const PerfilEstabelecimento(),
      },
    );
  }
}