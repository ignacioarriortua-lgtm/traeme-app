import 'package:flutter/material.dart';
import '../../models/pedido.dart';
import '../../models/cadete.dart';
import '../../services/mock_service.dart';
import '../../theme/app_theme.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _service = MockService();

  @override
  Widget build(BuildContext context) {
    final pendientesPago = _service.pedidos
        .where((p) => p.estado == EstadoPedido.pendientePago)
        .toList();

    final entregados = _service.pedidos
        .where((p) => p.estado == EstadoPedido.entregado)
        .toList();

    final double comisionesGanadas =
        entregados.fold(0, (sum, p) => sum + p.comisionApp);

    final cadete = _service.cadeteActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin • trae.me'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // RESUMEN DE CAJA DE LA APP
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Comisiones acumuladas (Viajes entregados)',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${comisionesGanadas.toStringAsFixed(0)}',
                  style: const TextStyle(
                    color: AppTheme.successColor,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Total de pedidos en el sistema: ${_service.pedidos.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          Text(
            'Transferencias por verificar (${pendientesPago.length})',
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          if (pendientesPago.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay transferencias pendientes de aprobación.',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
            ),
          ...pendientesPago.map((pedido) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Colors.orange.shade50,
              child: ListTile(
                title: Text(
                  '${pedido.id} • \$${pedido.totalCliente.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${pedido.tipo == TipoPedido.mandado ? "Mandado Libre" : pedido.comercioNombre}\n${pedido.detalle}',
                ),
                isThreeLine: true,
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      pedido.estado = pedido.tipo == TipoPedido.comercio
                          ? EstadoPedido.enPreparacion
                          : EstadoPedido.buscandoCadete;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        backgroundColor: AppTheme.successColor,
                        content: Text('¡Pago verificado! Pedido liberado.'),
                      ),
                    );
                  },
                  child: const Text('Aprobar Pago'),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          const Text(
            'Cadetes Registrados',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.sports_motorsports),
              ),
              title: Text(cadete.nombre,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'Patente: ${cadete.patenteMoto} • Saldo: \$${cadete.saldoComision.toStringAsFixed(0)}',
              ),
              trailing: Switch(
                value:
                    cadete.estadoValidacion == EstadoValidacionCadete.aprobado,
                activeColor: AppTheme.successColor,
                onChanged: (aprobado) {
                  setState(() {
                    cadete.estadoValidacion = aprobado
                        ? EstadoValidacionCadete.aprobado
                        : EstadoValidacionCadete.pendiente;
                    if (!aprobado) cadete.disponible = false;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}