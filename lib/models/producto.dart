class Producto {
  final String id;
  final String comercioId;
  final String nombre;
  final String descripcion;
  final double precio;
  final bool disponible;

  const Producto({
    required this.id,
    required this.comercioId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    this.disponible = true,
  });
}