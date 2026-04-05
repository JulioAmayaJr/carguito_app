import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/vehicles_provider.dart';

class VehiclesFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const VehiclesFormScreen({super.key, this.item});

  @override
  State<VehiclesFormScreen> createState() => _VehiclesFormScreenState();
}

class _VehiclesFormScreenState extends State<VehiclesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _plateCtrl.text = widget.item!['plate']?.toString() ?? '';
      _descriptionCtrl.text = widget.item!['description']?.toString() ?? '';
      _isActive = widget.item!['is_active'] != false;
    }
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<VehiclesProvider>();
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar vehículo' : 'Nuevo vehículo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _plateCtrl,
              decoration: const InputDecoration(
                labelText: 'Placas',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionCtrl,
              decoration: const InputDecoration(
                labelText: 'Descripción (opcional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            if (isEdit) ...[
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Activo'),
                subtitle: const Text(
                  'Los vehículos inactivos no se ofrecen en el check-in',
                ),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;
                      final data = <String, dynamic>{
                        'plate': _plateCtrl.text.trim(),
                        'description': _descriptionCtrl.text.trim(),
                      };
                      if (isEdit) data['is_active'] = _isActive;

                      final ok = isEdit
                          ? await prov.update(
                              widget.item!['id'].toString(), data)
                          : await prov.create(data);

                      if (!context.mounted) return;
                      if (ok) {
                        context.pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(prov.error ?? 'Error al guardar'),
                          ),
                        );
                      }
                    },
              child: prov.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Guardar' : 'Crear'),
            ),
          ],
        ),
      ),
    );
  }
}
