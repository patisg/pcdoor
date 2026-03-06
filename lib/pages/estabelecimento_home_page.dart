import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/avaliacao.dart';
import '../services/auth_service.dart';
import 'mais_info_page.dart';

class EstabelecimentoHomePage extends StatefulWidget {
  const EstabelecimentoHomePage({super.key});

  @override
  State<EstabelecimentoHomePage> createState() => _EstabelecimentoHomePageState();
}

class _EstabelecimentoHomePageState extends State<EstabelecimentoHomePage> {
  final _firestore = FirebaseFirestore.instance;

  double _notaMotora = 0;
  double _notaVisual = 0;
  double _notaAuditiva = 0;

  List<Map<String, String>> _comentarios = [];
  String? _estabelecimentoId;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    _estabelecimentoId = uid;

    final docEstab = await _firestore.collection('estabelecimentos').doc(uid).get();
    if (!mounted) return;
    if (docEstab.exists) {
      final notas = Map<String, dynamic>.from(docEstab.data()?['notaMediasCategorias'] ?? {});
      _notaMotora = (notas['acessibilidadeMotora'] as num?)?.toDouble() ?? 0;
      _notaVisual = (notas['acessibilidadeVisual'] as num?)?.toDouble() ?? 0;
      _notaAuditiva = (notas['acessibilidadeAuditiva'] as num?)?.toDouble() ?? 0;
    }

    final avaliacoesSnapshot = await _firestore
        .collection('avaliacoes')
        .where('estabelecimentoId', isEqualTo: uid)
        .get();

    if (!mounted) return;

    final comentarios = <Map<String, String>>[];
    for (final doc in avaliacoesSnapshot.docs) {
      final avaliacao = Avaliacao.fromMap(doc.id, doc.data());
      if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty) {
        final nomeUsuario = await _buscarNomeUsuario(avaliacao.usuarioId);
        if (!mounted) return;
        comentarios.add({'usuario': nomeUsuario, 'comentario': avaliacao.comentario!});
      }
    }

    setState(() {
      _comentarios = comentarios;
      _carregando = false;
    });
  }

  Future<String> _buscarNomeUsuario(String uid) async {
    try {
      final doc = await _firestore.collection('usuarios').doc(uid).get();
      return doc.data()?['nome'] as String? ?? 'Usuário';
    } catch (_) {
      return 'Usuário';
    }
  }

  String _classificar(double nota) {
    if (nota >= 2.6) return 'Acessível';
    if (nota >= 1.6) return 'Parcialmente Acessível';
    if (nota >= 1.0) return 'Não Acessível';
    return 'Não Avaliado';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text('Meu Estabelecimento', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () async {
              await context.read<AuthService>().logout();
            },
            child: const Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    'Suas avaliações de acessibilidade',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Acessibilidade Motora: ${_classificar(_notaMotora)}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Text('Acessibilidade Visual: ${_classificar(_notaVisual)}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 12),
                      Text('Acessibilidade Auditiva: ${_classificar(_notaAuditiva)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => MaisInfo(estabelecimentoId: _estabelecimentoId),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Mais detalhes', style: TextStyle(fontSize: 15)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text('Comentários', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: _comentarios.isEmpty
                      ? const Center(child: Text('Nenhum comentário encontrado'))
                      : ListView.separated(
                          itemCount: _comentarios.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (_, index) => ListTile(
                            leading: const Icon(Icons.account_circle, size: 60),
                            title: Text(_comentarios[index]['usuario']!),
                            subtitle: Text(_comentarios[index]['comentario']!),
                          ),
                        ),
                ),
              ],
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
              icon: const Icon(Icons.home, size: 36, color: Colors.white),
            ),
            IconButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/perfilEstabelecimento', (r) => false),
              icon: const Icon(Icons.person, size: 36, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}