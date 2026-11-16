import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../cliente/cliente_home_screen.dart';
import '../cadete/cadete_home_screen.dart';
import '../comercio/comercio_home_screen.dart';
import '../admin/admin_home_screen.dart';
class RoleSelectorScreen extends StatelessWidget {
  const RoleSelectorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.two_wheeler, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'trae.me',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.secondaryColor,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Tu pueblo en movimiento. Elegí un perfil para probar:',
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: ListView(
                  children: [
                    _RoleCard(
                      title: 'Soy Vecino (Consumidor)',
                      subtitle: 'Pedir comida o solicitar un mandado',
                      icon: Icons.shopping_bag_outlined,
                      color: AppTheme.primaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ClienteHomeScreen(),
                          ),
                        );
                      },
                    ),
                    _RoleCard(
                      title: 'Soy Cadete (Moto)',
                      subtitle: 'Ver viajes disponibles, registro y billetera',
                      icon: Icons.sports_motorsports_outlined,
                      color: Colors.blue.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CadeteHomeScreen(),
                        ),
                        );
                      },
                    ),
                    _RoleCard(
                      title: 'Soy Comercio',
                      subtitle: 'Gestionar pedidos entrantes y menú',
                      icon: Icons.storefront_outlined,
                      color: Colors.teal.shade700,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ComercioHomeScreen(),
                          ),
                        );
                      },
                    ),
                    _RoleCard(
                      title: 'Administrador (trae.me)',
                      subtitle: 'Aprobar carnets, pagos y caja general',
                      icon: Icons.admin_panel_settings_outlined,
                      color: AppTheme.secondaryColor,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AdminHomeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: CircleAvatar(
          radius: 26,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(subtitle, style: const TextStyle(fontSize: 13)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}