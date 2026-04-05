import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carguito_app/core/utils/role_bottom_menu.dart';
import '../providers/payments_provider.dart';

class PaymentsListScreen extends StatefulWidget {
  const PaymentsListScreen({super.key});

  @override
  State<PaymentsListScreen> createState() => _PaymentsListScreenState();
}

class _PaymentsListScreenState extends State<PaymentsListScreen> {
  String _search = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PaymentsProvider>().fetchAll();
    });
  }

  String _paymentCode(Map<String, dynamic> item) {
    final code = item['payment_code']?.toString().trim();
    final name = item['name']?.toString().trim();
    final id = item['id']?.toString().trim();

    if (code != null && code.isNotEmpty) {
      return code;
    }
    if (name != null && name.isNotEmpty) {
      return name;
    }
    if (id != null && id.isNotEmpty) {
      return 'PAY-$id';
    }
    return 'PAY-0000';
  }

  String _clientName(Map<String, dynamic> item) {
    final candidates = [
      item['client_name'],
      item['customer_name'],
      item['seller_name'],
      item['recipient_name'],
      item['full_name'],
      item['name'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return 'Cliente no disponible';
  }

  String _bankName(Map<String, dynamic> item) {
    final candidates = [
      item['bank_name'],
      item['bank'],
      item['account_bank'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return 'No disponible';
  }

  String _amountText(Map<String, dynamic> item) {
    final value = item['amount'] ?? item['total'] ?? item['payment_amount'];

    if (value == null) {
      return '\$0.00';
    }

    if (value is num) {
      return '\$${value.toStringAsFixed(2)}';
    }

    final parsed = double.tryParse(value.toString());
    if (parsed != null) {
      return '\$${parsed.toStringAsFixed(2)}';
    }

    return value.toString();
  }

  String _referenceText(Map<String, dynamic> item) {
    final candidates = [
      item['reference'],
      item['transfer_reference'],
      item['transaction_reference'],
      item['voucher_reference'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return 'Sin referencia';
  }

  String _dateText(Map<String, dynamic> item) {
    final candidates = [
      item['payment_date'],
      item['created_at'],
      item['updated_at'],
      item['date'],
    ];

    for (final value in candidates) {
      final text = value?.toString().trim();
      if (text != null && text.isNotEmpty) {
        return text;
      }
    }
    return 'No disponible';
  }

  String _statusKey(dynamic status) {
    final value = status?.toString().trim().toLowerCase() ?? '';

    if (value.contains('pending') ||
        value.contains('pendiente') ||
        value.contains('por aprobar')) {
      return 'pending';
    }
    if (value.contains('approved') ||
        value.contains('aprobado') ||
        value.contains('accepted') ||
        value.contains('aceptado')) {
      return 'approved';
    }
    if (value.contains('rejected') ||
        value.contains('rechazado') ||
        value.contains('declined') ||
        value.contains('denied')) {
      return 'rejected';
    }

    return 'pending';
  }

  String _statusLabel(dynamic status) {
    switch (_statusKey(status)) {
      case 'approved':
        return 'Aprobado';
      case 'rejected':
        return 'Rechazado';
      default:
        return 'Pendiente';
    }
  }

  List<Map<String, dynamic>> _filteredItems(List<Map<String, dynamic>> items) {
    final filteredByStatus = items.where((item) {
      if (_selectedFilter == 'all') {
        return true;
      }
      return _statusKey(item['status']) == _selectedFilter;
    }).toList();

    if (_search.trim().isEmpty) {
      return filteredByStatus;
    }

    final query = _search.trim().toLowerCase();

    return filteredByStatus.where((item) {
      final haystack = [
        _paymentCode(item),
        _clientName(item),
        _bankName(item),
        _referenceText(item),
        _amountText(item),
        _statusLabel(item['status']),
      ].join(' ').toLowerCase();

      return haystack.contains(query);
    }).toList();
  }

  int _countByStatus(List<Map<String, dynamic>> items, String status) {
    return items.where((item) => _statusKey(item['status']) == status).length;
  }

  void _showVoucher(BuildContext context, Map<String, dynamic> item) {
    final voucher = item['voucher_url']?.toString().trim() ??
        item['receipt_url']?.toString().trim() ??
        item['proof_url']?.toString().trim();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Comprobante ${_paymentCode(item)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                voucher != null && voucher.isNotEmpty
                    ? voucher
                    : 'No hay comprobante disponible para este pago.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF4A91F),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Cerrar',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PaymentsProvider>();
    final rawItems = provider.items.cast<Map<String, dynamic>>();
    final items = _filteredItems(rawItems);
    final pendingCount = _countByStatus(rawItems, 'pending');
    final approvedCount = _countByStatus(rawItems, 'approved');
    final rejectedCount = _countByStatus(rawItems, 'rejected');

    return Scaffold(
      backgroundColor: const Color(0xFFF6F4F7),
      bottomNavigationBar: const RoleBottomMenu(),
      body: SafeArea(
        child: provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.error != null && rawItems.isEmpty
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
                : Column(
                    children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.only(right: 40),
                                      child: Text(
                                        'Pagos',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF20212A),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Center(
                              child: Image.asset(
                                'assets/bank/payment1.png',
                                height: 175,
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) {
                                  return Container(
                                    height: 175,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1EEF3),
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 72,
                                        color: Color(0xFFF4A91F),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Mis pagos',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2C2D35),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Administra transferencias, comprobantes y estados de pago',
                              style: TextStyle(
                                fontSize: 15,
                                height: 1.45,
                                color: Color(0xFF6F717C),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Container(
                              height: 54,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9F7FA),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE2DDE6),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
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
                                    color: Color(0xFF8D8A97),
                                    size: 30,
                                  ),
                                  hintText: 'Buscar pago...',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF8D8A97),
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 15),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: _StatusCard(
                                    title: 'Pendientes',
                                    value: pendingCount,
                                    selected: _selectedFilter == 'pending',
                                    valueColor: const Color(0xFFD17C00),
                                    backgroundColor: const Color(0xFFF7F0E1),
                                    borderColor: const Color(0xFFE8D8B6),
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'pending';
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatusCard(
                                    title: 'Aprobados',
                                    value: approvedCount,
                                    selected: _selectedFilter == 'approved',
                                    valueColor: const Color(0xFF2E5A3D),
                                    backgroundColor: const Color(0xFFF0F5F0),
                                    borderColor: const Color(0xFFD8E5D7),
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'approved';
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _StatusCard(
                                    title: 'Rechazados',
                                    value: rejectedCount,
                                    selected: _selectedFilter == 'rejected',
                                    valueColor: const Color(0xFFD9382D),
                                    backgroundColor: const Color(0xFFF9F1F1),
                                    borderColor: const Color(0xFFEBCFCF),
                                    onTap: () {
                                      setState(() {
                                        _selectedFilter = 'rejected';
                                      });
                                    },
                                  ),
                                ),
                              ],
                            ),
                            if (rawItems.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedFilter = 'all';
                                    });
                                  },
                                  child: const Text(
                                    'Ver todos',
                                    style: TextStyle(
                                      color: Color(0xFF7B7E89),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            if (items.isEmpty)
                              const Padding(
                                padding: EdgeInsets.only(top: 40),
                                child: Center(
                                  child: Text(
                                    'No hay pagos para mostrar.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF6B7280),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...items.map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _PaymentCard(
                                    code: _paymentCode(item),
                                    clientName: _clientName(item),
                                    amount: _amountText(item),
                                    bankName: _bankName(item),
                                    dateText: _dateText(item),
                                    reference: _referenceText(item),
                                    status: _statusLabel(item['status']),
                                    statusKey: _statusKey(item['status']),
                                    onVoucherTap: () => _showVoucher(context, item),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String title;
  final int value;
  final bool selected;
  final Color valueColor;
  final Color backgroundColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _StatusCard({
    required this.title,
    required this.value,
    required this.selected,
    required this.valueColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? valueColor.withOpacity(0.55) : borderColor,
            width: selected ? 1.4 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2D35),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String code;
  final String clientName;
  final String amount;
  final String bankName;
  final String dateText;
  final String reference;
  final String status;
  final String statusKey;
  final VoidCallback onVoucherTap;

  const _PaymentCard({
    required this.code,
    required this.clientName,
    required this.amount,
    required this.bankName,
    required this.dateText,
    required this.reference,
    required this.status,
    required this.statusKey,
    required this.onVoucherTap,
  });

  Color get _chipBackground {
    switch (statusKey) {
      case 'approved':
        return const Color(0xFFDDE8DA);
      case 'rejected':
        return const Color(0xFFF3D9D7);
      default:
        return const Color(0xFFF8E2AC);
    }
  }

  Color get _chipText {
    switch (statusKey) {
      case 'approved':
        return const Color(0xFF32533A);
      case 'rejected':
        return const Color(0xFFB43A31);
      default:
        return const Color(0xFFD18800);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showAmount = amount.trim().isNotEmpty && amount != '\$0.00';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F7FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2DDE6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Transferencia #$code',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2F3038),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _chipBackground,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _chipText,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cliente: $clientName',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5D5F6B),
                height: 1.35,
              ),
            ),
          ),
          if (showAmount) ...[
            const SizedBox(height: 3),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Monto: $amount',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3C3F4A),
                  height: 1.35,
                ),
              ),
            ),
          ],
          const SizedBox(height: 3),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Banco: $bankName',
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF5D5F6B),
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  '$dateText   Referencia: $reference',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF6F717C),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: onVoucherTap,
                child: const Text(
                  'Ver comprobante',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4F5260),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}