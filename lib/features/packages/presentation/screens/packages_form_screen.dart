import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/packages_provider.dart';
import '../../../sellers/presentation/providers/sellers_provider.dart';
import '../../../recipients/presentation/providers/recipients_provider.dart';
import '../../../delivery_points/presentation/providers/delivery_points_provider.dart';

class PackagesFormScreen extends StatefulWidget {
  final Map<String, dynamic>? item;
  const PackagesFormScreen({super.key, this.item});

  @override
  State<PackagesFormScreen> createState() => _PackagesFormScreenState();
}

class _PackagesFormScreenState extends State<PackagesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _packageCodeCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  final _weightKgCtrl = TextEditingController();
  final _declaredValueCtrl = TextEditingController();
  final _shippingFeeCtrl = TextEditingController();

  // Foto del paquete
  File? _photoFile;
  String? _photoBase64;
  final ImagePicker _picker = ImagePicker();

  String? _selectedSellerId;
  String? _selectedRecipientId;
  String? _selectedDeliveryPointId;

  // Info del punto de entrega seleccionado
  Map<String, dynamic>? _selectedDeliveryPoint;
  List<String> _deliveryDays = [];
  DateTime? _estimatedDeliveryDate;
  DateTime? _selectedSpecificDate;

  // Mapa de días en español a números de weekday (DateTime.monday = 1, etc.)
  static const Map<String, int> _dayToWeekday = {
    'Lunes': 1,
    'Martes': 2,
    'Miércoles': 3,
    'Jueves': 4,
    'Viernes': 5,
    'Sábado': 6,
    'Domingo': 7,
  };

  static const Map<int, String> _weekdayToDay = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SellersProvider>().fetchAll();
      context.read<RecipientsProvider>().fetchAll();
      context.read<DeliveryPointsProvider>().fetchAll();
    });

    if (widget.item != null) {
      _packageCodeCtrl.text = widget.item!['package_code']?.toString() ?? '';
      _descriptionCtrl.text = widget.item!['description']?.toString() ?? '';
      _weightKgCtrl.text = widget.item!['weight_kg']?.toString() ?? '';
      _declaredValueCtrl.text =
          widget.item!['product_declared_value']?.toString() ?? '';
      _shippingFeeCtrl.text = widget.item!['shipping_fee']?.toString() ?? '';

      _selectedSellerId = widget.item!['seller_id']?.toString();
      _selectedRecipientId = widget.item!['recipient_id']?.toString();
      _selectedDeliveryPointId = widget.item!['delivery_point_id']?.toString();

      // Si ya tiene foto, guardar la URL
      if (widget.item!['photo_url'] != null) {
        _photoBase64 = widget.item!['photo_url'].toString();
      }
    }
  }

  @override
  void dispose() {
    _packageCodeCtrl.dispose();
    _descriptionCtrl.dispose();
    _weightKgCtrl.dispose();
    _declaredValueCtrl.dispose();
    _shippingFeeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 70,
    );
    if (image != null) {
      final file = File(image.path);
      final bytes = await file.readAsBytes();
      setState(() {
        _photoFile = file;
        _photoBase64 = 'data:image/jpeg;base64,${base64Encode(bytes)}';
      });
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Tomar Foto'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Seleccionar de Galería'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            if (_photoFile != null || _photoBase64 != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Eliminar Foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    _photoFile = null;
                    _photoBase64 = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Calcula la próxima fecha de entrega basado en los días disponibles
  DateTime? _calculateNextDeliveryDate(List<String> days) {
    if (days.isEmpty) return null;

    final now = DateTime.now();
    final validWeekdays = days
        .map((d) => _dayToWeekday[d])
        .where((d) => d != null)
        .cast<int>()
        .toList();

    if (validWeekdays.isEmpty) return null;

    // Buscar el próximo día válido (empezando desde mañana)
    for (int i = 1; i <= 7; i++) {
      final candidate = now.add(Duration(days: i));
      if (validWeekdays.contains(candidate.weekday)) {
        return candidate;
      }
    }
    return null;
  }

  /// Extrae los días de entrega del schedule JSON
  List<String> _extractDeliveryDays(dynamic schedule) {
    if (schedule == null) return [];
    try {
      Map<String, dynamic> scheduleMap;
      if (schedule is String) {
        scheduleMap = jsonDecode(schedule);
      } else {
        scheduleMap = Map<String, dynamic>.from(schedule);
      }
      if (scheduleMap.containsKey('days')) {
        return List<String>.from(scheduleMap['days']);
      }
    } catch (_) {}
    return [];
  }

  /// Verifica si una fecha cae en un día de entrega válido
  bool _isValidDeliveryDate(DateTime date) {
    if (_deliveryDays.isEmpty) return false;
    final validWeekdays = _deliveryDays
        .map((d) => _dayToWeekday[d])
        .where((d) => d != null)
        .cast<int>()
        .toList();
    return validWeekdays.contains(date.weekday);
  }

  void _onDeliveryPointChanged(String? val, List<dynamic> deliveryPoints) {
    setState(() {
      _selectedDeliveryPointId = val;
      _selectedSpecificDate = null;

      if (val != null) {
        _selectedDeliveryPoint =
            deliveryPoints.firstWhere((dp) => dp['id'].toString() == val,
                orElse: () => null);

        if (_selectedDeliveryPoint != null) {
          _deliveryDays =
              _extractDeliveryDays(_selectedDeliveryPoint!['schedule']);
          _estimatedDeliveryDate = _calculateNextDeliveryDate(_deliveryDays);
        }
      } else {
        _selectedDeliveryPoint = null;
        _deliveryDays = [];
        _estimatedDeliveryDate = null;
      }
    });
  }

  Future<void> _pickSpecificDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _estimatedDeliveryDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
      selectableDayPredicate: _isValidDeliveryDate,
      helpText: 'Solo días de entrega disponibles',
    );
    if (picked != null) {
      setState(() {
        _selectedSpecificDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<PackagesProvider>();
    final sellersProv = context.watch<SellersProvider>();
    final recipientsProv = context.watch<RecipientsProvider>();
    final deliveryProv = context.watch<DeliveryPointsProvider>();

    final isEdit = widget.item != null;
    final isLoadingMeta = sellersProv.isLoading ||
        recipientsProv.isLoading ||
        deliveryProv.isLoading;

    // Si estamos en modo edición y los delivery points ya cargaron, inicializar
    if (isEdit &&
        _selectedDeliveryPointId != null &&
        _selectedDeliveryPoint == null &&
        deliveryProv.items.isNotEmpty) {
      final found = deliveryProv.items.firstWhere(
          (dp) => dp['id'].toString() == _selectedDeliveryPointId,
          orElse: () => null);
      if (found != null) {
        _selectedDeliveryPoint = found;
        _deliveryDays = _extractDeliveryDays(found['schedule']);
        _estimatedDeliveryDate = _calculateNextDeliveryDate(_deliveryDays);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Editar Paquete' : 'Nuevo Paquete')),
      body: isLoadingMeta
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Vendedor
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Vendedor (Origen)',
                        border: OutlineInputBorder()),
                    value: sellersProv.items
                            .any((s) => s['id'] == _selectedSellerId)
                        ? _selectedSellerId
                        : null,
                    items: sellersProv.items
                        .map((s) => DropdownMenuItem<String>(
                            value: s['id'].toString(),
                            child: Text(s['business_name'] ??
                                s['contact_name'] ??
                                s['name'] ??
                                'Sin Nombre')))
                        .toList(),
                    validator: (v) => v == null ? 'Requerido' : null,
                    onChanged: (val) =>
                        setState(() => _selectedSellerId = val),
                  ),
                  const SizedBox(height: 10),

                  // Destinatario
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Destinatario (Cliente)',
                        border: OutlineInputBorder()),
                    value: recipientsProv.items
                            .any((r) => r['id'] == _selectedRecipientId)
                        ? _selectedRecipientId
                        : null,
                    items: recipientsProv.items
                        .map((r) => DropdownMenuItem<String>(
                            value: r['id'].toString(),
                            child: Text(r['full_name'] ??
                                r['name'] ??
                                'Sin Nombre')))
                        .toList(),
                    validator: (v) => v == null ? 'Requerido' : null,
                    onChanged: (val) =>
                        setState(() => _selectedRecipientId = val),
                  ),
                  const SizedBox(height: 10),

                  // Punto de Entrega (Destino)
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                        labelText: 'Punto de Entrega (Destino)',
                        border: OutlineInputBorder()),
                    value: deliveryProv.items.any(
                            (dp) => dp['id'].toString() == _selectedDeliveryPointId)
                        ? _selectedDeliveryPointId
                        : null,
                    items: deliveryProv.items
                        .map((dp) => DropdownMenuItem<String>(
                            value: dp['id'].toString(),
                            child: Text(
                                '${dp['name'] ?? ''} - ${dp['department'] ?? ''}, ${dp['city'] ?? ''}')))
                        .toList(),
                    validator: (v) => v == null ? 'Requerido' : null,
                    onChanged: (val) =>
                        _onDeliveryPointChanged(val, deliveryProv.items),
                  ),

                  // Info del destino seleccionado
                  if (_selectedDeliveryPoint != null) ...[
                    const SizedBox(height: 8),
                    Card(
                      color: Colors.blue.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.blue, size: 18),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${_selectedDeliveryPoint!['department'] ?? ''}, ${_selectedDeliveryPoint!['city'] ?? ''}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            if (_selectedDeliveryPoint!['address'] != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                  '📍 ${_selectedDeliveryPoint!['address']}',
                                  style: const TextStyle(fontSize: 13)),
                            ],
                            if (_selectedDeliveryPoint!['arrival_time'] !=
                                null) ...[
                              const SizedBox(height: 4),
                              Text(
                                  '🕐 Llegada: ${_selectedDeliveryPoint!['arrival_time']} — Salida: ${_selectedDeliveryPoint!['departure_time'] ?? 'N/A'}',
                                  style: const TextStyle(fontSize: 13)),
                            ],
                            if (_deliveryDays.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              const Text('Días de entrega:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13)),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 6,
                                children: _deliveryDays
                                    .map((day) => Chip(
                                        label: Text(day,
                                            style:
                                                const TextStyle(fontSize: 12)),
                                        visualDensity: VisualDensity.compact,
                                        backgroundColor:
                                            Colors.blue.shade100))
                                    .toList(),
                              ),
                            ],
                            if (_estimatedDeliveryDate != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.green.shade200),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        color: Colors.green, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Próxima entrega: ${_weekdayToDay[_estimatedDeliveryDate!.weekday]} ${_estimatedDeliveryDate!.day}/${_estimatedDeliveryDate!.month}/${_estimatedDeliveryDate!.year}',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Selector de fecha específica
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: _deliveryDays.isNotEmpty
                          ? () => _pickSpecificDate(context)
                          : null,
                      icon: const Icon(Icons.date_range),
                      label: Text(_selectedSpecificDate != null
                          ? 'Fecha elegida: ${_weekdayToDay[_selectedSpecificDate!.weekday]} ${_selectedSpecificDate!.day}/${_selectedSpecificDate!.month}/${_selectedSpecificDate!.year}'
                          : 'Elegir fecha específica (opcional)'),
                    ),
                    if (_selectedSpecificDate != null)
                      TextButton(
                        onPressed: () =>
                            setState(() => _selectedSpecificDate = null),
                        child: const Text('Usar próxima fecha automática',
                            style: TextStyle(fontSize: 12)),
                      ),
                  ],
                  const SizedBox(height: 10),

                  // Número de Paquete
                  TextFormField(
                      controller: _packageCodeCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Número de Paquete / Tracking',
                          hintText: 'Ej: PKG-001, TRACK-123',
                          prefixIcon: Icon(Icons.qr_code),
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 10),

                  // Descripción
                  TextFormField(
                      controller: _descriptionCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Descripción del paquete',
                          border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 10),

                  // Peso
                  TextFormField(
                      controller: _weightKgCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Peso (Kg)',
                          border: OutlineInputBorder()),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 10),

                  // Valor declarado
                  TextFormField(
                      controller: _declaredValueCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Valor Declarado del Producto (\$)',
                          border: OutlineInputBorder()),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 10),

                  // Tarifa
                  TextFormField(
                      controller: _shippingFeeCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Tarifa de Envío (\$)',
                          border: OutlineInputBorder()),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null),
                  const SizedBox(height: 16),

                  // Foto del paquete
                  const Text('Foto del Paquete',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _showPhotoOptions,
                    child: Container(
                      height: 180,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: _photoFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(_photoFile!,
                                  fit: BoxFit.cover,
                                  width: double.infinity))
                          : (_photoBase64 != null &&
                                  _photoBase64!.startsWith('data:'))
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.memory(
                                      base64Decode(
                                          _photoBase64!.split(',').last),
                                      fit: BoxFit.cover,
                                      width: double.infinity))
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.camera_alt,
                                        size: 48,
                                        color: Colors.grey.shade400),
                                    const SizedBox(height: 8),
                                    Text('Tomar foto o seleccionar',
                                        style: TextStyle(
                                            color: Colors.grey.shade500)),
                                  ],
                                ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón Guardar
                  ElevatedButton(
                    onPressed: prov.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              final deliveryDate = _selectedSpecificDate ??
                                  _estimatedDeliveryDate;

                              final req = {
                                'package_code': _packageCodeCtrl.text,
                                'seller_id': _selectedSellerId,
                                'recipient_id': _selectedRecipientId,
                                'delivery_point_id': _selectedDeliveryPointId,
                                'description': _descriptionCtrl.text,
                                'weight_kg':
                                    double.tryParse(_weightKgCtrl.text),
                                'product_declared_value':
                                    double.tryParse(_declaredValueCtrl.text) ??
                                        0,
                                'shipping_fee':
                                    double.tryParse(_shippingFeeCtrl.text) ?? 0,
                                if (deliveryDate != null)
                                  'estimated_delivery_at':
                                      deliveryDate.toIso8601String(),
                                if (_photoBase64 != null)
                                  'photo_url': _photoBase64,
                              };
                              if (!isEdit) {
                                final res = await prov.create(req);
                                if (res && context.mounted) {
                                  context.pop();
                                }
                                if (!res && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(prov.error ?? 'Error')));
                                }
                              } else {
                                final res =
                                    await prov.update(widget.item!['id'], req);
                                if (res && context.mounted) {
                                  context.pop();
                                }
                                if (!res && context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text(prov.error ?? 'Error')));
                                }
                              }
                            }
                          },
                    child: prov.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Guardar Paquete'),
                  )
                ],
              ),
            ),
    );
  }
}
