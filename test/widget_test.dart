import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:validade_zero/controllers/lote_controller.dart';
import 'package:validade_zero/main.dart';
import 'package:validade_zero/models/lote_perecivel.dart';

void main() {
  group('1. Testes Unitários - Model e Controller (Regras de Negócio)', () {
    test('Deve serializar e desserializar LotePerecivel corretamente (toMap/fromMap)', () {
      final agora = DateTime(2026, 11, 15);
      final lote = LotePerecivel(
        id: '10',
        nomeProduto: 'Leite de Amêndoas',
        codigoLote: 'LOTE-10X',
        dataAbertura: agora,
        dataVencimento: agora.add(const Duration(days: 3)),
        statusConsumo: 'ativo',
        uidBaristaRegistro: 'barista@thecoffee.com.br',
      );

      final map = lote.toMap();
      expect(map['nome_produto'], 'Leite de Amêndoas');
      expect(map['codigo_lote'], 'LOTE-10X');
      expect(map['data_abertura'], isA<Timestamp>());

      final reconstruido = LotePerecivel.fromMap(map, '10');
      expect(reconstruido.id, '10');
      expect(reconstruido.nomeProduto, 'Leite de Amêndoas');
      expect(reconstruido.statusConsumo, 'ativo');
    });

    test('Deve sanitizar entradas removendo caracteres de risco OWASP', () {
      final controller = LoteController();
      final sujo = '  <script>Leite/"Integral";</script>  ';
      final limpo = controller.sanitizarTexto(sujo);

      expect(limpo, 'scriptLeiteIntegralscript');
    });

    test('Deve validar coerência entre data de abertura e vencimento', () {
      final controller = LoteController();
      final abertura = DateTime(2026, 11, 15);
      final vencimentoInvalido = DateTime(2026, 11, 14);
      final vencimentoValido = DateTime(2026, 11, 15);

      expect(controller.validarDatas(abertura, vencimentoInvalido), isFalse);
      expect(controller.validarDatas(abertura, vencimentoValido), isTrue);
    });

    test('Deve calcular dias restantes e ordenar lista pelo método PEPS', () {
      final controller = LoteController();
      final dias = controller.calcularDiasRestantes(
        DateTime.now().add(const Duration(days: 5)),
      );
      expect(dias, 5);

      final novoLote = LotePerecivel(
        id: '99',
        nomeProduto: 'Chantilly Fresco',
        codigoLote: 'LOTE-99Z',
        dataAbertura: DateTime.now().subtract(const Duration(days: 3)),
        dataVencimento: DateTime.now().subtract(const Duration(days: 1)),
        statusConsumo: 'ativo',
        uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
      );

      controller.adicionarLote(novoLote);
      expect(controller.lotesAtivos.first.id, '99');
    });
  });

  group('2. Testes de Integração - Fluxo de Interface e Estado (Provider)', () {
    testWidgets('Fluxo integrado: Login -> Dashboard -> Soft Delete -> Desfazer', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LoteController(),
          child: const ValidadeZeroApp(),
        ),
      );

      // 1. Verifica tela de Login e tenta entrar vazio (validação de erro)
      expect(find.text('Validade Zero'), findsOneWidget);
      await tester.tap(find.text('Entrar'));
      await tester.pump();
      expect(find.text('Preencha o e-mail institucional e a senha.'), findsOneWidget);

      // 2. Preenche credenciais e navega para o Dashboard
      await tester.enterText(find.byType(TextField).at(0), 'barista@thecoffee.com.br');
      await tester.enterText(find.byType(TextField).at(1), 'SenhaForte123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // 3. Verifica cards iniciais no Dashboard PEPS
      expect(find.text('Olá, Barista.'), findsOneWidget);
      expect(find.text('Leite de Aveia'), findsOneWidget);

      // 4. Executa Soft Delete e aguarda animação do Snackbar concluir
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      expect(find.text('Leite de Aveia'), findsNothing);
      expect(find.text('DESFAZER'), findsOneWidget);

      // 5. Restaura o lote via ação reversível do Snackbar
      await tester.tap(find.text('DESFAZER'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.text('Leite de Aveia'), findsOneWidget);
    });

    testWidgets('Fluxo integrado: Cadastro de Novo Insumo com validação e salvamento', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => LoteController(),
          child: const ValidadeZeroApp(),
        ),
      );

      // Faz login
      await tester.enterText(find.byType(TextField).at(0), 'barista@thecoffee.com.br');
      await tester.enterText(find.byType(TextField).at(1), 'SenhaForte123');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Abre tela de cadastro
      await tester.tap(find.text('Novo Insumo'));
      await tester.pumpAndSettle();
      expect(find.text('Registrar Novo Insumo'), findsOneWidget);

      // Preenche nome e lote
      await tester.enterText(find.byType(TextField).at(0), 'Xarope de Baunilha');
      await tester.enterText(find.byType(TextField).at(1), 'LOTE-88V');

      // Seleciona Data de Vencimento no DatePicker
      await tester.tap(find.text('Selecione a data de vencimento'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Salva registro e verifica no Dashboard
      await tester.tap(find.text('Salvar Registro'));
      await tester.pumpAndSettle();
      expect(find.text('Xarope de Baunilha'), findsOneWidget);
      expect(find.text('Lote: LOTE-88V'), findsOneWidget);
    });
  });
}