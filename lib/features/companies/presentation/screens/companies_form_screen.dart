import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/companies_provider.dart';

class CompaniesFormScreen extends StatefulWidget {
  final Map<String, dynamic>? company;
  const CompaniesFormScreen({super.key, this.company});

  @override
  State<CompaniesFormScreen> createState() => _CompaniesFormScreenState();
}

class _CompaniesFormScreenState extends State<CompaniesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _legalCtrl = TextEditingController();
  final _rucCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  final _adminEmailCtrl = TextEditingController();
  final _adminPassCtrl = TextEditingController();
  final _adminNameCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameCtrl.text = widget.company!['name'] ?? '';
      _legalCtrl.text = widget.company!['legal_name'] ?? '';
      _rucCtrl.text = widget.company!['ruc_nit'] ?? '';
      _emailCtrl.text = widget.company!['email'] ?? '';
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _legalCtrl.dispose();
    _rucCtrl.dispose();
    _emailCtrl.dispose();
    _adminEmailCtrl.dispose();
    _adminPassCtrl.dispose();
    _adminNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CompaniesProvider>();
    final isEdit = widget.company != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Empresa' : 'Nueva Empresa')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Datos Base',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre Comercial',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _legalCtrl,
                decoration: const InputDecoration(
                    labelText: 'Razón Social', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _rucCtrl,
                decoration: const InputDecoration(
                    labelText: 'RUC / NIT', border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                    labelText: 'Email de Contacto',
                    border: OutlineInputBorder())),
            if (!isEdit) ...[
              const Divider(height: 40),
              const Text('Admin de la Empresa',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Se configurará automáticamente',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _adminNameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nombre del Admin',
                      border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _adminEmailCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Email del Admin (Login)',
                      border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _adminPassCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        if (!isEdit) {
                          final req = {
                            'name': _nameCtrl.text,
                            'legal_name': _legalCtrl.text,
                            'ruc_nit': _rucCtrl.text,
                            'email': _emailCtrl.text,
                            'admin_full_name': _adminNameCtrl.text,
                            'admin_email': _adminEmailCtrl.text,
                            'admin_password': _adminPassCtrl.text,
                          };

                          final res = await prov.create(req);
                          if (res && context.mounted) context.pop();
                          if (!res && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(prov.error ?? 'Error')));
                          }
                        } else {
                          final updatedData = {
                            'name': _nameCtrl.text,
                            'legal_name': _legalCtrl.text,
                            'ruc_nit': _rucCtrl.text,
                            'email': _emailCtrl.text,
                          };

                          final res = await prov.update(
                              widget.company!['id'], updatedData);
                          if (res && context.mounted) context.pop();
                          if (!res && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content:
                                    Text(prov.error ?? 'Error al actualizar')));
                          }
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
