import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/avaliacao.dart';

class AvaliacaoService {
  final _firestore = FirebaseFirestore.instance;

  Future<bool> enviarAvaliacao(Avaliacao avaliacao) async {
    try {
      await _firestore.collection('avaliacoes').add(avaliacao.toMap());

      await _atualizarMedias(avaliacao.estabelecimentoId);

      return true;
    } catch (e) {

      return false;
    }
  }

  Future<String> buscarCategoriaItem(String nomeItem) async {
    try {
      final snapshot = await _firestore
          .collection('itensAcessibilidade')
          .where('nome', isEqualTo: nomeItem)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data()['categoria'] as String? ?? '';
      }
    } catch (e) {
      debugPrint('Erro ao buscar categoria: $e');
    }
    return '';
  }

  Future<void> _atualizarMedias(String estabelecimentoId) async {

    final snapshot = await _firestore
        .collection('avaliacoes')
        .where('estabelecimentoId', isEqualTo: estabelecimentoId)
        .get();

    if (snapshot.docs.isEmpty) return;

    final somasCategorias = <String, double>{
      'acessibilidadeMotora': 0,
      'acessibilidadeVisual': 0,
      'acessibilidadeAuditiva': 0,
    };
    final contagemCategorias = <String, int>{
      'acessibilidadeMotora': 0,
      'acessibilidadeVisual': 0,
      'acessibilidadeAuditiva': 0,
    };

    final somasItens = <String, double>{};
    final contagemItens = <String, int>{};

    for (final doc in snapshot.docs) {
      final notasItens = Map<String, dynamic>.from(doc.data()['notasItens'] ?? {});

      notasItens.forEach((categoria, itens) {
        if (itens is Map) {
          itens.forEach((item, nota) {
            final notaDouble = (nota as num).toDouble();

            // Acumula por categoria
            if (somasCategorias.containsKey(categoria)) {
              somasCategorias[categoria] = somasCategorias[categoria]! + notaDouble;
              contagemCategorias[categoria] = contagemCategorias[categoria]! + 1;
            }

            // Acumula por item
            somasItens[item] = (somasItens[item] ?? 0) + notaDouble;
            contagemItens[item] = (contagemItens[item] ?? 0) + 1;
          });
        }
      });
    }

    // Calcula médias por categoria
    final mediasCategorias = <String, double>{};
    somasCategorias.forEach((categoria, soma) {
      final contagem = contagemCategorias[categoria]!;
      if (contagem > 0) mediasCategorias[categoria] = soma / contagem;
    });

    // Calcula médias por item
    final mediasItens = <String, double>{};
    somasItens.forEach((item, soma) {
      mediasItens[item] = soma / contagemItens[item]!;
    });

    // Atualiza no Firestore
    await _firestore.collection('estabelecimentos').doc(estabelecimentoId).update({
      'notaMediasCategorias': mediasCategorias,
      'notasMediasItens': mediasItens,
    });
  }
}