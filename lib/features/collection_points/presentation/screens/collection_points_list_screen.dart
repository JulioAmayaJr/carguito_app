import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/collection_points_provider.dart';

class CollectionPointsListScreen extends StatefulWidget {
  const CollectionPointsListScreen({super.key});

  @override
  State<CollectionPointsListScreen> createState() =>
      _CollectionPointsListScreenState();
}

class _CollectionPointsListScreenState
    extends State<CollectionPointsListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CollectionPointsProvider>().fetchAll();
    });
  }

  String _titleText(Map<String, dynamic> item) {
    final candidates = [
      item['name'],
      item['full_name'],
      item['contact_name'],
      item['seller_name'],
      item['description'],
      item['id'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return 'Punto de recolección';
  }

  String _subtitleText(Map<String, dynamic> item) {
    final candidates = [
      item['address'],
      item['pickup_address'],
      item['description'],
      item['reference'],
      item['location'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }

    return 'Sin dirección registrada';
  }

  List<Map<String, dynamic>> _filteredItems(List<dynamic> rawItems) {
    final items = rawItems.cast<Map<String, dynamic>>();

    if (_search.trim().isEmpty) {
      return items;
    }

    final query = _search.trim().toLowerCase();

    return items.where((item) {
      final fields = [
        _titleText(item),
        _subtitleText(item),
      ];

      return fields.any((field) => field.toLowerCase().contains(query));
    }).toList();
  }

  void _showActions(
    BuildContext context,
    Map<String, dynamic> item,
    CollectionPointsProvider provider,
  ) {
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
                _titleText(item),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              _CollectionActionTile(
                icon: Icons.edit_outlined,
                iconColor: const Color(0xFFF4A91F),
                title: 'Editar punto de recolección',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/collection_points/edit', extra: item);
                },
              ),
              const SizedBox(height: 10),
              _CollectionActionTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'Eliminar punto de recolección',
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
    final provider = context.watch<CollectionPointsProvider>();
    final items = _filteredItems(provider.items);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F8),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/collection_points/new'),
        backgroundColor: const Color(0xFFF4C136),
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(
          Icons.add_rounded,
          size: 32,
          color: Colors.white,
        ),
      ),
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
                    padding: const EdgeInsets.fromLTRB(0, 6, 0, 110),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(6, 0, 6, 0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: () => context.pop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                                color: Color(0xFF20242A),
                                size: 28,
                              ),
                            ),
                            const Expanded(
                              child: Text(
                                'Puntos de Recolección',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF20242A),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: _CollectionBannerCard(),
                      ),
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Mis puntos de recolección',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Administra los puntos de recolección registrados',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6F7480),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Container(
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 14,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: TextField(
                            onChanged: (value) {
                              setState(() {
                                _search = value;
                              });
                            },
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: Color(0xFF7A808B),
                                size: 30,
                              ),
                              hintText: 'Buscar envío...',
                              hintStyle: TextStyle(
                                color: Color(0xFF9AA0AA),
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              contentPadding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Mis puntos de recolección',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (items.isEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
                          child: _CreateNewCollectionCard(
                            onTap: () => context.push('/collection_points/new'),
                          ),
                        )
                      else
                        ...items.map(
                          (item) => Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
                            child: _CollectionPointCard(
                              title: _titleText(item),
                              subtitle: _subtitleText(item),
                              onTap: () {
                                _showActions(context, item, provider);
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
      ),
    );
  }
}

class _CollectionBannerCard extends StatelessWidget {
  const _CollectionBannerCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F4),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE9E9ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
        image: const DecorationImage(
          image: AssetImage('assets/collection/collection1.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _CollectionPointCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _CollectionPointCard({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF2B2B2B);
    const textMuted = Color(0xFF4B4F57);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.045),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFF4C136),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.25,
                        fontWeight: FontWeight.w500,
                        color: textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFB8BDC7),
                size: 30,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateNewCollectionCard extends StatelessWidget {
  final VoidCallback onTap;

  const _CreateNewCollectionCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFFFCF4),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFFF4C136),
              width: 1.3,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(27),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFF4C136),
                  size: 34,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Registrar nuevo punto de recolección',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF30343B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Toca aquí para agregar un punto de recolección',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6D727C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CollectionActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;

  const _CollectionActionTile({
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