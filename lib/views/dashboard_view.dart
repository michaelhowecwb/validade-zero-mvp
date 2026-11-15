import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/lote_controller.dart';
import '../models/lote_perecivel.dart';
import 'cadastro_lote_view.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<LoteController>(context);
    final lotes = controller.lotesAtivos;
    const azulPrimario = Color(0xFF0A4D8C);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: azulPrimario,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroLoteView()),
                  );
                },
                icon: const Icon(Icons.add, size: 20),
                label: const Text(
                  'Novo Insumo',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Olá, Barista.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: azulPrimario,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: ListView.separated(
                          itemCount: lotes.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final lote = lotes[index];
                            final dias = controller.calcularDiasRestantes(lote.dataVencimento);
                            return _buildCardLote(context, controller, lote, dias);
                          },
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

  Widget _buildCardLote(
    BuildContext context,
    LoteController controller,
    LotePerecivel lote,
    int dias,
  ) {
    Color corFundo;
    Color corTexto;
    IconData icone;
    String statusTexto;

    if (dias <= 0) {
      corFundo = const Color(0xFFFF004D);
      corTexto = Colors.white;
      icone = Icons.warning_rounded;
      statusTexto = 'Atenção, Vence Hoje!';
    } else if (dias <= 3) {
      corFundo = const Color(0xFFFFF566);
      corTexto = Colors.black;
      icone = Icons.hourglass_bottom_rounded;
      statusTexto = 'Vence em $dias dia(s)';
    } else {
      corFundo = const Color(0xFF66FFB2);
      corTexto = Colors.black;
      icone = Icons.check_circle_rounded;
      statusTexto = 'Vence em $dias dias';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: corFundo,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icone, size: 38, color: corTexto),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lote.nomeProduto,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: corTexto,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Lote: ${lote.codigoLote}',
                  style: TextStyle(fontSize: 14, color: corTexto),
                ),
                const SizedBox(height: 2),
                Text(
                  statusTexto,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: corTexto,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Registrar consumo ou descarte',
            icon: Icon(Icons.delete_outline, color: corTexto, size: 28),
            onPressed: () {
              controller.marcarLoteComoConsumido(lote.id);
              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Baixa registrada para "${lote.nomeProduto}".'),
                  action: SnackBarAction(
                    label: 'DESFAZER',
                    onPressed: () {
                      controller.restaurarLoteCancelado(lote.id);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}