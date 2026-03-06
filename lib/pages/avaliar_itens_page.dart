import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/avaliacao.dart';
import '../models/estabelecimento.dart';
import '../models/itens_selecionados.dart';
import '../services/avaliacao_service.dart';
import 'estabelecimento_selecionado_page.dart';

class AvaliarItens extends StatefulWidget {
  const AvaliarItens({
    super.key,
    required this.itensSelecionados,
    required this.estabelecimento,
  });

  final ItensSelecionados itensSelecionados;
  final Estabelecimento estabelecimento;

  @override
  State<AvaliarItens> createState() => _AvaliarItensState();
}

class _AvaliarItensState extends State<AvaliarItens> {
  final Map<String, int> _qualidadeDosItens = {};

  bool _todosAvaliados() {
    final total = widget.itensSelecionados.todos.length;
    final avaliados = _qualidadeDosItens.values.where((v) => v != 0).length;
    return avaliados == total;
  }

  void _confirmar() {
    if (!_todosAvaliados()) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Avaliar Itens'),
          content: const Text('Avalie todos os itens antes de continuar.'),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Adicionar Comentário'),
        content: const Text('Deseja adicionar um comentário à sua avaliação?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _enviarAvaliacao(null);
            },
            child: const Text('Sem comentário'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final comentario = await Navigator.pushNamed(context, '/comentario');
              _enviarAvaliacao(comentario as String?);
            },
            child: const Text('Sim'),
          ),
        ],
      ),
    );
  }

  Future<void> _enviarAvaliacao(String? comentario) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final itensComCategoria = <String, Map<String, int>>{};
    for (final entry in _qualidadeDosItens.entries) {
      final categoria = await AvaliacaoService().buscarCategoriaItem(entry.key);
      if (categoria.isEmpty) continue;
      itensComCategoria.putIfAbsent(categoria, () => {})[entry.key] = entry.value;
    }

    final avaliacao = Avaliacao(
      id: '',
      usuarioId: uid,
      estabelecimentoId: widget.estabelecimento.id,
      notasItens: itensComCategoria,
      dataAvaliacao: DateTime.now(),
      comentario: comentario,
    );

    final sucesso = await AvaliacaoService().enviarAvaliacao(avaliacao);
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(sucesso ? 'Avaliação Realizada' : 'Erro'),
        content: Text(sucesso ? 'Sua avaliação foi enviada com sucesso!' : 'Não foi possível enviar a avaliação.'),
        actions: [
          TextButton(
            onPressed: () {
              if (sucesso) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => EstabelecimentoSelecionado(estabelecimento: widget.estabelecimento)),
                  (_) => false,
                );
              } else {
                Navigator.pop(context);
              }
            },
            child: Text(sucesso ? 'Ver estabelecimento' : 'Ok'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosItens = widget.itensSelecionados.todos;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        centerTitle: true,
        title: Text('Avaliando: ${widget.estabelecimento.nome}', style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Avalie a qualidade dos itens selecionados',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todosItens.length + 1,
              itemBuilder: (_, index) {
                if (index == todosItens.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _confirmar,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Continuar Avaliação', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  );
                }

                final item = todosItens[index];
                final quality = _qualidadeDosItens[item] ?? 0;

                return Column(
                  children: [
                    Center(
                      child: Text(item, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _botaoNota(item, 1, 'Ruim', quality),
                        const SizedBox(width: 12),
                        _botaoNota(item, 2, 'Regular', quality),
                        const SizedBox(width: 12),
                        _botaoNota(item, 3, 'Bom', quality),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
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
              onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/perfilUsuario', (r) => false),
              icon: const Icon(Icons.person, size: 36, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _botaoNota(String item, int nota, String label, int qualidadeAtual) {
    final selecionado = qualidadeAtual == nota;
    return ElevatedButton(
      onPressed: () => setState(() => _qualidadeDosItens[item] = nota),
      style: ElevatedButton.styleFrom(
        backgroundColor: selecionado ? Colors.indigo : Colors.grey[300],
        foregroundColor: selecionado ? Colors.white : Colors.black,
      ),
      child: SizedBox(width: 70, child: Center(child: Text(label))),
    );
  }
}