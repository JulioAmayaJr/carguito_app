import 'package:flutter/material.dart';
import '../companies/companies_page.dart';
import '../packages/packages_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const CompaniesPage()));
            },
            child: const Text('Empresas'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const PackagesPage()));
            },
            child: const Text('Paquetes'),
          ),
        ],
      ),
    );
  }
}
