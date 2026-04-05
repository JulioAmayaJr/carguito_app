import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/shipments_provider.dart';
import '../../../packages/presentation/providers/packages_provider.dart';
import '../../../vehicles/presentation/providers/vehicles_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/access/role_capabilities.dart';

class ShipmentsFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const ShipmentsFormScreen({super.key, this.item});

  @override
  State<ShipmentsFormScreen> createState() => _ShipmentsFormScreenState();
}

class _ShipmentsFormScreenState extends State<ShipmentsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _odometerCtrl = TextEditingController();
  String? _selectedPackageId;
  final Set<String> _selectedPackageIds = {};
  String? _selectedVehicleId;
  bool _isInitialized = false;

  static bool _isDelivered(dynamic status) {
    final v = status?.toString().trim().toLowerCase() ?? '';
    return v == 'delivered' || v == 'cancelled';
  }

  Set<String> _packageIdsInTransit(List<dynamic> shipments) {
    final out = <String>{};
    for (final s in shipments) {
      if (s is! Map) continue;
      final st = s['status']?.toString();
      if (st == 'in_transit') {
        final pid = s['package_id']?.toString();
        if (pid != null) out.add(pid);
      }
    }
    return out;
  }

  bool _packageSelectable(
    Map<String, dynamic> p,
    Set<String> inTransitIds,
  ) {
    if (_isDelivered(p['status'])) return false;
    final id = p['id']?.toString();
    if (id == null) return false;
    if (inTransitIds.contains(id)) return false;
    return true;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final packagesProv = context.read<PackagesProvider>();
      final vehiclesProv = context.read<VehiclesProvider>();
      final shipmentsProv = context.read<ShipmentsProvider>();

      await Future.wait([
        packagesProv.fetchAll(),
        shipmentsProv.fetchAll(),
        vehiclesProv.fetchAll(activeOnly: true),
      ]);

      if (widget.item != null) {
        _selectedPackageId = widget.item!['package_id']?.toString();
        _selectedVehicleId = widget.item!['vehicle_id']?.toString();
        _odometerCtrl.text = widget.item!['odometer']?.toString() ?? '';
      } else {
        _odometerCtrl.text = '';
      }

      if (mounted) {
        setState(() => _isInitialized = true);
      }
    });
  }

  @override
  void dispose() {
    _odometerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsProv = context.watch<ShipmentsProvider>();
    final packagesProv = context.watch<PackagesProvider>();
    final vehiclesProv = context.watch<VehiclesProvider>();
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    final isDriver = user != null && RoleCapabilities.isDriverUser(user);
    final isEdit = widget.item != null;

    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final inTransit = _packageIdsInTransit(shipmentsProv.items);
    final selectablePackages = packagesProv.items
        .whereType<Map<String, dynamic>>()
        .where((p) => _packageSelectable(p, inTransit))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Registro' : 'Nuevo Check-in de Ruta'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Información del Envío',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
              ),
            ),
            const SizedBox(height: 16),
            if (isEdit) ...[
              DropdownButtonFormField<String>(
                value: _selectedPackageId,
                decoration: const InputDecoration(
                  labelText: 'Paquete',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                items: packagesProv.items
                    .map((p) => DropdownMenuItem<String>(
                          value: p['id'].toString(),
                          child: Text(
                            '${p['package_code']} - ${p['description'] ?? 'Sin desc.'}',
                          ),
                        ))
                    .toList(),
                onChanged: null,
              ),
            ] else ...[
              Text(
                isDriver
                    ? 'Seleccione los paquetes que transportará'
                    : 'Seleccione uno o más paquetes',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
              ),
              const SizedBox(height: 8),
              if (selectablePackages.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No hay paquetes disponibles para asignar a una ruta (ya en tránsito o entregados).',
                    style: TextStyle(color: Color(0xFF6B7280)),
                  ),
                )
              else
                ...selectablePackages.map((p) {
                  final id = p['id'].toString();
                  final selected = _selectedPackageIds.contains(id);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (v) {
                      setState(() {
                        if (v == true) {
                          _selectedPackageIds.add(id);
                        } else {
                          _selectedPackageIds.remove(id);
                        }
                      });
                    },
                    title: Text(
                      '${p['package_code']} — ${p['description'] ?? 'Sin desc.'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  );
                }),
            ],
            const SizedBox(height: 20),
            if (!isEdit && isDriver) ...[
              DropdownButtonFormField<String>(
                value: vehiclesProv.items.any(
                        (v) => v['id'].toString() == _selectedVehicleId)
                    ? _selectedVehicleId
                    : null,
                decoration: const InputDecoration(
                  labelText: 'Vehículo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  prefixIcon: Icon(Icons.directions_car_outlined),
                ),
                items: vehiclesProv.items
                    .map((v) => DropdownMenuItem<String>(
                          value: v['id'].toString(),
                          child: Text(
                            '${v['plate']}${v['description'] != null && v['description'].toString().isNotEmpty ? ' — ${v['description']}' : ''}',
                          ),
                        ))
                    .toList(),
                onChanged: (val) =>
                    setState(() => _selectedVehicleId = val),
                validator: (v) =>
                    isDriver && (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              if (vehiclesProv.items.isEmpty && !vehiclesProv.isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'No hay vehículos activos. Un administrador debe dar de alta la flota en Ajustes → Vehículos.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF92400E)),
                  ),
                ),
              const SizedBox(height: 20),
            ],
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.speed_rounded, color: Color(0xFFF4B83A)),
                      SizedBox(width: 8),
                      Text(
                        'Odómetro',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _odometerCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Odómetro actual (km)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      hintText: 'Millaje actual',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Requerido para check-in' : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: shipmentsProv.isLoading
                  ? null
                  : () async {
                      if (!_formKey.currentState!.validate()) return;

                      if (!isEdit) {
                        if (_selectedPackageIds.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Seleccione al menos un paquete',
                              ),
                            ),
                          );
                          return;
                        }
                        if (isDriver &&
                            (_selectedVehicleId == null ||
                                _selectedVehicleId!.isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Seleccione un vehículo'),
                            ),
                          );
                          return;
                        }
                      }

                      final req = <String, dynamic>{
                        'odometer': int.tryParse(_odometerCtrl.text) ?? 0,
                        'status': 'in_transit',
                        'driver_id': auth.user?.id,
                      };

                      if (!isEdit) {
                        req['package_ids'] = _selectedPackageIds.toList();
                        if (_selectedVehicleId != null) {
                          req['vehicle_id'] = _selectedVehicleId;
                        }
                      } else {
                        req['package_id'] = _selectedPackageId;
                        if (_selectedVehicleId != null) {
                          req['vehicle_id'] = _selectedVehicleId;
                        }
                      }

                      bool res;
                      if (!isEdit) {
                        res = await shipmentsProv.create(req);
                      } else {
                        res = await shipmentsProv.update(widget.item!['id'], req);
                      }

                      if (res && context.mounted) {
                        context.pop();
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              shipmentsProv.error ?? 'Error en el registro',
                            ),
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF4B83A),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: shipmentsProv.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      isEdit
                          ? 'Actualizar Registro'
                          : 'Confirmar Check-in y Salida',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Al confirmar, el cliente recibirá una notificación de que su paquete está en ruta.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF9CA3AF)),
            ),
          ],
        ),
      ),
    );
  }
}
