import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/auth/role_access.dart';
import '../../../../core/utils/role_bottom_menu.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final isDriver = RoleAccess.isDriverUser(auth.user);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const RoleBottomMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Icon(
                    isDriver ? Icons.local_shipping_rounded : Icons.badge_rounded,
                    color: const Color(0xFFF4B83A),
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isDriver ? 'Carguito Driver' : 'Carguito Equipo',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2937),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => auth.logout(),
                    icon: const Icon(Icons.logout_rounded, color: Color(0xFF6B7280)),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                children: [
                  Text(
                    'Bienvenido de vuelta,',
                    style: TextStyle(
                      fontSize: 16,
                      color: const Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    auth.user?.fullName.split(' ').first ?? 'Colega',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF111827),
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Status Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDriver ? const Color(0xFFF4B83A) : const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (isDriver ? const Color(0xFFF4B83A) : const Color(0xFF1F2937)).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          backgroundColor: Colors.white,
                          radius: 24,
                          child: Icon(Icons.check_circle_rounded, color: Color(0xFFF4B83A), size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'En Servicio',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                isDriver ? 'Tu ruta de hoy está activa.' : 'Operación estable.',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  Text(
                    isDriver ? 'Operaciones de Ruta' : 'Mis Tareas',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (isDriver) ...[
                    _QuickActionTile(
                      icon: Icons.how_to_reg_rounded,
                      title: 'Check-in de Paquete',
                      subtitle: 'Escanear o registrar entrada',
                      color: const Color(0xFFF4B83A),
                      onTap: () => context.push(AppRoutes.shipmentsNew),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionTile(
                      icon: Icons.map_rounded,
                      title: 'Mi Hoja de Ruta',
                      subtitle: 'Ver mapa y entregas de hoy',
                      color: const Color(0xFF3B82F6),
                      onTap: () => context.push(AppRoutes.shipmentsRoutes),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionTile(
                      icon: Icons.settings_rounded,
                      title: 'Mi Cuenta',
                      subtitle: 'Cambiar contraseña y perfil',
                      color: const Color(0xFF6B7280),
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                  ] else ...[
                    _QuickActionTile(
                      icon: Icons.inventory_2_rounded,
                      title: 'Gestión de Paquetes',
                      subtitle: 'Recibir y organizar',
                      color: const Color(0xFFF4B83A),
                      onTap: () => context.push(AppRoutes.packages),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionTile(
                      icon: Icons.local_shipping_rounded,
                      title: 'Envíos',
                      subtitle: 'Seguimiento y despacho',
                      color: const Color(0xFF3B82F6),
                      onTap: () => context.push(AppRoutes.shipments),
                    ),
                    const SizedBox(height: 12),
                    _QuickActionTile(
                      icon: Icons.settings_rounded,
                      title: 'Ajustes',
                      subtitle: 'Configuración personal',
                      color: const Color(0xFF6B7280),
                      onTap: () => context.push(AppRoutes.settings),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  const Text(
                    'Asistencia',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _SecondaryCard(
                          icon: Icons.support_agent_rounded,
                          label: 'Reportar Error',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SecondaryCard(
                          icon: Icons.contact_emergency_rounded,
                          label: 'Emergencia',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFD1D5DB)),
          ],
        ),
      ),
    );
  }
}

class _SecondaryCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _SecondaryCard({required this.icon, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF9CA3AF), size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
