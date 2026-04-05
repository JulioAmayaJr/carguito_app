import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/bank_accounts_provider.dart';

class BankAccountsListScreen extends StatefulWidget {
  const BankAccountsListScreen({super.key});

  @override
  State<BankAccountsListScreen> createState() => _BankAccountsListScreenState();
}

class _BankAccountsListScreenState extends State<BankAccountsListScreen> {
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BankAccountsProvider>().fetchAll();
    });
  }

  String _bankName(Map<String, dynamic> item) {
    final candidates = [
      item['bank_name'],
      item['name'],
      item['description'],
      item['id'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t;
    }
    return 'Cuenta';
  }

  String _accountNumber(Map<String, dynamic> item) {
    final raw = (item['account_number'] ?? item['number'] ?? item['iban'] ?? '')
        .toString()
        .trim();
    if (raw.length > 4) return '***** ${raw.substring(raw.length - 4)}';
    return raw.isEmpty ? '***** ----' : raw;
  }

  String _holderName(Map<String, dynamic> item) {
    final candidates = [
      item['holder_name'],
      item['owner_name'],
      item['full_name'],
      item['account_holder'],
    ];
    for (final v in candidates) {
      final t = v?.toString().trim();
      if (t != null && t.isNotEmpty) return t.toUpperCase();
    }
    return '';
  }

  String _accountType(Map<String, dynamic> item) {
    final type = (item['account_type'] ?? item['type'] ?? '').toString().trim();
    final currency =
        (item['currency'] ?? item['currency_code'] ?? 'USD').toString().trim();
    if (type.isEmpty) return currency;
    return '$type · $currency';
  }

  String _bankInitial(Map<String, dynamic> item) {
    final name = _bankName(item);
    return name.isNotEmpty ? name[0].toUpperCase() : 'B';
  }

  List<Map<String, dynamic>> _filteredItems(List<dynamic> rawItems) {
    final items = rawItems.cast<Map<String, dynamic>>();
    if (_search.trim().isEmpty) return items;
    final query = _search.trim().toLowerCase();
    return items.where((item) {
      return _bankName(item).toLowerCase().contains(query) ||
          _holderName(item).toLowerCase().contains(query) ||
          _accountNumber(item).toLowerCase().contains(query);
    }).toList();
  }

  void _showActions(
      BuildContext context, Map<String, dynamic> item, BankAccountsProvider provider) {
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
                _bankName(item),
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
                title: 'Editar cuenta bancaria',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  context.push('/bank_accounts/edit', extra: item);
                },
              ),
              const SizedBox(height: 10),
              _ActionTile(
                icon: Icons.delete_outline_rounded,
                iconColor: const Color(0xFFDC2626),
                title: 'Eliminar cuenta bancaria',
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      title: const Text('Confirmar eliminación'),
                      content:
                          const Text('¿Desea eliminar este registro?'),
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
    final provider = context.watch<BankAccountsProvider>();
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
          'Cuentas Bancarias',
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
              onTap: () => context.push('/bank_accounts/new'),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFF4A91F),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/bank_accounts/new'),
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
              : ListView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 110),
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 16),
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
                        image: const DecorationImage(
                          image: AssetImage('assets/bank/bank1.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const Text(
                      'Gestiona tus cuentas bancarias registradas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 14),
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
                        onChanged: (v) => setState(() => _search = v),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search_rounded,
                              color: Color(0xFF9CA3AF), size: 26),
                          hintText: 'Buscar cuenta bancaria...',
                          hintStyle: TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 15,
                              fontWeight: FontWeight.w500),
                          contentPadding: EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (filtered.isEmpty)
                      GestureDetector(
                        onTap: () => context.push('/bank_accounts/new'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBF0),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFF4A91F),
                              style: BorderStyle.solid,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4A91F),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(
                                    Icons.credit_card_rounded,
                                    color: Colors.white,
                                    size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+ Agregar nueva cuenta bancaria',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Toca aquí para agregar una nueva cuenta',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...filtered.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _BankAccountCard(
                              initial: _bankInitial(item),
                              bankName: _bankName(item),
                              accountNumber: _accountNumber(item),
                              holderName: _holderName(item),
                              accountType: _accountType(item),
                              onTap: () =>
                                  _showActions(context, item, provider),
                            ),
                          )),
                    if (filtered.isNotEmpty)
                      const SizedBox(height: 12),
                    if (filtered.isNotEmpty)
                      GestureDetector(
                        onTap: () => context.push('/bank_accounts/new'),
                        child: Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBF0),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: const Color(0xFFF4A91F),
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4A91F),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.credit_card_rounded,
                                    color: Colors.white, size: 26),
                              ),
                              const SizedBox(width: 14),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '+ Agregar nueva cuenta bancaria',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2937),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      'Toca aquí para agregar una nueva cuenta',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF9CA3AF),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }
}

class _BankAccountCard extends StatelessWidget {
  final String initial;
  final String bankName;
  final String accountNumber;
  final String holderName;
  final String accountType;
  final VoidCallback onTap;

  const _BankAccountCard({
    required this.initial,
    required this.bankName,
    required this.accountNumber,
    required this.holderName,
    required this.accountType,
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bankName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          holderName.isEmpty
                              ? accountNumber
                              : '$accountNumber · $holderName',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                 
                ],
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  accountType,
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