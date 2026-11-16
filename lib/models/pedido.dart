enum TipoPedido { comercio, mandado }

enum MetodoPago { transferencia, efectivo }

enum EstadoPedido {
  pendientePago,
  buscandoCadete,
  enPreparacion,
  enCamino,
  entregado,
  cancelado,
}

class Pedido {
  final String id;
  final TipoPedido tipo;
  final String? comercioNombre;
  final String direccionRetiro;
  final String direccionEntrega;
  final String detalle;
  final double subtotalProductos;
  final double costoEnvio;
  final double comisionApp;
  final MetodoPago metodoPago;
  EstadoPedido estado;
  final DateTime fecha;

  Pedido({
    required this.id,
    required this.tipo,
    this.comercioNombre,
    required this.direccionRetiro,
    required this.direccionEntrega,
    required this.detalle,
    required this.subtotalProductos,
    required this.costoEnvio,
    required this.comisionApp,
    required this.metodoPago,
    required this.estado,
    required this.fecha,
  });

  double get totalCliente => subtotalProductos + costoEnvio;
  double get gananciaCadete => costoEnvio - comisionApp;
}