import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:carguito_app/core/auth/role_access.dart';
import '../providers/vehicles_provider.dart';

class VehiclesListScreen extends StatefulWidget {
  const VehiclesListScreen({super.key});

  @override
  State<VehiclesListScreen> createState() => _VehiclesListScreenState();
}

class _VehiclesListScreenState extends State<VehiclesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VehiclesProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehiclesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Vehículos')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && provider.items.isEmpty
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index] as Map<String, dynamic>;
                    final plate = item['plate']?.toString() ?? '';
                    final desc = item['description']?.toString() ?? '';
                    final active = item['is_active'] == true;
                    return ListTile(
                      title: Text(plate),
                      subtitle: Text(
                        [if (desc.isNotEmpty) desc, if (!active) 'Inactivo']
                            .join(' · '),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => context.push(
                              AppRoutes.vehiclesEdit,
                              extra: item,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Desactivar vehículo'),
                                content: const Text(
                                  'El vehículo se marcará como inactivo y no aparecerá en el check-in del conductor.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => ctx.pop(),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      ctx.pop();
                                      provider.remove(item['id'].toString());
                                    },
                                    child: const Text('Desactivar'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push(AppRoutes.vehiclesNew),
      ),
    );
  }
}
