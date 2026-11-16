import 'package:flutter/material.dart';
import '../../models/pedido.dart';
import '../../models/cadete.dart';
import '../../services/mock_service.dart';
import '../../theme/app_theme.dart';

class CadeteHomeScreen extends StatefulWidget {
  const CadeteHomeScreen({super.key});

  @override
  State<CadeteHomeScreen> createState() => _CadeteHomeScreenState();
}

class _CadeteHomeScreenState extends State<CadeteHomeScreen> {
  final _service = MockService();
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final cadete = _service.cadeteActual;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Cadete • trae.me'),
        actions: [
          Row(
            children: [
              Text(
                cadete.disponible ? 'EN LÍNEA' : 'OFF',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: cadete.disponible ? AppTheme.successColor : Colors.grey,
                ),
              ),
              Switch(
                value: cadete.disponible,
                activeColor: AppTheme.successColor,
                onChanged: (val) {
                  if (cadete.estadoValidacion != EstadoValidacionCadete.aprobado) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tus documentos aún deben ser aprobados por Admin'),
                      ),
                    );
                    return;
                  }
                  setState(() => cadete.disponible = val);
                },
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildRadarTab(cadete),
          _buildBilleteraTab(cadete),
          _buildPapelesTab(cadete),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.two_wheeler_outlined),
            selectedIcon: Icon(Icons.two_wheeler),
            label: 'Viajes',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet),
            label: 'Billetera',
          ),
          NavigationDestination(
            icon: Icon(Icons.badge_outlined),
            selectedIcon: Icon(Icons.badge),
            label: 'Mis Papeles',
          ),
        ],
      ),
    );
  }

  // PESTAÑA 1: RADAR DE VIAJES Y VIAJE EN CURSO
  Widget _buildRadarTab(Cadete cadete) {
    final pedidosDisponibles = _service.pedidos
        .where((p) =>
            p.estado == EstadoPedido.buscandoCadete ||
            p.estado == EstadoPedido.enPreparacion ||
            p.estado == EstadoPedido.enCamino)
        .toList();

    if (!cadete.disponible) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.power_settings_new, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Estás desconectado',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Activá el interruptor de arriba a la derecha para empezar a recibir mandados y pedidos.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (cadete.bloqueadoPorDeuda)
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Alcanzaste el tope de efectivo. Solo verás pedidos pagos por transferencia hasta rendir comisión.',
                    style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        Text(
          'Pedidos activos (${pedidosDisponibles.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (pedidosDisponibles.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'No hay viajes pendientes en este momento.\nProbá crear uno desde el perfil Vecino.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ...pedidosDisponibles.map((pedido) {
          // Si está bloqueado por deuda de efectivo, ocultamos viajes en efectivo
          if (cadete.bloqueadoPorDeuda && pedido.metodoPago == MetodoPago.efectivo) {
            return const SizedBox.shrink();
          }

          final bool enCamino = pedido.estado == EstadoPedido.enCamino;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: enCamino ? AppTheme.primaryColor : Colors.grey.shade200,
                width: enCamino ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Chip(
                        label: Text(
                          pedido.tipo == TipoPedido.mandado
                              ? 'MANDADO LIBRE'
                              : (pedido.comercioNombre ?? 'COMERCIO'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                        ),
                        backgroundColor: pedido.tipo == TipoPedido.mandado
                            ? Colors.deepPurple
                            : AppTheme.secondaryColor,
                      ),
                      Text(
                        'Ganás \$${pedido.gananciaCadete.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pedido.detalle,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.store, size: 16, color: AppTheme.primaryColor),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Retiro: ${pedido.direccionRetiro}')),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.flag, size: 16, color: AppTheme.successColor),
                      const SizedBox(width: 6),
                      Expanded(child: Text('Entrega: ${pedido.direccionEntrega}')),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pedido.metodoPago == MetodoPago.efectivo
                            ? 'Cobrar en efectivo: \$${pedido.totalCliente.toStringAsFixed(0)}'
                            : 'Ya pago por Transferencia',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: pedido.metodoPago == MetodoPago.efectivo
                              ? Colors.orange.shade800
                              : AppTheme.successColor,
                        ),
                      ),
                      if (!enCamino)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              pedido.estado = EstadoPedido.enCamino;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('¡Viaje tomado! En camino al destino')),
                            );
                          },
                          child: const Text('Tomar Viaje'),
                        )
                      else
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                          onPressed: () {
                            setState(() {
                              _service.completarEntregaCadete(pedido);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: AppTheme.successColor,
                                content: Text('¡Entrega finalizada y saldo actualizado!'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check),
                          label: const Text('Entregado'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // PESTAÑA 2: BILLETERA Y CONTROL DE COMISIONES
  Widget _buildBilleteraTab(Cadete cadete) {
    final bool debePlata = cadete.saldoComision < 0;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Saldo Cuenta Corriente trae.me',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                '\$${cadete.saldoComision.toStringAsFixed(0)}',
                style: TextStyle(
                  color: debePlata ? Colors.amber : AppTheme.successColor,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                debePlata
                    ? 'Comisiones pendientes por viajes cobrados en efectivo (Tope: \$${cadete.limiteDeudaEfectivo.toStringAsFixed(0)})'
                    : 'Saldo a tu favor para cobrar por transferencia',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        if (debePlata)
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                cadete.saldoComision = 0;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: AppTheme.successColor,
                  content: Text('Rendición simulada: Tu saldo volvió a \$0'),
                ),
              );
            },
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Simular Rendición a trae.me (\$0)'),
          ),
      ],
    );
  }

  // PESTAÑA 3: DOCUMENTACIÓN (CARNET, CÉDULA, SEGURO)
  Widget _buildPapelesTab(Cadete cadete) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          tileColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: const Icon(Icons.verified_user, color: AppTheme.successColor, size: 32),
          title: Text(cadete.nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('Patente: ${cadete.patenteMoto} • Estado: ${cadete.estadoValidacion.name.toUpperCase()}'),
        ),
        const SizedBox(height: 20),
        const Text(
          'Documentación Obligatoria',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _docItem('DNI (Frente y Dorso)', cadete.tieneDni),
        _docItem('Licencia de Conducir (Carnet vigente)', cadete.tieneCarnet),
        _docItem('Cédula de la Moto', cadete.tieneCedula),
        _docItem('Seguro Obligatorio al día', cadete.tieneSeguro),
      ],
    );
  }

  Widget _docItem(String titulo, bool cargado) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(
          cargado ? Icons.check_circle : Icons.upload_file,
          color: cargado ? AppTheme.successColor : AppTheme.primaryColor,
        ),
        title: Text(titulo),
        trailing: Text(
          cargado ? 'Verificado' : 'Subir foto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: cargado ? AppTheme.successColor : AppTheme.primaryColor,
          ),
        ),
      ),
    );
  }
}