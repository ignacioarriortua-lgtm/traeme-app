enum EstadoValidacionCadete { pendiente, aprobado, rechazado }

class Cadete {
  final String id;
  String nombre;
  String telefono;
  String patenteMoto;
  bool tieneDni;
  bool tieneCarnet;
  bool tieneCedula;
  bool tieneSeguro;
  EstadoValidacionCadete estadoValidacion;
  bool disponible;
  double saldoComision; // Negativo = debe comisiones a trae.me por cobros en efectivo
  final double limiteDeudaEfectivo;

  Cadete({
    required this.id,
    required this.nombre,
    required this.telefono,
    required this.patenteMoto,
    this.tieneDni = false,
    this.tieneCarnet = false,
    this.tieneCedula = false,
    this.tieneSeguro = false,
    this.estadoValidacion = EstadoValidacionCadete.pendiente,
    this.disponible = false,
    this.saldoComision = 0.0,
    this.limiteDeudaEfectivo = -3000.0, // Tope negativo antes de pausar efectivo
  });

  bool get bloqueadoPorDeuda => saldoComision <= limiteDeudaEfectivo;
}