import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/estabelecimento.dart';
import '../models/itens_selecionados.dart';
import 'avaliar_itens_page.dart';

class CheckAvaliacao extends StatefulWidget {
  const CheckAvaliacao({super.key, required this.estabelecimento});

  final Estabelecimento estabelecimento;

  @override
  State<CheckAvaliacao> createState() => _CheckAvaliacaoState();
}

class _CheckAvaliacaoState extends State<CheckAvaliacao> {
  List<String> _acessibilidadeMotora = [];
  List<String> _acessibilidadeVisual = [];
  List<String> _acessibilidadeAuditiva = [];

  List<bool> _checkedMotora = [];
  List<bool> _checkedVisual = [];
  List<bool> _checkedAuditiva = [];

  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarItens();
  }

  Future<void> _carregarItens() async {
    final snapshot = await FirebaseFirestore.instance.collection('itensAcessibilidade').get();

    for (final doc in snapshot.docs) {
      final categoria = doc.data()['categoria'] as String?;
      final nome = doc.data()['nome'] as String?;
      if (categoria == null || nome == null) continue;

      if (categoria == 'acessibilidadeMotora') {
        _acessibilidadeMotora.add(nome);
      } else if (categoria == 'acessibilidadeVisual') {
        _acessibilidadeVisual.add(nome);
      } else if (categoria == 'acessibilidadeAuditiva') {
        _acessibilidadeAuditiva.add(nome);
      }
    }

    setState(() {
      _checkedMotora = List.filled(_acessibilidadeMotora.length, false);
      _checkedVisual = List.filled(_acessibilidadeVisual.length, false);
      _checkedAuditiva = List.filled(_acessibilidadeAuditiva.length, false);
      _carregando = false;
    });
  }

  bool _foiSelecionado() {
    return _checkedMotora.any((v) => v) ||
        _checkedVisual.any((v) => v) ||
        _checkedAuditiva.any((v) => v);
  }

  void _avancar() {
    if (!_foiSelecionado()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Erro'),
          content: const Text('Selecione ao menos um item'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
      return;
    }

    final itensSelecionados = ItensSelecionados(
      acessibilidadeMotora: _acessibilidadeMotora
          .asMap()
          .entries
          .where((e) => _checkedMotora[e.key])
          .map((e) => e.value)
          .toList(),
      acessibilidadeVisual: _acessibilidadeVisual
          .asMap()
          .entries
          .where((e) => _checkedVisual[e.key])
          .map((e) => e.value)
          .toList(),
      acessibilidadeAuditiva: _acessibilidadeAuditiva
          .asMap()
          .entries
          .where((e) => _checkedAuditiva[e.key])
          .map((e) => e.value)
          .toList(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AvaliarItens(
          itensSelecionados: itensSelecionados,
          estabelecimento: widget.estabelecimento,
        ),
      ),
    );
  }

  Widget _buildChecklist(String titulo, List<String> itens, List<bool> checked) {
    if (itens.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: itens.length,
          itemBuilder: (_, index) => CheckboxListTile(
            title: Text(itens[index]),
            value: checked[index],
            onChanged: (value) => setState(() => checked[index] = value ?? false),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: const Text('Avaliação', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _carregando
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const SizedBox(height: 20),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Selecione os itens de acessibilidade que deseja avaliar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                _buildChecklist('Acessibilidade Motora', _acessibilidadeMotora, _checkedMotora),
                _buildChecklist('Acessibilidade Visual', _acessibilidadeVisual, _checkedVisual),
                _buildChecklist('Acessibilidade Auditiva', _acessibilidadeAuditiva, _checkedAuditiva),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _avancar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Avaliar Itens', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
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
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/perfilUsuario', (r) => false),
              icon: const Icon(Icons.person, size: 36, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}