import 'package:flutter/material.dart';
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
  final _quantidadeController = TextEditingController(text: '1');
  DateTime _dataAbertura = DateTime.now();
  DateTime? _dataVencimento;

  String _formatarData(DateTime data) {
    final dia = data.day.toString().padLeft(2, '0');
    final mes = data.month.toString().padLeft(2, '0');
    return '$dia/$mes/${data.year}';
  }

  Future<void> _selecionarData(bool isAbertura) async {
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

  void _salvar() {
    final controller = Provider.of<LoteController>(context, listen: false);
    final nomeLimpo = controller.sanitizarTexto(_nomeController.text);
    final loteLimpo = controller.sanitizarTexto(_loteController.text).toUpperCase();
    final qtd = int.tryParse(_quantidadeController.text.trim()) ?? 0;

    if (nomeLimpo.isEmpty || loteLimpo.isEmpty || _dataVencimento == null || qtd <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos obrigatórios corretamente.')),
      );
      return;
    }

    if (!controller.validarDatas(_dataAbertura, _dataVencimento!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A data de vencimento não pode ser anterior à abertura.'),
        ),
      );
      return;
    }

    final novo = LotePerecivel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nomeProduto: nomeLimpo,
      codigoLote: loteLimpo,
      quantidadeUnidades: qtd,
      dataAbertura: _dataAbertura,
      dataVencimento: _dataVencimento!,
      statusConsumo: 'ativo',
      uidBaristaRegistro: 'barista.cabral@thecoffee.com.br',
    );

    controller.adicionarLote(novo);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    const azulPrimario = Color(0xFF0A4D8C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: azulPrimario,
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 24),
            child: const Text(
              'Registrar Novo Insumo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: azulPrimario,
                            side: const BorderSide(color: azulPrimario, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back, size: 18),
                          label: const Text('Voltar', style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('Nome do Insumo', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _nomeController,
                        decoration: InputDecoration(
                          hintText: 'Insira o nome do insumo',
                          filled: true,
                          fillColor: const Color(0xFFF2F4F7),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: azulPrimario, width: 1.5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: azulPrimario, width: 2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Lote', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _loteController,
                                  decoration: InputDecoration(
                                    hintText: 'Ex: LOTE-12A',
                                    filled: true,
                                    fillColor: const Color(0xFFF2F4F7),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: azulPrimario, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: azulPrimario, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Unidades', style: TextStyle(fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                TextField(
                                  controller: _quantidadeController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    hintText: '1',
                                    filled: true,
                                    fillColor: const Color(0xFFF2F4F7),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: azulPrimario, width: 1.5),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: const BorderSide(color: azulPrimario, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text('Data de Abertura', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selecionarData(true),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            border: Border.all(color: azulPrimario, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: azulPrimario),
                              const SizedBox(width: 10),
                              Text(_formatarData(_dataAbertura)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Data de Vencimento', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      InkWell(
                        onTap: () => _selecionarData(false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F4F7),
                            border: Border.all(color: azulPrimario, width: 1.5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_month, color: azulPrimario),
                              const SizedBox(width: 10),
                              Text(
                                _dataVencimento == null
                                    ? 'Selecione a data de vencimento'
                                    : _formatarData(_dataVencimento!),
                                style: TextStyle(
                                  color: _dataVencimento == null ? Colors.black54 : Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Center(
                        child: SizedBox(
                          width: 210,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: azulPrimario,
                              foregroundColor: Colors.white,
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            onPressed: _salvar,
                            child: const Text('Salvar Registro', style: TextStyle(fontSize: 17)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}