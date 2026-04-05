import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:carguito_app/core/auth/role_access.dart';
import 'package:carguito_app/core/utils/role_bottom_menu.dart';
import 'package:carguito_app/features/auth/presentation/providers/auth_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotificationsEnabled = true;
  bool _biometricEnabled = false;

  static const Color _backgroundColor = Color(0xFFF6F4F7);
  static const Color _cardColor = Colors.white;
  static const Color _titleColor = Color(0xFF3B3B45);
  static const Color _subtitleColor = Color(0xFF8B8B97);
  static const Color _sectionColor = Color(0xFFA2A2AD);
  static const Color _accentColor = Color(0xFFE5B63E);
  static const Color _dangerColor = Color(0xFFFA4A3A);
  static const Color _borderColor = Color(0xFFE9E7EC);

  @override
  Widget build(BuildContext context) {
    final showAdminSection =
        RoleAccess.showCompanyAdministrationInSettings(context.read<AuthProvider>().user);

    return Scaffold(
      backgroundColor: _backgroundColor,
      bottomNavigationBar: const RoleBottomMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildBanner(),
                  const SizedBox(height: 22),
                  _buildSectionTitle('Perfil'),
                  const SizedBox(height: 10),
                  _buildGroupCard(
                    children: [
                      _buildArrowTile(
                        icon: Icons.person_outline_rounded,
                        title: 'Información personal',
                        onTap: () {},
                      ),
                      _buildDivider(),
                      _buildArrowTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Cambiar contraseña',
                        onTap: () {},
                      ),
                    ],
                  ),
                  if (showAdminSection) ...[
                    const SizedBox(height: 18),
                    _buildSectionTitle('Administración'),
                    const SizedBox(height: 10),
                    _buildGroupCard(
                      children: [
                        _buildArrowTile(
                          icon: Icons.people_outline_rounded,
                          title: 'Empleados',
                          subtitle: 'Gestionar empleados',
                          onTap: () => context.push(AppRoutes.employees),
                        ),
                        _buildDivider(),
                        _buildArrowTile(
                          icon: Icons.storefront_outlined,
                          title: 'Vendedores',
                          subtitle: 'Gestionar vendedores',
                          onTap: () => context.push(AppRoutes.sellers),
                        ),
                        _buildDivider(),
                        _buildArrowTile(
                          icon: Icons.person_pin_outlined,
                          title: 'Clientes',
                          subtitle: 'Gestionar clientes',
                          onTap: () => context.push(AppRoutes.recipients),
                        ),
                        _buildDivider(),
                        _buildArrowTile(
                          icon: Icons.account_balance_outlined,
                          title: 'Cuentas bancarias',
                          subtitle: 'Gestionar cuentas bancarias',
                          onTap: () => context.push(AppRoutes.bankAccounts),
                        ),
                        _buildDivider(),
                        _buildArrowTile(
                          icon: Icons.directions_car_outlined,
                          title: 'Vehículos',
                          subtitle: 'Flota de la empresa',
                          onTap: () => context.push(AppRoutes.vehicles),
                        ),
                        _buildDivider(),
                        _buildArrowTile(
                          icon: Icons.qr_code_2_outlined,
                          title: 'QR de empresa',
                          subtitle: 'Códigos QR para vendedores y clientes',
                          onTap: () => context.push(AppRoutes.companyQr),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 18),
                  _buildSectionTitle('Preferencias'),
                  const SizedBox(height: 10),
                  _buildGroupCard(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        title: 'Notificaciones push',
                        subtitle: 'Recibir alertas y novedades',
                        value: _pushNotificationsEnabled,
                        onChanged: (value) {
                          setState(() => _pushNotificationsEnabled = value);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Seguridad'),
                  const SizedBox(height: 10),
                  _buildGroupCard(
                    children: [
                      _buildSwitchTile(
                        icon: Icons.fingerprint_rounded,
                        title: 'Biometría',
                        subtitle: 'Iniciar sesión con huella digital',
                        value: _biometricEnabled,
                        onChanged: (value) {
                          setState(() => _biometricEnabled = value);
                        },
                      ),
                      _buildDivider(),
                      _buildArrowTile(
                        icon: Icons.devices_other_outlined,
                        title: 'Dispositivos conectados',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildSectionTitle('Información'),
                  const SizedBox(height: 10),
                  _buildGroupCard(
                    children: [
                      _buildArrowTile(
                        icon: Icons.info_outline_rounded,
                        title: 'Acerca de',
                        onTap: () => _showAboutDialog(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Center(
                    child: Text(
                      'Versión 1.0.0',
                      style: TextStyle(
                        fontSize: 15,
                        color: _subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _dangerColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Configuración',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w600,
                color: _titleColor,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.settings_outlined,
                  color: Color(0xFF5A5A64),
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 152,
      decoration: BoxDecoration(
        color: const Color(0xFFFDFBFA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFF0ECE7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          'assets/setting/setting.png',
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: _sectionColor,
      ),
    );
  }

  Widget _buildGroupCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: _borderColor,
      indent: 18,
      endIndent: 18,
    );
  }

  Widget _buildArrowTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Icon(icon, size: 24, color: const Color(0xFF3E4048)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _titleColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: _subtitleColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF666874),
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF3E4048)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: _titleColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: _subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: _accentColor,
            inactiveThumbColor: const Color(0xFF8F909A),
            inactiveTrackColor: const Color(0xFFD7D8DE),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Carguito',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2026 Todos los derechos reservados',
      children: const [
        SizedBox(height: 8),
        Text('Aplicación de gestión de envíos y paquetería'),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text('Cerrar sesión'),
          content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: _dangerColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }
}