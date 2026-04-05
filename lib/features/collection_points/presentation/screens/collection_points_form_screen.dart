import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/collection_points_provider.dart';

class CollectionPointsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const CollectionPointsFormScreen({super.key, this.item});

  @override
  State<CollectionPointsFormScreen> createState() =>
      _CollectionPointsFormScreenState();
}

class _CollectionPointsFormScreenState
    extends State<CollectionPointsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _nameCtrl.text = widget.item!['name']?.toString() ?? '';
      _addressCtrl.text = widget.item!['address']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CollectionPointsProvider>();
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(isEdit
              ? 'Editar Puntos de Recolección'
              : 'Nuevo Puntos de Recolección')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'name', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _addressCtrl,
                decoration: const InputDecoration(
                    labelText: 'address', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final req = {
                          'name': _nameCtrl.text,
                          'address': _addressCtrl.text,
                        };
                        if (!isEdit) {
                          final res = await prov.create(req);
                          if (res && context.mounted) context.pop();
                          if (!res && context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(prov.error ?? 'Error')));
                        } else {
                          final res =
                              await prov.update(widget.item!['id'], req);
                          if (res && context.mounted) context.pop();
                          if (!res && context.mounted)
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(prov.error ?? 'Error al actualizar')));
                        }
                      }
                    },
              child: prov.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }
}
