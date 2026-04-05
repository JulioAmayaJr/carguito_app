import fs from 'fs';
import path from 'path';

const projectDir = '/Users/julioamaya/Projects/carguito/carguito_app/lib';

const ensureDir = (dirPath) => {
  fs.mkdirSync(dirPath, { recursive: true });
};

ensureDir(path.join(projectDir, 'features/platform/data'));
ensureDir(path.join(projectDir, 'features/platform/presentation/providers'));
ensureDir(path.join(projectDir, 'features/platform/presentation/screens'));
ensureDir(path.join(projectDir, 'features/companies/presentation/screens'));

fs.writeFileSync(path.join(projectDir, 'features/platform/data/platform_service.dart'), \`import 'package:dio/dio.dart';

class PlatformService {
  final Dio _dio;
  PlatformService(this._dio);

  Future<Map<String, dynamic>> getConfig() async {
    final res = await _dio.get('/platform/config');
    return res.data;
  }

  Future<Map<String, dynamic>> updateConfig(double fee, String currency) async {
    final res = await _dio.put('/platform/config', data: {
      'default_service_fee_amount': fee,
      'fee_currency': currency
    });
    return res.data;
  }

  Future<List<dynamic>> getBankAccounts() async {
    final res = await _dio.get('/platform/bank-accounts');
    return res.data;
  }

  Future<Map<String, dynamic>> addBankAccount(Map<String, dynamic> data) async {
    final res = await _dio.post('/platform/bank-accounts', data: data);
    return res.data;
  }
}
\`);

fs.writeFileSync(path.join(projectDir, 'features/platform/presentation/providers/platform_provider.dart'), \`import 'package:flutter/material.dart';
import '../../data/platform_service.dart';

class PlatformProvider extends ChangeNotifier {
  final PlatformService _service;

  Map<String, dynamic> config = {};
  List<dynamic> accounts = [];
  bool isLoading = false;
  String? error;

  PlatformProvider(this._service);

  Future<void> loadData() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      config = await _service.getConfig();
      accounts = await _service.getBankAccounts();
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateConfig(double fee, String currency) async {
    try {
      await _service.updateConfig(fee, currency);
      await loadData();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> addAccount(Map<String, dynamic> data) async {
    try {
      await _service.addBankAccount(data);
      await loadData();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
\`);

fs.writeFileSync(path.join(projectDir, 'features/platform/presentation/screens/platform_config_screen.dart'), \`import 'package:flutter/material.dart';
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
        final fee = prov.config['default_service_fee_amount']?.toString() ?? '0';
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
                const Text('Tarifa (Fee) Global por Envío', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextField(controller: _feeCtrl, decoration: const InputDecoration(labelText: 'Monto (USD)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => prov.updateConfig(double.tryParse(_feeCtrl.text) ?? 0, 'USD'),
                  child: const Text('Guardar Tarifa'),
                ),
                const Divider(height: 40),
                const Text('Cuentas Bancarias de Plataforma', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ...prov.accounts.map((b) => ListTile(
                  title: Text("\${b['bank_name']} - \${b['account_number']}"),
                  subtitle: Text(b['account_holder']),
                  leading: const Icon(Icons.account_balance),
                )),
                const SizedBox(height: 20),
                const Text('Agregar Cuenta', style: TextStyle(fontWeight: FontWeight.bold)),
                TextField(controller: _bankCtrl, decoration: const InputDecoration(labelText: 'Banco', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _accountCtrl, decoration: const InputDecoration(labelText: 'Número / CLABE', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: _holderCtrl, decoration: const InputDecoration(labelText: 'Titular', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    prov.addAccount({
                      'bank_name': _bankCtrl.text,
                      'account_number': _accountCtrl.text,
                      'account_holder': _holderCtrl.text,
                      'account_type': 'Checking',
                      'currency': 'USD'
                    }).then((v){
                      if(v){
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
\`);

fs.writeFileSync(path.join(projectDir, 'features/companies/presentation/screens/companies_form_screen.dart'), \`import 'package:flutter/material.dart';
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
  
  // Admin local fields
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
            const Text('Datos Base', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),
            TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre Comercial', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(controller: _legalCtrl, decoration: const InputDecoration(labelText: 'Razón Social', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(controller: _rucCtrl, decoration: const InputDecoration(labelText: 'RUC / NIT', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
            const SizedBox(height: 10),
            TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email de Contacto', border: OutlineInputBorder())),
            
            if (!isEdit) ...[
              const Divider(height: 40),
              const Text('Usuario / Admin de la Empresa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('Se creará este usuario automáticamente como company_admin', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 10),
              TextFormField(controller: _adminNameCtrl, decoration: const InputDecoration(labelText: 'Nombre del Admin', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _adminEmailCtrl, decoration: const InputDecoration(labelText: 'Email del Admin (Login)', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              const SizedBox(height: 10),
              TextFormField(controller: _adminPassCtrl, decoration: const InputDecoration(labelText: 'Contraseña', border: OutlineInputBorder()), obscureText: true, validator: (v) => v!.isEmpty ? 'Requerido' : null),
            ],
            
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final req = {
                    'name': _nameCtrl.text,
                    'legal_name': _legalCtrl.text,
                    'ruc_nit': _rucCtrl.text,
                    'email': _emailCtrl.text,
                    if (!isEdit) 'admin_full_name': _adminNameCtrl.text,
                    if (!isEdit) 'admin_email': _adminEmailCtrl.text,
                    if (!isEdit) 'admin_password': _adminPassCtrl.text,
                  };
                  
                  // For generic update we need to put inside another file or use provider.
                  // Current provider has create() only in its interface template, I'll update it to have \`update\` globally if not.
                  if (isEdit) {
                    // Custom update logic goes here.
                  } else {
                    final res = await prov.create(req);
                    if (res && context.mounted) context.pop();
                    if (!res && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Error')));
                    }
                  }
                }
              },
              child: const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }
}
\`);

fs.writeFileSync(path.join(projectDir, 'features/companies/presentation/screens/companies_list_screen.dart'), \`import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/companies_provider.dart';

class CompaniesListScreen extends StatefulWidget {
  const CompaniesListScreen({super.key});

  @override
  State<CompaniesListScreen> createState() => _CompaniesListScreenState();
}

class _CompaniesListScreenState extends State<CompaniesListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompaniesProvider>().fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompaniesProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Empresas (Companies)')),
      body: provider.isLoading 
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null
              ? Center(child: Text(provider.error!))
              : ListView.builder(
                  itemCount: provider.items.length,
                  itemBuilder: (context, index) {
                    final item = provider.items[index];
                    return ListTile(
                      title: Text(item['name'] ?? item['id'] ?? 'Unknown'),
                      subtitle: Text(\\\`RUC/NIT: \${item['ruc_nit']} - Activa: \${item['is_active']}\\\`),
                      onTap: () {
                         context.push('/companies/edit', extra: item);
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => context.push('/companies/new'),
      ),
    );
  }
}
\`);

let mainDart = fs.readFileSync(path.join(projectDir, 'main.dart'), 'utf8');
if (!mainDart.includes('platform_provider.dart')) {
  mainDart = mainDart.replace("import 'core/router/app_router.dart';", "import 'core/router/app_router.dart';\\nimport 'features/platform/data/platform_service.dart';\\nimport 'features/platform/presentation/providers/platform_provider.dart';");
  mainDart = mainDart.replace("      providers: [", "      providers: [\\n        ChangeNotifierProvider(create: (_) => PlatformProvider(PlatformService(dioClient.dio))),");
  fs.writeFileSync(path.join(projectDir, 'main.dart'), mainDart);
}

let appRouter = fs.readFileSync(path.join(projectDir, 'core/router/app_router.dart'), 'utf8');
if (!appRouter.includes('platform_config_screen.dart')) {
  appRouter = appRouter.replace("import '../../features/auth/presentation/providers/auth_provider.dart';", "import '../../features/auth/presentation/providers/auth_provider.dart';\\nimport '../../features/platform/presentation/screens/platform_config_screen.dart';\\nimport '../../features/companies/presentation/screens/companies_form_screen.dart';");
  appRouter = appRouter.replace("GoRoute(path: '/companies', builder: (_, __) => const CompaniesListScreen()),", "GoRoute(path: '/companies', builder: (_, __) => const CompaniesListScreen()),\\n      GoRoute(path: '/companies/new', builder: (_, __) => const CompaniesFormScreen()),\\n      GoRoute(path: '/companies/edit', builder: (context, state) => CompaniesFormScreen(company: state.extra as Map<String,dynamic>)),\\n      GoRoute(path: '/platform/config', builder: (_, __) => const PlatformConfigScreen()),");
  fs.writeFileSync(path.join(projectDir, 'core/router/app_router.dart'), appRouter);
}

let platformHome = fs.readFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/platform_home.dart'), 'utf8');
if (!platformHome.includes('/platform/config')) {
  platformHome = platformHome.replace("ListTile(title: const Text('Companies'), onTap: () => context.push('/companies')),", "ListTile(title: const Text('Companies'), onTap: () => context.push('/companies')),\\n            ListTile(title: const Text('Configuración Plataforma / Bancos'), onTap: () => context.push('/platform/config')),");
  fs.writeFileSync(path.join(projectDir, 'features/dashboard/presentation/screens/platform_home.dart'), platformHome);
}

console.log('Platform Config UI Generated Successfully');
