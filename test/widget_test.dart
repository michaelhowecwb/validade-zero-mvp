import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:validade_zero/controllers/lote_controller.dart';
import 'package:validade_zero/models/lote_perecivel.dart';
import 'package:validade_zero/views/login_view.dart';

void main() {
  group('Testes Unitários - LoteController (Regras PEPS, Validação e Filtros)', () {
    test('Deve sanitizar caracteres perigosos de entrada (Prevenção OWASP)', () {
      final controller = LoteController();
      const entradaMaliciosa = '  <script>Leite/Integral";</script>  ';
      final resultado = controller.sanitizarTexto(entradaMaliciosa);
      expect(resultado, 'scriptLeiteIntegralscript');
    });

    test('Deve validar corretamente datas de vencimento e abertura', () {
      final controller = LoteController();
      final hoje = DateTime(2026, 11, 15);
      final amanha = DateTime(2026, 11, 16);
      final ontem = DateTime(2026, 11, 14);

      expect(controller.validarDatas(hoje, amanha), isTrue);
      expect(controller.validarDatas(hoje, hoje), isTrue);
      expect(controller.validarDatas(hoje, ontem), isFalse);
    });

    test('Deve ordenar os lotes ativos pela regra PEPS e filtrar críticos', () {
      final controller = LoteController();
      final lotes = controller.lotesAtivos;

      expect(lotes.length, 3);
      expect(lotes.first.nomeProduto, 'Leite de Aveia');
      expect(lotes.last.nomeProduto, 'Leite Integral');

      controller.alternarFiltroCriticos(true);
      expect(controller.lotesAtivos.length, 1);
      expect(controller.lotesAtivos.first.nomeProduto, 'Leite de Aveia');
    });

    test('Deve realizar soft delete e restaurar lote cancelado', () {
      final controller = LoteController();
      final totalInicial = controller.lotesAtivos.length;

      controller.cancelarLotePorErro('1');
      expect(controller.lotesAtivos.length, totalInicial - 1);

      controller.restaurarLoteCancelado('1');
      expect(controller.lotesAtivos.length, totalInicial);
    });

    test('Deve serializar e desserializar LotePerecivel com quantidadeUnidades', () {
      final lote = LotePerecivel(
        id: '99',
        nomeProduto: 'Xarope de Baunilha',
        codigoLote: 'LOTE-99Z',
        quantidadeUnidades: 4,
        dataAbertura: DateTime(2026, 11, 15),
        dataVencimento: DateTime(2026, 11, 20),
        statusConsumo: 'ativo',
        uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
      );

      final mapa = lote.toMap();
      final reconstruido = LotePerecivel.fromMap(mapa, '99');

      expect(reconstruido.nomeProduto, 'Xarope de Baunilha');
      expect(reconstruido.quantidadeUnidades, 4);
    });
  });

  testWidgets('Teste de Integração - Fluxo de Login, Filtro e Cadastro de Insumo', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LoteController(),
        child: const MaterialApp(
          home: LoginView(),
        ),
      ),
    );

    expect(find.text('Validade Zero'), findsOneWidget);

    await tester.enterText(find.byType(TextField).at(0), 'barista.cabral@thecoffee.com.br');
    await tester.enterText(find.byType(TextField).at(1), 'Senha123');
    await tester.tap(find.text('Entrar'));
    await tester.pumpAndSettle();

    expect(find.text('Olá, Barista.'), findsOneWidget);
    expect(find.text('Leite de Aveia'), findsOneWidget);

    await tester.tap(find.text('Vence Hoje (Críticos)'));
    await tester.pumpAndSettle();
    expect(find.text('Leite Integral'), findsNothing);
  });
}