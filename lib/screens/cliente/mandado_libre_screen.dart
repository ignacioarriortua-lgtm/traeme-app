import 'package:flutter/material.dart';
import '../../models/pedido.dart';
import '../../services/mock_service.dart';
import '../../theme/app_theme.dart';

class MandadoLibreScreen extends StatefulWidget {
  const MandadoLibreScreen({super.key});

  @override
  State<MandadoLibreScreen> createState() => _MandadoLibreScreenState();
}

class _MandadoLibreScreenState extends State<MandadoLibreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _retiroCtrl = TextEditingController();
  final _entregaCtrl = TextEditingController();
  final _detalleCtrl = TextEditingController();
  final _montoCompraCtrl = TextEditingController(text: '0');

  bool _requiereCompra = false;
  MetodoPago _metodoPago = MetodoPago.transferencia;
  final _service = MockService();

  @override
  void dispose() {
    _retiroCtrl.dispose();
    _entregaCtrl.dispose();
    _detalleCtrl.dispose();
    _montoCompraCtrl.dispose();
    super.dispose();
  }

  void _confirmarMandado() {
    if (!_formKey.currentState!.validate()) return;

    final double compraEstimada =
        _requiereCompra ? (double.tryParse(_montoCompraCtrl.text) ?? 0) : 0;
    final double envio = _service.tarifaEnvioBase;
    final double comision = envio * _service.porcentajeComisionEnvio;

    final nuevoPedido = Pedido(
      id: 'MAN-${100 + _service.pedidos.length + 1}',
      tipo: TipoPedido.mandado,
      direccionRetiro: _retiroCtrl.text.trim(),
      direccionEntrega: _entregaCtrl.text.trim(),
      detalle: _detalleCtrl.text.trim(),
      subtotalProductos: compraEstimada,
      costoEnvio: envio,
      comisionApp: comision,
      metodoPago: _metodoPago,
      estado: _metodoPago == MetodoPago.transferencia
          ? EstadoPedido.pendientePago
          : EstadoPedido.buscandoCadete,
      fecha: DateTime.now(),
    );

    _service.crearPedido(nuevoPedido);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successColor),
            SizedBox(width: 8),
            Text('¡Mandado solicitado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Código: ${nuevoPedido.id}'),
            const SizedBox(height: 8),
            Text('Total a abonar: \$${nuevoPedido.totalCliente.toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            if (_metodoPago == MetodoPago.transferencia)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Transferí al Alias: TRAEME.APP\nEn cuanto verifiquemos el pago, un cadete sale para allá.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              )
            else
              const Text(
                'Tu pedido ya figura disponible para los cadetes conectados.',
                style: TextStyle(fontSize: 13),
              ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Cierra diálogo
              Navigator.pop(context); // Vuelve al Home
            },
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double envio = _service.tarifaEnvioBase;
    final double compra =
        _requiereCompra ? (double.tryParse(_montoCompraCtrl.text) ?? 0) : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pedir un Mandado')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              '¿Qué necesitás que busquemos o llevemos?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _detalleCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Detalle del mandado',
                hintText:
                    'Ej: Buscar una bolsa en lo de mi tía o comprar 2kg de pan en la panadería...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Escribí qué hay que hacer' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _retiroCtrl,
              decoration: InputDecoration(
                labelText: 'Punto A: ¿Dónde se retira?',
                prefixIcon: const Icon(Icons.location_on_outlined, color: AppTheme.primaryColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indicá la dirección de retiro' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _entregaCtrl,
              decoration: InputDecoration(
                labelText: 'Punto B: ¿Dónde se entrega?',
                prefixIcon: const Icon(Icons.flag_outlined, color: AppTheme.successColor),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Indicá tu dirección de entrega' : null,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              title: const Text('¿El cadete debe pagar algo al retirar?'),
              subtitle: const Text('Ej: compra en kiosco o farmacia no adherida'),
              value: _requiereCompra,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) => setState(() => _requiereCompra = val),
            ),
            if (_requiereCompra) ...[
              const SizedBox(height: 12),
              TextFormField(
                controller: _montoCompraCtrl,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Monto estimado de la compra (\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Método de Pago',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            RadioListTile<MetodoPago>(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Transferencia a trae.me (Recomendado)'),
              subtitle: const Text('Pagás por Alias/CVU antes de salir'),
              value: MetodoPago.transferencia,
              groupValue: _metodoPago,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) => setState(() => _metodoPago = val!),
            ),
            const SizedBox(height: 8),
            RadioListTile<MetodoPago>(
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: const Text('Efectivo al recibir'),
              subtitle: const Text('Le pagás en mano al cadete cuando llega'),
              value: MetodoPago.efectivo,
              groupValue: _metodoPago,
              activeColor: AppTheme.primaryColor,
              onChanged: (val) => setState(() => _metodoPago = val!),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tarifa de envío local:', style: TextStyle(color: Colors.white70)),
                      Text('\$${envio.toStringAsFixed(0)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  if (_requiereCompra) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Compra estimada:', style: TextStyle(color: Colors.white70)),
                        Text('\$${compra.toStringAsFixed(0)}',
                            style:
                                const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total estimado:',
                          style: TextStyle(
                              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      Text('\$${(envio + compra).toStringAsFixed(0)}',
                          style: const TextStyle(
                              color: AppTheme.primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _confirmarMandado,
              icon: const Icon(Icons.two_wheeler),
              label: const Text('Confirmar Mandado'),
            ),
          ],
        ),
      ),
    );
  }
}