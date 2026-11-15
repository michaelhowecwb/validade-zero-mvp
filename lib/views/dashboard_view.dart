import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/lote_controller.dart';
import '../models/lote_perecivel.dart';
import 'cadastro_lote_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LoteController>();
    final lotes = controller.lotesAtivos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Olá, Barista.'),
        backgroundColor: const Color(0xFF0A4D8C),
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF0A4D8C),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Novo Insumo', style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CadastroLoteView()),
                );
              },
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lotes.length,
        itemBuilder: (context, index) {
          final lote = lotes[index];
          final diasRestantes = controller.calcularDiasRestantes(lote.dataVencimento);
          return _buildLoteCard(context, controller, lote, diasRestantes);
        },
      ),
    );
  }

  Widget _buildLoteCard(
    BuildContext context,
    LoteController controller,
    LotePerecivel lote,
    int diasRestantes,
  ) {
    Color cardColor;
    Color textColor;
    IconData statusIcon;
    String statusText;

    if (diasRestantes <= 0) {
      cardColor = const Color(0xFFE5094D);
      textColor = Colors.white;
      statusIcon = Icons.warning_rounded;
      statusText = diasRestantes == 0
          ? 'Atenção, Vence Hoje!'
          : 'Vencido há ${diasRestantes.abs()} dia(s)!';
    } else if (diasRestantes <= 2) {
      cardColor = const Color(0xFFFFF168);
      textColor = Colors.black;
      statusIcon = Icons.hourglass_bottom_rounded;
      statusText = 'Vence em $diasRestantes dia(s)';
    } else {
      cardColor = const Color(0xFF5CF6B2);
      textColor = Colors.black;
      statusIcon = Icons.check_circle_rounded;
      statusText = 'Vence em $diasRestantes dias';
    }

    return Card(
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(statusIcon, size: 42, color: textColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lote.nomeProduto,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'Lote: ${lote.codigoLote}',
                    style: TextStyle(fontSize: 15, color: textColor),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              iconSize: 32,
              tooltip: 'Cancelar lote por erro de registro',
              icon: Icon(Icons.delete_outline, color: textColor),
              onPressed: () {
                controller.cancelarLotePorErro(lote.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}