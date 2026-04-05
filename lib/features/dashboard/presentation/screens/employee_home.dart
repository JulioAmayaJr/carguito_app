import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EmployeeHome extends StatelessWidget {
  const EmployeeHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Employee'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Employee Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
                title: const Text('Mis Paquetes'),
                onTap: () => context.push('/packages')),
            ListTile(
                title: const Text('Mis Envíos'),
                onTap: () => context.push('/shipments')),
            ListTile(
                title: const Text('Notificaciones'),
                onTap: () => context.push('/notifications')),
          ],
        ),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Hola Empleado ${auth.user?.fullName}',
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        const Text('Accede al menú para realizar entregas y checkins.'),
      ])),
    );
  }
}
