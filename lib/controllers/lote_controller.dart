import 'package:flutter/material.dart';
import '../models/lote_perecivel.dart';

class LoteController extends ChangeNotifier {
  final List<LotePerecivel> _lotesAtivos = [
    LotePerecivel(
      id: '1',
      nomeProduto: 'Leite de Aveia',
      codigoLote: 'LOTE-01A',
      dataAbertura: DateTime.now().subtract(const Duration(days: 2)),
      dataVencimento: DateTime.now(),
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    ),
    LotePerecivel(
      id: '2',
      nomeProduto: 'Grão Signature',
      codigoLote: 'LOTE-04B',
      dataAbertura: DateTime.now().subtract(const Duration(days: 1)),
      dataVencimento: DateTime.now().add(const Duration(days: 2)),
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    ),
    LotePerecivel(
      id: '3',
      nomeProduto: 'Leite Integral',
      codigoLote: 'LOTE-09C',
      dataAbertura: DateTime.now(),
      dataVencimento: DateTime.now().add(const Duration(days: 7)),
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    ),
  ];

  List<LotePerecivel> get lotesAtivos {
    final ativos = _lotesAtivos
        .where((lote) => lote.statusConsumo == 'ativo')
        .toList();
    ativos.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
    return ativos;
  }

  int calcularDiasRestantes(DateTime dataVencimento) {
    final hoje = DateTime.now();
    final dataAtualSemHora = DateTime(hoje.year, hoje.month, hoje.day);
    final vencimentoSemHora = DateTime(
      dataVencimento.year,
      dataVencimento.month,
      dataVencimento.day,
    );
    return vencimentoSemHora.difference(dataAtualSemHora).inDays;
  }

  bool validarDatas(DateTime abertura, DateTime vencimento) {
    final aberturaSemHora = DateTime(abertura.year, abertura.month, abertura.day);
    final vencimentoSemHora = DateTime(vencimento.year, vencimento.month, vencimento.day);
    return !vencimentoSemHora.isBefore(aberturaSemHora);
  }

  void adicionarLote(LotePerecivel novoLote) {
    _lotesAtivos.add(novoLote);
    notifyListeners();
  }

  void cancelarLotePorErro(String id) {
    final index = _lotesAtivos.indexWhere((lote) => lote.id == id);
    if (index != -1) {
      final loteAntigo = _lotesAtivos[index];
      _lotesAtivos[index] = LotePerecivel(
        id: loteAntigo.id,
        nomeProduto: loteAntigo.nomeProduto,
        codigoLote: loteAntigo.codigoLote,
        dataAbertura: loteAntigo.dataAbertura,
        dataVencimento: loteAntigo.dataVencimento,
        statusConsumo: 'cancelado_por_erro',
        uidBaristaRegistro: loteAntigo.uidBaristaRegistro,
      );
      notifyListeners();
    }
  }
}