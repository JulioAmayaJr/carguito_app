import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/employees_provider.dart';

class EmployeesListScreen extends StatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  State<EmployeesListScreen> createState() => _EmployeesListScreenState();
}

class _EmployeesListScreenState extends State<EmployeesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmployeesProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EmployeesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Empleados')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && provider.items.isEmpty
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item['user_id'] ?? item['id'] ?? 'Dato'),
                      subtitle: Text(item.toString()),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                context.push('/employees/edit', extra: item)),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDialog(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                        title:
                                            const Text('Confirmar Eliminación'),
                                        content: const Text(
                                            '¿Desea eliminar permanentemente este registro?'),
                                        actions: [
                                          TextButton(
                                              child: const Text('Cancelar'),
                                              onPressed: () => ctx.pop()),
                                          TextButton(
                                              child: const Text('Eliminar'),
                                              onPressed: () {
                                                ctx.pop();
                                                provider.remove(item['id']);
                                              })
                                        ]))),
                      ]),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/employees/new'),
      ),
    );
  }
}
