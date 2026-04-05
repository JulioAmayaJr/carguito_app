import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:carguito_app/core/auth/role_access.dart';
import 'package:carguito_app/core/utils/role_bottom_menu.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/packages_provider.dart';

class PackagesListScreen extends StatefulWidget {
  const PackagesListScreen({super.key});

  @override
  State<PackagesListScreen> createState() => _PackagesListScreenState();
}

class _PackagesListScreenState extends State<PackagesListScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PackagesProvider>().fetchAll();
    });
  }

  String _packageCode(Map<String, dynamic> item) {
    final code = item['package_code']?.toString().trim();
    final id = item['id']?.toString().trim();
    final desc = item['description']?.toString().trim();

    if (code != null && code.isNotEmpty) {
      return code.toUpperCase();
    }
    if (id != null && id.isNotEmpty) {
      return id.toUpperCase();
    }
    if (desc != null && desc.isNotEmpty) {
      return desc;
    }
    return 'PAQUETE';
  }

  String _statusLabel(dynamic status) {
    final value = status?.toString().trim().toLowerCase() ?? '';

    switch (value) {
      case 'delivered':
      case 'entregado':
      case 'completed':
      case 'completado':
        return 'Delivered';
      case 'in_transit':
      case 'in transit':
      case 'transit':
      case 'en_transito':
      case 'en tránsito':
      case 'en transito':
        return 'In Transit';
      case 'draft':
        return 'Borrador';
      case 'pending':
        return 'Pendiente';
      default:
        return value.isEmpty ? 'Pendiente' : value;
    }
  }

  bool _isDelivered(dynamic status) {
    final value = status?.toString().trim().toLowerCase() ?? '';
    return value == 'delivered' ||
        value == 'entregado' ||
        value == 'completed' ||
        value == 'completado';
  }

  String _fromText(Map<String, dynamic> item) {
    final candidates = [
      item['from_address'],
      item['origin_address'],
      item['pickup_address'],
      item['collection_address'],
      item['sender_address'],
      item['from'],
      item['origin'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return 'Sin origen';
  }

  String _toText(Map<String, dynamic> item) {
    final candidates = [
      item['to_address'],
      item['destination_address'],
      item['delivery_address'],
      item['recipient_address'],
      item['to'],
      item['destination'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return 'Sin destino';
  }

  String _dateText(Map<String, dynamic> item, bool delivered) {
    final candidates = delivered
        ? [
            item['delivered_at'],
            item['delivery_date'],
            item['updated_at'],
            item['date'],
          ]
        : [
            item['estimated_delivery'],
            item['estimated_delivery_at'],
            item['eta'],
            item['delivery_date'],
            item['created_at'],
          ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return delivered ? 'No disponible' : 'Por definir';
  }

  List<Map<String, dynamic>> _filteredItems(List<Map<String, dynamic>> items) {
    if (_selectedFilter == 'all') {
      return items;
    }
    if (_selectedFilter == 'in_transit') {
      return items.where((item) => !_isDelivered(item['status'])).toList();
    }
    if (_selectedFilter == 'delivered') {
      return items.where((item) => _isDelivered(item['status'])).toList();
    }
    return items;
  }

  void _showPackageActions(
    BuildContext context,
    Map<String, dynamic> item,
    bool canEdit,
    PackagesProvider provider,
  ) {
    if (!canEdit) {
      return;
    }

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
                _packageCode(item),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 18),
              _ActionTile(
                icon: Icons.edit_outlined,
                iconColor: const Color(0xFFF4A91F),
                title: 'Editar paquete',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/packages/edit', extra: item);
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'Eliminar paquete',
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PackagesProvider>();
    final auth = context.watch<AuthProvider>();
    final canEdit = RoleAccess.canManagePackages(auth.user);

    final items = _filteredItems(provider.items.cast<Map<String, dynamic>>());
    final totalCount = provider.items.length;
    final inTransitCount =
        provider.items.where((item) => !_isDelivered(item['status'])).length;
    final deliveredCount =
        provider.items.where((item) => _isDelivered(item['status'])).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      floatingActionButton: canEdit
          ? FloatingActionButton(
              onPressed: () => context.push('/packages/new'),
              backgroundColor: const Color(0xFFF4A91F),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 30,
                color: Colors.white,
              ),
            )
          : null,
      bottomNavigationBar: const RoleBottomMenu(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFFF3F4F6),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      final u = context.read<AuthProvider>().user;
                      if (u != null) {
                        context.go(RoleAccess.homeFor(u));
                      }
                    },
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Paquetes',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                    ),
                    child: const Icon(
                      Icons.notifications_rounded,
                      size: 21,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _TopStatTab(
                              title: 'Total',
                              value: totalCount,
                              selected: _selectedFilter == 'all',
                              onTap: () {
                                setState(() {
                                  _selectedFilter = 'all';
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _TopStatTab(
                              title: 'In Transit',
                              value: inTransitCount,
                              selected: _selectedFilter == 'in_transit',
                              highlight: true,
                              onTap: () {
                                setState(() {
                                  _selectedFilter = 'in_transit';
                                });
                              },
                            ),
                          ),
                          Expanded(
                            child: _TopStatTab(
                              title: 'Delivered',
                              value: deliveredCount,
                              selected: _selectedFilter == 'delivered',
                              onTap: () {
                                setState(() {
                                  _selectedFilter = 'delivered';
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      setState(() {
                        _selectedFilter = value;
                      });
                    },
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: 'all',
                        child: Text('Todos'),
                      ),
                      PopupMenuItem(
                        value: 'in_transit',
                        child: Text('En tránsito'),
                      ),
                      PopupMenuItem(
                        value: 'delivered',
                        child: Text('Entregados'),
                      ),
                    ],
                    child: Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4A91F),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFF4A91F).withOpacity(0.22),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Filter',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
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
                      : items.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: Text(
                                  'No hay paquetes registrados.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final item = items[index];
                                final delivered = _isDelivered(item['status']);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _PackageCard(
                                    packageCode: _packageCode(item),
                                    statusLabel: _statusLabel(item['status']),
                                    delivered: delivered,
                                    fromText: _fromText(item),
                                    toText: _toText(item),
                                    dateText: _dateText(item, delivered),
                                    onTap: () => _showPackageActions(
                                      context,
                                      item,
                                      canEdit,
                                      provider,
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStatTab extends StatelessWidget {
  final String title;
  final int value;
  final bool selected;
  final bool highlight;
  final VoidCallback onTap;

  const _TopStatTab({
    required this.title,
    required this.value,
    required this.selected,
    required this.onTap,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = selected
        ? (highlight ? const Color(0xFFF4A91F) : const Color(0xFF1F2937))
        : const Color(0xFF4B5563);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF9FAFB) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$title: ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                ),
              ),
              TextSpan(
                text: '$value',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PackageCard extends StatelessWidget {
  final String packageCode;
  final String statusLabel;
  final bool delivered;
  final String fromText;
  final String toText;
  final String dateText;
  final VoidCallback onTap;

  const _PackageCard({
    required this.packageCode,
    required this.statusLabel,
    required this.delivered,
    required this.fromText,
    required this.toText,
    required this.dateText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF334155);
    const textMuted = Color(0xFF64748B);
    const divider = Color(0xFFE5E7EB);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Image.asset(
                  'assets/login/box1.png',
                  width: 46,
                  height: 46,
                  fit: BoxFit.contain,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        packageCode,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: delivered
                              ? const Color(0xFF8CB43F)
                              : const Color(0xFFF4A91F),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                delivered
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF8CB43F),
                        size: 34,
                      )
                    : Image.asset(
                        'assets/login/box1.png',
                        width: 40,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  delivered ? 'Delivered on:' : 'Estimated Delivery:',
                  style: const TextStyle(
                    fontSize: 14,
                    color: textMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    dateText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: divider, height: 1),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 50,
                  child: Text(
                    'From:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    fromText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  width: 50,
                  child: Text(
                    'To:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    toText,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textMuted,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
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
                child: Icon(
                  icon,
                  color: iconColor,
                ),
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
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFF94A3B8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}