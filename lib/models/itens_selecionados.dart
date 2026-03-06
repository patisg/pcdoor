class ItensSelecionados {
  final List<String> acessibilidadeMotora;
  final List<String> acessibilidadeVisual;
  final List<String> acessibilidadeAuditiva;

  ItensSelecionados({
    required this.acessibilidadeMotora,
    required this.acessibilidadeVisual,
    required this.acessibilidadeAuditiva,
  });

  bool get isEmpty =>
      acessibilidadeMotora.isEmpty &&
      acessibilidadeVisual.isEmpty &&
      acessibilidadeAuditiva.isEmpty;

  List<String> get todos => [
        ...acessibilidadeMotora,
        ...acessibilidadeVisual,
        ...acessibilidadeAuditiva,
      ];
}