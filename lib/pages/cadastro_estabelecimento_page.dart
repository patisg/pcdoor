import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pcdoor/main.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';

class CadastroEstabelecimentoPage extends StatefulWidget {
  const CadastroEstabelecimentoPage({super.key});

  @override
  State<CadastroEstabelecimentoPage> createState() => _CadastroEstabelecimentoPageState();
}

class _CadastroEstabelecimentoPageState extends State<CadastroEstabelecimentoPage> {
  final formKey = GlobalKey<FormState>();
  final nomeController = TextEditingController();
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final enderecoController = TextEditingController();

  bool _obscureText = true;
  String? selectedTipo;
  List<String> tiposCarregados = [];

  @override
  void initState() {
    super.initState();
    _carregarTipos();
  }

  @override
  void dispose() {
    nomeController.dispose();
    emailController.dispose();
    senhaController.dispose();
    confirmarSenhaController.dispose();
    enderecoController.dispose();
    super.dispose();
  }

  Future<void> _carregarTipos() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('tipos').get();
      final lista = snapshot.docs.map((doc) => doc['nome'] as String).toList();
      setState(() => tiposCarregados = lista);
    } catch (e) {
      debugPrint('Erro ao carregar tipos: $e');
    }
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
    if (senhaController.text != confirmarSenhaController.text) {
      exibirAlerta('Erro ao cadastrar', 'A confirmação de senha não coincide com a senha', 'Fechar', () {});
      return;
    }
    try {
      await context.read<AuthService>().registrarEstabelecimento(
        nomeController.text,
        emailController.text,
        senhaController.text,
        enderecoController.text,
        selectedTipo!,
      );
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
              const Text('Conta tipo Estabelecimento', style: TextStyle(fontSize: 18, color: Colors.grey)),
              const SizedBox(height: 20),
              _buildField(controller: nomeController, label: 'Nome do Estabelecimento', validator: (v) => v!.isEmpty ? 'Informe o nome!' : null),
              _buildField(controller: enderecoController, label: 'Endereço', validator: (v) => v!.isEmpty ? 'Informe o endereço!' : null),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                child: Semantics(
                  label: 'Selecione o Tipo',
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Selecione o Tipo'),
                    value: selectedTipo,
                    onChanged: (value) => setState(() => selectedTipo = value),
                    items: tiposCarregados.map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo))).toList(),
                    validator: (v) => v == null ? 'Selecione um tipo' : null,
                  ),
                ),
              ),
              _buildField(controller: emailController, label: 'Email', keyboardType: TextInputType.emailAddress, validator: (v) => v!.isEmpty ? 'Informe o email!' : null),
              _buildSenhaField(controller: senhaController, label: 'Senha'),
              _buildSenhaField(controller: confirmarSenhaController, label: 'Confirme a Senha'),
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