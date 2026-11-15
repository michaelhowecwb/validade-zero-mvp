import 'package:cloud_firestore/cloud_firestore.dart';

class LotePerecivel {
  final String id;
  final String nomeProduto;
  final String codigoLote;
  final DateTime dataAbertura;
  final DateTime dataVencimento;
  final String statusConsumo; // "ativo", "finalizado", "descartado_vencido", "cancelado_por_erro"
  final String uidBaristaRegistro;

  LotePerecivel({
    required this.id,
    required this.nomeProduto,
    required this.codigoLote,
    required this.dataAbertura,
    required this.dataVencimento,
    required this.statusConsumo,
    required this.uidBaristaRegistro,
  });

  factory LotePerecivel.fromMap(Map<String, dynamic> map, String documentId) {
    return LotePerecivel(
      id: documentId,
      nomeProduto: map['nome_produto'] ?? '',
      codigoLote: map['codigo_lote'] ?? '',
      dataAbertura: (map['data_abertura'] as Timestamp).toDate(),
      dataVencimento: (map['data_vencimento'] as Timestamp).toDate(),
      statusConsumo: map['status_consumo'] ?? 'ativo',
      uidBaristaRegistro: map['uid_barista_registro'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome_produto': nomeProduto,
      'codigo_lote': codigoLote,
      'data_abertura': Timestamp.fromDate(dataAbertura),
      'data_vencimento': Timestamp.fromDate(dataVencimento),
      'status_consumo': statusConsumo,
      'uid_barista_registro': uidBaristaRegistro,
    };
  }
}