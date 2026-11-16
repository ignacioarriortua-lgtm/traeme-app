import 'package:flutter/material.dart';
import '../../models/comercio.dart';
import '../../models/pedido.dart';
import '../../services/mock_service.dart';
import '../../theme/app_theme.dart';

class ComercioHomeScreen extends StatefulWidget {
  const ComercioHomeScreen({super.key});

  @override
  State<ComercioHomeScreen> createState() => _ComercioHomeScreenState();
}

class _ComercioHomeScreenState extends State<ComercioHomeScreen> {
  final _service = MockService();
  int _tabIndex = 0;

  // Simulamos que el comercio logueado es el primero ("Rotisería El Centro")
  Comercio get _miComercio => _service.comercios.first;

  @override
  Widget build(BuildContext context) {
    final pedidosLocal = _service.pedidos
        .where((p) =>
            p.tipo == TipoPedido.comercio &&
            p.comercioNombre == _miComercio.nombre)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_miComercio.nombre),
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          _buildPedidosTab(pedidosLocal),
          _buildMenuTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Pedidos',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu),
            label: 'Mi Menú',
          ),
        ],
      ),
    );
  }

  // PESTAÑA 1: PEDIDOS ENTRANTES AL COMERCIO
  Widget _buildPedidosTab(List<Pedido> pedidos) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Pedidos del local (${pedidos.length})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (pedidos.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                'Todavía no entraron pedidos para este comercio.\nProbá hacer una compra desde el perfil Vecino.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ...pedidos.map((pedido) {
          final bool esperandoPago =
              pedido.estado == EstadoPedido.pendientePago;
          final bool enCocina = pedido.estado == EstadoPedido.enPreparacion;

          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pedido.id,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Chip(
                        label: Text(
                          pedido.estado.name.toUpperCase(),
                          style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pedido.detalle,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Entrega: ${pedido.direccionEntrega}',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comida: \$${pedido.subtotalProductos.toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (esperandoPago)
                        const Text(
                          'Esperando validación de pago...',
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        )
                      else if (enCocina)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.successColor,
                          ),
                          onPressed: () {
                            setState(() {
                              pedido.estado = EstadoPedido.buscandoCadete;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    '¡Pedido listo! Ya figura en el Radar de los cadetes.'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.two_wheeler),
                          label: const Text('Listo para retirar'),
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

  // PESTAÑA 2: CATÁLOGO DEL COMERCIO
  Widget _buildMenuTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _miComercio.productos.length,
      itemBuilder: (context, index) {
        final prod = _miComercio.productos[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            title: Text(prod.nombre,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('\$${prod.precio.toStringAsFixed(0)}'),
            trailing: const Chip(
              label: Text('Activo',
                  style: TextStyle(color: AppTheme.successColor, fontSize: 12)),
            ),
          ),
        );
      },
    );
  }
}