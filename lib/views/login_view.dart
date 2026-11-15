import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../controllers/lote_controller.dart';
import '../models/lote_perecivel.dart';

class CadastroLoteView extends StatefulWidget {
  const CadastroLoteView({super.key});

  @override
  State<CadastroLoteView> createState() => _CadastroLoteViewState();
}

class _CadastroLoteViewState extends State<CadastroLoteView> {
  final _nomeController = TextEditingController();
  final _loteController = TextEditingController();
  DateTime _dataAbertura = DateTime.now();
  DateTime? _dataVencimento;
  String? _erroValidacao;

  final DateFormat _formatter = DateFormat('dd/MM/yyyy');

  Future<void> _selecionarData(BuildContext context, bool isAbertura) async {
    final selecionada = await showDatePicker(
      context: context,
      initialDate: isAbertura ? _dataAbertura : (_dataVencimento ?? DateTime.now()),
      firstDate: DateTime(2025),
      lastDate: DateTime(2030),
    );
    if (selecionada != null) {
      setState(() {
        if (isAbertura) {
          _dataAbertura = selecionada;
        } else {
          _dataVencimento = selecionada;
        }
      });
    }
  }

  void _salvarRegistro() {
    final controller = context.read<LoteController>();
    final nomeLimpo = controller.sanitizarTexto(_nomeController.text);
    final loteLimpo = controller.sanitizarTexto(_loteController.text);

    if (nomeLimpo.isEmpty || loteLimpo.isEmpty || _dataVencimento == null) {
      setState(() {
        _erroValidacao = 'Todos os campos são obrigatórios.';
      });
      return;
    }

    if (!controller.validarDatas(_dataAbertura, _dataVencimento!)) {
      setState(() {
        _erroValidacao = 'A data de vencimento não pode ser anterior à abertura.';
      });
      return;
    }

    final novoLote = LotePerecivel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeProduto: nomeLimpo,
      codigoLote: loteLimpo.toUpperCase(),
      dataAbertura: _dataAbertura,
      dataVencimento: _dataVencimento!,
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    );

    controller.adicionarLote(novoLote);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Novo Insumo'),
        backgroundColor: const Color(0xFF0A4D8C),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Nome do Insumo', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                hintText: 'Insira o nome do insumo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Lote', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            TextField(
              controller: _loteController,
              decoration: const InputDecoration(
                hintText: 'Insira o lote do insumo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Data de Abertura', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(_formatter.format(_dataAbertura)),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () => _selecionarData(context, true),
            ),
            const SizedBox(height: 16),
            const Text('Data de Vencimento', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today),
              label: Text(
                _dataVencimento == null
                    ? 'Selecione a data de vencimento'
                    : _formatter.format(_dataVencimento!),
              ),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                alignment: Alignment.centerLeft,
              ),
              onPressed: () => _selecionarData(context, false),
            ),
            if (_erroValidacao != null) ...[
              const SizedBox(height: 12),
              Text(
                _erroValidacao!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ],
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A4D8C),
                  foregroundColor: Colors.white,
                ),
                onPressed: _salvarRegistro,
                child: const Text('Salvar Registro', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}