import 'package:flutter_test/flutter_test.dart';
import 'package:validade_zero/controllers/lote_controller.dart';
import 'package:validade_zero/models/lote_perecivel.dart';

void main() {
  group('Testes Unitários - LoteController (Regras de Negócio PEPS)', () {
    test('Deve validar que data de vencimento não pode ser anterior à abertura', () {
      final controller = LoteController();
      final abertura = DateTime(2026, 11, 15);
      final vencimentoInvalido = DateTime(2026, 11, 14);
      final vencimentoValido = DateTime(2026, 11, 18);

      expect(controller.validarDatas(abertura, vencimentoInvalido), isFalse);
      expect(controller.validarDatas(abertura, vencimentoValido), isTrue);
    });

    test('Deve realizar apagamento lógico (Soft Delete) mantendo rastreabilidade', () {
      final controller = LoteController();
      final totalInicial = controller.lotesAtivos.length;
      final idPrimeiroLote = controller.lotesAtivos.first.id;

      controller.cancelarLotePorErro(idPrimeiroLote);

      expect(controller.lotesAtivos.length, equals(totalInicial - 1));
    });

    test('Deve adicionar novo lote perecível e ordenar por vencimento mais próximo (PEPS)', () {
      final controller = LoteController();
      final novoLote = LotePerecivel(
        id: '99',
        nomeProduto: 'Chantilly Fresco',
        codigoLote: 'LOTE-99Z',
        dataAbertura: DateTime.now(),
        dataVencimento: DateTime.now().subtract(const Duration(days: 1)),
        statusConsumo: 'ativo',
        uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
      );

      controller.adicionarLote(novoLote);

      expect(controller.lotesAtivos.first.id, equals('99'));
    });
  });
}