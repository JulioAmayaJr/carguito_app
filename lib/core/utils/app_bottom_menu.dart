import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppBottomMenu extends StatelessWidget {
  final int currentIndex;

  const AppBottomMenu({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom
            : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Inicio',
            selected: currentIndex == 0,
            onTap: () => context.go('/seller/home'),
          ),
          _NavItem(
            icon: Icons.local_shipping_outlined,
            label: 'Paquetes',
            selected: currentIndex == 1,
            onTap: () => context.go('/packages'),
          ),
          _NavItem(
            icon: Icons.location_on_rounded,
            label: 'Envíos',
            selected: currentIndex == 2,
            onTap: () => context.go('/shipments'),
          ),
          _NavItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Pagos',
            selected: currentIndex == 3,
            onTap: () => context.go('/payments'),
          ),
          _NavItem(
            icon: Icons.settings_rounded,
            label: 'Ajustes',
            selected: currentIndex == 4,
            onTap: () => context.go('/settings'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const selectedColor = Color(0xFFE3A521);
    const normalColor = Color(0xFF6B7280);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF6DF) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 28,
              color: selected ? selectedColor : normalColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? selectedColor : normalColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}