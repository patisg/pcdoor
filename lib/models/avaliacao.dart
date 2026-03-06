class Avaliacao {
  final String id;
  final String usuarioId;
  final String estabelecimentoId;
  final Map<String, Map<String, int>> notasItens;
  final DateTime dataAvaliacao;
  final String? comentario;

  Avaliacao({
    required this.id,
    required this.usuarioId,
    required this.estabelecimentoId,
    required this.notasItens,
    required this.dataAvaliacao,
    this.comentario,
  });

  factory Avaliacao.fromMap(String id, Map<String, dynamic> map) {
    final notasItensMap = <String, Map<String, int>>{};

    if (map['notasItens'] is Map) {
      (map['notasItens'] as Map).forEach((categoria, itens) {
        if (itens is Map) {
          notasItensMap[categoria as String] = itens.map(
            (k, v) => MapEntry(k as String, (v as num).toInt()),
          );
        }
      });
    }

    return Avaliacao(
      id: id,
      usuarioId: map['usuarioId'] as String,
      estabelecimentoId: map['estabelecimentoId'] as String,
      notasItens: notasItensMap,
      dataAvaliacao: DateTime.parse(map['dataAvaliacao']).toLocal(),
      comentario: map['comentario'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'estabelecimentoId': estabelecimentoId,
      'notasItens': notasItens,
      'dataAvaliacao': dataAvaliacao.toUtc().toIso8601String(),
      'comentario': comentario,
    };
  }
}