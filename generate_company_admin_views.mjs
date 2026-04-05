import fs from 'fs';
import path from 'path';

const projectDir = '/Users/julioamaya/Projects/carguito/carguito_app/lib';

const cruds = [
  { m: 'branches', t: 'Sucursales', fields: ['name', 'address'] },
  { m: 'sellers', t: 'Vendedores', fields: ['name', 'phone'] },
  { m: 'recipients', t: 'Destinatarios', fields: ['name', 'phone', 'address'] },
  { m: 'collection_points', t: 'Puntos de Recolección', fields: ['name', 'address'] },
  { m: 'delivery_points', t: 'Puntos de Entrega', fields: ['name', 'address'] },
  { m: 'packages', t: 'Paquetes', fields: ['description', 'weight', 'declared_value'] },
  { m: 'shipments', t: 'Envíos', fields: ['vehicle_plate', 'status'] },
  { m: 'bank_accounts', t: 'Cuentas Bancarias', fields: ['bank_name', 'account_number', 'account_type'] },
];

cruds.forEach(c => {
  const PascalCase = c.m.split('_').map(w => w[0].toUpperCase() + w.slice(1)).join('');

  // 1. Rewrite Provider to ensure it has update() and delete()
  const providerContent = "import 'package:flutter/material.dart';\n" +
"import '../../data/" + c.m + "_service.dart';\n\n" +
"class " + PascalCase + "Provider extends ChangeNotifier {\n" +
"  final " + PascalCase + "Service _service;\n" +
"  List<dynamic> items = [];\n" +
"  bool isLoading = false;\n" +
"  String? error;\n\n" +
"  " + PascalCase + "Provider(this._service);\n\n" +
"  Future<void> fetchAll() async {\n" +
"    isLoading = true;\n" +
"    error = null;\n" +
"    notifyListeners();\n" +
"    try {\n" +
"      items = await _service.getAll();\n" +
"    } catch (e) {\n" +
"      error = e.toString();\n" +
"    } finally {\n" +
"      isLoading = false;\n" +
"      notifyListeners();\n" +
"    }\n" +
"  }\n\n" +
"  Future<bool> create(Map<String, dynamic> data) async {\n" +
"    isLoading = true;\n" +
"    error = null;\n" +
"    notifyListeners();\n" +
"    try {\n" +
"      await _service.create(data);\n" +
"      await fetchAll();\n" +
"      return true;\n" +
"    } catch (e) {\n" +
"      error = e.toString();\n" +
"      isLoading = false;\n" +
"      notifyListeners();\n" +
"      return false;\n" +
"    }\n" +
"  }\n\n" +
"  Future<bool> update(String id, Map<String, dynamic> data) async {\n" +
"    isLoading = true;\n" +
"    error = null;\n" +
"    notifyListeners();\n" +
"    try {\n" +
"      await _service.update(id, data);\n" +
"      await fetchAll();\n" +
"      return true;\n" +
"    } catch (e) {\n" +
"      error = e.toString();\n" +
"      isLoading = false;\n" +
"      notifyListeners();\n" +
"      return false;\n" +
"    }\n" +
"  }\n\n" +
"  Future<bool> remove(String id) async {\n" +
"    isLoading = true;\n" +
"    error = null;\n" +
"    notifyListeners();\n" +
"    try {\n" +
"      await _service.delete(id);\n" +
"      await fetchAll();\n" +
"      return true;\n" +
"    } catch (e) {\n" +
"      error = e.toString();\n" +
"      isLoading = false;\n" +
"      notifyListeners();\n" +
"      return false;\n" +
"    }\n" +
"  }\n" +
"}\n";

  fs.writeFileSync(path.join(projectDir, "features/" + c.m + "/presentation/providers/" + c.m + "_provider.dart"), providerContent);

  // 2. Rewrite List Screen with Edit trailing and Delete Action
  const listScreenContent = "import 'package:flutter/material.dart';\n" +
"import 'package:provider/provider.dart';\n" +
"import 'package:go_router/go_router.dart';\n" +
"import '../providers/" + c.m + "_provider.dart';\n\n" +
"class " + PascalCase + "ListScreen extends StatefulWidget {\n" +
"  const " + PascalCase + "ListScreen({super.key});\n\n" +
"  @override\n" +
"  State<" + PascalCase + "ListScreen> createState() => _" + PascalCase + "ListScreenState();\n" +
"}\n\n" +
"class _" + PascalCase + "ListScreenState extends State<" + PascalCase + "ListScreen> {\n" +
"  @override\n" +
"  void initState() {\n" +
"    super.initState();\n" +
"    WidgetsBinding.instance.addPostFrameCallback((_) {\n" +
"      context.read<" + PascalCase + "Provider>().fetchAll();\n" +
"    });\n" +
"  }\n\n" +
"  @override\n" +
"  Widget build(BuildContext context) {\n" +
"    final provider = context.watch<" + PascalCase + "Provider>();\n" +
"    return Scaffold(\n" +
"      appBar: AppBar(title: const Text('" + c.t + "')),\n" +
"      body: provider.isLoading \n" +
"          ? const Center(child: CircularProgressIndicator())\n" +
"          : provider.error != null && provider.items.isEmpty\n" +
"              ? Center(child: Text(provider.error!))\n" +
"              : ListView.builder(\n" +
"                  itemCount: provider.items.length,\n" +
"                  itemBuilder: (context, index) {\n" +
"                    final item = provider.items[index];\n" +
"                    return ListTile(\n" +
"                      title: Text(item['name'] ?? item['bank_name'] ?? item['description'] ?? item['id'] ?? 'Dato'),\n" +
"                      subtitle: Text(item.toString()),\n" +
"                      trailing: Row(\n" +
"                        mainAxisSize: MainAxisSize.min,\n" +
"                        children: [\n" +
"                          IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => context.push('/" + c.m + "/edit', extra: item)),\n" +
"                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => showDialog(\n" +
"                            context: context,\n" +
"                            builder: (ctx) => AlertDialog(\n" +
"                              title: const Text('Confirmar Eliminación'),\n" +
"                              content: const Text('¿Desea eliminar permanentemente este registro?'),\n" +
"                              actions: [\n" +
"                                TextButton(child: const Text('Cancelar'), onPressed: () => ctx.pop()),\n" +
"                                TextButton(child: const Text('Eliminar'), onPressed: () { ctx.pop(); provider.remove(item['id']); })\n" +
"                              ]\n" +
"                            )\n" +
"                          )),\n" +
"                        ]\n" +
"                      ),\n" +
"                    );\n" +
"                  },\n" +
"                ),\n" +
"      floatingActionButton: FloatingActionButton(\n" +
"        child: const Icon(Icons.add),\n" +
"        onPressed: () => context.push('/" + c.m + "/new'),\n" +
"      ),\n" +
"    );\n" +
"  }\n" +
"}\n";

  fs.writeFileSync(path.join(projectDir, "features/" + c.m + "/presentation/screens/" + c.m + "_list_screen.dart"), listScreenContent);

  // 3. Create Form Screen dynamically
  const formScreenContent = "import 'package:flutter/material.dart';\n" +
"import 'package:provider/provider.dart';\n" +
"import 'package:go_router/go_router.dart';\n" +
"import '../providers/" + c.m + "_provider.dart';\n\n" +
"class " + PascalCase + "FormScreen extends StatefulWidget {\n" +
"  final Map<String, dynamic>? item;\n" +
"  const " + PascalCase + "FormScreen({super.key, this.item});\n\n" +
"  @override\n" +
"  State<" + PascalCase + "FormScreen> createState() => _" + PascalCase + "FormScreenState();\n" +
"}\n\n" +
"class _" + PascalCase + "FormScreenState extends State<" + PascalCase + "FormScreen> {\n" +
"  final _formKey = GlobalKey<FormState>();\n" +
  c.fields.map(f => "  final _" + f + "Ctrl = TextEditingController();").join('\n') + "\n\n" +
"  @override\n" +
"  void initState() {\n" +
"    super.initState();\n" +
"    if (widget.item != null) {\n" +
      c.fields.map(f => "      _" + f + "Ctrl.text = widget.item!['" + f + "']?.toString() ?? '';").join('\n') + "\n" +
"    }\n" +
"  }\n\n" +
"  @override\n" +
"  void dispose() {\n" +
      c.fields.map(f => "    _" + f + "Ctrl.dispose();").join('\n') + "\n" +
"    super.dispose();\n" +
"  }\n\n" +
"  @override\n" +
"  Widget build(BuildContext context) {\n" +
"    final prov = context.watch<" + PascalCase + "Provider>();\n" +
"    final isEdit = widget.item != null;\n\n" +
"    return Scaffold(\n" +
"      appBar: AppBar(title: Text(isEdit ? 'Editar " + c.t + "' : 'Nuevo " + c.t + "')),\n" +
"      body: Form(\n" +
"        key: _formKey,\n" +
"        child: ListView(\n" +
"          padding: const EdgeInsets.all(16),\n" +
"          children: [\n" +
            c.fields.map(f => "            TextFormField(controller: _" + f + "Ctrl, decoration: const InputDecoration(labelText: '" + f + "', border: OutlineInputBorder()), validator: (v) => v!.isEmpty ? 'Requerido' : null),").join('\n            const SizedBox(height: 10),\n') + "\n" +
"            const SizedBox(height: 24),\n" +
"            ElevatedButton(\n" +
"              onPressed: prov.isLoading ? null : () async {\n" +
"                if (_formKey.currentState!.validate()) {\n" +
"                  final req = {\n" +
                    c.fields.map(f => "                    '" + f + "': _" + f + "Ctrl.text,").join('\n') + "\n" +
"                  };\n" +
"                  if (!isEdit) {\n" +
"                    final res = await prov.create(req);\n" +
"                    if (res && context.mounted) context.pop();\n" +
"                    if (!res && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Error')));\n" +
"                  } else {\n" +
"                    final res = await prov.update(widget.item!['id'], req);\n" +
"                    if (res && context.mounted) context.pop();\n" +
"                    if (!res && context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(prov.error ?? 'Error al actualizar')));\n" +
"                  }\n" +
"                }\n" +
"              },\n" +
"              child: prov.isLoading\n" +
"                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))\n" +
"                  : const Text('Guardar'),\n" +
"            )\n" +
"          ],\n" +
"        ),\n" +
"      ),\n" +
"    );\n" +
"  }\n" +
"}\n";

  fs.writeFileSync(path.join(projectDir, "features/" + c.m + "/presentation/screens/" + c.m + "_form_screen.dart"), formScreenContent);

});

// Re-map Router to include /edit and /new for all the above views

let appRouter = fs.readFileSync(path.join(projectDir, 'core/router/app_router.dart'), 'utf8');

cruds.forEach(c => {
  const PascalCase = c.m.split('_').map(w => w[0].toUpperCase() + w.slice(1)).join('');
  
  if (!appRouter.includes(c.m + "_form_screen.dart")) {
    appRouter = appRouter.replace(
      "import '../../features/" + c.m + "/presentation/screens/" + c.m + "_list_screen.dart';",
      "import '../../features/" + c.m + "/presentation/screens/" + c.m + "_list_screen.dart';\nimport '../../features/" + c.m + "/presentation/screens/" + c.m + "_form_screen.dart';"
    );
  }

  // Find the basic list route and inject form routes alongside if missing
  const routeDeclaration = "GoRoute(path: '/" + c.m + "', builder: (_, __) => const " + PascalCase + "ListScreen()),";
  if (appRouter.includes(routeDeclaration) && !appRouter.includes("path: '/" + c.m + "/new'")) {
    appRouter = appRouter.replace(
      routeDeclaration,
      routeDeclaration + "\n      GoRoute(path: '/" + c.m + "/new', builder: (_, __) => const " + PascalCase + "FormScreen()),\n      GoRoute(path: '/" + c.m + "/edit', builder: (context, state) => " + PascalCase + "FormScreen(item: state.extra as Map<String,dynamic>)),"
    );
  }
});

fs.writeFileSync(path.join(projectDir, 'core/router/app_router.dart'), appRouter);

console.log('Company Admin UI Full Views Generated Successfully');
