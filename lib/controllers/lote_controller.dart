import 'package:flutter/material.dart';
import '../models/lote_perecivel.dart';

class LoteController extends ChangeNotifier {
  final List<LotePerecivel> _lotesAtivos = [
    LotePerecivel(
      id: '1',
      nomeProduto: 'Leite de Aveia',
      codigoLote: 'LOTE-01A',
      quantidadeUnidades: 2,
      dataAbertura: DateTime.now().subtract(const Duration(days: 4)),
      dataVencimento: DateTime.now(),
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    ),
    LotePerecivel(
      id: '2',
      nomeProduto: 'Grão Signature',
      codigoLote: 'LOTE-04B',
      quantidadeUnidades: 3,
      dataAbertura: DateTime.now().subtract(const Duration(days: 5)),
      dataVencimento: DateTime.now().add(const Duration(days: 2)),
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    ),
    LotePerecivel(
      id: '3',
      nomeProduto: 'Leite Integral',
      codigoLote: 'LOTE-09C',
      quantidadeUnidades: 5,
      dataAbertura: DateTime.now(),
      dataVencimento: DateTime.now().add(const Duration(days: 7)),
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    ),
  ];

  bool _apenasCriticos = false;
  bool get apenasCriticos => _apenasCriticos;

  void alternarFiltroCriticos(bool valor) {
    _apenasCriticos = valor;
    notifyListeners();
  }

  List<LotePerecivel> get lotesAtivos {
    final ativos = _lotesAtivos.where((lote) {
      if (lote.statusConsumo != 'ativo') return false;
      if (_apenasCriticos) {
        return calcularDiasRestantes(lote.dataVencimento) <= 0;
      }
      return true;
    }).toList();
    ativos.sort((a, b) => a.dataVencimento.compareTo(b.dataVencimento));
    return ativos;
  }

  String sanitizarTexto(String entrada) {
    return entrada.trim().replaceAll(RegExp(r'[<>"/;]'), '');
  }

  int calcularDiasRestantes(DateTime dataVencimento) {
    final hoje = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final vencimento = DateTime(
      dataVencimento.year,
      dataVencimento.month,
      dataVencimento.day,
    );
    return vencimento.difference(hoje).inDays;
  }

  bool validarDatas(DateTime abertura, DateTime vencimento) {
    final dataAberturaLimpa = DateTime(abertura.year, abertura.month, abertura.day);
    final dataVencimentoLimpa = DateTime(vencimento.year, vencimento.month, vencimento.day);
    return !dataVencimentoLimpa.isBefore(dataAberturaLimpa);
  }

  void adicionarLote(LotePerecivel novoLote) {
    _lotesAtivos.add(novoLote);
    notifyListeners();
  }

  void cancelarLotePorErro(String id) {
    _alterarStatusLote(id, 'cancelado');
  }

  void restaurarLoteCancelado(String id) {
    _alterarStatusLote(id, 'ativo');
  }

  void _alterarStatusLote(String id, String novoStatus) {
    final index = _lotesAtivos.indexWhere((item) => item.id == id);
    if (index != -1) {
      final atual = _lotesAtivos[index];
      _lotesAtivos[index] = LotePerecivel(
        id: atual.id,
        nomeProduto: atual.nomeProduto,
        codigoLote: atual.codigoLote,
        quantidadeUnidades: atual.quantidadeUnidades,
        dataAbertura: atual.dataAbertura,
        dataVencimento: atual.dataVencimento,
        statusConsumo: novoStatus,
        uidBaristaRegistro: atual.uidBaristaRegistro,
      );
      notifyListeners();
    }
  }
}