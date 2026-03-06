import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MaisInfo extends StatefulWidget {
  final String? estabelecimentoId;

  const MaisInfo({super.key, this.estabelecimentoId});

  @override
  State<MaisInfo> createState() => _MaisInfoState();
}

class _MaisInfoState extends State<MaisInfo> {
  Map<String, double> _acessibilidadeMotora = {};
  Map<String, double> _acessibilidadeVisual = {};
  Map<String, double> _acessibilidadeAuditiva = {};
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarNotas();
  }

  Future<void> _carregarNotas() async {
    final id = widget.estabelecimentoId;
    if (id == null) return;

    final firestore = FirebaseFirestore.instance;

    final docEstab = await firestore.collection('estabelecimentos').doc(id).get();
    final notasMediasItens = Map<String, dynamic>.from(docEstab.data()?['notasMediasItens'] ?? {});

    if (notasMediasItens.isEmpty) {
      setState(() => _carregando = false);
      return;
    }

    final itensSnapshot = await firestore.collection('itensAcessibilidade').get();
    final categoriaMap = <String, String>{};
    for (final doc in itensSnapshot.docs) {
      final nome = doc.data()['nome'] as String?;
      final categoria = doc.data()['categoria'] as String?;
      if (nome != null && categoria != null) {
        categoriaMap[nome] = categoria;
      }
    }

    final motora = <String, double>{};
    final visual = <String, double>{};
    final auditiva = <String, double>{};

    notasMediasItens.forEach((item, nota) {
      final categoria = categoriaMap[item];
      final notaDouble = (nota as num).toDouble();
      if (categoria == 'acessibilidadeMotora') {
        motora[item] = notaDouble;
      } else if (categoria == 'acessibilidadeVisual') {
        visual[item] = notaDouble;
      } else if (categoria == 'acessibilidadeAuditiva') {
        auditiva[item] = notaDouble;
      }
    });

    setState(() {
      _acessibilidadeMotora = motora;
      _acessibilidadeVisual = visual;
      _acessibilidadeAuditiva = auditiva;
      _carregando = false;
    });
  }

  String _classificar(double nota) {
    if (nota >= 2.6) return 'Acessível';
    if (nota >= 1.6) return 'Parcialmente Acessível';
    if (nota >= 1.0) return 'Não Acessível';
    return 'Não Avaliado';
  }

  Widget _buildSection(String titulo, Map<String, double> itens) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Center(
          child: Text(titulo, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        ),
        const SizedBox(height: 10),
        itens.isEmpty
            ? const Text('Itens ainda não avaliados', style: TextStyle(fontSize: 16))
            : Column(
                children: itens.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Text('${e.key}: ${_classificar(e.value)}', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                )).toList(),
              ),
        const SizedBox(height: 10),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text('Acessibilidade dos itens', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSection('Itens de Acessibilidade Motora', _acessibilidadeMotora),
                    _buildSection('Itens de Acessibilidade Visual', _acessibilidadeVisual),
                    _buildSection('Itens de Acessibilidade Auditiva', _acessibilidadeAuditiva),
                  ],
                ),
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
