import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/fees_provider.dart';

class FeesListScreen extends StatefulWidget {
  const FeesListScreen({super.key});

  @override
  State<FeesListScreen> createState() => _FeesListScreenState();
}

class _FeesListScreenState extends State<FeesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeesProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FeesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Fees')),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item['name'] ??
                          item['package_code'] ??
                          item['id'] ??
                          'Unknown'),
                      subtitle: Text(item.toString()),
                    );
                  },
                ),
    );
  }
}
