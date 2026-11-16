import 'package:flutter/material.dart';
import '../../models/comercio.dart';
import '../../models/producto.dart';
import '../../models/pedido.dart';
import '../../services/mock_service.dart';
import '../../theme/app_theme.dart';

class ComercioDetalleScreen extends StatefulWidget {
  final Comercio comercio;

  const ComercioDetalleScreen({super.key, required this.comercio});

  @override
  State<ComercioDetalleScreen> createState() => _ComercioDetalleScreenState();
}

class _ComercioDetalleScreenState extends State<ComercioDetalleScreen> {
  final _service = MockService();
  // Mapa de productoId -> cantidad en el carrito
  final Map<String, int> _carrito = {};

  int get _totalItems => _carrito.values.fold(0, (sum, qty) => sum + qty);

  double get _subtotalProductos {
    double total = 0;
    _carrito.forEach((productoId, cantidad) {
      final prod = widget.comercio.productos.firstWhere((p) => p.id == productoId);
      total += prod.precio * cantidad;
    });
    return total;
  }

  void _agregarProducto(Producto p) {
    setState(() {
      _carrito[p.id] = (_carrito[p.id] ?? 0) + 1;
    });
  }

  void _quitarProducto(Producto p) {
    setState(() {
      if (!_carrito.containsKey(p.id)) return;
      if (_carrito[p.id]! > 1) {
        _carrito[p.id] = _carrito[p.id]! - 1;
      } else {
        _carrito.remove(p.id);
      }
    });
  }

  void _abrirCheckout() {
    final direccionCtrl = TextEditingController();
    MetodoPago metodoPago = MetodoPago.transferencia;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final double subtotal = _subtotalProductos;
            final double envio = widget.comercio.costoEnvio;
            final double total = subtotal + envio;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Confirmar pedido en ${widget.comercio.nombre}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: direccionCtrl,
                      decoration: InputDecoration(
                        labelText: 'Tu dirección de entrega',
                        hintText: 'Ej: Calle 9 de Julio 420 (portón negro)',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '¿Cómo vas a pagar?',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    RadioListTile<MetodoPago>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Transferencia a trae.me'),
                      subtitle: const Text('Pagás el total al Alias TRAEME.APP'),
                      value: MetodoPago.transferencia,
                      groupValue: metodoPago,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setModalState(() => metodoPago = v!),
                    ),
                    RadioListTile<MetodoPago>(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Efectivo al recibir'),
                      subtitle: const Text('Le pagás al cadete en tu puerta'),
                      value: MetodoPago.efectivo,
                      groupValue: metodoPago,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (v) => setModalState(() => metodoPago = v!),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Productos:'),
                        Text('\$${subtotal.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Envío:'),
                        Text('\$${envio.toStringAsFixed(0)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total:',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          '\$${total.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (direccionCtrl.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ingresá tu dirección de entrega')),
                            );
                            return;
                          }

                          // Armar resumen textual de los ítems pedidos
                          final List<String> resumenItems = [];
                          _carrito.forEach((prodId, qty) {
                            final p = widget.comercio.productos
                                .firstWhere((item) => item.id == prodId);
                            resumenItems.add('${qty}x ${p.nombre}');
                          });

                          final nuevoPedido = Pedido(
                            id: 'PED-${100 + _service.pedidos.length + 1}',
                            tipo: TipoPedido.comercio,
                            comercioNombre: widget.comercio.nombre,
                            direccionRetiro: widget.comercio.direccion,
                            direccionEntrega: direccionCtrl.text.trim(),
                            detalle: resumenItems.join(', '),
                            subtotalProductos: subtotal,
                            costoEnvio: envio,
                            comisionApp: envio * _service.porcentajeComisionEnvio,
                            metodoPago: metodoPago,
                            estado: metodoPago == MetodoPago.transferencia
                                ? EstadoPedido.pendientePago
                                : EstadoPedido.enPreparacion,
                            fecha: DateTime.now(),
                          );

                          _service.crearPedido(nuevoPedido);

                          Navigator.pop(ctx); // Cierra modal
                          Navigator.pop(context); // Vuelve al Home

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppTheme.successColor,
                              content: Text(
                                '¡Pedido ${nuevoPedido.id} enviado a ${widget.comercio.nombre}!',
                              ),
                            ),
                          );
                        },
                        child: const Text('Enviar Pedido'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.comercio.nombre),
      ),
      body: Column(
        children: [
          // CABECERA DEL COMERCIO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.comercio.categoria} • ${widget.comercio.direccion}',
                  style: const TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text(widget.comercio.tiempoEstimado),
                    const SizedBox(width: 16),
                    const Icon(Icons.two_wheeler, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Text('Envío \$${widget.comercio.costoEnvio.toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // LISTA DE PRODUCTOS
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: widget.comercio.productos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final producto = widget.comercio.productos[index];
                final cantidad = _carrito[producto.id] ?? 0;

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              producto.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              producto.descripcion,
                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '\$${producto.precio.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: AppTheme.secondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (cantidad == 0)
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                            side: const BorderSide(color: AppTheme.primaryColor),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () => _agregarProducto(producto),
                          child: const Text('+ Agregar'),
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              onPressed: () => _quitarProducto(producto),
                              icon: const Icon(Icons.remove_circle_outline,
                                  color: AppTheme.primaryColor),
                            ),
                            Text(
                              '$cantidad',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            IconButton(
                              onPressed: () => _agregarProducto(producto),
                              icon: const Icon(Icons.add_circle,
                                  color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // BARRA FLOTANTE DEL CARRITO
      bottomNavigationBar: _totalItems > 0
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: _abrirCheckout,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ver carrito ($_totalItems)'),
                      Text('\$${(_subtotalProductos + widget.comercio.costoEnvio).toStringAsFixed(0)}'),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }
}