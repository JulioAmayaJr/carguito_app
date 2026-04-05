import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class SellerHome extends StatelessWidget {
  const SellerHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Vendedor'),
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
                decoration: BoxDecoration(color: Colors.orange),
                child: Text('Menú Vendedor',
                    style: TextStyle(color: Colors.white, fontSize: 24))),
            ListTile(
                leading: const Icon(Icons.qr_code),
                title: const Text('Registrar Cliente (Compartir QR)'),
                onTap: () => context.push('/company/qr')),
            const Divider(),
            ListTile(
                title: const Text('Mis Paquetes'),
                onTap: () => context.push('/packages')),
          ],
        ),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Bienvenido Vendedor ${auth.user?.fullName}',
            style: const TextStyle(fontSize: 24)),
      ])),
    );
  }
}
