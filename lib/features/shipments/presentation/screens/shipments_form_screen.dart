import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/shipments_provider.dart';

class ShipmentsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const ShipmentsFormScreen({super.key, this.item});

  @override
  State<ShipmentsFormScreen> createState() => _ShipmentsFormScreenState();
}

class _ShipmentsFormScreenState extends State<ShipmentsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vehicle_plateCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _vehicle_plateCtrl.text = widget.item!['vehicle_plate']?.toString() ?? '';
      _statusCtrl.text = widget.item!['status']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _vehicle_plateCtrl.dispose();
    _statusCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ShipmentsProvider>();
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Envíos' : 'Nuevo Envíos')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _vehicle_plateCtrl,
                decoration: const InputDecoration(
                    labelText: 'vehicle_plate', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _statusCtrl,
                decoration: const InputDecoration(
                    labelText: 'status', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final req = {
                          'vehicle_plate': _vehicle_plateCtrl.text,
                          'status': _statusCtrl.text,
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
