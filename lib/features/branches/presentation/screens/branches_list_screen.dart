import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/branches_provider.dart';

class BranchesListScreen extends StatefulWidget {
  const BranchesListScreen({super.key});

  @override
  State<BranchesListScreen> createState() => _BranchesListScreenState();
}

class _BranchesListScreenState extends State<BranchesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BranchesProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<BranchesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Sucursales')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && provider.items.isEmpty
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item['name'] ??
                          item['bank_name'] ??
                          item['description'] ??
                          item['id'] ??
                          'Dato'),
                      subtitle: Text(item.toString()),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () =>
                                context.push('/branches/edit', extra: item)),
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
        onPressed: () => context.push('/branches/new'),
      ),
    );
  }
}
