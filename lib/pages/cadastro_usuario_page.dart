import 'package:flutter/material.dart';
import 'package:pcdoor/main.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class CadastroUsuarioPage extends StatefulWidget {
  const CadastroUsuarioPage({super.key});

  @override
  State<CadastroUsuarioPage> createState() => _CadastroUsuarioPageState();
}

class _CadastroUsuarioPageState extends State<CadastroUsuarioPage> {
  final formKey = GlobalKey<FormState>();
  final nome = TextEditingController();
  final email = TextEditingController();
  final senha = TextEditingController();
  final confirmarSenha = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    senha.dispose();
    confirmarSenha.dispose();
    super.dispose();
  }

  void exibirAlerta(String titulo, String mensagem, String botaoTexto, VoidCallback acaoBotao) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(botaoTexto),
          ),
        ],
      ),
    ).then((_) => acaoBotao());
  }

  Future<void> registrar() async {
    if (senha.text != confirmarSenha.text) {
      exibirAlerta('Erro ao cadastrar', 'A confirmação de senha não coincide com a senha', 'Fechar', () {});
      return;
    }
    try {
      await context.read<AuthService>().registrarUsuario(nome.text, email.text, senha.text);
      if (!mounted) return;
      exibirAlerta('Cadastro realizado!', 'Realize o login para acessar sua conta.', 'Ir ao login', () {
        Navigator.pushNamed(context, '/login');
      });
    } on AuthException catch (e) {
      exibirAlerta('Erro ao cadastrar', e.message, 'Fechar', () {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 100),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              const Text('Crie sua conta', style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, letterSpacing: -1.5)),
              const SizedBox(height: 20),
              const Text('Conta tipo Usuário', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildField(controller: nome, label: 'Nome de Usuário', validator: (v) => v!.isEmpty ? 'Informe seu nome!' : null),
              _buildField(controller: email, label: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Informe seu email!' : null),
              _buildSenhaField(controller: senha, label: 'Senha'),
              _buildSenhaField(controller: confirmarSenha, label: 'Confirmação de Senha'),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ElevatedButton(
                  onPressed: () { if (formKey.currentState!.validate()) registrar(); },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(padding: EdgeInsets.all(16), child: Text('Cadastrar', style: TextStyle(fontSize: 20))),
                    ],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => navigatorKey.currentState?.pushNamedAndRemoveUntil('/', (r) => false),
                child: const Text('Voltar ao Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    required String? Function(String?) validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Semantics(
        label: label,
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(border: const OutlineInputBorder(), labelText: label),
          validator: validator,
        ),
      ),
    );
  }

  Widget _buildSenhaField({required TextEditingController controller, required String label}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
      child: Semantics(
        label: label,
        child: TextFormField(
          controller: controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            labelText: label,
            suffixIcon: IconButton(
              onPressed: () => setState(() => _obscureText = !_obscureText),
              icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
            ),
          ),
          validator: (v) => v!.isEmpty ? 'Informe a senha!' : null,
        ),
      ),
    );
  }
}