import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/recipients_provider.dart';

class RecipientsListScreen extends StatefulWidget {
  const RecipientsListScreen({super.key});

  @override
  State<RecipientsListScreen> createState() => _RecipientsListScreenState();
}

class _RecipientsListScreenState extends State<RecipientsListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipientsProvider>().fetchAll();
    });
  }

  String _fullName(Map<String, dynamic> item) {
    final candidates = [
      item['full_name'],
      item['name'],
      item['first_name'] != null
          ? '${item['first_name']} ${item['last_name'] ?? ''}'.trim()
          : null,
      item['id'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return 'Destinatario';
  }

  String _phone(Map<String, dynamic> item) {
    final candidates = [
      item['phone'],
      item['phone_number'],
      item['mobile'],
      item['contact_phone'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return '';
  }

  String _email(Map<String, dynamic> item) {
    final candidates = [
      item['email'],
      item['email_address'],
      item['contact_email'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return '';
  }

  String _city(Map<String, dynamic> item) {
    final candidates = [
      item['city'],
      item['municipality'],
      item['address_city'],
      item['location'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return '';
  }

  String _address(Map<String, dynamic> item) {
    final candidates = [
      item['address'],
      item['street_address'],
      item['full_address'],
      item['delivery_address'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return '';
  }

  List<Map<String, dynamic>> _filteredItems(List<dynamic> rawItems) {
    final items = rawItems.cast<Map<String, dynamic>>();
    if (_search.trim().isEmpty) return items;
    final query = _search.trim().toLowerCase();
    return items.where((item) {
      return _fullName(item).toLowerCase().contains(query) ||
          _phone(item).toLowerCase().contains(query) ||
          _email(item).toLowerCase().contains(query) ||
          _city(item).toLowerCase().contains(query);
    }).toList();
  }

  void _showActions(BuildContext context, Map<String, dynamic> item,
      RecipientsProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Container(
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).padding.bottom + 12,
          ),
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
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
                _fullName(item),
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
                title: 'Editar destinatario',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/recipients/edit', extra: item);
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'Eliminar destinatario',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
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
    final provider = context.watch<RecipientsProvider>();
    final filtered = _filteredItems(provider.items);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF1F2937), size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Destinatarios',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: GestureDetector(
              onTap: () => context.push('/recipients/new'),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: Color(0xFFF4A91F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/recipients/new'),
        backgroundColor: const Color(0xFFF4A91F),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.error != null && provider.items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      provider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, color: Color(0xFF6B7280)),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
                      child: Container(
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
                          onChanged: (v) => setState(() => _search = v),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            prefixIcon: Icon(Icons.search_rounded,
                                color: Color(0xFF9CA3AF), size: 26),
                            hintText: 'Buscar destinatario...',
                            hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: filtered.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay destinatarios registrados.',
                                style: TextStyle(
                                    fontSize: 15, color: Color(0xFF6B7280)),
                              ),
                            )
                          : ListView.separated(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 4, 14, 110),
                              itemCount: filtered.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return _RecipientCard(
                                  fullName: _fullName(item),
                                  phone: _phone(item),
                                  email: _email(item),
                                  city: _city(item),
                                  address: _address(item),
                                  onTap: () =>
                                      _showActions(context, item, provider),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  final String fullName;
  final String phone;
  final String email;
  final String city;
  final String address;
  final VoidCallback onTap;

  const _RecipientCard({
    required this.fullName,
    required this.phone,
    required this.email,
    required this.city,
    required this.address,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E7EB),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Color(0xFF9CA3AF),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              if (phone.isNotEmpty) ...[
                                const Icon(Icons.phone_rounded,
                                    size: 13, color: Color(0xFF6B7280)),
                                const SizedBox(width: 4),
                                Text(
                                  phone,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                              if (phone.isNotEmpty && email.isNotEmpty)
                                const Text(
                                  ' · ',
                                  style: TextStyle(
                                      color: Color(0xFF9CA3AF), fontSize: 13),
                                ),
                              if (email.isNotEmpty)
                                Expanded(
                                  child: Text(
                                    email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF6B7280),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          if (address.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 13, color: Color(0xFF9CA3AF)),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    address,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF9CA3AF),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (city.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF9FAFB),
                    borderRadius:
                        BorderRadius.vertical(bottom: Radius.circular(18)),
                  ),
                  child: Text(
                    city,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ),
            ],
          ),
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
        child: Padding(
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
              const Icon(Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8)),
            ],
          ),
        ),
      ),
    );
  }
}