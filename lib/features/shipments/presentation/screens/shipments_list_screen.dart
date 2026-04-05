import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:carguito_app/core/auth/role_access.dart';
import 'package:carguito_app/core/utils/role_bottom_menu.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/shipments_provider.dart';

class ShipmentsListScreen extends StatefulWidget {
  const ShipmentsListScreen({super.key});

  @override
  State<ShipmentsListScreen> createState() => _ShipmentsListScreenState();
}

class _ShipmentsListScreenState extends State<ShipmentsListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ShipmentsProvider>().fetchAll();
    });
  }

  String _shipmentCode(Map<String, dynamic> item) {
    final candidates = [
      item['shipment_code'],
      item['route_code'],
      item['code'],
      item['tracking_code'],
      item['name'],
      item['id'],
    ];
    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text.toUpperCase();
    }
    return 'ENVÍO';
  }

  String _statusLabel(dynamic status) {
    final value = status?.toString().trim().toLowerCase() ?? '';
    switch (value) {
      case 'completed':
      case 'completado':
      case 'done':
      case 'finished':
      case 'finalizado':
      case 'delivered':
      case 'entregado':
        return 'Entregado';
      case 'in_progress':
      case 'in progress':
      case 'en_progreso':
      case 'en progreso':
      case 'transit':
      case 'in_transit':
      case 'en tránsito':
      case 'en transito':
        return 'En tránsito';
      case 'pending':
      case 'pendiente':
        return 'Pendiente';
      case 'cancelled':
      case 'cancelado':
        return 'Cancelado';
      default:
        return value.isEmpty ? 'Pendiente' : value;
    }
  }

  Color _statusBg(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return const Color(0xFFE8F5D9);
      case 'en tránsito':
        return const Color(0xFFEFF3F6);
      case 'cancelado':
        return const Color(0xFFFDE8E8);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _statusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return const Color(0xFF6FA329);
      case 'en tránsito':
        return const Color(0xFF64748B);
      case 'cancelado':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF64748B);
    }
  }

  String _originText(Map<String, dynamic> item) {
    final candidates = [
      item['from_address'],
      item['origin_address'],
      item['pickup_address'],
      item['collection_address'],
      item['origin'],
      item['from'],
    ];
    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return 'Sin origen';
  }

  String _destinationText(Map<String, dynamic> item) {
    final candidates = [
      item['to_address'],
      item['destination_address'],
      item['delivery_address'],
      item['dropoff_address'],
      item['destination'],
      item['to'],
    ];
    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return 'Sin destino';
  }

  String _dateText(Map<String, dynamic> item) {
    final candidates = [
      item['scheduled_time'],
      item['scheduled_date'],
      item['shipment_date'],
      item['delivery_date'],
      item['pickup_date'],
      item['created_at'],
    ];
    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return 'Por definir';
  }

  String _packagesCount(Map<String, dynamic> item) {
    final candidates = [
      item['packages_count'],
      item['package_count'],
      item['qty'],
      item['quantity'],
      item['total_packages'],
    ];
    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) return text;
    }
    return '0';
  }

  List<Map<String, dynamic>> _filteredItems(List<dynamic> rawItems) {
    final items = rawItems.cast<Map<String, dynamic>>();
    if (_search.trim().isEmpty) return items;
    final query = _search.trim().toLowerCase();
    return items.where((item) {
      final fields = [
        _shipmentCode(item),
        _originText(item),
        _destinationText(item),
        _statusLabel(item['status']),
      ];
      return fields.any((field) => field.toLowerCase().contains(query));
    }).toList();
  }

  List<Map<String, dynamic>> _activeItems(List<Map<String, dynamic>> items) {
    return items.where((item) {
      final status = _statusLabel(item['status']).toLowerCase();
      return status != 'entregado' && status != 'cancelado';
    }).toList();
  }

  void _showShipmentActions(
    BuildContext context,
    Map<String, dynamic> item,
    ShipmentsProvider provider,
  ) {
    final auth = context.read<AuthProvider>();
    final isDriver = RoleAccess.isDriverUser(auth.user);
    final isInTransit = _statusLabel(item['status']).toLowerCase() == 'en tránsito';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 46,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _shipmentCode(item),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 18),
              
              if (isDriver && isInTransit) ...[
                _ShipmentActionTile(
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: const Color(0xFF10B981),
                  title: 'Confirmar Entrega',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(AppRoutes.shipmentsDelivery, extra: item);
                  },
                ),
                const SizedBox(height: 10),
              ],

              if (RoleAccess.canManageShipments(auth.user)) ...[
                _ShipmentActionTile(
                  icon: Icons.edit_outlined,
                  iconColor: const Color(0xFFF4A91F),
                  title: 'Editar envío',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    context.push(AppRoutes.shipmentsEdit, extra: item);
                  },
                ),
                const SizedBox(height: 10),
                _ShipmentActionTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFDC2626),
                  title: 'Eliminar envío',
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Confirmar eliminación'),
                        content: const Text('¿Desea eliminar este registro?'),
                        actions: [
                          TextButton(
                            onPressed: () => ctx.pop(),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              ctx.pop();
                              provider.remove(item['id']);
                            },
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ShipmentsProvider>();
    final auth = context.read<AuthProvider>();
    final isDriver = RoleAccess.isDriverUser(auth.user);
    final canManageShipments = RoleAccess.canManageShipments(auth.user);

    final filteredItems = _filteredItems(provider.items);
    final activeItems = _activeItems(filteredItems);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      floatingActionButton: canManageShipments
        ? FloatingActionButton(
            onPressed: () => context.push(AppRoutes.shipmentsNew),
            backgroundColor: const Color(0xFFF4A91F),
            elevation: 6,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
          )
        : null,
      bottomNavigationBar: const RoleBottomMenu(),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null && provider.items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        provider.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 110),
                    children: [
                      _TopIllustrationCard(
                        showLogisticsShortcuts: RoleAccess.canNavigate(
                            auth.user, AppRoutes.collectionPoints),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mis envíos',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Administra y da seguimiento a tus envíos',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF7A7F87),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (value) => setState(() => _search = value),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: Color(0xFF9CA3AF),
                              size: 28,
                            ),
                            hintText: 'Buscar envío...',
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Activos',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2B2B2B),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (activeItems.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE5E7EB)),
                          ),
                          child: const Text(
                            'No hay envíos activos.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 15,
                              color: Color(0xFF6B7280),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        ...activeItems.map(
                          (item) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ShipmentCard(
                              shipmentCode: _shipmentCode(item),
                              statusLabel: _statusLabel(item['status']),
                              statusBg: _statusBg(_statusLabel(item['status'])),
                              statusTextColor: _statusTextColor(_statusLabel(item['status'])),
                              originText: _originText(item),
                              destinationText: _destinationText(item),
                              dateText: _dateText(item),
                              packagesCount: _packagesCount(item),
                              onTap: () => _showShipmentActions(context, item, provider),
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _TopIllustrationCard extends StatelessWidget {
  const _TopIllustrationCard({this.showLogisticsShortcuts = true});

  final bool showLogisticsShortcuts;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 172,
            width: double.infinity,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
              image: DecorationImage(
                image: AssetImage('assets/shiping/shiping1.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          if (showLogisticsShortcuts)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: _QuickRouteCard(
                      title: 'Puntos de\nrecolecta',
                      onTap: () => context.push(AppRoutes.collectionPoints),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _QuickRouteCard(
                      title: 'Puntos de\nentrega',
                      onTap: () => context.push(AppRoutes.deliveryPoints),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickRouteCard extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _QuickRouteCard({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4DF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFF4A91F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2B2B2B),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFFC4C7CE)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShipmentCard extends StatelessWidget {
  final String shipmentCode;
  final String statusLabel;
  final Color statusBg;
  final Color statusTextColor;
  final String originText;
  final String destinationText;
  final String dateText;
  final String packagesCount;
  final VoidCallback onTap;

  const _ShipmentCard({
    required this.shipmentCode,
    required this.statusLabel,
    required this.statusBg,
    required this.statusTextColor,
    required this.originText,
    required this.destinationText,
    required this.dateText,
    required this.packagesCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF2F343B);
    const textMuted = Color(0xFF68707B);
    const divider = Color(0xFFE8EAEE);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4DF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.local_shipping_rounded,
                      size: 28,
                      color: Color(0xFFF4A91F),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      shipmentCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: textDark,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: statusTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.circle, size: 9, color: Color(0xFFF4B43A)),
                  const SizedBox(width: 8),
                  Text(
                    packagesCount,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFF4A91F),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      originText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: textDark,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFFB4B9C1), size: 28),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: divider, height: 1),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, size: 20, color: Color(0xFFF4A91F)),
                  const SizedBox(width: 6),
                  const Text(
                    'De',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textDark),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      destinationText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textDark),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      dateText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: textMuted),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShipmentActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ShipmentActionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF8FAFC),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}