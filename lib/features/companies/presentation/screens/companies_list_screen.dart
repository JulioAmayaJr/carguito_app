import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/companies_provider.dart';

class CompaniesListScreen extends StatefulWidget {
  const CompaniesListScreen({super.key});

  @override
  State<CompaniesListScreen> createState() => _CompaniesListScreenState();
}

class _CompaniesListScreenState extends State<CompaniesListScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar empresas al iniciar la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompaniesProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompaniesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Empresas (Companies)')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item['name'] ?? item['id'] ?? 'Unknown'),
                      subtitle: Text(
                          "RUC/NIT: ${item['ruc_nit']} - Activa: ${item['is_active']}"),
                      onTap: () {
                        // Navegar a edición con los datos de la empresa
                        context.push('/companies/edit', extra: item);
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/companies/new'),
      ),
    );
  }
}
