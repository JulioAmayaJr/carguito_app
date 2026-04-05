import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/platform_provider.dart';

class PlatformConfigScreen extends StatefulWidget {
  const PlatformConfigScreen({super.key});

  @override
  State<PlatformConfigScreen> createState() => _PlatformConfigScreenState();
}

class _PlatformConfigScreenState extends State<PlatformConfigScreen> {
  final _feeCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accountCtrl = TextEditingController();
  final _holderCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlatformProvider>().loadData().then((_) {
        final prov = context.read<PlatformProvider>();
        final fee =
            prov.config['default_service_fee_amount']?.toString() ?? '0';
        _feeCtrl.text = fee;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PlatformProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración Plataforma')),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Tarifa (Fee) Global por Envío',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(
                    controller: _feeCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Monto (USD)', border: OutlineInputBorder()),
                    keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => prov.updateConfig(
                      double.tryParse(_feeCtrl.text) ?? 0, 'USD'),
                  child: const Text('Guardar Tarifa'),
                ),
                const Divider(height: 40),
                const Text('Cuentas Bancarias de Plataforma',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...prov.accounts.map((b) => ListTile(
                      title: Text("${b['bank_name']} - ${b['account_number']}"),
                      subtitle: Text(b['account_holder']),
                      leading: const Icon(Icons.account_balance),
                    )),
                const SizedBox(height: 20),
                const Text('Agregar Cuenta',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(
                    controller: _bankCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Banco', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                    controller: _accountCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Número / CLABE',
                        border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(
                    controller: _holderCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Titular', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    prov.addAccount({
                      'bank_name': _bankCtrl.text,
                      'account_number': _accountCtrl.text,
                      'account_holder': _holderCtrl.text,
                      'account_type': 'Checking',
                      'currency': 'USD'
                    }).then((v) {
                      if (v) {
                        _bankCtrl.clear();
                        _accountCtrl.clear();
                        _holderCtrl.clear();
                      }
                    });
                  },
                  child: const Text('Agregar Banco'),
                ),
              ],
            ),
    );
  }
}
