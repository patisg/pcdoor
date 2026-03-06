import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/estabelecimento.dart';
import 'estabelecimento_selecionado_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _firestore = FirebaseFirestore.instance;
  final _campoDePesquisaController = TextEditingController();

  List<Estabelecimento> _estabelecimentos = [];
  List<Estabelecimento> _resultadosBusca = [];
  List<String> _tiposCarregados = [];
  String? _selectedTipo;
  bool _exibirResultados = false;

  @override
  void initState() {
    super.initState();
    _listarEstabelecimentos();
    _carregarTipos();
  }

  @override
  void dispose() {
    _campoDePesquisaController.dispose();
    super.dispose();
  }

  Future<void> _carregarTipos() async {
    try {
      final snapshot = await _firestore.collection('tipos').get();
      setState(() {
        _tiposCarregados = snapshot.docs.map((doc) => doc['nome'] as String).toList();
      });
    } catch (e) {
      debugPrint('Erro ao carregar tipos: $e');
    }
  }

  Future<void> _listarEstabelecimentos() async {
    try {
      final snapshot = await _firestore.collection('estabelecimentos').get();
      setState(() {
        _estabelecimentos = snapshot.docs
            .map((doc) => Estabelecimento.fromMap(doc.id, doc.data()))
            .toList();
      });
    } catch (e) {
      debugPrint('Erro ao listar estabelecimentos: $e');
    }
  }

  void _buscar() {
    final termo = _campoDePesquisaController.text.toLowerCase();
    setState(() {
      if (termo.isNotEmpty) {
        _resultadosBusca = _estabelecimentos
            .where((e) => e.nome.toLowerCase().contains(termo))
            .toList();
        _exibirResultados = true;
      } else if (_selectedTipo != null) {
        _resultadosBusca = _estabelecimentos
            .where((e) => e.tipo == _selectedTipo)
            .toList();
        _exibirResultados = true;
      } else {
        _exibirResultados = false;
      }
    });
  }

  void _limparBusca() {
    setState(() {
      _exibirResultados = false;
      _selectedTipo = null;
      _campoDePesquisaController.clear();
    });
  }

  Widget _buildCard(Estabelecimento estabelecimento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Semantics(
        label: '${estabelecimento.nome}, ${estabelecimento.tipo}, Endereço ${estabelecimento.endereco}',
        child: ListTile(
          title: Text(estabelecimento.nome),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(estabelecimento.tipo, style: const TextStyle(fontSize: 16)),
              Text(estabelecimento.endereco, style: const TextStyle(fontSize: 16)),
            ],
          ),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EstabelecimentoSelecionado(estabelecimento: estabelecimento),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lista = _exibirResultados ? _resultadosBusca : _estabelecimentos;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.indigo,
        title: const Text(
          'Estabelecimentos Cadastrados',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(180),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                TextField(
                  controller: _campoDePesquisaController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nome...',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedTipo,
                    hint: const Text('Selecionar tipo'),
                    underline: const SizedBox(),
                    onChanged: (value) => setState(() => _selectedTipo = value),
                    items: _tiposCarregados
                        .map((tipo) => DropdownMenuItem(value: tipo, child: Text(tipo)))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _limparBusca,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[350], foregroundColor: Colors.black),
                        child: const Text('Listar Todos'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _buscar,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[350], foregroundColor: Colors.black),
                        child: const Text('Buscar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: Semantics(
        label: 'Lista de estabelecimentos',
        child: ListView.builder(
          itemCount: lista.length,
          itemBuilder: (_, index) => _buildCard(lista[index]),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.indigo,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Semantics(
              label: 'Botão de Home',
              child: IconButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/', (r) => false),
                icon: const Icon(Icons.home, size: 36, color: Colors.white),
              ),
            ),
            Semantics(
              label: 'Botão Perfil',
              child: IconButton(
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/perfilUsuario', (r) => false),
                icon: const Icon(Icons.person, size: 36, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}