import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/bank_accounts_provider.dart';

class BankAccountsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const BankAccountsFormScreen({super.key, this.item});

  @override
  State<BankAccountsFormScreen> createState() => _BankAccountsFormScreenState();
}

class _BankAccountsFormScreenState extends State<BankAccountsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bankNameCtrl = TextEditingController();
  final _accountNumberCtrl = TextEditingController();
  final _accountHolderCtrl = TextEditingController();
  final _accountTypeCtrl = TextEditingController();
  final _currencyCtrl = TextEditingController(text: 'USD');

  @override
  void initState() {
    super.initState();
    if (widget.item != null) {
      _bankNameCtrl.text = widget.item!['bank_name']?.toString() ?? '';
      _accountNumberCtrl.text =
          widget.item!['account_number']?.toString() ?? '';
      _accountHolderCtrl.text =
          widget.item!['account_holder']?.toString() ?? '';
      _accountTypeCtrl.text = widget.item!['account_type']?.toString() ?? '';
      _currencyCtrl.text = widget.item!['currency']?.toString() ?? 'USD';
    }
  }

  @override
  void dispose() {
    _bankNameCtrl.dispose();
    _accountNumberCtrl.dispose();
    _accountHolderCtrl.dispose();
    _accountTypeCtrl.dispose();
    _currencyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<BankAccountsProvider>();
    final isEdit = widget.item != null;

    return Scaffold(
      appBar: AppBar(
          title: Text(
              isEdit ? 'Editar Cuenta Bancaria' : 'Nueva Cuenta Bancaria')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _bankNameCtrl,
                decoration: const InputDecoration(
                    labelText: 'Nombre del Banco',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _accountNumberCtrl,
                decoration: const InputDecoration(
                    labelText: 'Número de Cuenta',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(
                controller: _accountHolderCtrl,
                decoration: const InputDecoration(
                    labelText: 'Titular de la Cuenta',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                  labelText: 'Tipo de Cuenta',
                  border: OutlineInputBorder()),
              value: _accountTypeCtrl.text.isNotEmpty
                  ? _accountTypeCtrl.text
                  : null,
              items: const [
                DropdownMenuItem(value: 'ahorro', child: Text('Ahorro')),
                DropdownMenuItem(value: 'corriente', child: Text('Corriente')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _accountTypeCtrl.text = val);
                }
              },
            ),
            const SizedBox(height: 10),
            TextFormField(
                controller: _currencyCtrl,
                decoration: const InputDecoration(
                    labelText: 'Moneda',
                    border: OutlineInputBorder()),
                validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: prov.isLoading
                  ? null
                  : () async {
                      if (_formKey.currentState!.validate()) {
                        final req = {
                          'bank_name': _bankNameCtrl.text,
                          'account_number': _accountNumberCtrl.text,
                          'account_holder': _accountHolderCtrl.text,
                          'account_type': _accountTypeCtrl.text,
                          'currency': _currencyCtrl.text,
                        };
                        if (!isEdit) {
                          final res = await prov.create(req);
                          if (res && context.mounted) {
                            context.pop();
                          }
                          if (!res && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(prov.error ?? 'Error')));
                          }
                        } else {
                          final res =
                              await prov.update(widget.item!['id'], req);
                          if (res && context.mounted) {
                            context.pop();
                          }
                          if (!res && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        prov.error ?? 'Error al actualizar')));
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
