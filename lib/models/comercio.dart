import 'producto.dart';

class Comercio {
  final String id;
  final String nombre;
  final String categoria;
  final String direccion;
  final String tiempoEstimado;
  final double costoEnvio;
  final bool abierto;
  final List<Producto> productos;

  const Comercio({
    required this.id,
    required this.nombre,
    required this.categoria,
    required this.direccion,
    required this.tiempoEstimado,
    required this.costoEnvio,
    required this.abierto,
    required this.productos,
  });
}