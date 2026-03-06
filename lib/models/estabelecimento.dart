class Estabelecimento {
  final String id;
  final String nome;
  final String tipo;
  final String endereco;

  Estabelecimento({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.endereco,
  });

  factory Estabelecimento.fromMap(String id, Map<String, dynamic> map) {
    return Estabelecimento(
      id: id,
      nome: map['nome'] as String,
      tipo: map['tipo'] as String,
      endereco: map['endereco'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'tipo': tipo,
      'endereco': endereco,
    };
  }
}