import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/avaliacao.dart';
import '../models/estabelecimento.dart';
import 'check_avaliacao_page.dart';
import 'mais_info_page.dart';

class EstabelecimentoSelecionado extends StatefulWidget {
  const EstabelecimentoSelecionado({super.key, required this.estabelecimento});

  final Estabelecimento estabelecimento;

  @override
  State<EstabelecimentoSelecionado> createState() => _EstabelecimentoSelecionadoState();
}

class _EstabelecimentoSelecionadoState extends State<EstabelecimentoSelecionado> {
  final _firestore = FirebaseFirestore.instance;

  double _notaMotora = 0;
  double _notaVisual = 0;
  double _notaAuditiva = 0;

  List<Map<String, String>> _comentarios = [];
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    final id = widget.estabelecimento.id;

    final docEstab = await _firestore.collection('estabelecimentos').doc(id).get();
    if (docEstab.exists) {
      final notas = Map<String, dynamic>.from(docEstab.data()?['notaMediasCategorias'] ?? {});
      _notaMotora = (notas['acessibilidadeMotora'] as num?)?.toDouble() ?? 0;
      _notaVisual = (notas['acessibilidadeVisual'] as num?)?.toDouble() ?? 0;
      _notaAuditiva = (notas['acessibilidadeAuditiva'] as num?)?.toDouble() ?? 0;
    }

    final avaliacoesSnapshot = await _firestore
        .collection('avaliacoes')
        .where('estabelecimentoId', isEqualTo: id)
        .get();

    final comentarios = <Map<String, String>>[];
    for (final doc in avaliacoesSnapshot.docs) {
      final avaliacao = Avaliacao.fromMap(doc.id, doc.data());
      if (avaliacao.comentario != null && avaliacao.comentario!.isNotEmpty) {
        final nome = await _buscarNomeUsuario(avaliacao.usuarioId);
        comentarios.add({'usuario': nome, 'comentario': avaliacao.comentario!});
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
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text('Detalhes do Estabelecimento', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
        ),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.estabelecimento.nome, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Tipo: ${widget.estabelecimento.tipo}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Endereço: ${widget.estabelecimento.endereco}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 32),
                  const Center(child: Text('Acessibilidade', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 16),
                  Text('Acessibilidade Motora: ${_classificar(_notaMotora)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Acessibilidade Visual: ${_classificar(_notaVisual)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  Text('Acessibilidade Auditiva: ${_classificar(_notaAuditiva)}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => MaisInfo(estabelecimentoId: widget.estabelecimento.id)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Mais detalhes'),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => CheckAvaliacao(estabelecimento: widget.estabelecimento)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Avaliar'),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Center(child: Text('Comentários', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 12),
                  _comentarios.isEmpty
                      ? const Center(child: Text('Nenhum comentário ainda.'))
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _comentarios.length,
                          separatorBuilder: (_, __) => const Divider(),
                          itemBuilder: (_, index) => ListTile(
                            leading: const Icon(Icons.account_circle, size: 50),
                            title: Text(_comentarios[index]['usuario']!),
                            subtitle: Text(_comentarios[index]['comentario']!),
                          ),
                        ),
                ],
              ),
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
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/perfilUsuario', (r) => false),
              icon: const Icon(Icons.person, size: 36, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}