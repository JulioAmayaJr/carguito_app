import 'package:flutter/material.dart';
import '../../../../core/utils/role_bottom_menu.dart';

class DriverRoutesScreen extends StatelessWidget {
  const DriverRoutesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      bottomNavigationBar: const RoleBottomMenu(),
      appBar: AppBar(
        title: const Text('Mi Hoja de Ruta'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.map_rounded, color: Color(0xFF3B82F6), size: 64),
              ),
              const SizedBox(height: 24),
              const Text(
                'Navegación en Tiempo Real',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
              ),
              const SizedBox(height: 12),
              const Text(
                'Estamos preparando la integración con Mapbox para ofrecerte las mejores rutas de entrega optimizadas.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Color(0xFF6B7280), height: 1.5),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.list_alt_rounded),
                label: const Text('Ver Listado de Entregas'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF4B83A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
