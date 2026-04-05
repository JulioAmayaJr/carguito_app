import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PlatformHome extends StatelessWidget {
  const PlatformHome({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Admin'),
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
              child: Text('Platform Menu',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
                title: const Text('Companies'),
                onTap: () => context.push('/companies')),
            ListTile(
                title: const Text('Packages'),
                onTap: () => context.push('/packages')),
            ListTile(
                title: const Text('Shipments'),
                onTap: () => context.push('/shipments')),
            ListTile(
                title: const Text('Payments'),
                onTap: () => context.push('/payments')),
            ListTile(
                title: const Text('Fees'), onTap: () => context.push('/fees')),
            ListTile(
                title: const Text('Bank Accounts'),
                onTap: () => context.push('/bank_accounts')),
            ListTile(
                title: const Text('Notifications'),
                onTap: () => context.push('/notifications')),
          ],
        ),
      ),
      body: Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('Bienvenido ${auth.user?.fullName}',
            style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 20),
        const Text('Dashboard platform API: /api/dashboard/platform'),
      ])),
    );
  }
}
