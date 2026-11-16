import 'package:flutter/material.dart';
import '../../models/comercio.dart';
import '../../services/mock_service.dart';
import '../../theme/app_theme.dart';
import 'mandado_libre_screen.dart';
import 'comercio_detalle_screen.dart';

class ClienteHomeScreen extends StatefulWidget {
  const ClienteHomeScreen({super.key});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final _service = MockService();
  String _categoriaSeleccionada = 'Todos';

  final List<String> _categorias = [
    'Todos',
    'Rotiserías',
    'Kioscos',
    'Heladerías',
    'Farmacias',
  ];

  @override
  Widget build(BuildContext context) {
    final List<Comercio> comerciosFiltrados = _categoriaSeleccionada == 'Todos'
        ? _service.comercios
        : _service.comercios
            .where((c) => c.categoria == _categoriaSeleccionada)
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.two_wheeler, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('trae.me'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Mis Pedidos',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tenés ${_service.pedidos.length} pedido(s) registrado(s)'),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // TARJETA HERO: MANDADO LIBRE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, Color(0xFFE64A19)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt, color: Colors.amber, size: 28),
                    SizedBox(width: 6),
                    Text(
                      '¿Necesitás un mandado?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Buscamos encomiendas, llaves, remedios o compramos en cualquier local del pueblo.',
                  style: TextStyle(color: Colors.white, fontSize: 14, height: 1.3),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryColor,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MandadoLibreScreen(),
                        ),
                      );
                    },
                    child: const Text('Pedir un Mandado Ahora'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Text(
            'Comercios Adheridos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.secondaryColor,
            ),
          ),
          const SizedBox(height: 12),

          // FILTRO DE CATEGORÍAS
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categorias.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = _categorias[index];
                final selected = cat == _categoriaSeleccionada;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  selectedColor: AppTheme.primaryColor,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : AppTheme.secondaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                  onSelected: (_) => setState(() => _categoriaSeleccionada = cat),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // LISTA DE COMERCIOS
          ...comerciosFiltrados.map((comercio) {
            return Card(
              margin: const EdgeInsets.only(bottom: 14),
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  radius: 26,
                  backgroundColor: comercio.abierto
                      ? AppTheme.primaryColor.withOpacity(0.12)
                      : Colors.grey.shade200,
                  child: Icon(
                    Icons.storefront,
                    color: comercio.abierto ? AppTheme.primaryColor : Colors.grey,
                  ),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        comercio.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: comercio.abierto
                            ? AppTheme.successColor.withOpacity(0.12)
                            : Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        comercio.abierto ? 'ABIERTO' : 'CERRADO',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: comercio.abierto ? AppTheme.successColor : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    '${comercio.categoria} • ${comercio.tiempoEstimado} • Envío \$${comercio.costoEnvio.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
               onTap: () {
                  if (!comercio.abierto) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Este comercio se encuentra cerrado')),
                    );
                    return;
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ComercioDetalleScreen(comercio: comercio),
                    ),
                  );
                },
                  
              ),
            );
          }),
        ],
      ),
    );
  }
}