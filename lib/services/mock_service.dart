import '../models/comercio.dart';
import '../models/producto.dart';
import '../models/pedido.dart';
import '../models/cadete.dart';


class MockService {
  static final MockService _instance = MockService._internal();
  factory MockService() => _instance;
  MockService._internal();

  // Tarifa base estándar del pueblo (editable luego desde Admin)
  double tarifaEnvioBase = 2000.0;
  double porcentajeComisionEnvio = 0.20; // 20% para trae.me
// Cadete logueado de prueba
  final Cadete cadeteActual = Cadete(
    id: 'cad-1',
    nombre: 'Lucas Gómez',
    telefono: '3735-441122',
    patenteMoto: 'A123BCD',
    tieneDni: true,
    tieneCarnet: true,
    tieneCedula: true,
    tieneSeguro: true,
    estadoValidacion: EstadoValidacionCadete.aprobado,
    disponible: true,
    saldoComision: -800.0, // Ejemplo: ya debe $800 de 2 viajes en efectivo
  );

  void completarEntregaCadete(Pedido pedido) {
    pedido.estado = EstadoPedido.entregado;

    if (pedido.metodoPago == MetodoPago.efectivo) {
      // El cadete cobró todo en mano: se le descuenta la comisión de trae.me de su saldo
      cadeteActual.saldoComision -= pedido.comisionApp;
    } else {
      // El cliente pagó por transferencia a trae.me: la app le suma su ganancia neta al cadete
      cadeteActual.saldoComision += pedido.gananciaCadete;
    }
  }
  final List<Comercio> comercios = [
    const Comercio(
      id: 'c1',
      nombre: 'Rotisería El Centro',
      categoria: 'Rotiserías',
      direccion: 'Av. San Martín 340',
      tiempoEstimado: '25 - 35 min',
      costoEnvio: 2000,
      abierto: true,
      productos: [
        Producto(
          id: 'p1',
          comercioId: 'c1',
          nombre: 'Pizza Muzzarella Grande',
          descripcion: '8 porciones, salsa casera, aceitunas y orégano',
          precio: 9500,
        ),
        Producto(
          id: 'p2',
          comercioId: 'c1',
          nombre: 'Docena de Empanadas',
          descripcion: 'Carne cortada a cuchillo, pollo o jamón y queso',
          precio: 11000,
        ),
        Producto(
          id: 'p3',
          comercioId: 'c1',
          nombre: 'Sándwich de Milanesa Completo',
          descripcion: 'Con lechuga, tomate, jamón, queso, huevo y papas',
          precio: 7500,
        ),
      ],
    ),
    const Comercio(
      id: 'c2',
      nombre: 'Kiosco 24hs La Esquina',
      categoria: 'Kioscos',
      direccion: 'Belgrano y Rivadavia',
      tiempoEstimado: '15 - 20 min',
      costoEnvio: 1800,
      abierto: true,
      productos: [
        Producto(
          id: 'p4',
          comercioId: 'c2',
          nombre: 'Coca-Cola 2.25L',
          descripcion: 'Bien fría',
          precio: 3800,
        ),
        Producto(
          id: 'p5',
          comercioId: 'c2',
          nombre: 'Bolsa de Hielo 4kg',
          descripcion: 'Rolito cristalino',
          precio: 2500,
        ),
        Producto(
          id: 'p6',
          comercioId: 'c2',
          nombre: 'Combo Picada Rápida',
          descripcion: 'Papas fritas + maní saborizado + 2 latas de cerveza',
          precio: 8200,
        ),
      ],
    ),
    const Comercio(
      id: 'c3',
      nombre: 'Heladería Nevada',
      categoria: 'Heladerías',
      direccion: 'Sarmiento 120',
      tiempoEstimado: '15 - 25 min',
      costoEnvio: 2000,
      abierto: true,
      productos: [
        Producto(
          id: 'p7',
          comercioId: 'c3',
          nombre: '1 Kg de Helado Artesanal',
          descripcion: 'Hasta 4 sabores a elección',
          precio: 12000,
        ),
        Producto(
          id: 'p8',
          comercioId: 'c3',
          nombre: '1/2 Kg de Helado',
          descripcion: 'Hasta 3 sabores a elección',
          precio: 6800,
        ),
      ],
    ),
    const Comercio(
      id: 'c4',
      nombre: 'Farmacia del Pueblo (Turno)',
      categoria: 'Farmacias',
      direccion: 'Mitre 510',
      tiempoEstimado: '15 - 20 min',
      costoEnvio: 2000,
      abierto: false,
      productos: [],
    ),
  ];

  // Lista compartida de pedidos entre pantallas
  final List<Pedido> pedidos = [
    Pedido(
      id: 'PED-101',
      tipo: TipoPedido.mandado,
      direccionRetiro: 'Terminal de Ómnibus (Encomiendas)',
      direccionEntrega: 'Barrio Norte - Calle Güemes 230',
      detalle: 'Retirar caja chica a nombre de Juan Pérez',
      subtotalProductos: 0,
      costoEnvio: 2000,
      comisionApp: 400,
      metodoPago: MetodoPago.efectivo,
      estado: EstadoPedido.buscandoCadete,
      fecha: DateTime.now().subtract(const Duration(minutes: 5)),
    ),
  ];

  void crearPedido(Pedido nuevo) {
    pedidos.insert(0, nuevo);
  }
}