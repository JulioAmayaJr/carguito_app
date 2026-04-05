import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/employees_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class EmployeesFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const EmployeesFormScreen({super.key, this.item});

  @override
  State<EmployeesFormScreen> createState() => _EmployeesFormScreenState();
}

class _EmployeesFormScreenState extends State<EmployeesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _roleCtrl = TextEditingController(text: 'driver');

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _roleCtrl.text = widget.item!['employee_role']?.toString() ?? 'driver';
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<EmployeesProvider>();
    final auth = context.read<AuthProvider>();
    final isEdit = widget.item != null;

    return Scaffold(
      appBar:
          AppBar(title: Text(isEdit ? 'Editar Empleado' : 'Nuevo Empleado')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (!isEdit) ...[
              TextFormField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Email (Login)', border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _passCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Contraseña', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Nombre Completo',
                      border: OutlineInputBorder()),
                  validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
            ],
            TextFormField(
                controller: _roleCtrl,
                decoration: const InputDecoration(
                    labelText: 'Rol (admin, driver, receiver)',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final req = {
                          'employee_role': _roleCtrl.text,
                          'company_id': auth.user?.toJson()['company_id'],
                        };
                        if (!isEdit) {
                          req['user_email'] = _emailCtrl.text;
                          req['user_password'] = _passCtrl.text;
                          req['user_full_name'] = _nameCtrl.text;
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
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(prov.error ?? 'Error')));
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
