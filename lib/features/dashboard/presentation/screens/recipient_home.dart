import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class RecipientHome extends StatelessWidget {
  const RecipientHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Portal del Cliente'),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout), onPressed: () => auth.logout()),
        ],
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Hola Cliente ${auth.user?.fullName}',
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        const Text('Aquí podrás rastrear tus paquetes fácilmente.'),
        const SizedBox(height: 20),
        ElevatedButton.icon(
            onPressed: () => context.push('/packages'),
            icon: const Icon(Icons.inventory_2),
            label: const Text('Ver Mis Paquetes / Tracking')),
      ])),
    );
  }
}
